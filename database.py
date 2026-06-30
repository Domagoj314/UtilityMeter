import sqlite3

database = "measurements.db"
create_table = """
CREATE TABLE IF NOT EXISTS measurements (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    reading REAL NOT NULL,
    datetime TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    image_path TEXT NOT NULL  
)
"""

altertable_addtype = """
ALTER TABLE measurements ADD COLUMN type TEXT
"""

try:
    with sqlite3.connect(database) as conn:
        cursor = conn.cursor()
        cursor.execute(create_table)
        cursor.execute(altertable_addtype)
        conn.commit()

except sqlite3.Error as e:
    print(f"An error occurred while creating the table: {e}")
        
    