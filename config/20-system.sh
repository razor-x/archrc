# shellcheck disable=2154

# OS

## Arch Linux
AddPackage base # Minimal package set to define a basic Arch Linux installation
AddPackage base-devel # Basic tools to build Arch Linux packages
AddPackage linux # The Linux kernel and modules
AddPackage linux-firmware # Firmware files for Linux - Default set
AddPackage linux-headers # Headers and scripts for building modules for the Linux kernel

## Boot
CopyFileTo "/etc/fstab.$hostname" /etc/fstab
CopyFileTo "/boot/loader/entries/arch.$hostname.conf" /boot/loader/entries/arch.conf 755
CopyFile /boot/loader/loader.conf 755

## Locale
CopyFile /etc/locale.conf
CopyFile /etc/locale.gen

## Time
SystemdEnable systemd-timesyncd

## Console
AddPackage terminus-font # Monospace bitmap font (for X11 and console)
AddPackage foot-terminfo # Extra non-standard terminfo files for foot, a Wayland terminal emulator
AddPackage ghostty-terminfo # Terminfo for ghostty
AddPackage kitty-terminfo # Terminfo for kitty, an OpenGL-based terminal emulator
CopyFile /etc/vconsole.conf

## Network
CopyFile /etc/systemd/network/10-dhcp.network
SystemdEnable systemd-networkd

## Wi-Fi
if "$has_wifi"; then
  AddPackage iwd # Internet Wireless Daemon
fi

## DNS
CopyFile /etc/systemd/resolved.conf.d/99-fallback.conf
CreateLink /etc/resolv.conf ../run/systemd/resolve/stub-resolv.conf
SystemdEnable systemd-resolved

## VirtualBox
if "$is_virtualbox"; then
  AddPackage virtualbox-guest-utils # VirtualBox Guest userspace utilities
  SystemdEnable vboxservice
else
  AddPackage virtualbox # Powerful x86 virtualization for enterprise as well as home use
  AddPackage virtualbox-host-modules-arch # Virtualbox host kernel modules for Arch Kernel
   virtualbox
fi

# Packages

## paccache
AddPackage pacman-contrib # Contributed scripts and tools for pacman systems
SystemdEnable paccache.timer

## Reflector
AddPackage reflector # A Python 3 module and script to retrieve and filter the latest Pacman mirror list.
CopyFile /etc/xdg/reflector/reflector.conf
SystemdEnable reflector

## Aura
AddPackage --foreign aura # A package manager for Arch Linux and its AUR
sed -i \
  "/OPTIONS=/s/ debug / !debug /" \
  "$(GetPackageOriginalFile pacman /etc/makepkg.conf)" # Disable debug packages

# Security

## sudo
AddPackage sudo # Give certain users the ability to run some commands as root
CopyFile /etc/sudoers

## PAM
CopyFile /etc/security/faillock.conf
CopyFile /etc/security/pam_env.conf

## nftables
AddPackage nftables # Netfilter tables userspace tools
CopyFile /etc/nftables.conf
SystemdEnable nftables

## SSH
AddPackage openssh # SSH protocol implementation for remote login, command execution and file transfer
SystemdEnable sshd
CopyFile /etc/ssh/sshd_config

# Performance

## inotify
CopyFile /etc/sysctl.d/99-inotify.conf

## journald
CopyFile /etc/systemd/journald.conf.d/99-size.conf

## OOM
SystemdEnable systemd-oomd
