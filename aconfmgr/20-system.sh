# shellcheck disable=2154

# Platform

AddPackage base # Minimal package set to define a basic Arch Linux installation
AddPackage base-devel # Basic tools to build Arch Linux packages
AddPackage linux # The Linux kernel and modules
AddPackage linux-firmware # Firmware files for Linux - Default set
AddPackage efivar # Tools and libraries to work with EFI variables
AddPackage sudo # Give certain users the ability to run some commands as root

if [ "$is_virtualbox" = true ]; then
  AddPackage virtualbox-guest-utils # VirtualBox Guest userspace utilities
fi

SystemdEnable systemd-networkd
SystemdEnable systemd-resolved
SystemdEnable sshd

# Configuration

AddPackage reflector # A Python 3 module and script to retrieve and filter the latest Pacman mirror list.
AddPackage --foreign aconfmgr-git # A configuration manager for Arch Linux
AddPackage --foreign aura # A package manager for Arch Linux and its AUR
AddPackage --foreign aura-debug # Detached debugging symbols for aura

# Services
AddPackage openssh # SSH protocol implementation for remote login, command execution and file transfer
