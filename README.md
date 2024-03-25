![](./docs/logo.png)

**Status(main branch)**

![](https://img.shields.io/badge/maintained-yes-green)
![](https://img.shields.io/badge/license-MIT-blue)
[![](https://img.shields.io/badge/website-pangio.xyz-red)](https://pangio.xyz)

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
- 4G mobile data

The Pangio can be remotely shredded at any time, protecting your identity in case it gets discovered.

You can also SSH into your PangioPi through the Tor network, and eavesdrop on its surroundings by listening in real time to what its microphone is picking up.

## System requirements

You'll need a fresh Kali Linux installation on your Raspberry Pi Zero 2WH. We use Kali Linux because its kernel provides necessary features Ubuntu doesn't.

Make sure you added your Ed25519 SSH public key to the root account's authorized keys. Also disable `lightdm` if you want some speedup as it's not necessary.

## Installation guide

Clone the repo and navigate to `installation`. From there, run the shell script as root:

`$ ./get_pangio.sh`

If you want to manually install everything, see [installation.md](./docs/installation.md)

## Configuration guide

If you're not using the installation script, you have to follow the configuration guide.

See [configuration.md](./docs/configuration.md)

## User manual

This manual is here to help you make the most of your Pangio!

See [user-manual.md](./docs/user-manual.md)

## Architecture

The PangioPI software stack uses the following components in Docker:
- `pangio-sender`: API server that handles data exfiltration
- `pangio-ingest`: Black hole that ingests as much data as possible
- `pangio-webui`: Handles the WebUI

But also the following tools ready to be used
- `pangio-shredder`: Shred the device in case it gets discovered

## Required hardware

See [hardware.md](./docs/hardware.md)

## Note on protecting women

Devices with features similar as those of the Pangio (Apple Airtags, etc.) have been used in a systemic way in acts of harassment, stalking, and violence against women. Important decisions have to be made regarding what features to implement so as to not endanger women and keep the Pangio a pentesting device.

The following data is beind considered for ingestion, but due to the aforementionned concerns, their implementation is being delayed:

- Audio (onboard microphone, continuous recording)
- Video (onboard camera, regular interval pictures)

## Development progress

```
[ ] Pangio
    [ ] Docker stack
        [ ] pangio-sender
            [ ] Yubikey integration
                [ ] Data encryption
                [ ] Digital signatures
            [X] Compression
            [ ] Exfiltration over SMS
            [X] Exfiltration over phone call
            [ ] Exfiltration over email
            [ ] Exfiltration over HTTP
                [ ] GET
                [ ] POST
        [ ] pangio-ingest
            [ ] SQL interface
            [ ] Data ingestion
                [ ] RTC
                [ ] GPS
                [ ] WAP
                [ ] BLE
        [ ] pangio-webui
            [ ] Django skeleton
            [ ] CSS
            [ ] Authentication
            [ ] Main features
                [ ] Display recently ingested data
                [ ] Display graphs of recently ingested data
    [ ] Custom Python libraries
        [ ] SIM7600G-H
        [X] UPS Lite
    [ ] Tools
        [X] Tor proxy configuration script
        [X] GPG configuration script
        [ ] Dial-Up configuration (PPP)
        [ ] YubiKey configuration script
        [ ] Device shredder
    [ ] System
        [ ] Security hardening
            [X] SSH hardening (OpenSSH)
            [ ] Reverse-proxy hardening (NGINX)
                [ ] Cryptography
                [ ] Certificate management
            [ ] Firewall configuration
            [ ] Fail2Ban
            [ ] Tor hardening
                [ ] Stealthing hidden services
                    [ ] HTTP/S
                    [ ] SSH
    [ ] Installation
        [X] Shell-script based installer
        [ ] Flashable ISO based on Kali Linux
```

## Contributions

See [CONTRIBUTING.md](./CONTRIBUTING.md)

## Code of conduct

See [CODE_OF_CONDUCT.md](./CODE_OF_CONDUCT.md)

## Active contributors

Chelsea Murgia <[mail@chelsea486mhz.fr](mailto:mail@chelsea486mhz.fr)>