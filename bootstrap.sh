#!/bin/bash

# shellcheck disable=SC2064,SC2086

set -u

puts () {
  echo "-- [${2:-}] ${1:-}"
}

set_hostname () {
  hostname="$(uname --nodename)"
  puts 'Setting' 'Hostname'
  echo "$hostname" | sudo tee /etc/hostname
  puts 'Set' 'Hostname'
}

set_clock () {
  puts 'Setting' 'Hardware clock'
  sudo hwclock --systohc
  puts 'Set' 'Hardware clock'

  puts 'Setting' 'Time zone'
  sudo ln --symbolic --force /usr/share/zoneinfo/America/Los_Angeles /etc/localtime
  puts 'Set' 'Time zone'
}

copy_fstab () {
  puts 'Save' 'fstab'
  hostname="$(uname --nodename)"
  cp /etc/fstab "config/files/etc/fstab.${hostname,,}"
  puts 'Saved' 'fstab'
}

patch_loader_entry () {
  puts 'Patch' 'Arch loader entry'
  root_uuid="$(cat /etc/fstab | grep --only-matching --perl-regexp 'UUID=\K\S+(?=\s+/\s)')"
  hostname="$(uname --nodename)"
  sed --in-place \
    "s/__UUID__/$root_uuid/g" "config/files/boot/loader/entries/arch.${hostname,,}.conf"
  puts 'Patched' 'Arch loader entry'
}

generate_locale () {
  puts 'Generating' 'Locale'
  sudo cp config/files/etc/locale.conf /etc/locale.conf
  sudo cp config/files/etc/locale.gen /etc/locale.gen
  sudo locale-gen
  export "$(cat /etc/locale.conf)"
  puts 'Generated' 'Locale'
}

generate_ssh_key () {
  privkey="${1:-}"

  if [[ -z "$privkey" ]]; then
    echo 'Output path for SSH private key was empty'
    exit 3
  fi

  puts 'Generating' 'SSH key'
  ssh-keygen -t ed25519 -f "$privkey" -N "" -C \
    "$(whoami)@$(uname --nodename)-$(date --iso-8601)"
  puts 'Generated' 'SSH key'
}

install_aconfmgr () (
  puts 'Installing' 'aconfmgr'
  temp_dir=$(mktemp --directory)
  trap "rm --recursive --force $temp_dir; exit" HUP INT TERM PIPE EXIT
  cd "$temp_dir" || exit 4
  sudo pacman --sync --noconfirm git
  git clone https://aur.archlinux.org/aconfmgr-git.git
  cd aconfmgr-git || exit 5
  makepkg --syncdeps
  sudo pacman --upgrade --noconfirm ./aconfmgr-*.pkg.tar.zst
  aconfmgr --config config check
  puts 'Installed' 'aconfmgr'
)

update_repo_remote () (
  puts 'Update' 'Repo remote'
  git remote set-url origin 'git@github.com:razor-x/archrc.git'
  puts 'Updated' 'Repo remote'
)

main () {
  if [[ $EUID -eq 0 ]]; then
    echo 'Must not run as root.'
    exit 1
  fi

  echo '==== AUTHENTICATING FOR archrc ./bootstrap.sh ===='
  echo 'Authentication is required to bootstrap configuration.'
  echo "Authenticating as: $(whoami)"
  sudo echo
  echo '==== AUTHENTICATING COMPLETE ===='

  puts 'Bootstrapping' 'archrc'

  set_hostname
  set_clock

  copy_fstab
  patch_loader_entry

  privkey="$HOME/.ssh/id_ed25519"
  if [[ -f "$privkey" ]]; then
    puts 'Skipping' 'SSH key generation'
  else
    sudo pacman --sync --noconfirm git openssh
    generate_ssh_key $privkey
  fi

  sudo pacman --sync --refresh --refresh

  generate_locale
  install_aconfmgr
  update_repo_remote

  sudo pacman --sync --noconfirm just

  puts 'Bootstrapped' 'archrc'
}

main
exit
