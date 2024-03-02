import struct
from smbus2 import SMBus

CW2015_ADDRESS = 0X62
CW2015_REG_VCELL = 0X02
CW2015_REG_SOC = 0X04
CW2015_REG_MODE = 0X0A


# Class defining a Pi UPS
class PiUPS:
    def __init__(self):
        self.bus = SMBus(1)  # 0 = /dev/i2c-0 (port I2C0), 1 = /dev/i2c-1 (port I2C1)
        # Wake up the device
        self.bus.write_word_data(CW2015_ADDRESS, CW2015_REG_MODE, 0x30)

    def readVoltage(self):
        read = self.bus.read_word_data(CW2015_ADDRESS, CW2015_REG_VCELL)
        swapped = struct.unpack("<H", struct.pack(">H", read))[0]
        voltage = swapped * 0.305 / 1000
        return voltage

    def readCapacity(self):
        read = self.bus.read_word_data(CW2015_ADDRESS, CW2015_REG_SOC)
        swapped = struct.unpack("<H", struct.pack(">H", read))[0]
        capacity = swapped / 256
        return capacity
