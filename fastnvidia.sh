#!/bin/bash

# a script for installing nvidia drivers, version newer than 550.xx

set -e
if [[ $EUID -ne 0 ]]; then
    echo "Error: Run script as root or use sudo ./fastnvidia.sh"
    exit 1
fi

echo -e "System? \n 1)Debian \n 2)Arch Linux \n 3)Void Linux"
read system
if [[ "$system" == 1 ]]; then

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

read -r -p "Installed succesful. Reboot now? (y/N): " reply
if [[ "$reply" == "y" || "$reply" == "Y" ]]; then
    reboot
else
    echo "Ok. Dont forget to reboot system!"
fi
elif [[ "$system" == 2 ]]; then
pacman -Syyu --noconfirm
if ! grep -q "^\[multilib\]" /etc/pacman.conf; then
    sed -i '/^#\[multilib\]/,/^#Include/ s/^#//' /etc/pacman.conf
fi
pacman -S --needed --noconfirm nvidia-dkms nvidia-utils lib32-nvidia-utils nvidia-settings linux-headers
echo "options nvidia-drm modeset=1" > /etc/modprobe.d/nvidia.conf
if ! grep -q "nvidia nvidia_modeset nvidia_uvm nvidia_drm" /etc/mkinitcpio.conf; then
sed -i 's/^MODULES=(/MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm /' /etc/mkinitcpio.conf
fi
mkinitcpio -P
read -r -p "Installed succesful. Reboot now? (y/N): " reply
if [[ "$reply" == "y" || "$reply" == "Y" ]]; then
    reboot
else
    echo "Ok. Dont forget to reboot system!"
fi
elif [[ "$system" == 3 ]]; then
    xbps-install -Syu xbps
    xbps-install -Syu
    xbps-install -Sy void-repo-nonfree void-repo-multilib void-repo-multilib-nonfree
    xbps-install -Syu
    xbps-install -y linux-headers dkms nvidia nvidia-dkms nvidia-libs-32bit
    echo "options nvidia-drm modeset=1" > /etc/modprobe.d/nvidia.conf
    echo "blacklist nouveau" > /etc/modprobe.d/blacklist-nouveau.conf
    echo "options nouveau modeset=0" >> /etc/modprobe.d/blacklist-nouveau.conf
    xbps-reconfigure -fa

    read -r -p "Installed succesful. Reboot now? (y/N): " reply
    if [[ "$reply" == "y" || "$reply" == "Y" ]]; then
        reboot
    else
        echo "Ok. Dont forget to reboot system!"
    fi
fi

