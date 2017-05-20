#!/bin/bash
set +x
set -e

# Make sure only root can run our script
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root"
   echo "Usage: sudo $0" 1>&2
   exit 1
fi

echo ""
echo "Installing basic X11 packages on HypriotOS"

# --------------------------------------------------------------------
echo ""
echo " STEP 1: Rotate screen for 7 inch Touch Screen "
CONFIG_TXT_FILE=/boot/config.txt
echo display_rotate=2 >> $CONFIG_TXT_FILE
cat ${CONFIG_TXT_FILE}
echo "...done"


# --------------------------------------------------------------------
echo ""
echo " STEP 2: install X11 and LightDM"
apt-get update
apt-get install -y --no-install-recommends xserver-xorg xinit xserver-xorg-video-fbdev lxde lxde-common lightdm x11-xserver-utils
apt-get install -y policykit-1 hal
echo "...done"


# --------------------------------------------------------------------
echo ""
echo " STEP 3: enable LightDM autologin for user=pirate"
LIGHTDM_CONF_FILE=/etc/lightdm/lightdm.conf
if [ ! -f ${LIGHTDM_CONF_FILE}.sav ]; then
  # backup original file
  mv ${LIGHTDM_CONF_FILE} ${LIGHTDM_CONF_FILE}.sav

cat << EOF | tee ${LIGHTDM_CONF_FILE} >/dev/null
[SeatDefaults]
autologin-user=pirate
autologin-user-timeout=0
EOF

fi
cat ${LIGHTDM_CONF_FILE}
echo "...done"


# --------------------------------------------------------------------
echo ""
echo " STEP 4: Installing tools to compile stuff"
apt-get install -y git build-essential xorg-dev xutils-dev x11proto-dri2-dev
apt-get install -y libltdl-dev libtool automake libdrm-dev


# --------------------------------------------------------------------
echo ""
# not working echo " STEP 5: install pre-compiled fbturbo"
echo " STEP 5: Compiling fbturbo"
# not working FBTURBO_TAR_URL=https://github.com/hypriot/x11-on-HypriotOS/raw/master/fbturbo/fbturbo.tar.gz
# not working FBTURBO_TAR_TMPFILE=/tmp/fbturbo.tar.gz
# not working wget -O ${FBTURBO_TAR_TMPFILE} ${FBTURBO_TAR_URL}
# not working tar xvf ${FBTURBO_TAR_TMPFILE} -C /
# not working rm -f ${FBTURBO_TAR_TMPFILE}
git clone https://github.com/ssvb/xf86-video-fbturbo.git
cd xf86-video-fbturbo
autoreconf -vi
./configure --prefix=/usr
make
make install
cp xorg.conf /etc/X11/xorg.conf
echo "...done"


# --------------------------------------------------------------------
echo ""
echo " STEP 6: Remove tools to compile stuff"
apt-get remove -y git build-essential xorg-dev xutils-dev x11proto-dri2-dev
apt-get remove -y libltdl-dev libtool automake libdrm-dev
echo "...done"


# --------------------------------------------------------------------
echo ""
echo " STEP 7: Installing Chromium web browser"
# --------------------------------------------------------------------
echo ""
apt-get install -y chromium-browser
echo "...done"


echo "...X11 installation done, please reboot"
