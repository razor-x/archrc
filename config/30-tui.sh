# Shell

## Fish
AddPackage fish # Smart and user friendly shell intended mostly for interactive use
AddPackage fisher # A package manager for the fish shell

## nushell
AddPackage nushell # A new type of shell

## Zsh
AddPackage zsh # A very advanced and programmable command interpreter (shell) for UNIX

## TUI
AddPackage neovim # Fork of Vim aiming to improve user experience, plugins, and GUIs
AddPackage ouch # A command line utility for easily compressing and decompressing files and directories
AddPackage xh # Friendly and fast tool for sending HTTP requests
AddPackage yazi # Blazing fast terminal file manager written in Rust, based on async I/O
AddPackage zellij # A terminal multiplexer

## TODO
AddPackage atuin # Magical shell history
AddPackage bat # Cat clone with syntax highlighting and git integration
AddPackage broot # Fuzzy Search + tree + cd
AddPackage dust # A more intuitive version of du in rust
AddPackage eza # A modern replacement for ls (community fork of exa)
AddPackage fd # Simple, fast and user-friendly alternative to find
AddPackage fx # Command-line tool and terminal JSON viewer
AddPackage fzf # Command-line fuzzy finder
AddPackage git-delta # Syntax-highlighting pager for git and diff output
AddPackage gitui # Blazing fast terminal-ui for git written in Rust
AddPackage go-yq # Portable command-line YAML processor
AddPackage hyperfine # A command-line benchmarking tool
AddPackage just # A handy way to save and run project-specific commands
AddPackage procs # A modern replacement for ps written in Rust
AddPackage sd # Intuitive find & replace
AddPackage zenith # Terminal system monitor with histograms
AddPackage zoxide # A smarter cd command for your terminal
AddPackage shellcheck # Shell script analysis tool
AddPackage dua-cli # A tool to conveniently learn about the disk usage of directories, fast!
AddPackage presenterm # A markdown terminal slideshow tool
AddPackage ripgrep-all # rga: ripgrep, but also search in PDFs, E-Books, Office documents, zip, tar.gz, etc.
AddPackage wiki-tui # A simple and easy to use Wikipedia Text User Interface
AddPackage caddy # Fast web server with automatic HTTPS

# Sysadmin

## Configuration
AddPackage chezmoi # Manage your dotfiles across multiple machines
AddPackage --foreign aconfmgr-git # A configuration manager for Arch Linux

## Hardware
AddPackage efivar # Tools and libraries to work with EFI variables
AddPackage lsof # Lists open files for running Unix processes
AddPackage usbutils # A collection of USB tools to query connected USB devices
AddPackage pciutils # PCI bus configuration space access library and tools

## Filesystem
AddPackage gptfdisk # A text-mode partitioning tool that works on GUID Partition Table (GPT) disks

## Network
AddPackage bind # A complete, highly portable implementation of the DNS protocol
AddPackage dnssec-tools # libval & dnssec management tools
AddPackage inetutils # A collection of common network programs
AddPackage openbsd-netcat # TCP/IP swiss army knife. OpenBSD variant.
AddPackage openssl # The Open Source toolkit for Secure Sockets Layer and Transport Layer Security
AddPackage traceroute # Tracks the route taken by packets over an IP network
AddPackage whois # Intelligent WHOIS client

# Canonical

## Util
AddPackage curl # command line tool and library for transferring data with URLs

AddPackage jaq # A jq clone focussed on correctness, speed, and simplicity
CreateLink /usr/local/bin/jq /usr/bin/jaq
RemoveFile /usr/local/bin/jq
RemoveFile /usr/local/bin
RemoveFile /usr/local
RemoveFile /usr

AddPackage less # A terminal based program for viewing text files
AddPackage man-db # A utility for reading man pages
AddPackage man-pages # Linux man pages
AddPackage moreutils # A growing collection of the unix tools that nobody thought to write thirty years ago
AddPackage pkgfile # A tool to search for files in official repository packages
AddPackage rclone # rsync for cloud storage
AddPackage ripgrep # A search tool that combines the usability of ag with the raw speed of grep
AddPackage rsync # A fast and versatile file copying tool for remote and local files
AddPackage strace # A diagnostic, debugging and instructional userspace tracer
AddPackage tree # A directory listing program displaying a depth indented list of files
AddPackage wget # Network utility to retrieve files from the web
AddPackage which # A utility to show the full path of commands

## Git
AddPackage git # the fast distributed version control system
AddPackage git-lfs # Git extension for versioning large files

## GPG
AddPackage gnupg # Complete and free implementation of the OpenPGP standard
AddPackage pinentry # Collection of simple PIN or passphrase entry dialogs which utilize the Assuan protocol

# Archivers

## ZIP
AddPackage zip # Compressor/archiver for creating and modifying zipfiles
AddPackage unzip # For extracting and viewing files in .zip archives

## 7-Zip
AddPackage 7zip # File archiver for extremely high compression

## RAR
AddPackage unrar-free # Free utility to extract files from RAR archives

## zlib
AddPackage zlib # Compression library implementing the deflate compression method found in gzip and PKZIP
