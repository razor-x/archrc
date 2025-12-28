save:
  sudo pacman --sync --refresh --refresh
  aconfmgr --config config save

apply:
  sudo pacman --sync --refresh --refresh
  aconfmgr --config config apply

  # Apply again to ensure units installed by new packages are enabled.
  aconfmgr --config config apply

  sudo locale-gen
  sudo mkinitcpio --preset linux
  sudo pkgfile --update
  fish --command fish_update_completions
