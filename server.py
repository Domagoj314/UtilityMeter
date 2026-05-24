from flask import Flask, request
import numpy as np
import cv2

app = Flask(__name__)

@app.route('/ocr', methods=['POST'])
def ocr():
    jpg = request.data
    arr = np.frombuffer(jpg, dtype=np.uint8)
    img = cv2.imdecode(arr, cv2.IMREAD_COLOR)
    img = cv2.rotate(img, cv2.ROTATE_180)
    img = cv2.flip(img, 1)
    cv2.imwrite("picture.png", img)
    print("Picture saved!")
    return "OK", 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)