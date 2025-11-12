#!/usr/bin/env bash

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
  echo $hostname | sudo -S tee /etc/hostname
  sudo -S hostnamectl hostname $hostname
  puts 'Hostname' $hostname
}

install_config () {
  puts 'Installing' 'Config Curator'
  sudo -S pacman -S --noconfirm rsync nodejs npm
  npm install
  puts 'Installed' 'Config Curator'

  puts 'Installing' 'Config'
  npm start
  puts 'Installed' 'Config'
}

generate_locale () {
  puts 'Generating' 'Locale'
  sudo -S locale-gen
  export $(cat /etc/locale.conf)
  puts 'Generated' 'Locale'
}

install_aura () (
  puts 'Installing' 'Aura'
  sudo -S pacman -S --noconfirm git cargo
  mkdir tmp
  cd tmp
  git clone https://aur.archlinux.org/aura.git
  cd aura
  makepkg -s
  sudo pacman -U --noconfirm ./aura-*.pkg.tar.zst
  puts 'Installed' 'Aura'
)

install_aconfmgr () {
  puts 'Installing' 'aconfmgr'
  aura -A --noconfirm aconfmgr-git
  puts 'Installed' 'aconfmgr'
}

main () {
  if [[ $(id -u) == 0 ]]; then
    echo 'Must not run as root.'
    exit 1
  fi

  echo 'Pre-authenticate for sudo.'
  sudo -S echo

  set_hostname ${1:-}
  install_config
  generate_locale
  install_aura
  install_aconfmgr
  puts 'Done' ''
}

main ${1:-}
exit
