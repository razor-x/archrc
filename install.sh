#!/usr/bin/env bash

set -e
set -u

main () {
  cmd="${1:-}"

  if [ "$(id -u)" -eq 0 ]; then
    echo 'Must not run as root.'
    exit 1
  fi

  sudo -S echo

  if [ "${cmd}" = 'config' ]; then
    echo '> aconfmgr save'
    aconfmgr --aur-helper aura --config aconfmgr save
    exit
  fi

  echo '> aconfmgr apply'
  aconfmgr --aur-helper aura --config aconfmgr apply

  # Apply again to ensure units installed by new packages are enabled.
  echo '> aconfmgr apply'
  aconfmgr --aur-helper aura --config aconfmgr apply

  echo '> locale-gen'
  sudo locale-gen
}

main "${1:-}"
exit
