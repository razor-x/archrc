#!/bin/bash

# shellcheck disable=SC2154,SC2329

# SystemdEnable
#
# Enable a systemd unit file.
function SystemdEnable() {
  [[ $# -ne 1 ]] && FatalError "Expected 1 arguments, got $#."
  local unit=$1
  mkdir -p "$tmp_dir"/systemd
  printf "%s\n" "$unit" >> "$tmp_dir/systemd/units"
}
