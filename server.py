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

#post za novo mjerenje
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
    current_type = get_current_type()
    print("Slika spremljena!")
    try:
        conn = sqlite3.connect("measurements.db")
        cursor = conn.cursor()
        cursor.execute("INSERT INTO measurements (reading, image_path, type) VALUES (?, ?, ?)", (12, f"pictures/{filename}", current_type))
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
            cursor.execute("SELECT id, reading, datetime, image_path, type FROM measurements")
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


if __name__ == '__main__':
    app.run(host='0.0.0.0', port=5000)