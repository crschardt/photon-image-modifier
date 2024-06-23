
# Create pi/raspberry login
if id "$1" >/dev/null 2>&1; then
    echo 'user found'
else
    echo "creating pi user"
    useradd pi -b /home
    usermod -a -G sudo pi
    mkdir /home/pi
    chown -R pi /home/pi
fi
echo "pi:raspberry" | chpasswd

apt-get update
wget https://git.io/JJrEP -O install.sh
chmod +x install.sh

sed -i 's/# AllowedCPUs=4-7/AllowedCPUs=4-7/g' install.sh

./install.sh -m -q
rm install.sh

# Installing addtional things
apt-get install -y network-manager net-tools libatomic1
# mrcal stuff
apt-get install -y libcholmod3 liblapack3 libsuitesparseconfig5
apt-get install -y libc6 libstdc++6

cat > /etc/netplan/00-default-nm-renderer.yaml <<EOF
network:
  renderer: NetworkManager
EOF

# # Remove extra packages 
# echo "Purging extra things"
# apt-get remove -y gdb gcc g++ linux-headers* libgcc*-dev
# apt-get remove -y snapd
# apt-get autoremove -y


# echo "Installing additional things"
# sudo apt-get update
# apt-get install -y network-manager net-tools libatomic1
# # mrcal stuff
# apt-get install -y libcholmod3 liblapack3 libsuitesparseconfig5
# apt-get install -y libc6 libstdc++6

# cat > /etc/netplan/00-default-nm-renderer.yaml <<EOF
# network:
#   renderer: NetworkManager
# EOF

# rm -rf /var/lib/apt/lists/*
# apt-get clean

# rm -rf /usr/share/doc
# rm -rf /usr/share/locale/
