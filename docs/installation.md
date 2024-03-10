![](./logo.png)

**Status(main branch)**

![](https://img.shields.io/badge/license-MIT-blue) 

---

## Installation guide

This guide covers the installation of the software stack on the PangioPi device.

### 1. Install Dependencies

Python is required during the setup of your Pangio device. Install it using:

`$ sudo apt install -y python3`

The stack is containerized and orchestrated through Docker Compose. You need the docker engine and docker compose plugin installed on the device, and Pangio is using the official repository. As such we will start by removing any existing installation of Docker:

`$ for pkg in docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc; do sudo apt-get remove $pkg; done`

Install the official Docker GPG key:

```
# Add Docker's official GPG key:
$ sudo apt-get update
$ sudo apt-get install ca-certificates curl
$ sudo install -m 0755 -d /etc/apt/keyrings
$ sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
$ sudo chmod a+r /etc/apt/keyrings/docker.asc
```

You can then setup the official Docker repository:

```
$ echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
$ sudo apt-get update
```

We can now install Docker from the official repository:

`$ sudo apt-get install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin`

Install `rng-tools`, a package to make use of our Pangio's hardware random number generator.

`$ apt install -y rng-tools`

Once installed, it must be configured to use the onboard hardware random number generator. Edit `/etc/default/rng-tools-debian` and uncomment this line:

`#HRNGDEVICE=/dev/hwrng`

Restart the service:

`$ sudo systemctl restart rng-tools`

Your Pangio relies on 2G/2G+ networking. We therefore need to configure dial-up connectivity. Install `ppp`:

`$ sudo apt install -y ppp`

### 2. Configure networking

Create `/etc/ppp/peers/gprs`:
```
connect "/usr/sbin/chat -v -f /etc/chatscripts/gprs"
/dev/serial0
115200
nocrtscts
debug
nodetach
ipcp-accept-local
ipcp-accept-remote
noipdefault
usepeerdns
defaultroute
persist
noauth
```

We now create a `systemd` unit to handle connectivity for us. Create `/etc/systemd/system/ppphat.service`:
```
[Unit]
Description=PPP over Serial link
After=network.target

[Service]
Exec=/usr/sbin/pppd call gprs
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

Reload `systemctl`:

`$ sudo systemctl daemon-reload`

Enable and start the unit:

`$ sudo systemctl enable --now ppphat.service`

At this point, your Pangio should be able to reach the net. But you might require extra configuration depending on your carrier such as login information. Please take care of that first before moving on to the next step.

### 3. SSH setup

Being able to SSH into your Pangio gives you a significant advantage when using the Pangio as a on-premises attack platform.

Create the `.ssh` folder in thr root home directory:

`$ sudo mkdir /root/.ssh`

In the folder, create the `authorized_keys` file, and paste your SSH public key into it.

`$ vim /root/.ssh/authorized_keys`

Now, configure `/etc/ssh/sshd_config` to refuse password connections:

```
PermitRootLogin prohibit-password
PasswordAuthentication no
PubkeyAuthentication yes
```

### 4. Tor setup

Your Pangio will now need to access the Tor network, requiring a local Tor proxy to be running. Install `tor`:

`$ sudo apt install tor`

Edit `/etc/tor/torrc` to add the following lines:

```
SocksPort 172.17.0.1:9050
SocksPolicy accept 172.17.0.0./16
```

You can now restart the Tor proxy:

`$ sudo systemctl restart tor@default.service`

The Tor proxy is now listening for incoming connections on the Pangio Docker subnet.

### 5. Hidden service setup

A Tor hidden service is a way to expose one of your local services on the Tor network. In this case, we want the SSH server to be a hidden service. Edit `/etc/tor/torrc` on your Pangio:

```
HiddenServiceDir /var/lib/tor/ssh/
HiddenServicePort 22 127.0.0.1:22
HiddenServiceAuthorizeClient stealth pangioremote
```

Restart the Tor service:

`$ sudo systemctl restart tor`

Obtain the authentication cookie for the client `pangioremote`:

`$ cat /var/lib/tor/ssh/hostname`

Now, on the machine you will use to control the Pangio, edit `/etc/tor/torrc`:

`HidServAuth hostaddress.onion authcookie`

Restart the Tor service:

`$ sudo systemctl restart tor`

You can now SSH into your Pangio over Tor:

`torify ssh username@hostaddress.onion`

### 6. Create a user for Pangio

The following command should create the `pangio` user and create its home directory.

`$ sudo useradd -m pangio`

The `pangio` user needs a PGP identity. Create it using the provided Python script:

`su pangio -c './general/init_pgp.py'`

# You can now move on to the configuration manual.