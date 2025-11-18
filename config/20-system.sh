# shellcheck disable=2154

# OS

## Arch Linux
AddPackage base # Minimal package set to define a basic Arch Linux installation
AddPackage base-devel # Basic tools to build Arch Linux packages
AddPackage linux # The Linux kernel and modules
AddPackage linux-firmware # Firmware files for Linux - Default set

## AUR
#TODO
AddPackage --foreign aura # A package manager for Arch Linux and its AUR

## Boot
CopyFileTo "/etc/fstab.$hostname" /etc/fstab
CopyFileTo "/boot/loader/entries/arch.$hostname.conf" /boot/loader/entries/arch.conf 755
CopyFile /boot/loader/loader.conf 755

## Locale
CopyFile /etc/locale.conf
CopyFile /etc/locale.gen

## Console
AddPackage terminus-font # Monospace bitmap font (for X11 and console)
CopyFile /etc/vconsole.conf

## VirtualBox Guest
if [ "$is_virtualbox" = true ]; then
  AddPackage virtualbox-guest-utils # VirtualBox Guest userspace utilities
  SystemdEnable vboxservice
fi

# sudo
AddPackage sudo # Give certain users the ability to run some commands as root
CopyFile /etc/sudoers

# Network

CopyFile /etc/systemd/network/10-dhcp.network
SystemdEnable systemd-networkd
SystemdEnable systemd-resolved

# Services

# SSH
AddPackage openssh # SSH protocol implementation for remote login, command execution and file transfer
SystemdEnable sshd
CopyFile /etc/ssh/sshd_config

# Reflector
#TODO
AddPackage reflector # A Python 3 module and script to retrieve and filter the latest Pacman mirror list.
SystemdEnable reflector

# Tools

AddPackage inetutils # A collection of common network programs
AddPackage less # A terminal based program for viewing text files
AddPackage man-db # A utility for reading man pages
AddPackage efivar # Tools and libraries to work with EFI variables
