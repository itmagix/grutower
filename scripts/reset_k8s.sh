#!/bin/bash
if [ $EUID -ne 0 ]; then
   echo ""
   echo "This script must be run as root" 1>&2
   exit 1
else
   echo ""
   echo "We are ruling the world! Continue!"
fi
echo ""
salt '*' cmd.run "kubeadm reset"
for i in `docker images -q` ; do docker rmi $i ; done
