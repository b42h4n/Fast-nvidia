#!/bin/bash

# a script for installing nvidia drivers, version newer than 550.xx

set -e

if [[ $EUID -ne 0 ]]; then
    echo "Запустите скрипт от root или через sudo"
    exit 1
fi

cat > /etc/apt/sources.list << 'EOF'
deb http://deb.debian.org/debian/ trixie main contrib non-free non-free-firmware
deb-src http://deb.debian.org/debian/ trixie main contrib non-free non-free-firmware

deb http://security.debian.org/debian-security trixie-security main contrib non-free non-free-firmware
deb-src http://security.debian.org/debian-security trixie-security main contrib non-free non-free-firmware

deb http://deb.debian.org/debian/ trixie-updates main contrib non-free non-free-firmware
deb-src http://deb.debian.org/debian/ trixie-updates main contrib non-free non-free-firmware
EOF

apt update
apt upgrade -y
apt install -y linux-headers-$(uname -r) build-essential dkms

dpkg --add-architecture i386
wget https://developer.download.nvidia.com/compute/cuda/repos/debian13/x86_64/cuda-keyring_1.1-1_all.deb
dpkg -i cuda-keyring_1.1-1_all.deb
rm cuda-keyring_1.1-1_all.deb

apt update
apt install -y nvidia-open

# Перезагрузка
read -p "Установка завершена. Перезагрузить сейчас? (y/Y): " reply
if [[ "$reply" == "y" || "$reply" == "Y" ]]; then
    reboot
else
    echo "Ok. Не забудьте перезагрузиться позже."
fi