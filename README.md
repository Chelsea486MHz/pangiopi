![](./docs/logo.png)

**Status(main branch)**

![](https://img.shields.io/badge/maintained-yes-green) ![](https://img.shields.io/badge/license-MIT-blue) 

---

## What is PangioPi?

The PangioPi is a sneaky little hacking companion that is easy to hide and use as a remote attack platform.

The PangioPi continuously ingests and sniffs the following data:
- Wi-Fi access points
- MAC addresses
- Bluetooth advertisements
- Real-time GPS data

It can exfiltrate the data with PGP over the following transport layers:
- Phone calls (QRCode over SSTV)
- SMS
- 3G mobile data

You can also SSH into your PangioPi through the Tor network!

## Installation guide

See [installation.md](./docs/installation.md)

## Configuration guide

See [configuration.md](./docs/configuration.md)

## User manual

See [user-manual.md](./docs/user-manual.md)

## Architecture

The PangioPI software stack uses the following components:
- `pangio-sender`: API server to exfiltrate data
- `pangio-ingest`: Black-hole that ingests as much data as possible

As for the hardware, the following components are used:
- Raspberry Pi Zero 2W
- Pi Zero UPS lite
- Waveshare SIM868 HAT

Additionnaly, third-party software is used:
- `mariadb`: to store ingested data
- `tor`: to expose SSH

As well as the following libraries:
- [gsmHat](https://github.com/Civlo85/gsmHat): to use the SIM868 expansion board

## Contributions

See [CONTRIBUTING.md](./CONTRIBUTING.md)

## Code of conduct

See [CODE_OF_CONDUCT.md](./CODE_OF_CONDUCT.md)

## Active contributors

Chelsea Murgia <[mail@chelsea486mhz.fr](mailto:mail@chelsea486mhz.fr)>