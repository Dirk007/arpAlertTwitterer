#!/bin/bash

# This script copies the arpAlertTwitterer.py script to /usr/local/bin and then installs a systemd service
# for arpalert which calls the script in order to send Twitter direct messages on arp alert.

twitterPyTargetPath="/usr/local/bin"
twitterPyFilename="arpAlertTwitterer.py"

if [ $(id -u) -ne 0 ]; then
    echo "Please run ${0} as root (sudo)"
    exit 1
fi

existingService=$(systemctl list-units | grep arpalert)
if [ ! -z "${existingService}" ]; then
    echo "WARNING: There seems to be an already running arpalert service! Stopping it."
    systemctl stop arpalert
fi

if [ ! -f "/etc/arpAlertTwitterer.conf" ]; then
    echo "'/etc/arpAlertTwitterer.conf' not found. Please create it (eg from the sample.conf) and try again.";
    exit 1
fi

arpalert="$(which "arpalert")"

if [ -z "${arpalert}" ]; then
    echo "'arpalert' not found. \n
    Please install it with 'sudo apt-get install arpalert'."
    echo -n "Do you want me to execute exactly this now? [y/N]: "
    read -n 1 arpInstallAnswer
    echo ""
    if [ "${arpInstallAnswer}" = 'y' ]; then
        echo "Installing arpalert..."
        apt-get install arpalert
        if [ "${?}" -ne 0 ]; then
            echo "ERROR: Something went wrong while trying to install arpalert."
            echo "Please check the output above, fix whatever is needed and try again."
            echo "Exiting for now."
            exit 1
        fi
    else
        echo "Aborting. Please install arpalert first before trying again."
        exit 1
    fi
else
    echo "arpalert found: '${arpalert}'"
fi

if [ ! -e "${twitterPyTargetPath}" ]; then
    echo "ERROR: I have no access to '${twitterPyTargetPath}'. Something seems to be broken. \
    If you are sure that everything is correct, please modify this script to copy ${twitterPyFilename} to \
    an other location of your choice. You have to modify the 'ExecStart' inside 'arpalert.service' then \
    accordingly (this is hardcoded to '${twitterPyTargetPath}' after installation). Exiting now."
    exit 1
fi

if [ -f "./${twitterPyFilename}" ]; then
    twitterPy="./${twitterPyFilename}"
else
    if [ -f "../${twitterPyFilename}" ]; then
        twitterPy="../${twitterPyFilename}"
    fi
fi

if [ -z "${twitterPy}" ]; then
    echo "ERROR: '${twitterPyFilename}' not found in this or parent directory. Please copy the script to '$(pwd)'"
    exit 1
fi

echo "Copying ${twitterPy} to ${twitterPyTargetPath}"
cp -f ${twitterPy} ${twitterPyTargetPath}

echo "Installing systemd service for arpalert"
# Modify the ExecStart according to the found arpalert
cp -f ./arpalert.service.in ./arpalert.service
mkdir -p /var/arpalert
chown arpalert /var/arpalert
callArguments="-e ${twitterPyTargetPath}/${twitterPyFilename} -l /var/arpalert/leases.dat"
execStart="${arpalert} ${callArguments}"
echo "- Setting ExecStart to ${execStart}"
eval "sed -i -e 's@ExecStart=@ExecStart=${execStart}@g' ./arpalert.service"
cp ./arpalert.service /etc/systemd/system/
systemctl enable arpalert

echo "You can start the arpalert service with 'sudo systemctl start arpalert'"
echo ""
echo "CHECK BEFORE STARTING THE SERVICE:"
echo "Run 'sudo su -c \"${twitterPyTargetPath}/${twitterPyFilename} 1 2 3 4 5 6\" arpalert' to check if \
everything Python-wise is set up correctly."
echo "If getting 'tweepy module not found': Try 'sudo -H pip3 install tweepy'!"
echo "Why you should do: you have not installed tweepy system global but only user wise yet."