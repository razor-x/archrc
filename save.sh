#!/usr/bin/env bash

set -e
set -u

main () {
  cmd="${1:-}"

  if [ "$(id -u)" -eq 0 ]; then
    echo 'Must not run as root.'
    exit 1
  fi

  echo '==== AUTHENTICATING FOR archrc ./save.sh ===='
  echo 'Authentication is required to save configuration.'
  echo "Authenticating as: $(whoami)"
  sudo -S echo
  echo '==== AUTHENTICATING COMPLETE ===='

  aconfmgr --aur-helper aura --config config save

  exit
}

main "${1:-}"
exit
