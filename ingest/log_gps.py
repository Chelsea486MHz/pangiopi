import os
import time
import mysql.connector
from gsmHat import GSMHat

# Connect to the GPS module
gsm = GSMHat(os.environ.get('GSM_PORT'), os.environ.get('GSM_BAUDRATE'))

# Connect to the Pangio DB container (MariaDB)
try:
    sql_connection = mysql.connector.connect(
        host=os.environ.get('MYSQL_HOST'),
        user=os.environ.get('MYSQL_USER'),
        password=os.environ.get('MYSQL_PASSWORD'),
        database=os.environ.get('MYSQL_DATABASE')
    )

except mysql.connector.Error as err:
    print(err)

# Get the GPS values
timestamp = time.strftime('%Y-%m-%d %H:%M:%S')
GPSObj = gsm.GetActualGPS()
latitude = GPSObj.Latitude
longitude = GPSObj.Longitude
speed = GPSObj.Speed
course = GPSObj.Course

# Insert the data into the table
cursor = sql_connection.cursor()
cursor.execute(
    "INSERT INTO gps (timestamp, latitude, longitude, speed, course) "
    "VALUES (%s, %s, %s, %s, %s)", (timestamp, latitude, longitude, speed, course)
)

# We're done
sql_connection.commit()
cursor.close()
sql_connection.close()
