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
    cv2.imwrite("picture.png", img)
    print("Picture saved!")
    image = Image.open("picture.png")
    text = tess.image_to_string(image)
    print(text)
    return text, 200


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)