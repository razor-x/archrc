#!/usr/bin/env bash

# shellcheck disable=SC2064,SC2086

set -e
set -u

puts () {
  echo "-- [${2:-}] ${1:-}"
}

set_hostname () {
  hostname="$(uname -n)"
  puts 'Setting' 'Hostname'
  echo "$hostname" | sudo tee /etc/hostname
  puts 'Set' 'Hostname'
}

set_clock () {
  puts 'Setting' 'Hardware clock'
  sudo hwclock --systohc
  puts 'Set' 'Hardware clock'

  puts 'Setting' 'Time zone'
  sudo ln -sf /usr/share/zoneinfo/America/Los_Angeles /etc/localtime
  puts 'Set' 'Time zone'
}

copy_fstab () {
  puts 'Save' 'fstab'
  hostname="$(uname -n)"
  cp /etc/fstab "config/files/etc/fstab.${hostname,,}"
  puts 'Saved' 'fstab'
}

patch_loader_entry () {
  puts 'Patch' 'Arch loader entry'
  root_uuid="$(cat /etc/fstab | grep -oP 'UUID=\K\S+(?=\s+/\s)')"
  hostname="$(uname -n)"
  sed -i "s/__UUID__/$root_uuid/g" "config/files/boot/loader/entries/arch.${hostname,,}.conf"
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

  if [ -z "${privkey}" ]; then
    echo 'Output path for SSH private key was empty'
    exit 3
  fi

  puts 'Generating' 'SSH key'
  ssh-keygen -t ed25519 -f "$privkey" -N "" -C "$(whoami)@$(uname -n)-$(date -I)"
  puts 'Generated' 'SSH key'
}

install_aconfmgr () (
  puts 'Installing' 'aconfmgr'
  temp_dir=$(mktemp -d)
  trap "rm -rf $temp_dir; exit" HUP INT TERM PIPE EXIT
  cd "$temp_dir"
  sudo pacman -S --noconfirm git cargo
  git clone https://aur.archlinux.org/aconfmgr-git.git
  cd aconfmgr-git
  makepkg -s
  sudo pacman -U --noconfirm ./aconfmgr-*.pkg.tar.zst
  aconfmgr --aur-helper aura --config config check
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
  if [ -f "$privkey" ]; then
    puts 'Skipping' 'SSH key generation'
  else
    sudo pacman -S --noconfirm git openssh
    generate_ssh_key $privkey
  fi

  sudo pacman -Syy

  generate_locale
  install_aura
  install_aconfmgr
  update_repo_remote

  puts 'Bootstrapped' 'archrc'
}

main
exit
