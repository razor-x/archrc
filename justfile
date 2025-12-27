save: authenticate
  sudo pacman --sync --refresh --refresh
  aconfmgr --config config save

apply: authenticate
  sudo pacman --sync --refresh --refresh
  aconfmgr --config config apply

  # Apply again to ensure units installed by new packages are enabled.
  aconfmgr --config config apply

  sudo locale-gen
  sudo mkinitcpio --preset linux
  sudo pkgfile --update
  fish -c fish_update_completions

[private]
@authenticate:
  if [[ $EUID -eq 0 ]]; then \
    echo 'Must not run as root.'; exit 1; \
  fi

  echo '==== AUTHENTICATING FOR archrc ===='
  echo 'Authentication is required.'
  echo "Authenticating as: $(whoami)"
  sudo true
  echo '==== AUTHENTICATING COMPLETE ===='
