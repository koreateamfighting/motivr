from flask import Flask, Response,jsonify  
from flask_cors import CORS

import cv2
import threading
import time
import re

app = Flask(__name__)
CORS(app, supports_credentials=True, origins="*")
gray_frame_cache = {}   # 흑백 처리된 프레임
color_frame_cache = {}  # 컬러 원본 프레임
motion_label_cache = {}
cache_lock = threading.Lock()

# 카메라 URL 생성 함수
def generate_camera_config(cam_id):
    match = re.match(r'^cam(\d+)$', cam_id.lower())
    if not match:
        return None
    cam_number = int(match.group(1))
    rtsp_base = 'rtsp://admin:admin1234!@218.149.187.159:40551/unicast/'
    return f'{rtsp_base}c{cam_number}/s0/live'

# 카메라별 백그라운드 프레임 수집 쓰레드 시작
def start_cam_thread(cam_id):
    def capture():
        rtsp_url = generate_camera_config(cam_id)
        if not rtsp_url:
            return

        cap = cv2.VideoCapture(rtsp_url)
        if not cap.isOpened():
            print(f"\u274c [{cam_id}] RTSP 연결 실패")
            return

        ret, prev = cap.read()
        if not ret or prev is None:
            cap.release()
            return

        while True:
            ret, frame = cap.read()
            if not ret or frame is None:
                break

            # 모션 감지 및 박스 그리기
            diff = cv2.absdiff(prev, frame)
            gray = cv2.cvtColor(diff, cv2.COLOR_BGR2GRAY)
            blur = cv2.GaussianBlur(gray, (5, 5), 0)
            _, thresh = cv2.threshold(blur, 25, 255, cv2.THRESH_BINARY)
            contours, _ = cv2.findContours(thresh, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
            motion_labels = {}
            for i, c in enumerate(contours):
                if cv2.contourArea(c) > 500:
                    x, y, w, h = cv2.boundingRect(c)
                    label = f"Line_{i+1}"
                    motion_labels[label] = True
                    cv2.rectangle(frame, (x, y), (x + w, y + h), (0, 255, 0), 2)
                    cv2.putText(frame, label, (x, y - 10),
                                cv2.FONT_HERSHEY_SIMPLEX, 0.6, (0, 255, 0), 2)

            prev = frame

            # 흑백 처리 후 BGR 복구
            gray_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
            gray_frame = cv2.cvtColor(gray_frame, cv2.COLOR_GRAY2BGR)

            # 프레임 저장
            with cache_lock:
                gray_frame_cache[cam_id] = gray_frame
                color_frame_cache[cam_id] = frame.copy()
                motion_label_cache[cam_id] = motion_labels 
                #motion_label_cache[cam_id] = {"Line_1": True}
            time.sleep(0.05)  # 약 20fps

        cap.release()
        print(f"\ud83d\udea9 [{cam_id}] 종료됨")

    thread = threading.Thread(target=capture, daemon=True)
    thread.start()


# 기존 흑백 스트리밍 (모션 + 회색 처리)
@app.route('/stream/<cam_id>')
def stream(cam_id):
    if cam_id not in gray_frame_cache:
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

# 추가된 컬러 스트리밍
# 단순 컬러 MJPEG 스트리밍 (OpenCV 전처리 없음)
@app.route('/stream_color/<cam_id>')
def stream_color(cam_id):
    rtsp_url = generate_camera_config(cam_id)
    if not rtsp_url:
        return Response("Invalid cam_id", status=400)

    def generate():
        cap = cv2.VideoCapture(rtsp_url)
        if not cap.isOpened():
            print(f"❌ [stream_color] RTSP 연결 실패: {cam_id}")
            return

        while True:
            ret, frame = cap.read()
            if not ret or frame is None:
                break

            _, buffer = cv2.imencode('.jpg', frame)
            yield (
                b'--frame\r\n'
                b'Content-Type: image/jpeg\r\n\r\n' + buffer.tobytes() + b'\r\n'
            )
            time.sleep(0.05)  # 약 20fps

        cap.release()
        print(f"📴 [stream_color] 종료됨: {cam_id}")

    return Response(generate(), mimetype='multipart/x-mixed-replace; boundary=frame')

@app.route('/motion_status/<cam_id>')
def get_motion_status(cam_id):
    with cache_lock:
        labels = motion_label_cache.get(cam_id, {})
    return jsonify({
        "cam": cam_id,
        "lines": labels
    })
