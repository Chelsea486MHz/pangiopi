import os
import time
import mysql.connector
from scapy.all import *

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


# Callback function for sniffing
def process_packet(packet):
    if packet.haslayer(Dot11):
        if packet.type == 0 and packet.subtype == 8:
            timestamp = time.strftime('%Y-%m-%d %H:%M:%S')
            ssid = packet.info.decode('utf-8')
            bssid = packet.addr2
            channel = int(ord(packet[Dot11Elt:3].info))
            rssi = packet.dBm_AntSignal
            cursor = sql_connection.cursor()
            cursor.execute(
                "INSERT INTO wap (timestamp, ssid, bssid, channel, rssi) "
                "VALUES (%s, %s, %s, %s, %s)", (timestamp, ssid, bssid, channel, rssi)
            )
            sql_connection.commit()
            cursor.close()

# Sniff for WAPs
# Triggers the callback function for each packet
sniff(iface=os.environ.get("PANGIO_WAP_SNIFFING_INTERFACE"), prn=process_packet, store=0)

sql_connection.close()