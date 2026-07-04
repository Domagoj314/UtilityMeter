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
import os
import re


tess.pytesseract.tesseract_cmd = PATH_TO_TESSERACT_EXECUTABLE

app = Flask(__name__)

CORS(app)

def get_current_type():
    if os.path.exists("current_type.txt"):
        with open("current_type.txt", "r") as f:
            return f.read().strip()
    else:
        return "struja"

def save_current_type(current_type):
    with open("current_type.txt", "w") as f:
        f.write(current_type)


current_type = get_current_type()


def get_current_interval():
    if os.path.exists("current_interval.txt"):
        with open("current_interval.txt", "r") as f:
            return f.read().strip()
    else:
        return "30"

def save_current_interval(current_interval):
    with open("current_interval.txt", "w") as f:
        f.write(current_interval)

current_interval = get_current_interval()


#post za novo mjerenje
@app.route('/ocr', methods=['POST'])
def ocr():
    api_key = request.headers.get('X-API-Key')
    if api_key != apikey:
        return "Unauthorized", 401
    jpg = request.data
    arr = np.frombuffer(jpg, dtype=np.uint8)
    img = cv2.imdecode(arr, cv2.IMREAD_COLOR)

    img = cv2.rotate(img, cv2.ROTATE_180)
    img = cv2.flip(img, 1)

    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    inverted = cv2.bitwise_not(gray)
    _, thresh = cv2.threshold(inverted, 127, 255, cv2.THRESH_BINARY)


    text = tess.image_to_string(thresh, config='--psm 6 --oem 3 -c tessedit_char_whitelist=0123456789.')
    text = text.strip()

    numbers = re.findall(r'\d+\.?\d*', text)
    print(f"OCR: {text}")
    reading = float(numbers[0]) if numbers else 0.0


    filename = datetime.now().strftime("%Y%m%d_%H%M%S") + ".png"
    cv2.imwrite(f"pictures/{filename}", thresh)
    current_type = get_current_type()
    print("Slika spremljena!")
    try:
        conn = sqlite3.connect("measurements.db")
        cursor = conn.cursor()
        cursor.execute("INSERT INTO measurements (reading, image_path, type) VALUES (?, ?, ?)", (reading, f"pictures/{filename}", current_type))
        conn.commit()
    except sqlite3.Error as e:
        print(f"An error occurred while adding data to the table: {e}")
        return "Database error", 500
    return "ok", 200


#get za sva mjerenja
@app.route('/measurements', methods=['GET'])
def get_measurements():
    api_key = request.headers.get('X-API-Key')
    if api_key != apikey:
        return "Unauthorized", 401
    try:
        conn = sqlite3.connect("measurements.db")
        cursor = conn.cursor()
        requested_type = request.args.get('type')
        if requested_type:
            cursor.execute("SELECT id, reading, datetime, image_path, type FROM measurements WHERE type = ? ORDER BY datetime DESC", (requested_type,))
        else:
            cursor.execute("SELECT id, reading, datetime, image_path, type FROM measurements ORDER BY datetime DESC")
        rows = cursor.fetchall()
        measurements = []
        for row in rows:
            measurements.append({
                "id": row[0],
                "reading": row[1],
                "datetime": row[2],
                "image_path": row[3],
                "type": row[4]
            })
        return jsonify(measurements), 200
    except sqlite3.Error as e:
        print(f"An error occurred while fetching data from the table: {e}")
        return "Database error", 500




#post za postavljanje tipa mjerenja
@app.route('/set-type', methods=['POST'])
def set_type():
    api_key = request.headers.get('X-API-Key')
    if api_key != apikey:
        return "Unauthorized", 401

    data = request.get_json()
    if 'type' not in data:
        return "Bad Request: 'type' field is required", 400
    current_type = data['type']
    save_current_type(current_type)
    return "Type set successfully", 200

#get za dohvat trenutnog tipa mjerenja
@app.route('/get-type', methods=['GET'])
def get_type():
    api_key = request.headers.get('X-API-Key')
    if api_key != apikey:
        return "Unauthorized", 401
    current_type = get_current_type()
    return jsonify({"type": current_type}), 200



#get za dohvat trenutnog intervala mjerenja
@app.route('/get-interval', methods=['GET'])
def get_interval():
    api_key = request.headers.get('X-API-Key')
    if api_key != apikey:
        return "Unauthorized", 401
    current_interval = get_current_interval()
    return jsonify({"interval": int(current_interval)}), 200


#post za postavljanje intervala mjerenja
@app.route('/set-interval', methods=['POST'])
def set_interval():
    api_key = request.headers.get('X-API-Key')
    if api_key != apikey:
        return "Unauthorized", 401

    data = request.get_json()
    if 'interval' not in data:
        return "Bad Request: 'interval' field is required", 400
    current_interval = str(data['interval'])
    save_current_interval(current_interval)
    return "Interval set successfully", 200


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)