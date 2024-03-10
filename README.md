![](./docs/logo.png)

**Status(main branch)**

![](https://img.shields.io/badge/maintained-yes-green) ![](https://img.shields.io/badge/license-MIT-blue) 

---

## What is PangioPi?

The PangioPi is a sneaky little hacking companion that is easy to hide and use as a remote attack platform. It is meant to be controlled from a WebUI over Tor.

The PangioPi continuously ingests and sniffs the following data:
- Wi-Fi access points
- MAC addresses
- Bluetooth advertisements
- Real-time GPS data

It can exfiltrate the data with PGP over the following transport layers:
- Phone calls (QRCode over SSTV)
- SMS
- 3G mobile data

You can also SSH into your PangioPi through the Tor network, and eavesdrop on its surroundings by listening in real time to what its microphone is picking up.

## Installation guide

You'll need a fresh Ubuntu Server 64 installation on your Raspberry Pi Zero 2WH.

Clone the repo and navigate to `installation`. From there, run the shell script as an unpriviledged user:

```
$ chmod +x get_pangio.sh
$ ./get_pangio.sh
```

If you want to manually install everything, see [installation.md](./docs/installation.md)

## Configuration guide

If you're not using the installation script, you have to follow the configuration guide.

See [configuration.md](./docs/configuration.md)

## User manual

This manual is here to help you make the most of your Pangio!

See [user-manual.md](./docs/user-manual.md)

## Architecture

The PangioPI software stack uses the following components:
- `pangio-sender`: API server to exfiltrate data
- `pangio-ingest`: Black-hole that ingests as much data as possible
- `pangio-listener`: Listens for commands from the Flipper Zero

As for the hardware, the following components are used:
- Raspberry Pi Zero 2WH
- Pi Zero UPS lite
- Waveshare SIM868 HAT

The following libraries have been used:
- [gsmHat](https://github.com/Civlo85/gsmHat): to use the SIM868 expansion board

## Contributions

See [CONTRIBUTING.md](./CONTRIBUTING.md)

## Code of conduct

See [CODE_OF_CONDUCT.md](./CODE_OF_CONDUCT.md)

## Active contributors

Chelsea Murgia <[mail@chelsea486mhz.fr](mailto:mail@chelsea486mhz.fr)>