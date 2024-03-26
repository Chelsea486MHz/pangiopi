import os
import mysql.connector
from datetime import datetime
from log_wap import sniff_wifi_packets
from log_battery import get_battery_state
from log_gps import get_gps_data


# Connect to MySQL Database
def connect_to_db():
    db = mysql.connector.connect(
        host=os.environ.get("DB_HOST"),
        user=os.environ.get("DB_USER"),
        password=os.environ.get("DB_PASSWORD"),
        database=os.environ.get("DB_NAME")
    )
    return db


# Log data to the database
def log_to_db(db, gps_data, battery_data, wap_data):
    cursor = db.cursor()
    current_time = datetime.now().strftime("%Y-%m-%d %H:%M:%S")

    # GPS data
    gps_values = [(current_time, *data) for data in gps_data]
    gps_query = "INSERT INTO gps (timestamp, latitude, longitude, speed, course) VALUES (%s, %s, %s, %s, %s)"
    cursor.executemany(gps_query, gps_values)

    # battery data
    battery_values = [(current_time, *data) for data in battery_data]
    battery_query = "INSERT INTO battery (timestamp, voltage, capacity) VALUES (%s, %s, %s)"
    cursor.executemany(battery_query, battery_values)

    # WAP data
    wap_values = [(current_time, *data.values()) for data in wap_data]
    wap_query = "INSERT INTO wap (timestamp, ssid, bssid, channel, rssi) VALUES (%s, %s, %s, %s, %s)"
    cursor.executemany(wap_query, wap_values)

    db.commit()
    cursor.close()


if __name__ == "__main__":
    db = connect_to_db()
    log_to_db(db, get_gps_data(), get_battery_state(), sniff_wifi_packets())
    db.close()
