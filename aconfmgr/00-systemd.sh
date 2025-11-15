#!/bin/bash

# SystemdEnable
#
# Enable a systemd unit file.
function SystemdEnable() {
  [[ $# -ne 1 ]] && FatalError "Expected 2 arguments, got $#."
  systemctl enable "$1"
}
