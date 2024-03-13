#!/bin/bash

# Resets the line
LINE_RESET='\e[2K\r'

# Terminal escape codes to color text
TEXT_GREEN='\e[032m'
TEXT_YELLOW='\e[33m'
TEXT_RED='\e[31m'
TEXT_RESET='\e[0m'

# Logs like systemd on startup, it's pretty
TEXT_INFO="[${TEXT_YELLOW}i${TEXT_RESET}]"
TEXT_FAIL="[${TEXT_RED}-${TEXT_RESET}]"
TEXT_SUCC="[${TEXT_GREEN}+${TEXT_RESET}]"

LOGFILE="./pangio_install.log"

# Variables related to dependencies
dependencies=`cat dependencies.txt`
docker_pkg_to_remove=`cat docker_pkg_to_remove.txt`
docker_pkg_to_install=`cat docker_pkg_to_install.txt`

cat pangio_banner.txt
echo ""
echo ""
echo ""

echo "Pangio Install" > ${LOGFILE}

#################
#################
#################

# Refreshing package cache
echo -n -e "${TEXT_INFO} Running apt-update"
apt update &>> ${LOGFILE}
if [ $? -eq 0 ]; then
	echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_SUCC} Updated the package list"
else
	echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_FAIL} Failed to update the package list"
    exit 255
fi

# Installing the dependencies
echo -e "${TEXT_INFO} Installing dependencies"
for dep in ${dependencies}; do
    echo -n -e "${TEXT_INFO} Installing dependency $dep"
    apt install $dep -y &>> ${LOGFILE}
    if [ $? -eq 0 ]; then
        echo -n -e "${LINE_RESET}"
        echo -e "${TEXT_SUCC} Installed dependency $dep"
    else
        echo -n -e "${LINE_RESET}"
        echo -e "${TEXT_FAIL} Failed to install dependency $dep"
        exit 255
    fi
done

# Remove existing Docker packages
echo -n -e "${TEXT_INFO} Removing existing Docker packages"
for pkg in ${docker_pkg_to_remove}; do
    apt remove $pkg -y &>> ${LOGFILE}
    if [ $? -eq 0 ]; then
	echo -n -e "${LINE_RESET}"
        echo -e "${TEXT_SUCC} Removed $pkg"
    else
	    echo -n -e "${LINE_RESET}"
        echo -e "${TEXT_FAIL} Failed to remove $pkg"
        exit 255
    fi
done

# Add the official Docker PGP key
install -m 0755 -d /etc/apt/keyrings &>> ${LOGFILE}

echo -n -e "${TEXT_INFO} Adding the official Docker PGP key"
curl -fsSL https://download.docker.com/linux/debian/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg &>> ${LOGFILE}
if [ $? -eq 0 ]; then
	echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_SUCC} Added the official Docker PGP key"
else
	echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_FAIL} Failed to add the official Docker PGP key"
    exit 255
fi

echo -n -e "${TEXT_INFO} Setting correct key permissions"
chmod a+r /etc/apt/keyrings/docker.asc &>> ${LOGFILE}
if [ $? -eq 0 ]; then
	echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_SUCC} Set correct key permissions"
else
	echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_FAIL} Failed to set correct key permissions"
    exit 255
fi

# Add the Docker repository
echo \
  "deb [arch=arm64 signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/debian bookworm stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list &>> ${LOGFILE}
echo -e "${TEXT_SUCC} Added the Docker repository"

# Run apt-update again
echo -n -e "${TEXT_INFO} Running apt-update"
apt update &>> ${LOGFILE}
if [ $? -eq 0 ]; then
	echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_SUCC} Updated the package list"
else
	echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_FAIL} Failed to update the package list"
    exit 255
fi

# Install Docker
echo -e "${TEXT_INFO} Installing Docker packages"
for pkg in ${docker_pkg_to_install}; do
    echo -n -e "${TEXT_INFO} Installing Docker package $pkg"
    apt install ${docker_pkg_to_install} -y &>> ${LOGFILE}
    if [ $? -eq 0 ]; then
    echo -n -e "${LINE_RESET}"
        echo -e "${TEXT_SUCC} Installed Docker package $pkg"
    else
    echo -n -e "${LINE_RESET}"
        echo -e "${TEXT_FAIL} Failed to install Docker package $pkg"
        exit 255
    fi
done
echo -e "${TEXT_SUCC} Installed Docker packages"

#################
#################
#################

# Stop hardware RNG
echo -n -e "${TEXT_INFO} Stopping hardware RNG"
systemctl stop rng-tools &>> ${LOGFILE}
if [ $? -eq 0 ]; then
	echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_SUCC} Stopped hardware RNG"
else
	echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_FAIL} Failed to stop hardware RNG"
fi

# Stop SSH
echo -n -e "${TEXT_INFO} Stopping SSH"
systemctl stop ssh &>> ${LOGFILE}
if [ $? -eq 0 ]; then
	echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_SUCC} Stopped SSH"
else
	echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_FAIL} Failed to stop SSH"
fi

# Stop Docker
echo -n -e "${TEXT_INFO} Stopping Docker"
systemctl stop docker &>> ${LOGFILE}
if [ $? -eq 0 ]; then
	echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_SUCC} Stopped Docker"
else
	echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_FAIL} Failed to stop Docker"
fi

# Stop Tor
echo -n -e "${TEXT_INFO} Stopping the Tor SOCKS5 proxy"
systemctl stop tor@default.service &>> ${LOGFILE}
if [ $? -eq 0 ]; then
	echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_SUCC} Stopped the Tor SOCKS5 proxy"
else
	echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_FAIL} Failed to stop the Tor SOCKS5 proxy"
fi

#################
#################
#################

# Check if Docker group exists
echo -n -e "${TEXT_INFO} Checking if Docker group exists"
getent group docker &>> ${LOGFILE}
if [ $? -eq 0 ]; then
    echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_INFO} Docker group exists. Skipping"
else
    echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_FAIL} Docker group does not exist. Creating"

    # Create Docker group
    echo -n -e "${TEXT_INFO} Creating Docker group"
    groupadd docker &>> ${LOGFILE}
    if [ $? -eq 0 ]; then
        echo -n -e "${LINE_RESET}"
        echo -e "${TEXT_SUCC} Created Docker group"
    else
        echo -n -e "${LINE_RESET}"
        echo -e "${TEXT_FAIL} Failed to create Docker group. Does it already exist?"
    fi

    # Add current user to Docker group
    echo -n -e "${TEXT_INFO} Adding current user to Docker group"
    usermod -aG docker $USER &>> ${LOGFILE}
    if [ $? -eq 0 ]; then
        echo -n -e "${LINE_RESET}"
        echo -e "${TEXT_SUCC} Added current user to Docker group"
    else
        echo -n -e "${LINE_RESET}"
        echo -e "${TEXT_FAIL} Failed to add current user to Docker group. Is the user already a member?"
    fi
fi

# Configure rng-tools
echo -n -e "${TEXT_INFO} Configuring hardware RNG"
sed -i 's/#HRNGDEVICE/HRNGDEVICE/g' /etc/default/rng-tools-debian &>> ${LOGFILE}
if [ $? -eq 0 ]; then
	echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_SUCC} Configured hardware RNG"
else
	echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_FAIL} Failed to configure hardware RNG"
    exit 255
fi

## Create ppp device node
#echo -n -e "${TEXT_INFO} Creating ppp device node"
#mknod /dev/ppp c 108 0 &>> ${LOGFILE}
#if [ $? -eq 0 ]; then
#    echo -n -e "${LINE_RESET}"
#    echo -e "${TEXT_SUCC} Created ppp device node"
#else
#    echo -n -e "${LINE_RESET}"
#    echo -e "${TEXT_FAIL} Failed to create ppp device node"
#    exit 255
#fi

## Configure dial-up connection
#echo -n -e "${TEXT_INFO} Configuring dial-up connection"
#cp gprs_peer.txt /etc/ppp/peers/gprs &>> ${LOGFILE}
#if [ $? -eq 0 ]; then
#	echo -n -e "${LINE_RESET}"
#    echo -e "${TEXT_SUCC} Configured dial-up connection"
#else
#	echo -n -e "${LINE_RESET}"
#    echo -e "${TEXT_FAIL} Failed to configure dial-up connection"
#    exit 255
#fi

## Install the chatscript
#echo -n -e "${TEXT_INFO} Installing chatscript"
#cp chatscript.txt /etc/chatscripts/gprs &>> ${LOGFILE}
#if [ $? -eq 0 ]; then
#    echo -n -e "${LINE_RESET}"
#    echo -e "${TEXT_SUCC} Installed chatscript"
#else
#    echo -n -e "${LINE_RESET}"
#    echo -e "${TEXT_FAIL} Failed to install chatscript"
#    exit 255
#fi

## Create a systemd unit
#echo -n -e "${TEXT_INFO} Creating systemd unit for pppd"
#cp ppphat.service /etc/systemd/system/ppphat.service &>> ${LOGFILE}
#if [ $? -eq 0 ]; then
#	echo -n -e "${LINE_RESET}"
#    echo -e "${TEXT_SUCC} Created systemd unit for pppd"
#else
#	echo -n -e "${LINE_RESET}"
#    echo -e "${TEXT_FAIL} Failed to create systemd unit for pppd"
#    exit 255
#fi

# Configure the Tor proxy
echo -n -e "${TEXT_INFO} Installing Tor SOCKS5 proxy configuration"
cp torrc /etc/tor/torrc &>> ${LOGFILE}
if [ $? -eq 0 ]; then
	echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_SUCC} Installed the Tor SOCKS5 proxy configuration"
else
	echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_FAIL} Failed to install the Tor SOCKS5 proxy configuration"
    exit 255
fi

# Check if the SSH host keys exist
echo -n -e "${TEXT_INFO} Checking if SSH host keys exist"
ls /etc/ssh/ssh_host_* &>> ${LOGFILE}
if [ $? -eq 0 ]; then
    echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_INFO} SSH host keys exist. Removing"

    # Remove existing SSH host keys
    echo -n -e "${TEXT_INFO} Removing existing SSH host keys"
    rm /etc/ssh/ssh_host_* &>> ${LOGFILE}
    if [ $? -eq 0 ]; then
        echo -n -e "${LINE_RESET}"
        echo -e "${TEXT_SUCC} Removed existing SSH host keys"
    else
        echo -n -e "${LINE_RESET}"
        echo -e "${TEXT_FAIL} Failed to remove existing SSH host keys"
        exit 255
    fi
else
    echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_INFO} SSH host keys do not exist."
fi

# Generate a robust SSH host key
echo -n -e "${TEXT_INFO} Generating SSH host key"
ssh-keygen -a 128 -t ed25519 -f /etc/ssh/ssh_host_ed25519_key -q -N ""
if [ $? -eq 0 ]; then
    echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_SUCC} Generated SSH host key"
else
    echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_FAIL} Failed to generate SSH host key"
    exit 255
fi

# Install our sshd_config file
echo -n -e "${TEXT_INFO} Installing SSH server configuration"
cp sshd_config /etc/ssh/sshd_config &>> ${LOGFILE}
if [ $? -eq 0 ]; then
    echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_SUCC} Installed SSH server configuration"
else
    echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_FAIL} Failed to install SSH server configuration"
    exit 255
fi

# Install the banner
echo -n -e "${TEXT_INFO} Installing SSH banner"
cp banner /etc/ssh/banner &>> ${LOGFILE}
if [ $? -eq 0 ]; then
    echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_SUCC} Installed SSH banner"
else
    echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_FAIL} Failed to install SSH banner"
    exit 255
fi

#################
#################
#################

# Reload systemd
echo -n -e "${TEXT_INFO} Reloading systemd"
systemctl daemon-reload &>> ${LOGFILE}
if [ $? -eq 0 ]; then
	echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_SUCC} Reloaded systemd"
else
	echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_FAIL} Failed to reload systemd"
    exit 255
fi

## Enable and start pppd
#echo -e "${TEXT_INFO} Enabling and starting pppd"
#systemctl enable --now ppphat.service &>> ${LOGFILE}
#if [ $? -eq 0 ]; then
#    echo -e "${TEXT_SUCC} Enabled and started pppd"
#else
#    echo -e "${TEXT_FAIL} Failed to enable and start pppd"
#    exit 255
#fi

# Enable and start SSH
echo -n -e "${TEXT_INFO} Enabling and starting SSH"
systemctl enable --now ssh &>> ${LOGFILE}
if [ $? -eq 0 ]; then
	echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_SUCC} Enabled and started SSH"
else
	echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_FAIL} Failed to enable and start SSH"
    exit 255
fi

# Enable and start Docker
echo -n -e "${TEXT_INFO} Enabling and starting Docker"
systemctl enable --now docker &>> ${LOGFILE}
if [ $? -eq 0 ]; then
	echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_SUCC} Enabled and started Docker"
else
	echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_FAIL} Failed to enable and start Docker"
    exit 255
fi

# Enable and start Tor
echo -n -e "${TEXT_INFO} Enabling and starting the Tor SOCKS5 proxy"
systemctl enable --now tor@default.service &>> ${LOGFILE}
if [ $? -eq 0 ]; then
	echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_SUCC} Enabled and started the Tor SOCKS5 proxy"
else
	echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_FAIL} Failed to enable and start the Tor SOCKS5 proxy"
    exit 255
fi

#################
#################
#################

# Create a temporary venv
echo -n -e "${TEXT_INFO} Creating a temporary venv"
python3 -m venv /root/venv &>> ${LOGFILE}
if [ $? -eq 0 ]; then
    echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_SUCC} Created a temporary venv"
else
    echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_FAIL} Failed to temporary create a venv"
    exit 255
fi

# Install gnupg in the venv
echo -n -e "${TEXT_INFO} Installing gnupg in the venv"
/root/venv/bin/pip install gnupg &>> ${LOGFILE}
if [ $? -eq 0 ]; then
    echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_SUCC} Installed gnupg in the venv"
else
    echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_FAIL} Failed to install gnupg in the venv"
    exit 255
fi

# Create the PGP key
# We're using a python script to do it, because in all honesty
# the GPG cli is a pain in the ass
echo -n -e "${TEXT_INFO} Creating the PGP key"
cp init_pgp.py /root/init_pgp.py
chown pangio:pangio /root/init_pgp.py
python3 /root/init_pgp.py &>> ${LOGFILE}
if [ $? -eq 0 ]; then
    echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_SUCC} Created the PGP key"
else
    echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_FAIL} Failed to create the PGP key"
    exit 255
fi

# Remove the script
echo -n -e "${TEXT_INFO} Removing the script"
rm /root/init_pgp.py &>> ${LOGFILE}
if [ $? -eq 0 ]; then
    echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_SUCC} Removed the script"
else
    echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_FAIL} Failed to remove the script"
    exit 255
fi

# Remove the venv
echo -n -e "${TEXT_INFO} Removing the venv"
rm -rf /root/venv &>> ${LOGFILE}
if [ $? -eq 0 ]; then
    echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_SUCC} Removed the venv"
else
    echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_FAIL} Failed to remove the venv"
    exit 255
fi

#################
#################
#################

# Copy the Pangio files to the root directory
echo -n -e "${TEXT_INFO} Copying the Pangio files to the root directory"
cp -r ../ingest /root/ingest &>> ${LOGFILE}
cp -r ../sender /root/sender &>> ${LOGFILE}
cp -r ../listener /root/listener &>> ${LOGFILE}
cp ../.env.example /root/.env &>> ${LOGFILE}
cp ../docker-compose.yml /root/docker-compose.yml &>> ${LOGFILE}
echo -e "${TEXT_SUCC} Copied the Pangio files to the root directory"

# Prompt the user for their phone number. Retry until a valid number is entered.
echo -n -e "${TEXT_INFO} Enter the phone number you'll exfiltrate to: "
read phone_number
while ! [[ $phone_number =~ ^\+[0-9]{11}$ ]]; do
    echo -n -e "${TEXT_FAIL} Invalid phone number"
    read phone_number
done

# Replace the placeholder phone number in the .env file with the user's phone number
echo -n -e "${TEXT_INFO} Setting exfiltration number"
sed -i "s/PANGIO_GSM_REMOTE_NUMBER=\"\+33613121337\"/PANGIO_GSM_REMOTE_NUMBER=\"$phone_number\"/g" /root/.env &>> ${LOGFILE}
echo -e "${TEXT_SUCC} Exfiltration number set"

# Set the MariaDB password
MARIADB_PASSWORD=$(python3 -c 'import secrets; print(secrets.token_urlsafe(32))')
echo -n -e "${TEXT_INFO} Setting MariaDB password"
sed -i "s/PANGIO_DB_PASSWORD=\"changeme\"/PANGIO_DB_PASSWORD=\"$MARIADB_PASSWORD\"/g" /root/.env &>> ${LOGFILE}
if [ $? -eq 0 ]; then
    echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_SUCC} Set MariaDB password"
else
    echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_FAIL} Failed to set MariaDB password"
    exit 255
fi

# Set the MariaDB root password
MARIADB_ROOT_PASSWORD=$(python3 -c 'import secrets; print(secrets.token_urlsafe(32))')
echo -n -e "${TEXT_INFO} Setting MariaDB root password"
sed -i "s/PANGIO_DB_PASSWORD_ROOT=\"changemetoo\"/PANGIO_DB_PASSWORD_ROOT=\"$MARIADB_ROOT_PASSWORD\"/g" /root/.env &>> ${LOGFILE}
if [ $? -eq 0 ]; then
    echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_SUCC} Set MariaDB root password"
else
    echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_FAIL} Failed to set MariaDB root password"
    exit 255
fi

## Kill the Wi-Fi link
#echo -n -e "${TEXT_INFO} Killing the Wi-Fi link"
#ifconfig wlan0 down &>> ${LOGFILE}
#if [ $? -eq 0 ]; then
#    echo -n -e "${LINE_RESET}"
#    echo -e "${TEXT_SUCC} Killed the Wi-Fi link"
#else
#    echo -n -e "${LINE_RESET}"
#    echo -e "${TEXT_FAIL} Failed to kill the Wi-Fi link"
#    exit 255
#fi
#
## Set Wi-Fi monitor mode
#echo -n -e "${TEXT_INFO} Enabling Wi-Fi monitor mode"
#iwconfig wlan0 mode monitor &>> ${LOGFILE}
#if [ $? -eq 0 ]; then
#    echo -n -e "${LINE_RESET}"
#    echo -e "${TEXT_SUCC} Enabled Wi-Fi monitor mode"
#else
#    echo -n -e "${LINE_RESET}"
#    echo -e "${TEXT_FAIL} Failed to enable Wi-Fi monitor mode"
#fi
#
## Enable the Wi-Fi device
#echo -n -e "${TEXT_INFO} Enabling the Wi-Fi device"
#ifconfig wlan0 up &>> ${LOGFILE}
#if [ $? -eq 0 ]; then
#    echo -n -e "${LINE_RESET}"
#    echo -e "${TEXT_SUCC} Enabled the Wi-Fi device"
#else
#    echo -n -e "${LINE_RESET}"
#    echo -e "${TEXT_FAIL} Failed to enable the Wi-Fi device"
#    exit 255
#fi

#################
#################
#################

# Start the Pangio containers
echo -n -e "${TEXT_INFO} Starting the Pangio containers"
docker-compose -f /root/docker-compose.yml up -d &>> ${LOGFILE}
if [ $? -eq 0 ]; then
    echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_SUCC} Started the Pangio containers"
else
    echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_FAIL} Failed to start the Pangio containers"
    exit 255
fi

# Communicate the onion address to the user
echo -e "${TEXT_INFO} Make note of the following onion address! It's how you will SSH into your pangio."
cat /var/lib/tor/ssh/hostname

# Communicate the SSH fingerprint to the user
echo -e "${TEXT_INFO} Make note of the following SSH fingerprint to avoid MitM attacks!"
ssh-keygen -l -f /etc/ssh/ssh_host_ed25519_key.pub

# Synchronize I/O writes
echo -n -e "${TEXT_INFO} Synchronizing I/O writes"
sync &>> ${LOGFILE}
if [ $? -eq 0 ]; then
    echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_SUCC} Synchronized I/O writes"
else
    echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_FAIL} Failed to synchronize I/O writes"
    exit 255
fi
# We're done!
echo -e "${TEXT_SUCC} Pangio installation complete! Please restart your device now."