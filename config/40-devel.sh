# Shared

## Tools
AddPackage ctags # Generates an index file of language objects found in source files
AddPackage hyperfine # A command-line benchmarking tool
AddPackage just # A handy way to save and run project-specific commands
AddPackage kondo # Save disk space by cleaning non-essential files from software projects
AddPackage mise # The front-end to your dev env
AddPackage strace # A diagnostic, debugging and instructional userspace tracer
AddPackage watchexec # Executes commands in response to file modifications

## Libraries
AddPackage blas-openblas # An optimized BLAS library based on GotoBLAS2 1.13 BSD (Provides BLAS/CBLAS/LAPACK/LAPACKE system-wide)
AddPackage libffi # Portable foreign function interface library
AddPackage libgit2 # A linkable library for Git
AddPackage libyaml # YAML 1.1 library
AddPackage perl-libwww # The World-Wide Web library for Perl
AddPackage python-bottleneck # Fast NumPy array functions written in Cython
AddPackage python-matplotlib # A python plotting library, making publication quality plots
AddPackage python-numexpr # Fast numerical array expression evaluator for Python, NumPy, PyTables, pandas
AddPackage python-numpy # Scientific tools for Python
AddPackage python-pandas # High-performance, easy-to-use data structures and data analysis tools for Python
AddPackage python-pandas-datareader # Data readers extracted from the pandas codebase
AddPackage python-scipy # Open-source software for mathematics, science, and engineering
AddPackage sqlite # A C library that implements an SQL database engine
AddPackage tk # A windowing toolkit for use with tcl

## Native Modules
AddPackage cmake # A cross-platform open-source make system
AddPackage gcc-fortran # Fortran front-end for GCC

# Languages
#
# Included for each language where possible:
# - Compiler or interpreter
# - Standard libraries
# - REPL
# - Language Server Protocol (LSP)
# - Package/project/dependency manager
# - Formatter
# - Linter

## C/C++
AddPackage clang # C language family frontend for LLVM

## Clojure
AddPackage clojure # Lisp dialect for the JVM
AddPackage leiningen # Automate Clojure projects
AddPackage --foreign clojure-lsp-bin # Language Server (LSP) for Clojure
AddPackage --foreign cljfmt-bin # A formatter for Clojure code
AddPackage --foreign clj-kondo-bin # A minimal and opinionated linter for Clojure code that sparks joy.

## Go
AddPackage go # Core compiler tools for the Go programming language
AddPackage gopls # Language server for Go programming language
AddPackage golangci-lint # Fast linters runner for Go

## JavaScript/TypeScript/Web
AddPackage nodejs # Evented I/O for V8 javascript ("Current" release)
AddPackage typescript # JavaScript with syntax for types
AddPackage typescript-language-server # Language Server Protocol (LSP) implementation for TypeScript using tsserver
AddPackage bun # Incredibly fast JavaScript runtime, bundler, test runner, and package manager – all in one
AddPackage deno # A secure runtime for JavaScript and TypeScript
AddPackage biome # Formatter, linter, and more for Javascript, Typescript, JSON, and CSS
AddPackage npm # JavaScript package manager
AddPackage pnpm # Fast, disk space efficient package manager
AddPackage yarn # Fast, reliable, and secure dependency management

## Lua
AddPackage lua # Powerful lightweight programming language designed for extending applications
AddPackage lua-sec # Lua bindings for OpenSSL library to provide TLS/SSL communication for Lua 5.4
AddPackage lua-language-server # Lua Language Server coded by Lua
AddPackage stylua # Deterministic code formatter for Lua
AddPackage selene # Blazing-fast modern Lua linter written in Rust
AddPackage luarocks # Deployment and management system for Lua modules

## PHP
AddPackage php # A general-purpose scripting language that is especially suited to web development
AddPackage psalm # A static analysis tool for finding errors in PHP applications
AddPackage composer # Dependency Manager for PHP
AddPackage --foreign phpactor # PHP completion, refactoring, introspection tool and language server
AddPackage --foreign mago-bin # An extremely fast PHP linter, formatter, and static analyzer, written in Rust.

## Python
AddPackage python # The Python programming language
AddPackage pyright # Type checker for the Python language
AddPackage bpython # Fancy ncurses interface to the Python interpreter
AddPackage ruff # An extremely fast Python linter, written in Rust
AddPackage python-pip # The PyPA recommended tool for installing Python packages
AddPackage python-poetry # Python dependency management and packaging made easy
AddPackage uv # An extremely fast Python package installer and resolver written in Rust

## Ruby
AddPackage ruby # An object-oriented language for quick and easy programming
AddPackage ruby-docs # Documentation files for Ruby
AddPackage ruby-stdlib # Full Ruby StdLib including default gems, bundled gems and tools
AddPackage ruby-pry # A runtime developer console and IRB alternative with powerful introspection capabilities
AddPackage rubocop # A Ruby code style checking and code formatting tool

## Shell
AddPackage bash-language-server # Bash language server implementation based on Tree Sitter and its grammar for Bash
AddPackage shfmt # Format shell programs
AddPackage --foreign shellcheck-bin # Shell script analysis tool (binary release, static)
