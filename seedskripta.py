import sqlite3
from datetime import datetime
import random

conn = sqlite3.connect("measurements.db")
cursor = conn.cursor()

# Struja - pocinje na 5800, raste ~5-10 kWh dnevno
base_struja = 5800.0
for month in [6, 7]:
    days = 30 if month == 6 else 7
    for day in range(1, days + 1):
        date = datetime(2026, month, day, 12, 0, 0)
        base_struja += random.uniform(5, 10)
        cursor.execute(
            "INSERT INTO measurements (reading, image_path, type, datetime) VALUES (?, ?, ?, ?)",
            (round(base_struja, 1), f"pictures/s_{month}_{day}.png", "struja", date.strftime("%Y-%m-%d %H:%M:%S"))
        )

# Voda - pocinje na 580, raste ~0.5-1.5 m3 dnevno
base_voda = 580.0
for month in [6, 7]:
    days = 30 if month == 6 else 7
    for day in range(1, days + 1):
        date = datetime(2026, month, day, 12, 0, 0)
        base_voda += random.uniform(0.5, 1.5)
        cursor.execute(
            "INSERT INTO measurements (reading, image_path, type, datetime) VALUES (?, ?, ?, ?)",
            (round(base_voda, 2), f"pictures/v_{month}_{day}.png", "voda", date.strftime("%Y-%m-%d %H:%M:%S"))
        )

# Plin - pocinje na 240, raste ~0.2-0.8 m3 dnevno
base_plin = 240.0
for month in [6, 7]:
    days = 30 if month == 6 else 7
    for day in range(1, days + 1):
        date = datetime(2026, month, day, 12, 0, 0)
        base_plin += random.uniform(0.2, 0.8)
        cursor.execute(
            "INSERT INTO measurements (reading, image_path, type, datetime) VALUES (?, ?, ?, ?)",
            (round(base_plin, 2), f"pictures/p_{month}_{day}.png", "plin", date.strftime("%Y-%m-%d %H:%M:%S"))
        )

conn.commit()
conn.close()
print("Podaci ubaceni!")