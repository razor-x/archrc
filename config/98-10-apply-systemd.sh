#!/bin/bash

# shellcheck disable=SC2154

while read -r unit; do
  if systemctl cat "$unit" &>/dev/null; then
    sudo systemctl enable "$unit"
  else
    echo "Unit not found: $unit"
  fi
done < "$tmp_dir"/systemd/enable-units

while read -r unit; do
  if systemctl cat "$unit" &>/dev/null; then
    sudo systemctl disable "$unit"
  fi
done < "$tmp_dir"/systemd/disable-units
