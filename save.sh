#!/usr/bin/env bash

set -e
set -u

main () {
  if [ "$(id -u)" -eq 0 ]; then
    echo 'Must not run as root.'
    exit 1
  fi

  echo '==== AUTHENTICATING FOR archrc ./save.sh ===='
  echo 'Authentication is required to save configuration.'
  echo "Authenticating as: $(whoami)"
  sudo echo
  echo '==== AUTHENTICATING COMPLETE ===='

  aconfmgr --aur-helper aura --config config save
}

main
exit
