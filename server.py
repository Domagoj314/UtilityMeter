from flask import Flask, request
import numpy as np
import cv2
import pytesseract as tess
from PIL import Image
from secrets import PATH_TO_TESSERACT_EXECUTABLE
from secrets import apikey
import sqlite3
from datetime import datetime
from flask import jsonify
from flask_cors import CORS



tess.pytesseract.tesseract_cmd = PATH_TO_TESSERACT_EXECUTABLE

app = Flask(__name__)

CORS(app)

@app.route('/ocr', methods=['POST'])
def ocr():
    api_key = request.headers.get('X-API-Key')
    if api_key != apikey:
        return "Unauthorized", 401
    jpg = request.data
    arr = np.frombuffer(jpg, dtype=np.uint8)
    img = cv2.imdecode(arr, cv2.IMREAD_COLOR)
    filename = datetime.now().strftime("%Y%m%d_%H%M%S") + ".png"
    cv2.imwrite(f"pictures/{filename}", img)
    print("Slika spremljena!")
    try:
        conn = sqlite3.connect("measurements.db")
        cursor = conn.cursor()
        cursor.execute("INSERT INTO measurements (reading, image_path) VALUES (?, ?)", (34, f"pictures/{filename}"))
        conn.commit()
    except sqlite3.Error as e:
        print(f"An error occurred while adding data to the table: {e}")
        return "Database error", 500
    return "ok", 200

@app.route('/measurements', methods=['GET'])
def get_measurements():
    api_key = request.headers.get('X-API-Key')
    if api_key != apikey:
        return "Unauthorized", 401
    try:
        conn = sqlite3.connect("measurements.db")
        cursor = conn.cursor()
        cursor.execute("SELECT id, reading, datetime, image_path FROM measurements")
        rows = cursor.fetchall()
        measurements = []
        for row in rows:
            measurements.append({
                "id": row[0],
                "reading": row[1],
                "datetime": row[2],
                "image_path": row[3]
            })
        return jsonify(measurements), 200
    except sqlite3.Error as e:
        print(f"An error occurred while fetching data from the table: {e}")
        return "Database error", 500


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)