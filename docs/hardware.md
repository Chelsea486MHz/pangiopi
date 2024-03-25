![](./logo.png)

**Status(main branch)**

![](https://img.shields.io/badge/license-MIT-blue) 

---

## Pangio hardware

Should you have to purchase everything, the Pangio will cost you on average 250 EUR, but that cost can be considerably lowered if you already have some parts on hand and can get reduced shipping costs.

This document details the required hardware, and the rationale behind their inclusion in the system.

### 🖥️ Raspberry Pi Zero 2W

**Type:** ARM based SoC

**Cost:** 30 EUR

The Raspberry Pi Zero 2W is the best choice for the Pangio: its small physical footprint allows for easy concealment, for example in removable ceilings. It supports 64-bit ARM, and with a modified firmware, its Wi-Fi chip can be set to monitoring mode allowing for WAP data collection.

Overwall, it's the perfect choice for our pentesting tool!

### 🔑 YubiKey 5 Nano

**Type:** Hardware security module (HSM)

**Cost:** 60 EUR

The YubiKey 5 Nano is an essential component of the Pangio system: its small physical footprint allows seamless integration in the system, and its PGP features allow for data encryption and signature.

By storing the GPG private key on the YubiKey, its extraction becomes near impossible.

Locking the YubiKey with a password, stored on the Pangio, allows the user to protect their identity by triggering the Pangio Shredder. This way, even in the target's hands, the Pangio PGP key cannot be retrieved to send you bogus data.

### 🛜 Waveshare SIM7600G-H

**Type:** Edge connectivity module (LTE/4G/3G/2G)

**Cost:** 100 EUR

The specificity of this module lies in its connectivity with the Rasperry Pi: it uses the USB bus instead of the GPIO UART, offering two extra USB ports for devices like the YubiKey 5 Nano, as well as extra bandwidth for network connectivity.

The modem has no region locking, and accepts any SIM cards. Prepaid cards can be used and swapped as needed, though there may be some extra configuration required for the PPP daemon to authentify you to the network infrastructure.

Another important feature of this module is GNSS compatibility: this way, the Pangio has access to its geographic location.

### 🔋 UPS Lite

**Type:** Uninterruptible power supply (UPS)

**Cost:** 20 EUR

The Pi UPS Lite is a small footprint device that powers the Pangio with a 1000mAh battery, and allows use while recharging. However, due to the way it interfaces with the Pi, it must be modified to work on the Pangio.

Its pogo pins are supposed to make contact with the underside of the Pangio, but that space is already occupied by the edge connectivity module, meaning the pogo pins must be removed, and cables must instead be soldered in their place to connect to the Pi GPIO.

### 💾 64 GB SDXC Micro-SD card

**Type:** Storage device

**Cost:** 20-30 EUR

Our Pangio ingests a lot of data, and a large storage device is preferred here. With the Pi Zero 2W, we won't be getting more that 25 MB/s of real usage bandwidth, so don't bother getting the most expensive devices out there. Just make sure you're getting reliable storage.