from flask import Flask, request, jsonify, Response
import threading
import cv2
import time

app = Flask(__name__)

CAM_CONFIGS = {
    'cam1': 'rtsp://admin:admin1234!@218.149.187.159:40551/unicast/c1/s0/live',
    'cam2': 'rtsp://admin:admin1234!@218.149.187.159:40551/unicast/c2/s0/live',
}

active_threads = {}

def detect_motion(cam_id, url):
    print(f'🎥 [{cam_id}] 모션 감지 시작: {url}')
    cap = cv2.VideoCapture(url)
    time.sleep(1)

    if not cap.isOpened():
        print(f'❌ [{cam_id}] RTSP 열기 실패')
        return

    ret, prev = cap.read()
    while ret:
        ret, frame = cap.read()
        if not ret:
            break

        diff = cv2.absdiff(prev, frame)
        gray = cv2.cvtColor(diff, cv2.COLOR_BGR2GRAY)
        blur = cv2.GaussianBlur(gray, (5,5), 0)
        _, thresh = cv2.threshold(blur, 25, 255, cv2.THRESH_BINARY)

        contours, _ = cv2.findContours(thresh, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)
        for c in contours:
            if cv2.contourArea(c) > 1500: # 민감도 값이 클수록 큰 움직임만 감지
                
                break

        prev = frame

    cap.release()
    print(f'🛑 [{cam_id}] 모션 감지 종료')

def generate_motion_stream(cam_id):
    rtsp_url = CAM_CONFIGS.get(cam_id)
    if not rtsp_url:
        return

    cap = cv2.VideoCapture(rtsp_url)
    time.sleep(1)

    if not cap.isOpened():
        print(f'❌ [{cam_id}] RTSP 열기 실패')
        return

    ret, prev = cap.read()
    while ret:
        ret, frame = cap.read()
        if not ret or frame is None:
            break

        # 🎯 움직임 감지
        diff = cv2.absdiff(prev, frame)
        gray = cv2.cvtColor(diff, cv2.COLOR_BGR2GRAY)
        blur = cv2.GaussianBlur(gray, (5, 5), 0)
        _, thresh = cv2.threshold(blur, 25, 255, cv2.THRESH_BINARY)
        contours, _ = cv2.findContours(thresh, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

        padding = 10
        for c in contours:
            if cv2.contourArea(c) > 500:
                x, y, w, h = cv2.boundingRect(c)
                cv2.rectangle(
                    frame,
                    (max(x - padding, 0), max(y - padding, 0)),
                    (x + w + padding, y + h + padding),
                    (0, 255, 0),
                    2
                )

        prev = frame

        # ✅ 프레임을 흑백으로 변환하고 다시 BGR로 되돌림
        gray_frame = cv2.cvtColor(frame, cv2.COLOR_BGR2GRAY)
        frame = cv2.cvtColor(gray_frame, cv2.COLOR_GRAY2BGR)

        _, buffer = cv2.imencode('.jpg', frame)
        jpg_bytes = buffer.tobytes()

        yield (
            b'--frame\r\n'
            b'Content-Type: image/jpeg\r\n\r\n' + jpg_bytes + b'\r\n'
        )

    cap.release()


@app.route('/preview/<cam_id>')
@app.route('/preview/<cam_id>')
def preview_capture(cam_id):
    rtsp_url = CAM_CONFIGS.get(cam_id)
    if not rtsp_url:
        return 'Invalid cam ID', 400

    cap = cv2.VideoCapture(rtsp_url)
    time.sleep(1)

    if not cap.isOpened():
        return '❌ RTSP 열기 실패', 500

    ret1, frame1 = cap.read()
    ret2, frame2 = cap.read()
    cap.release()

    if not ret1 or frame1 is None or frame2 is None:
        return '❌ 프레임 읽기 실패', 500

    # 🎯 움직임 감지
    diff = cv2.absdiff(frame1, frame2)
    gray = cv2.cvtColor(diff, cv2.COLOR_BGR2GRAY)
    blur = cv2.GaussianBlur(gray, (5, 5), 0)
    _, thresh = cv2.threshold(blur, 25, 255, cv2.THRESH_BINARY)
    contours, _ = cv2.findContours(thresh, cv2.RETR_EXTERNAL, cv2.CHAIN_APPROX_SIMPLE)

    # ✅ 전체 프레임을 흑백으로 변환 (3채널 유지)
    gray_frame = cv2.cvtColor(frame1, cv2.COLOR_BGR2GRAY)
    output = cv2.cvtColor(gray_frame, cv2.COLOR_GRAY2BGR)

    # ✅ 초록색 감지 박스는 흑백 프레임 위에 그림
    padding = 10
    for c in contours:
        if cv2.contourArea(c) > 500:
            x, y, w, h = cv2.boundingRect(c)
            cv2.rectangle(
                output,
                (max(x - padding, 0), max(y - padding, 0)),
                (x + w + padding, y + h + padding),
                (0, 255, 0),  # 초록색
                2
            )

    # ✅ 인코딩 후 전송
    _, buffer = cv2.imencode('.jpg', output)
    return Response(buffer.tobytes(), mimetype='image/jpeg')



@app.route('/start', methods=['POST'])
def start_motion():
    data = request.get_json()
    cam_id = data.get('cam_id')
    url = data.get('url')

    if not cam_id or not url:
        return jsonify({'error': 'cam_id 또는 url 누락'}), 400

    if cam_id in active_threads:
        return jsonify({'message': f'{cam_id} 이미 실행 중'}), 200

    thread = threading.Thread(target=detect_motion, args=(cam_id, url), daemon=True)
    thread.start()
    active_threads[cam_id] = thread

    return jsonify({'message': f'{cam_id} 모션 감지 시작됨'}), 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5001)
