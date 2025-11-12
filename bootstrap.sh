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
  ./node_modules/.bin/curator
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
  sudo -S pacman -S --noconfirm git base-devel cargo
  mkdir tmp
  cd tmp
  git clone https://aur.archlinux.org/aura.git
  cd aura
  makepkg -s
  sudo pacman -U --noconfirm ./aura-*.pkg.tar.zst
  cd ..
  cd ..
  rm -rf tmp
  puts 'Installed' 'Aura'
)

install_aconfmgr () (
  puts 'Installing' 'aconfmgr'

  # UPSTREAM: Need aura support
  # aura -A --noconfirm aconfmgr-git

  mkdir tmp
  cd tmp
  git clone https://aur.archlinux.org/aconfmgr-git.git
  cd aconfmgr-git
  sed -i 's|CyberShadow/aconfmgr|rxfork/aconfmgr#branch=aura-aur-helper|g' PKGBUILD
  makepkg -s
  sudo pacman -U --noconfirm ./aconfmgr-git-*.pkg.tar.zst
  cd ..
  cd ..
  rm -rf tmp

  mkdir -p aconfmgr
  aconfmgr --aur-helper aura --config aconfmgr check
  puts 'Installed' 'aconfmgr'
)

main () {
  if [[ $(id -u) == 0 ]]; then
    echo 'Must not run as root.'
    exit 1
  fi

  echo 'Pre-authenticate for sudo.'
  sudo -S echo

  rm -rf node_modules
  rm -rf tmp

  set_hostname ${1:-}
  install_config
  generate_locale
  install_aura
  install_aconfmgr
  puts 'Done' ''
}

main ${1:-}
exit
