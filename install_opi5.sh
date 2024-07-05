
# Create pi/raspberry login
if id "$1" >/dev/null 2>&1; then
    echo 'user found'
else
    echo "creating pi user"
    useradd pi -m -b /home -s /bin/bash
    usermod -a -G sudo pi
fi
echo "pi:raspberry" | chpasswd

apt-get update --quiet

# clean up stuff
echo 'Purging snaps'
# get rid of snaps
rm -rf /var/lib/snapd/seed/snaps/*
rm -f /var/lib/snapd/seed/seed.yaml
apt-get purge --yes --quiet lxd-installer lxd-agent-loader
apt-get purge --yes --quiet snapd

# remove bluetooth daemon
apt-get purge --yes --quiet bluez

apt-get --yes --quiet autoremove

# run Photonvision install script
wget https://git.io/JJrEP -O install.sh
chmod +x install.sh

sed -i 's/# AllowedCPUs=4-7/AllowedCPUs=0-7/g' install.sh

./install.sh -n -q
rm install.sh


# Remove extra packages 
# echo "Purging extra things"
# apt-get remove -y gdb gcc g++ linux-headers* libgcc*-dev
# apt-get remove -y snapd
# apt-get autoremove -y


echo "Installing additional things"

apt-get install --yes --quiet network-manager net-tools libatomic1

sed -i '/version: 2/a\ \ renderer: NetworkManager' /boot/network-config
grep 'renderer' /boot/network-config

sed -i 's/#hostname:.*/hostname: photonvision/' /boot/user-data
grep 'hostname' /boot/user-data

# systemctl disable NetworkManager-wait-online.service
systemctl disable systemd-networkd-wait-online.service

apt-get install --yes --quiet libc6 libstdc++6

# cat > /etc/netplan/00-default-nm-renderer.yaml <<EOF
# network:
#   renderer: NetworkManager
# EOF

if [ $(cat /etc/lsb-release | grep -c "24.04") -gt 0 ]; then
    # add jammy to apt sources 
    echo "Adding jammy to list of apt sources"
    add-apt-repository -y -S 'deb http://ports.ubuntu.com/ubuntu-ports jammy main universe'
fi

apt-get --quiet update

# mrcal stuff
apt-get install --yes --quiet libcholmod3 liblapack3 libsuitesparseconfig5


rm -rf /var/lib/apt/lists/*
apt-get --yes --quiet autoclean

rm -rf /usr/share/doc
rm -rf /usr/share/locale/
