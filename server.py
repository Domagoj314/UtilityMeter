from flask import Flask, request
import numpy as np
import cv2
import pytesseract as tess
from PIL import Image
from secrets import PATH_TO_TESSERACT_EXECUTABLE
from secrets import apikey

tess.pytesseract.tesseract_cmd = PATH_TO_TESSERACT_EXECUTABLE

app = Flask(__name__)

@app.route('/ocr', methods=['POST'])
def ocr():
    api_key = request.headers.get('X-API-Key')
    if api_key != apikey:
        return "Unauthorized", 401
    jpg = request.data
    arr = np.frombuffer(jpg, dtype=np.uint8)
    img = cv2.imdecode(arr, cv2.IMREAD_COLOR)
    cv2.imwrite("picture.png", img)
    print("Slika spremljena!")
    return "ok", 200


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)