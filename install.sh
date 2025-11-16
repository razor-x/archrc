#!/usr/bin/env bash

set -e
set -u

main () {
  cmd="${1:-}"

  if [ "$(id -u)" -eq 0 ]; then
    echo 'Must not run as root.'
    exit 1
  fi

  echo '> Pre-authenticate for sudo.'
  sudo -S echo

  npm ci

    echo '> curator'
    sudo ./node_modules/.bin/curator
    echo '> locale-gen'
    sudo locale-gen

  if [ "${cmd}" = 'config' ]; then
    echo '> aconfmgr save'
    aconfmgr --aur-helper aura --config aconfmgr save

    exit
  fi

  echo '> aconfmgr apply'
  aconfmgr --aur-helper aura --config aconfmgr apply

  echo '> curator'
  sudo ./node_modules/.bin/curator

  echo '> aconfmgr apply'
  aconfmgr --aur-helper aura --config aconfmgr apply
}

main "${1:-}"
exit
