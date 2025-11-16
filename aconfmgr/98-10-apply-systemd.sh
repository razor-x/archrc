#!/bin/bash

# shellcheck disable=SC2154

while read -r unit; do
  if systemctl list-unit-files | grep -q "^${unit}[@.]"; then
  sudo -S systemctl enable "$unit"
  else
    echo "Unit not found: $unit"
  fi
done < "$tmp_dir"/systemd/units
