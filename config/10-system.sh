# shellcheck disable=2154

# OS

## Arch Linux
AddPackage base # Minimal package set to define a basic Arch Linux installation
AddPackage base-devel # Basic tools to build Arch Linux packages
AddPackage linux # The Linux kernel and modules
AddPackage linux-firmware # Firmware files for Linux - Default set

## Pacman
AddPackage pacman-contrib # Contributed scripts and tools for pacman systems
SystemdEnable paccache.timer

## AUR
AddPackage --foreign aura # A package manager for Arch Linux and its AUR
sed -i \
  "/OPTIONS=/s/ debug / !debug /" \
  "$(GetPackageOriginalFile pacman /etc/makepkg.conf)" # Disable debug packages

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

## VirtualBox
if [ "$is_virtualbox" = true ]; then
  AddPackage virtualbox-guest-utils # VirtualBox Guest userspace utilities
  SystemdEnable vboxservice
else
  AddPackage virtualbox # Powerful x86 virtualization for enterprise as well as home use
  AddPackage virtualbox-host-modules-arch # Virtualbox host kernel modules for Arch Kernel
   virtualbox
fi

# Security

## sudo
AddPackage sudo # Give certain users the ability to run some commands as root
CopyFile /etc/sudoers

## PAM
CopyFile /etc/security/faillock.conf

## nftables
CopyFile /etc/nftables.conf
SystemdEnable nftables

# Performance

CopyFile /etc/sysctl.d/99-inotify.conf
CopyFile /etc/systemd/journald.conf.d/99-size.conf

# Network

CopyFile /etc/systemd/network/10-dhcp.network
SystemdEnable systemd-networkd

CopyFile /etc/systemd/resolved.conf.d/99-fallback.conf
SystemdEnable systemd-resolved

# Services

# NTP
SystemdEnable systemd-timesyncd

# SSH
AddPackage openssh # SSH protocol implementation for remote login, command execution and file transfer
SystemdEnable sshd
CopyFile /etc/ssh/sshd_config

# Reflector
AddPackage reflector # A Python 3 module and script to retrieve and filter the latest Pacman mirror list.
CopyFile /etc/xdg/reflector/reflector.conf
SystemdEnable reflector

# Tools

AddPackage inetutils # A collection of common network programs
AddPackage less # A terminal based program for viewing text files
AddPackage man-db # A utility for reading man pages
AddPackage efivar # Tools and libraries to work with EFI variables
AddPackage dnssec-tools # libval & dnssec management tools
