#!/usr/bin/env bash

# shellcheck disable=SC2064

set -e
set -u

puts () {
  echo "-- [${1:-}] ${2:-}"
}

set_hostname () {
  hostname="${1:-}"

  if [[ -z ${hostname} ]]; then
    echo 'Must give hostname as first argument.'
    exit 2
  fi

  puts 'Setting' 'Hostname'
  sudo -S hostnamectl hostname "$hostname"
  puts 'Hostname' "$hostname"
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
  puts 'Copy' 'fstab'
  cp /etc/fstab "etc/fstab.$(uname -n)"
  puts 'Copied' 'fstab'
}

generate_locale () {
  puts 'Generating' 'Locale'
  sudo -S locale-gen
  export "$(cat /etc/locale.conf)"
  puts 'Generated' 'Locale'
}

generate_ssh_key () {
  puts 'Generating' 'SSH key'
  ssh-keygen -C "$(whoami)@$(uname -n)-$(date -I)"
  puts 'Generated' 'SSH key'
}

install_aura () (
  puts 'Installing' 'Aura'
  temp_dir=$(mktemp -d)
  trap "rm -rf $temp_dir; exit" HUP INT TERM PIPE EXIT
  cd "$temp_dir"
  sudo -S pacman -S --noconfirm git base-devel cargo
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

install_config () {
  puts 'Installing' 'Config Curator'
  sudo -S pacman -S --noconfirm rsync nodejs npm
  npm ci
  puts 'Installed' 'Config Curator'

  puts 'Installing' 'Config'
  ./node_modules/.bin/curator
  puts 'Installed' 'Config'
}

main () {
  if [[ $(id -u) == 0 ]]; then
    echo 'Must not run as root.'
    exit 1
  fi

  echo 'Pre-authenticate for sudo.'
  sudo -S echo

  set_hostname "${1:-}"
  set_clock

  copy_fstab

  if [ ! -d "$HOME/.ssh" ]; then
    generate_ssh_key
  fi

  sudo pacman -Syy

  install_config
  generate_locale
  install_aura
  install_aconfmgr
  puts 'Done' ''
}

main "${1:-}"
exit
