#!/usr/bin/env bash

set -e
set -u

main () {
  cmd="${1:-}"

  if [ "$(id -u)" -eq 0 ]; then
    echo 'Must not run as root.'
    exit 1
  fi

  echo '==== AUTHENTICATING FOR archrc ./apply.sh ===='
  echo 'Authentication is required to apply configuration.'
  echo 'Authenticating as: $(whoami)'
  sudo -S echo
  echo '==== AUTHENTICATING COMPLETE ===='

  aconfmgr --aur-helper aura --config config apply

  # Apply again to ensure units installed by new packages are enabled.
  aconfmgr --aur-helper aura --config config apply

  sudo -S locale-gen
  sudo -S mkinitcpio -p linux
}

main "${1:-}"
exit
