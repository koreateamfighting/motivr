from flask import Flask, Response, jsonify
from flask_cors import CORS
import cv2
import threading
import time
import re
import pyodbc
from datetime import datetime

app = Flask(__name__)
CORS(app, supports_credentials=True, origins="*")

gray_frame_cache = {}
color_frame_cache = {}
motion_label_cache = {}
streaming_threads = {}
cache_lock = threading.Lock()

def generate_camera_config(cam_id):
    match = re.match(r'^cam(\d+)$', cam_id.lower())
    if not match:
        return None
    cam_number = int(match.group(1))
    return f'rtsp://admin:admin1234!@218.149.187.159:40551/unicast/c{cam_number}/s0/live'

def start_cam_thread(cam_id):
    if cam_id in streaming_threads:
        return

    def capture():
        rtsp_url = generate_camera_config(cam_id)
        if not rtsp_url:
            return

        cap = cv2.VideoCapture(rtsp_url)
        if not cap.isOpened():
            print(f"❌ [{cam_id}] RTSP 연결 실패")
            return

        # ✅ 그림자 제거에 강한 배경모델
        fgbg = cv2.createBackgroundSubtractorMOG2(history=500, varThreshold=50, detectShadows=True)

        while True:
            ret, frame = cap.read()
            if not ret or frame is None:
                break

            frame_with_box = frame.copy()

            # ✅ 배경 제거 및 그림자 필터링
            fgmask = fgbg.apply(frame)
            _, thresh = cv2.threshold(fgmask, 220, 255, cv2.THRESH_BINARY)

            contours, _ = cv2.findContours(thresh, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

            motion_labels = {}
            for i, c in enumerate(contours):
                area = cv2.contourArea(c)
                if area > 100000:  # ✅  설정한 감도 유지
                    x, y, w, h = cv2.boundingRect(c)
                    aspect_ratio = w / h if h != 0 else 0
                    if 0.3 < aspect_ratio < 3.0:  # ✅ 줄같은 얇은 건 무시
                        label = f"Line_{i+1}"
                        motion_labels[label] = True

                        if area >= 200000:
                            level = "red"
                            color = (0, 0, 255)  # 빨간색
                        else:
                            level = "green"
                            color = (0, 255, 0)  # 초록색
                        motion_labels[label] = level
                        cv2.rectangle(frame_with_box, (x, y), (x + w, y + h), color, 2)
                        cv2.putText(frame_with_box, label, (x, y - 10), cv2.FONT_HERSHEY_SIMPLEX, 0.6, color, 2)
                        insert_alarmhistory(cam_id, area)

            # ✅ 사각형은컬러 유지, 배경은 흑백 처리
            gray_img = cv2.cvtColor(frame_with_box, cv2.COLOR_BGR2GRAY)
            gray_3ch = cv2.cvtColor(gray_img, cv2.COLOR_GRAY2BGR)
                        
            mask_green = cv2.inRange(frame_with_box, (0, 250, 0), (0, 255, 0))
            mask_red = cv2.inRange(frame_with_box, (0, 0, 250), (0, 0, 255))
            color_mask = cv2.bitwise_or(mask_green, mask_red)

            color_part = cv2.bitwise_and(frame_with_box, frame_with_box, mask=color_mask)
            gray_part = cv2.bitwise_and(gray_3ch, gray_3ch, mask=cv2.bitwise_not(color_mask))
            combined = cv2.add(color_part, gray_part)

            with cache_lock:
                gray_frame_cache[cam_id] = combined
                color_frame_cache[cam_id] = frame_with_box
                motion_label_cache[cam_id] = motion_labels

            time.sleep(0.05)

        cap.release()
        print(f"📴 [{cam_id}] 종료됨")

    thread = threading.Thread(target=capture, daemon=True)
    streaming_threads[cam_id] = thread
    thread.start()

def insert_alarmhistory(cam_id, area):
    if area < 60000:
        return  # 감지 민감도 이하일 경우 무시

    event = '경고' if area >= 200000 else '주의'
    log = f'{cam_id} # {event}'
    timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S')

    try:
        conn = pyodbc.connect(
           'DRIVER={ODBC Driver 17 for SQL Server};'
            'SERVER=175.45.193.227,1433;'
            'DATABASE=master;'
            'UID=myuser;'
            'PWD=mot!vr2025'
            )
        cursor = conn.cursor()
        cursor.execute("""
            INSERT INTO AlarmHistory (DeviceID, Timestamp, Event, Log, Location, Latitude, Longitude, Type)
            VALUES (?, ?, ?, ?, NULL, NULL, NULL, 'cctv')
        """, (cam_id, timestamp, event, log))
        conn.commit()
        cursor.close()
        conn.close()
        print(f"✅ {cam_id} 알람 저장됨: {event}")
    except Exception as e:
        print(f"❌ DB 저장 오류: {e}")

@app.route('/stream/<cam_id>')
def stream(cam_id):
    if cam_id not in streaming_threads:
        start_cam_thread(cam_id)

    def generate():
        while True:
            with cache_lock:
                frame = gray_frame_cache.get(cam_id)
            if frame is not None:
                _, buffer = cv2.imencode('.jpg', frame)
                yield (
                    b'--frame\r\n'
                    b'Content-Type: image/jpeg\r\n\r\n' + buffer.tobytes() + b'\r\n'
                )
            time.sleep(0.05)
    return Response(generate(), mimetype='multipart/x-mixed-replace; boundary=frame')

@app.route('/stream_color/<cam_id>')
def stream_color(cam_id):
    if cam_id not in streaming_threads:
        start_cam_thread(cam_id)

    def generate():
        retry_count = 0
        while True:
            with cache_lock:
                frame = color_frame_cache.get(cam_id)
            if frame is not None:
                _, buffer = cv2.imencode('.jpg', frame)
                yield (
                    b'--frame\r\n'
                    b'Content-Type: image/jpeg\r\n\r\n' + buffer.tobytes() + b'\r\n'
                )
                retry_count = 0
            else:
                retry_count += 1
                if retry_count > 100:
                    break
            time.sleep(0.05)
    return Response(generate(), mimetype='multipart/x-mixed-replace; boundary=frame')

@app.route('/motion_status/<cam_id>')
def get_motion_status(cam_id):
    with cache_lock:
        labels = motion_label_cache.get(cam_id, {})
    return jsonify({
        "cam": cam_id,
        "lines": labels
    })


# if __name__ == '__main__':
#     app.run(host='0.0.0.0', port=5001)

def start_all_cameras():
    for cam_id in ['cam1', 'cam2']:
        start_cam_thread(cam_id)
