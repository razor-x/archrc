#!/bin/bash

# shellcheck disable=SC2154

if [[ -f "$tmp_dir/systemd/enable-units" ]]; then
  while read -r unit; do
    if systemctl cat "$unit" &>/dev/null; then
      sudo systemctl enable "$unit"
    else
      echo "Unit not found: $unit"
    fi
  done < "$tmp_dir"/systemd/enable-units
fi

if [[ -f "$tmp_dir/systemd/disable-units" ]]; then
  while read -r unit; do
    if systemctl cat "$unit" &>/dev/null; then
      sudo systemctl disable "$unit"
    fi
  done < "$tmp_dir"/systemd/disable-units
fi
