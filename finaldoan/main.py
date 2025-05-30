import cv2
import mediapipe as mp
import numpy as np
import tensorflow as tf
from flask import Flask, Response
import firebase_admin
from firebase_admin import credentials, db
from plank_detect import PlankDetector
from squat_rep import SquatDetector
from pushup_rep import PushupDetector

# Khởi tạo Flask app
app = Flask(__name__)

# Khởi tạo Firebase Admin SDK
cred = credentials.Certificate("/Users/nguyen/Downloads/codetestdoan/flutterproject-9fa77-firebase-adminsdk-u49fy-9200db7819.json")
firebase_admin.initialize_app(cred, {
    'databaseURL': 'https://flutterproject-9fa77-default-rtdb.asia-southeast1.firebasedatabase.app/'
})

# Các instance của detector
detectors = {
    'Push Up': PushupDetector(),
    'Squat': SquatDetector(),
    'Plank': PlankDetector()
}

# Hàm để lấy loại bài tập hiện tại từ Firebase
def get_current_exercise():
    ref = db.reference('current_exercise')
    return ref.get()

def generate_frames():
    cap = cv2.VideoCapture(0)
    current_exercise = get_current_exercise()
    if current_exercise in detectors:
        detector = detectors[current_exercise]
    while True:
        success, frame = cap.read()
        if not success:
            break
        else:
            # Lấy loại bài tập hiện tại
                # Thực hiện phát hiện động tác
            frame = detector.process_frame(frame)
            
            # Encode frame to JPEG
            ret, buffer = cv2.imencode('.jpg', frame)
            frame = buffer.tobytes()
            
            yield (b'--frame\r\n'
                   b'Content-Type: image/jpeg\r\n\r\n' + frame + b'\r\n')

@app.route('/video_feed')
def video_feed():
    return Response(generate_frames(), mimetype='multipart/x-mixed-replace; boundary=frame')

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8000)
