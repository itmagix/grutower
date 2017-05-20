#!/bin/bash
PASSWORD=`openssl rand -hex 12`
MINIONS="minion1,minion2,minion3,minion4,minion5"
SSHMINIONS="minion1 minion2 minion3 minion4 minion5"
CONFIGS="profiles,repos,system,minion"

echo "Step 1 - Check for Root rights"
if [ $EUID -ne 0 ]; then
   echo ""
   echo "This script must be run as root" 1>&2
   echo ""
   exit 1
else
   echo ""
   echo "We are ruling the world! Continue!"
   echo ""
fi
echo ""

echo "Step 2 - Copy Salt Repository to the minions"
for i in $SSHMININOS ; do scp ~/repos/saltstack.list $i ; done
for i in $SSHMINIONS ; do ssh $i sudo mv saltstack.list /etc/apt/sources.list.d/ ; done

echo "Step 3 - Install Salt Minions"
for i in $SSHMINIONS ; do ssh $i sudo apt-get update && sudo apt-get install -y salt-minion ; done

echo "Step 4 - Copy initial Salt config file"
for i in $SSHMINIONS ; do scp ~/configs/minion $i:/etc/salt/ ; done

echo "Step 5 - Restart Salt minion process"
for i in $SSHMINIONS ; do ssh $i systemctl restart salt-minion ; done

echo "Step 6 - Add all Salt Minion keys to the Master"
salt-key -y -A
echo ""

echo "Step 7 - Deploy default configuration files"
salt -L $MINIONS state.apply $CONFIGS
echo ""

echo "Step 8 - Change Pirate password"
salt -L $MINIONS cmd.run "echo pirate:$PASSWORD | chpasswd"
echo "changed Password to $PASSWORD"
echo ""

echo "Step 9 - Set timezone to Europe/Amsterdam"
salt -L $MINIONS cmd.run "timedatectl set-timezone Europe/Amsterdam"
salt -L $MINIONS cmd.run "timedatectl"
echo ""

echo "Step 10 - Updating Minions"
salt -L $MINIONS cmd.run "apt-get update && apt-get -y upgrade"
echo ""

echo "Step 11 - Reboot Minions"
salt -L $MINIONS cmd.run "reboot"
echo ""
echo "The No Response message is the one we expecting, because of the boot of the Minions"
echo ""

echo "Step 12 - Sleep for 20 seconds"
sleep 10
echo "10 Seconds remaining"
sleep 5
echo "5 Seconds remaining"
sleep 1
echo "4 Seconds remaining"
sleep 1
echo "3 Seconds remaining"
sleep 1
echo "2 Seconds remaining"
sleep 1
echo "1 Second remaining"
sleep 1
echo ""
echo "Done sleeping let's see if Kevin, Dave, Stuart, Jon and the rest is back"
echo ""

echo "Step 13 - See if the Minions are back"
salt-run manage.status
echo ""

echo "Step 14 - Installing Kubernetes on the Minions"
salt -L $MINIONS cmd.run "curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -"
salt -L $MINIONS cmd.run "apt-get update && apt-get install -y kubeadm"
echo ""
echo "Provisioning ready"

exit 0
