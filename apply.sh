#!/usr/bin/env bash

set -e
set -u

main () {
  if [[ $EUID -eq 0 ]]; then
    echo 'Must not run as root.'
    exit 1
  fi

  echo '==== AUTHENTICATING FOR archrc ./apply.sh ===='
  echo 'Authentication is required to apply configuration.'
  echo "Authenticating as: $(whoami)"
  sudo echo
  echo '==== AUTHENTICATING COMPLETE ===='

  aconfmgr --config config apply

  # Apply again to ensure units installed by new packages are enabled.
  aconfmgr --config config apply

  sudo locale-gen
  sudo mkinitcpio -p linux

  if command -v fish &> /dev/null; then
    fish -c fish_update_completions
  fi
}

main
exit
