
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

before=$(df --output=used / | tail -n1)
# clean up stuff
echo 'Purging snaps'
# get rid of snaps
rm -rf /var/lib/snapd/seed/snaps/*
rm -f /var/lib/snapd/seed/seed.yaml
apt-get purge --yes --quiet lxd-installer lxd-agent-loader
apt-get purge --yes --quiet snapd

# remove bluetooth daemon
apt-get purge --yes --quiet bluez

# apt-get remove -y gdb gcc g++ linux-headers* libgcc*-dev

apt-get --yes --quiet autoremove

after=$(df --output=used / | tail -n1)
freed=$(( before - after ))

echo "Freed up $freed bytes"

# run Photonvision install script
wget https://git.io/JJrEP -O install.sh
chmod +x install.sh

sed -i 's/# AllowedCPUs=4-7/AllowedCPUs=0-7/g' install.sh

./install.sh -n -q
rm install.sh

echo "Installing additional things"

apt-get install --yes --quiet network-manager net-tools libatomic1

# set NetworkManager as the renderer in cloud-init
sed -i '/version: 2/a\ \ renderer: NetworkManager' /boot/network-config
grep 'renderer' /boot/network-config

# set the hostname in cloud-init
sed -i 's/#hostname:.*/hostname: photonvision/' /boot/user-data
grep 'hostname:' /boot/user-data

# add run command to disable cloud-init after first boot
sed -i '$a\\nruncmd:\n- [ touch, /etc/cloud/cloud-init.disabled ]' /boot/user-data
tail /boot/user-data

# tell NetworkManager not to wait for the carrier on ethernet, which can delay boot
# when the coprocessor isn't connected to the ethernet
cat > /etc/NetworkManager/conf.d/50-ignore-carrier.conf <<EOF
[main]
ignore-carrier=*
EOF

# modify photonvision.service to wait for the network before starting
# this helps ensure that photonvision detects the network the first time it starts
sed -i '/Description/aAfter=network-online.target' /etc/systemd/system/photonvision.service
sed -i 's/-n$//' /etc/systemd/system/photonvision.service
cat /etc/systemd/system/photonvision.service

# systemctl disable NetworkManager-wait-online.service
systemctl disable systemd-networkd-wait-online.service

apt-get install --yes --quiet libc6 libstdc++6


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
