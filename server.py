from flask import Flask, request
import numpy as np
import cv2
import pytesseract as tess
from PIL import Image
from secrets import PATH_TO_TESSERACT_EXECUTABLE

tess.pytesseract.tesseract_cmd = PATH_TO_TESSERACT_EXECUTABLE

app = Flask(__name__)

@app.route('/ocr', methods=['POST'])
def ocr():
    jpg = request.data
    arr = np.frombuffer(jpg, dtype=np.uint8)
    img = cv2.imdecode(arr, cv2.IMREAD_COLOR)
    
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    inverted = cv2.bitwise_not(gray)
    inverted = cv2.resize(inverted, (0,0), fx=2, fy=2, interpolation=cv2.INTER_CUBIC)
    _, inverted = cv2.threshold(inverted, 127, 255, cv2.THRESH_BINARY)
    cv2.imwrite("picture.png", inverted)


    text = tess.image_to_string(inverted, config='--psm 6 --oem 3 -c tessedit_char_whitelist=0123456789.')
    print(text)
    return text, 200


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)