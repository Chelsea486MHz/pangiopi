import os
import time
import mysql.connector
from . import piups

# Connect to the PiUPS
pi_ups = piups.PiUPS()

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

# Get the battery voltage and capacity + timestamp
timestamp = time.strftime('%Y-%m-%d %H:%M:%S')
voltage = piups.readVoltage()
capacity = piups.readCapacity()

# Insert the data into the table
cursor = sql_connection.cursor()
cursor.execute(
    "INSERT INTO battery (timestamp, voltage, capacity) "
    "VALUES (%s, %s, %s)", (timestamp, voltage, capacity)
)

# We're done
sql_connection.commit()
cursor.close()
sql_connection.close()
