#!/bin/bash
PASSWORD=`openssl rand -hex 12`
MINIONS="minion1,minion2,minion3,minion4,minion5"
SSHMINIONS="192.168.3.41 192.168.3.42 192.168.3.43 192.168.3.44"
SSHLASTMINION="192.168.3.45"
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

echo "Step 2 - Copy Salt Repository to the minions"
for i in $(echo $SSHMINIONS) ; do sshpass -p "hypriot" scp -o "StrictHostKeyChecking no" /home/pirate/grutower/gru_req/repos/saltstack.list pirate@$i:~ & done
for i in $(echo $SSHLASTMINION) ; do sshpass -p "hypriot" scp -o "StrictHostKeyChecking no" /home/pirate/grutower/gru_req/repos/saltstack.list pirate@$i:~ ; done
for i in $(echo $SSHMINIONS) ; do sshpass -p "hypriot" ssh pirate@$i sudo mv saltstack.list /etc/apt/sources.list.d/ & done
for i in $(echo $SSHLASTMINION) ; do sshpass -p "hypriot" ssh pirate@$i sudo mv saltstack.list /etc/apt/sources.list.d/ ; done
echo ""

echo "Step 3 - Install Salt Minions"
for i in $(echo $SSHMINIONS) ; do sshpass -p "hypriot" ssh pirate@$i "wget -O - https://repo.saltstack.com/apt/debian/8/armhf/latest/SALTSTACK-GPG-KEY.pub | sudo apt-key add - && sudo apt-get update && sudo apt-get install -y salt-minion" & done
for i in $(echo $SSHLASTMINION) ; do sshpass -p "hypriot" ssh pirate@$i "wget -O - https://repo.saltstack.com/apt/debian/8/armhf/latest/SALTSTACK-GPG-KEY.pub | sudo apt-key add - && sudo apt-get update && sudo apt-get install -y salt-minion" ; done
echo ""

echo "Step 4 - Copy initial Salt config file"
for i in $(echo $SSHMINIONS) ; do sshpass -p "hypriot" scp /home/pirate/grutower/gru_req/configs/minion pirate@$i:~ & done
for i in $(echo $SSHLASTMINION) ; do sshpass -p "hypriot" scp /home/pirate/grutower/gru_req/configs/minion pirate@$i:~ ; done
for i in $(echo $SSHMINIONS) ; do sshpass -p "hypriot" ssh pirate@$i sudo mv minion /etc/salt/ & done
for i in $(echo $SSHLASTMINION) ; do sshpass -p "hypriot" ssh pirate@$i sudo mv minion /etc/salt/ ; done
echo ""

echo "Step 5 - Restart Salt minion process"
for i in $(echo $SSHMINIONS) ; do sshpass -p "hypriot" ssh pirate@$i sudo systemctl restart salt-minion & done
for i in $(echo $SSHLASTMINION) ; do sshpass -p "hypriot" ssh pirate@$i sudo systemctl restart salt-minion ; done
echo ""

echo "Step 6 - Sleep for 20 seconds"
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
echo "Done sleeping let's see if we have some Minios want to meet Gru"
echo ""

echo "Step 7 - Add all Salt Minion keys to the Master"
salt-key -y -A
echo ""

echo "Step 8 - Deploy default configuration files"
salt -L $MINIONS state.apply $CONFIGS
echo ""

echo "Step 9 - Change Pirate password"
salt -L $MINIONS cmd.run "echo pirate:$PASSWORD | chpasswd"
echo pirate:$PASSWORD | chpasswd
echo ""

echo "Step 10 - Set timezone to Europe/Amsterdam"
salt -L $MINIONS cmd.run "timedatectl set-timezone Europe/Amsterdam"
salt -L $MINIONS cmd.run "timedatectl"
echo ""

echo "Step 11 - Updating Minions"
salt -L $MINIONS cmd.run "apt-get update && apt-get -y upgrade"
echo ""

echo "Step 12 - Reboot Minions"
salt -L $MINIONS cmd.run "reboot"
echo ""
echo "The No Response message is the one we expecting, because of the boot of the Minions"
echo ""

echo "Step 13 - Sleep for 20 seconds"
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

echo "Step 14 - See if the Minions are back"
salt-run manage.status
echo ""

echo "Step 15 - Installing Kubernetes on the Minions"
salt -L $MINIONS cmd.run "curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -"
salt -L $MINIONS cmd.run "apt-get update && apt-get install -y kubeadm"
echo ""

# maikel echo "Step 16 - Initiating Kubernetes cluster on Gru"
# maikel kubeadm init --pod-network-cidr=10.244.0.0/16
# maikel cp /etc/kubernetes/admin.conf /home/pirate/
# maikel sudo chown $(id -u pirate):$(id -g pirate) /home/pirate/admin.conf
# maikel echo "KUBECONFIG=$HOME/admin.conf >> ~/.profile"
# maikel echo ""

# maikel echo "Step 17 - Let the Minion join the cluster"
# maikel KUBETOKEN=`sudo kubeadm token list | tail -n1 | awk '{print $1}'`
# maikel salt -L $MINIONS cmd.run "kubeadm join --token $KUBETOKEN gru:6443"

# maikel echo "Step 18 - Sleep for 20 seconds"
# maikel sleep 10
# maikel echo "10 Seconds remaining"
# maikel sleep 5
# maikel echo "5 Seconds remaining"
# maikel sleep 1
# maikel echo "4 Seconds remaining"
# maikel sleep 1
# maikel echo "3 Seconds remaining"
# maikel sleep 1
# maikel echo "2 Seconds remaining"
# maikel sleep 1
# maikel echo "1 Second remaining"
# maikel sleep 1
# maikel echo ""
# maikel echo "Done sleeping let's see if there was some magic"
# maikel echo ""

# maikel echo "Step 19 - See if the Minions joined the Gru Tower"
# maikel KUBECONFIG=$HOME/admin.conf
# maikel kubectl get nodes 
# maikel echo ""
# maikel echo "It's OK if the status is Not Ready, they will be later"
# maikel echo ""

# maikel echo "Step 20 - Install Flannel RBAC Profile"
# maikel kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel-rbac.yml

# maikel echo "Step 21 - Install Flannel as pod network"
# maikel curl -sSL https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml | sed "s/amd64/arm/g" | kubectl create -f -

# maikel echo "Step 22 - Change IPTABLES Rules on the Minions"
# maikel salt -L $MINIONS cmd.run  "iptables -A FORWARD -i cni0 -j ACCEPT"
# maikel salt -L $MINIONS cmd.run  "iptables -A FORWARD -o cni0 -j ACCEPT"

# maikel echo 'Provisioning ready - It can take a couple of minutes to settle down, just check the command: "kubectl get po --all-namespaces" a few times'
echo "The default password for user pirate changed on Gru and the Minions to $PASSWORD, write this down!"
echo ""
exit 0
