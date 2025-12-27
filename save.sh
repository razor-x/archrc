#!/usr/bin/env bash

set -u

main () {
  if [[ $EUID -eq 0 ]]; then
    echo 'Must not run as root.'
    exit 1
  fi

  echo '==== AUTHENTICATING FOR archrc ./save.sh ===='
  echo 'Authentication is required to save configuration.'
  echo "Authenticating as: $(whoami)"
  sudo echo
  echo '==== AUTHENTICATING COMPLETE ===='

  sudo pacman --sync --refresh --refresh

  aconfmgr --config config save
}

main
exit
