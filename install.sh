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

  if [[ "$cmd" = 'config' ]]; then
    npm start
    aconfmgr --aur-helper aura --config aconfmgr apply
    exit
  fi

  aconfmgr --aur-helper aura --config aconfmgr apply
}

main "${1:-}"
exit
