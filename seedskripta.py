# skripta_plin.py
import sqlite3
from datetime import datetime, timedelta
import random

conn = sqlite3.connect("measurements.db")
cursor = conn.cursor()

base = 244.0
for i in range(7):
    date = datetime.now() - timedelta(days=6-i)
    base += random.uniform(0.3, 1.5)
    cursor.execute(
        "INSERT INTO measurements (reading, image_path, type, datetime) VALUES (?, ?, ?, ?)",
        (round(base, 2), f"pictures/test_{i}.png", "plin", date.strftime("%Y-%m-%d %H:%M:%S"))
    )

conn.commit()
conn.close()
print("Plin podaci ubačeni!")