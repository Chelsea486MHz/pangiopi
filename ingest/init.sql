USE pangio;

CREATE TABLE IF NOT EXISTS gps (
    id INT AUTO_INCREMENT PRIMARY KEY,
    timestamp DATETIME NOT NULL,
    latitude DECIMAL(10, 8) NOT NULL,
    longitude DECIMAL(11, 8) NOT NULL,
    speed DECIMAL(5, 2) NOT NULL,
    course DECIMAL(5, 2) NOT NULL
);

CREATE TABLE IF NOT EXISTS battery (
    id INT AUTO_INCREMENT PRIMARY KEY,
    timestamp DATETIME NOT NULL,
    voltage DECIMAL(5, 2) NOT NULL,
    capacity DECIMAL(5, 2) NOT NULL
);

CREATE TABLE IF NOT EXISTS wap (
    id INT AUTO_INCREMENT PRIMARY KEY,
    timestamp DATETIME NOT NULL,
    ssid VARCHAR(32) NOT NULL,
    bssid VARCHAR(17) NOT NULL,
    channel INT NOT NULL,
    rssi INT NOT NULL
);