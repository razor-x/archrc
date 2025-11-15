#!/usr/bin/env bash

# shellcheck disable=SC2064,SC2086

set -e
set -u

puts () {
  echo "-- [${2:-}] ${1:-}"
}

set_hostname () {
  hostname="${1:-}"

  if [ -z "${hostname}" ]; then
    echo 'Must give hostname as first argument.'
    exit 2
  fi

  puts 'Setting' 'Hostname'
  sudo -S hostnamectl hostname "$hostname"
  puts 'Set' 'Hostname'
}

set_clock () {
  puts 'Setting' 'Hardware clock'
  sudo -S hwclock --systohc
  puts 'Set' 'Hardware clock'

  puts 'Setting' 'Time zone'
  sudo -S ln -sf /usr/share/zoneinfo/America/Los_Angeles /etc/localtime
  puts 'Set' 'Time zone'
}

copy_fstab () {
  puts 'Save' 'fstab'
  hostname="$(uname -n)"
  cp /etc/fstab "etc/fstab.${hostname,,}"
  puts 'Saved' 'fstab'
}

patch_loader_entry () {
  puts 'Patch' 'Arch loader entry'
  root_uuid="$(cat /etc/fstab | grep -oP 'UUID=\K\S+(?=\s+/\s)')"
  hostname="$(uname -n)"
  sed -i "s/__UUID__/$root_uuid/g" "boot/loader/entries/arch.${hostname,,}.conf"
  puts 'Patched' 'Arch loader entry'
}

generate_locale () {
  puts 'Generating' 'Locale'
  sudo -S locale-gen
  export "$(cat /etc/locale.conf)"
  puts 'Generated' 'Locale'
}

generate_ssh_key () {
  privkey="${1:-}"

  if [ -z "${privkey}" ]; then
    echo 'Output path for SSH private key was empty'
    exit 3
  fi

  puts 'Generating' 'SSH key'
  ssh-keygen -t ed25519 -f "$privkey" -N "" -C "$(whoami)@$(uname -n)-$(date -I)"
  puts 'Generated' 'SSH key'
}

install_config () {
  puts 'Installing' 'Config Curator'
  sudo -S pacman -S --noconfirm rsync nodejs npm
  npm ci
  puts 'Installed' 'Config Curator'

  puts 'Installing' 'Config'
  sudo -S ./node_modules/.bin/curator
  puts 'Installed' 'Config'
}

install_aura () (
  puts 'Installing' 'Aura'
  temp_dir=$(mktemp -d)
  trap "rm -rf $temp_dir; exit" HUP INT TERM PIPE EXIT
  cd "$temp_dir"
  sudo -S pacman -S --noconfirm git cargo
  git clone https://aur.archlinux.org/aura.git
  cd aura
  makepkg -s
  sudo pacman -U --noconfirm ./aura-*.pkg.tar.zst
  puts 'Installed' 'Aura'
)

install_aconfmgr () (
  puts 'Installing' 'aconfmgr'

  # UPSTREAM: Need aura support
  # aura -A --noconfirm aconfmgr-git

  temp_dir=$(mktemp -d)
  trap "rm -rf $temp_dir; exit" HUP INT TERM PIPE EXIT
  cd "$temp_dir"
  git clone https://aur.archlinux.org/aconfmgr-git.git
  cd aconfmgr-git
  sed -i 's|CyberShadow/aconfmgr|rxfork/aconfmgr#branch=aura-aur-helper|g' PKGBUILD
  makepkg -s
  sudo pacman -U --noconfirm ./aconfmgr-git-*.pkg.tar.zst

  mkdir -p aconfmgr
  aconfmgr --aur-helper aura --config aconfmgr check
  puts 'Installed' 'aconfmgr'
)

update_repo_remote () (
  puts 'Update' 'Repo remote'
  git remote set-url origin 'git@github.com:razor-x/archrc.git'
  puts 'Updated' 'Repo remote'
)

main () {
  if [ "$(id -u)" -eq 0 ]; then
    echo 'Must not run as root.'
    exit 1
  fi

  puts 'Bootstrapping' 'archrc'

  # Pre-authenticate for sudo.
  sudo -S echo

  set_hostname "${1:-}"
  set_clock

  copy_fstab
  patch_loader_entry

  privkey="$HOME/.ssh/id_ed25519"
  if [ -f "$privkey" ]; then
    puts 'Skipping' 'SSH key generation'
  else
    generate_ssh_key $privkey
  fi

  sudo pacman -Syy

  install_config
  generate_locale
  install_aura
  install_aconfmgr
  update_repo_remote
  puts 'Bootstrapped' 'archrc'
}

main "${1:-}"
exit
