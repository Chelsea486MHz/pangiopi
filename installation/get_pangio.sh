#!/bin/bash

cat pangio_banner.txt

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

#################
#################
#################

# Install the required packages
echo -n -e "${TEXT_INFO} Running apt-update"
sudo apt-get update -y 2>&1 ${LOGFILE} 
if [ $? -eq 0 ]; then
	echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_INFO} Updated the package list"
else
	echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_FAIL} Failed to update the package list"
    exit 255
fi

# Remove existing Docker packages
echo -n -e "${TEXT_INFO} Removing existing Docker packages"
for pkg in ${docker_pkg_to_remove}; do
    sudo apt-get remove $pkg -y
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
sudo install -m 0755 -d /etc/apt/keyrings 2>&1 ${LOGFILE}

echo -n -e "${TEXT_INFO} Adding the official Docker PGP key"
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc 2>&1 ${LOGFILE}
if [ $? -eq 0 ]; then
	echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_SUCC} Added the official Docker PGP key"
else
	echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_FAIL} Failed to add the official Docker PGP key"
    exit 255
fi

echo -n -e "${TEXT_INFO} Setting correct key permissions"
sudo chmod a+r /etc/apt/keyrings/docker.asc 2>&1 ${LOGFILE}
if [ $? -eq 0 ]; then
	echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_SUCC} Set correct key permissions"
else
	echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_FAIL} Failed to set correct key permissions"
    exit 255
fi

# Add the Docker repo
echo -e "${TEXT_INFO} Adding the Docker repository"
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
echo -e "${TEXT_SUCC} Added the Docker repository"

# Run apt-update again
echo -n -e "${TEXT_INFO} Running apt-update"
sudo apt-get update -y 2>&1 ${LOGFILE}
if [ $? -eq 0 ]; then
	echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_SUCC} Updated the package list"
else
	echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_FAIL} Failed to update the package list"
    exit 255
fi

# Install Docker
echo -n -e "${TEXT_INFO} Installing Docker"
sudo apt-get install ${docker_pkg_to_install} -y 2>&1 ${LOGFILE}
if [ $? -eq 0 ]; then
	echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_SUCC} Installed Docker"
else
	echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_FAIL} Failed to install Docker"
    exit 255
fi

#################
#################
#################

# Stop hardware RNG
echo -n -e "${TEXT_INFO} Stopping hardware RNG"
sudo systemctl stop rng-tools 2>&1 ${LOGFILE}
if [ $? -eq 0 ]; then
	echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_SUCC} Stopped hardware RNG"
else
	echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_FAIL} Failed to stop hardware RNG"
    exit 255
fi

# Stop pppd
echo -n -e "${TEXT_INFO} Stopping pppd"
sudo systemctl stop ppphat.service 2>&1 ${LOGFILE}
if [ $? -eq 0 ]; then
	echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_SUCC} Stopped pppd"
else
	echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_FAIL} Failed to stop pppd"
    exit 255
fi

# Stop SSH
echo -n -e "${TEXT_INFO} Stopping SSH"
sudo systemctl stop ssh 2>&1 ${LOGFILE}
if [ $? -eq 0 ]; then
	echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_SUCC} Stopped SSH"
else
	echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_FAIL} Failed to stop SSH"
    exit 255
fi

# Stop Docker
echo -n -e "${TEXT_INFO} Stopping Docker"
sudo systemctl stop docker 2>&1 ${LOGFILE}
if [ $? -eq 0 ]; then
	echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_SUCC} Stopped Docker"
else
	echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_FAIL} Failed to stop Docker"
    exit 255
fi

# Stop Tor
echo -n -e "${TEXT_INFO} Stopping the Tor SOCKS5 proxy"
sudo systemctl stop
if [ $? -eq 0 ]; then
	echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_SUCC} Stopped the Tor SOCKS5 proxy"
else
	echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_FAIL} Failed to stop the Tor SOCKS5 proxy"
    exit 255
fi

#################
#################
#################

# Create Docker group
echo -n -e "${TEXT_INFO} Creating Docker group"
sudo groupadd docker 2>&1 ${LOGFILE}
if [ $? -eq 0 ]; then
	echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_SUCC} Created Docker group"
else
	echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_FAIL} Failed to create Docker group"
    exit 255
fi

# Add current user to Docker group
echo -n -e "${TEXT_INFO} Adding current user to Docker group"
sudo usermod -aG docker $USER 2>&1 ${LOGFILE}
if [ $? -eq 0 ]; then
	echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_SUCC} Added current user to Docker group"
else
	echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_FAIL} Failed to add current user to Docker group"
    exit 255
fi

# Configure rng-tools
echo -n -e "${TEXT_INFO} Configuring hardware RNG"
sudo sed -i 's/#HRNGDEVICE/HRNGDEVICE/g' /etc/default/rng-tools-debian 2>&1 ${LOGFILE}
if [ $? -eq 0 ]; then
	echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_SUCC} Configured hardware RNG"
else
	echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_FAIL} Failed to configure hardware RNG"
    exit 255
fi

# Configure dial-up connection
echo -n -e "${TEXT_INFO} Configuring dial-up connection"
sudo cp gprs_peer.txt /etc/ppp/peers/gprs 2>&1 ${LOGFILE}
if [ $? -eq 0 ]; then
	echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_SUCC} Configured dial-up connection"
else
	echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_FAIL} Failed to configure dial-up connection"
    exit 255
fi

# Create a systemd unit
echo -n -e "${TEXT_INFO} Creating systemd unit for pppd"
sudo cp ppphat.service /etc/systemd/system/ppphat.service 2>&1 ${LOGFILE}
if [ $? -eq 0 ]; then
	echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_SUCC} Created systemd unit for pppd"
else
	echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_FAIL} Failed to create systemd unit for pppd"
    exit 255
fi

# Configure the Tor proxy
echo -n -e "${TEXT_INFO} Installing Tor SOCKS5 proxy configuration"
sudo cp torrc /etc/tor/torrc 2>&1 ${LOGFILE}
if [ $? -eq 0 ]; then
	echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_SUCC} Installed the Tor SOCKS5 proxy configuration"
else
	echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_FAIL} Failed to install the Tor SOCKS5 proxy configuration"
    exit 255
fi

# Install our sshd_config file
echo -n -e "${TEXT_INFO} Installing SSH server configuration"
sudo cp sshd_config /etc/ssh/sshd_config 2>&1 ${LOGFILE}
if [ $? -eq 0 ]; then
    echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_SUCC} Installed SSH server configuration"
else
    echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_FAIL} Failed to install SSH server configuration"
    exit 255
fi

# Generate a robust SSH host key
echo -e "${TEXT_INFO} Generating SSH host key"
ssh-keygen -a 128 -t ed25519 -f /etc/ssh/ssh_host_ed25519_key
if [ $? -eq 0 ]; then
    echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_SUCC} Generated SSH host key"
else
    echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_FAIL} Failed to generate SSH host key"
    exit 255
fi

#################
#################
#################

# Reload systemd
echo -n -e "${TEXT_INFO} Reloading systemd"
sudo systemctl daemon-reload 2>&1 ${LOGFILE}
if [ $? -eq 0 ]; then
	echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_SUCC} Reloaded systemd"
else
	echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_FAIL} Failed to reload systemd"
    exit 255
fi

# Enable and start hardware RNG
echo -n -e "${TEXT_INFO} Restarting hardware RNG"
sudo systemctl enable --now rng-tools 2>&1 ${LOGFILE}
if [ $? -eq 0 ]; then
	echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_SUCC} Restarted hardware RNG"
else
	echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_FAIL} Failed to restart hardware RNG"
    exit 255
fi

# Enable and start pppd
echo -e "${TEXT_INFO} Enabling and starting pppd"
sudo systemctl enable --now ppphat.service 2>&1 ${LOGFILE}
if [ $? -eq 0 ]; then
    echo -e "${TEXT_SUCC} Enabled and started pppd"
else
    echo -e "${TEXT_FAIL} Failed to enable and start pppd"
    exit 255
fi

# Enable and start SSH
echo -n -e "${TEXT_INFO} Enabling and starting SSH"
sudo systemctl enable --now ssh 2>&1 ${LOGFILE}
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
sudo systemctl enable --now docker 2>&1 ${LOGFILE}
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
sudo systemctl enable --now tor@default.service 2>&1 ${LOGFILE}
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

# Create the Pangio user
echo -n -e "${TEXT_INFO} Creating the Pangio user"
sudo useradd -m pangio 2>&1 ${LOGFILE}
if [ $? -eq 0 ]; then
	echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_SUCC} Created the Pangio user"
else
	echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_FAIL} Failed to create the Pangio user"
    exit 255
fi

# Create a venv for pangio
echo -n -e "${TEXT_INFO} Creating a venv for pangio"
sudo -u pangio python3 -m venv /home/pangio/venv 2>&1 ${LOGFILE}
if [ $? -eq 0 ]; then
    echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_SUCC} Created a venv for pangio"
else
    echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_FAIL} Failed to create a venv for pangio"
    exit 255
fi

# Install gnupg in the venv
echo -n -e "${TEXT_INFO} Installing gnupg in the venv"
sudo -u pangio /home/pangio/venv/bin/pip install gnupg 2>&1 ${LOGFILE}
if [ $? -eq 0 ]; then
    echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_SUCC} Installed gnupg in the venv"
else
    echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_FAIL} Failed to install gnupg in the venv"
    exit 255
fi

# Create the Pangio user PGP key
# We're using a python script to do it, because in all honesty
# the GPG cli is a pain in the ass
echo -n -e "${TEXT_INFO} Creating the Pangio user PGP key"
cp init_pgp.py /home/pangio/init_pgp.py
chown pangio:pangio /home/pangio/init_pgp.py
sudo -u pangio -c 'python3 /home/pangio/init_pgp.py' 2>&1 ${LOGFILE}
if [ $? -eq 0 ]; then
    echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_SUCC} Created the Pangio user PGP key"
else
    echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_FAIL} Failed to create the Pangio user PGP key"
    exit 255
fi

# Remove the script
echo -n -e "${TEXT_INFO} Removing the script"
rm /home/pangio/init_pgp.py 2>&1 ${LOGFILE}
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
sudo -u pangio rm -rf /home/pangio/venv 2>&1 ${LOGFILE}
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

# Copy the Pangio files to the Pangio user's home directory
echo -n -e "${TEXT_INFO} Copying the Pangio files to the Pangio user's home directory"
cp -r ../ingest /home/pangio/ingest 2>&1 ${LOGFILE}
cp -r ../sender /home/pangio/sender 2>&1 ${LOGFILE}
cp -r ../listener /home/pangio/listener 2>&1 ${LOGFILE}
cp ../.env.example /home/pangio/.env 2>&1 ${LOGFILE}
cp ../docker-compose.yml /home/pangio/docker-compose.yml 2>&1 ${LOGFILE}
echo -e "${TEXT_SUCC} Copied the Pangio files to the Pangio user's home directory"

# Prompt the user for their phone number. Retry until a valid number is entered.
echo -n -e "${TEXT_INFO} Enter the phone number you'll exfiltrate to: "
read phone_number
while ! [[ $phone_number =~ ^\+[0-9]{11}$ ]]; do
    echo -n -e "${TEXT_FAIL} Invalid phone number"
    read phone_number
done

# Replace the placeholder phone number in the .env file with the user's phone number
echo -n -e "${TEXT_INFO} Setting exfiltration number"
sed -i "s/PANGIO_GSM_REMOTE_NUMBER=\"\+33613121337\"/PANGIO_GSM_REMOTE_NUMBER=\"$phone_number\"/g" /home/pangio/.env 2>&1 ${LOGFILE}
echo -e "${TEXT_SUCC} Exfiltration number set"

# Set the MariaDB password
MARIADB_PASSWORD=$(python3 -c 'import secrets; print(secrets.token_urlsafe(32))')
echo -n -e "${TEXT_INFO} Setting MariaDB password"
sed -i "s/PANGIO_DB_PASSWORD=\"changeme\"/PANGIO_DB_PASSWORD=\"$MARIADB_PASSWORD\"/g" /home/pangio/.env 2>&1 ${LOGFILE}
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
sed -i "s/PANGIO_DB_PASSWORD_ROOT=\"changemetoo\"/PANGIO_DB_PASSWORD_ROOT=\"$MARIADB_ROOT_PASSWORD\"/g" /home/pangio/.env 2>&1 ${LOGFILE}
if [ $? -eq 0 ]; then
    echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_SUCC} Set MariaDB root password"
else
    echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_FAIL} Failed to set MariaDB root password"
    exit 255
fi

# Kill the Wi-Fi link
echo -n -e "${TEXT_INFO} Killing the Wi-Fi link"
sudo ifconfig wlan0 down 2>&1 ${LOGFILE}
if [ $? -eq 0 ]; then
    echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_SUCC} Killed the Wi-Fi link"
else
    echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_FAIL} Failed to kill the Wi-Fi link"
    exit 255
fi

# Set Wi-Fi monitor mode
echo -n -e "${TEXT_INFO} Enabling Wi-Fi monitor mode"
sudo iwconfig wlan0 mode monitor 2>&1 ${LOGFILE}
if [ $? -eq 0 ]; then
    echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_SUCC} Enabled Wi-Fi monitor mode"
else
    echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_FAIL} Failed to enable Wi-Fi monitor mode"
    exit 255
fi

# Enable the Wi-Fi device
echo -n -e "${TEXT_INFO} Enabling the Wi-Fi device"
sudo ifconfig wlan0 up 2>&1 ${LOGFILE}
if [ $? -eq 0 ]; then
    echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_SUCC} Enabled the Wi-Fi device"
else
    echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_FAIL} Failed to enable the Wi-Fi device"
    exit 255
fi

#################
#################
#################

# Start the Pangio containers
echo -n -e "${TEXT_INFO} Starting the Pangio containers"
sudo -u pangio docker-compose -f /home/pangio/docker-compose.yml up -d 2>&1 ${LOGFILE}
if [ $? -eq 0 ]; then
    echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_SUCC} Started the Pangio containers"
else
    echo -n -e "${LINE_RESET}"
    echo -e "${TEXT_FAIL} Failed to start the Pangio containers"
    exit 255
fi

# Communicate the onion address and auth cookie to the user
echo -e "${TEXT_INFO} Make note of the following onion address and auth cookie!"
cat /var/lib/tor/ssh/hostname

# Communicate the SSH fingerprint to the user
echo -e "${TEXT_INFO} Make note of the following SSH fingerprint!"
ssh-keygen -l -f /etc/ssh/ssh_host_ed25519_key.pub

# We're done!
echo -e "${TEXT_SUCC} Pangio nstallation complete!"