import mysql.connector
import os

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

# Create the GPS table if it doesn't exist
cursor = sql_connection.cursor()
cursor.execute(
    "CREATE TABLE IF NOT EXISTS gps ("
    "id INT AUTO_INCREMENT PRIMARY KEY, "
    "timestamp DATETIME NOT NULL, "
    "latitude DECIMAL(10, 8) NOT NULL, "
    "longitude DECIMAL(11, 8) NOT NULL, "
    "speed DECIMAL(5, 2) NOT NULL, "
    "course DECIMAL(5, 2) NOT NULL"
    ")"
)

# Create the battery table if it doesn't exist
cursor.execute(
    "CREATE TABLE IF NOT EXISTS battery ("
    "id INT AUTO_INCREMENT PRIMARY KEY, "
    "timestamp DATETIME NOT NULL, "
    "voltage DECIMAL(5, 2) NOT NULL, "
    "capacity DECIMAL(5, 2) NOT NULL"
    ")"
)

# Create the WAP table if it doesn't exist
cursor.execute(
    "CREATE TABLE IF NOT EXISTS wap ("
    "id INT AUTO_INCREMENT PRIMARY KEY, "
    "timestamp DATETIME NOT NULL, "
    "ssid VARCHAR(32) NOT NULL, "
    "bssid VARCHAR(17) NOT NULL, "
    "channel INT NOT NULL, "
    "rssi INT NOT NULL"
    ")"
)

# We're done
sql_connection.commit()
cursor.close()
sql_connection.close()
