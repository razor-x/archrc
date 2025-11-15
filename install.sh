#!/usr/bin/env bash

set -e
set -u

main () {
  cmd="${1:=config}"

  if [[ $(id -u) == 0 ]]; then
    echo 'Must not run as root.'
    exit 1
  fi

  echo 'Pre-authenticate for sudo.'
  sudo -S echo

  npm ci

  if [[ "$cmd" = 'config' ]]; then
    ./node_modules/.bin/curator
    aconfmgr --aur-helper aura --config aconfmgr save
    exit
  fi

  aconfmgr --aur-helper aura --config aconfmgr apply
}

main "${1:-}"
exit
