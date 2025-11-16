#!/bin/bash

# shellcheck disable=SC2154

while read -r unit; do
  echo "$unit"
done < "$tmp_dir"/systemd/units
