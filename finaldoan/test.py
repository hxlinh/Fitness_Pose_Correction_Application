from flask import Flask, Response
import cv2

# Tạo đối tượng Flask
app = Flask(__name__)


# Hàm để phát video qua HTTP
def generate():
    cap = cv2.VideoCapture('http://192.168.100.107:5000/video_feed')
    while True:
        # Đọc một frame từ webcam
        ret, frame = cap.read()
        if not ret:
            break
        else:
            # Chuyển đổi hình ảnh thành định dạng JPEG
            ret, jpeg = cv2.imencode('.jpg', frame)

            # Trả về ảnh JPEG dưới dạng byte stream
            frame = jpeg.tobytes()

            # Gửi các dữ liệu ảnh dưới định dạng multipart
            yield (b'--frame\r\n'
                b'Content-Type: image/jpeg\r\n\r\n' + frame + b'\r\n')

# Tạo route cho stream video
@app.route('/video')
def video():
    return Response(generate(),
                    mimetype='multipart/x-mixed-replace; boundary=frame')

# Chạy ứng dụng Flask
if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=8000)