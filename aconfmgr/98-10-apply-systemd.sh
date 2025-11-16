#!/bin/bash

# shellcheck disable=SC2154

while read -r unit; do
  sudo -S systemctl enable "$unit"
done < "$tmp_dir"/systemd/units
