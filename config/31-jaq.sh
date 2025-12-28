# Shadow jq with jaq.
AddPackage jaq # A jq clone focussed on correctness, speed, and simplicity
CreateLink /usr/local/bin/jq /usr/bin/jaq

## Required for aconfmgr to remain idempotent.
RemoveFile /usr/local/bin/jq
RemoveFile /usr/local/bin
RemoveFile /usr/local
RemoveFile /usr
