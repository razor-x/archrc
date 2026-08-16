#!/usr/bin/env fish

# Resolve each Arch package's upstream GitHub repository.
# Usage: ./resolve-develpkgs.fish [package-file]
# Output is saved beside the package file as <package-file>.github.
# Each line is: <package>\t<GitHub repository URL or NOT FOUND note>

set -l package_file develpkgs
if test (count $argv) -gt 1
    echo "usage: "(status filename)" [package-file]" >&2
    exit 2
else if test (count $argv) -eq 1
    set package_file $argv[1]
end

if not test -r $package_file
    echo (status filename)": cannot read $package_file" >&2
    exit 2
end

set -l output_file "$package_file.github"
set -l temporary_output "$output_file.tmp.$fish_pid"

function cleanup --on-event fish_exit --inherit-variable temporary_output
    command rm -f -- $temporary_output
end

for command in pacman curl
    if not command -q $command
        echo (status filename)": required command not found: $command" >&2
        exit 2
    end
end

function github_repositories
    # Reduce release, archive, and source URLs to https://github.com/OWNER/REPO.
    string join \n -- $argv \
        | string match --all --regex --ignore-case 'https?://(www\.)?github\.com/[a-z0-9_.-]+/[a-z0-9_.-]+' \
        | string replace --regex --ignore-case '^https?://(www\.)?github\.com/' 'https://github.com/' \
        | string replace --regex --ignore-case '\.git$' '' \
        | string replace --regex '/$' '' \
        | sort --unique
end

while read --line line
    set -l package (string replace --regex '#.*$' '' -- $line | string trim)
    test -n "$package"; or continue

    set -l info (env LC_ALL=C pacman --sync --info -- $package 2>/dev/null)
    if test $status -ne 0
        printf '%s\t%s\n' $package 'NOT FOUND (package is absent from the configured sync databases)'
        continue
    end

    set -l upstream (string match --regex '^URL\s*:.*' $info \
        | string replace --regex '^[^:]+:\s*' '' \
        | string trim)
    # pacman does not expose the package base, which is needed for split
    # packages, so obtain it from Arch's package API.
    set -l package_base $package
    set -l escaped_package (string escape --style=url -- $package)
    set -l package_json (curl --fail --silent --show-error --max-time 15 -- \
        "https://archlinux.org/packages/search/json/?name=$escaped_package")
    if test $status -eq 0
        set -l api_package_base (string match --regex --groups-only \
            '"pkgbase"\s*:\s*"([^"]+)"' $package_json)
        if test (count $api_package_base) -gt 0
            set package_base $api_package_base[1]
        end
    end

    # Prefer the package's declared upstream URL.
    set -l repositories (github_repositories $upstream)

    # Some upstream homepages redirect to their GitHub repository.
    if test (count $repositories) -eq 0 -a -n "$upstream"
        set -l effective_url (curl --location --silent --show-error \
            --output /dev/null --write-out '%{url_effective}' --max-time 15 -- $upstream)
        if test $status -eq 0
            set repositories (github_repositories $effective_url)
        end
    end

    # Otherwise inspect the official Arch PKGBUILD. Source URLs commonly point
    # at GitHub even when the declared homepage does not.
    if test (count $repositories) -eq 0
        set -l pkgbuild_url "https://gitlab.archlinux.org/archlinux/packaging/packages/$package_base/-/raw/main/PKGBUILD"
        set -l pkgbuild (curl --fail --location --silent --show-error --max-time 15 -- $pkgbuild_url)
        if test $status -eq 0
            set repositories (github_repositories $pkgbuild)
        end
    end

    # As a final conservative fallback, accept a repository only when the
    # upstream homepage contains exactly one distinct GitHub repository link.
    if test (count $repositories) -eq 0 -a -n "$upstream"
        set -l homepage (curl --fail --location --silent --show-error --max-time 15 -- $upstream)
        if test $status -eq 0
            set repositories (github_repositories $homepage)
        end
    end

    if test (count $repositories) -eq 1
        printf '%s\t%s\n' $package $repositories[1]
    else if test (count $repositories) -eq 0
        printf '%s\tNOT FOUND (upstream: %s)\n' $package $upstream
    else
        printf '%s\tNOT FOUND (ambiguous candidates: %s)\n' \
            $package (string join ', ' $repositories)
    end
end <$package_file >$temporary_output

if not command mv -- $temporary_output $output_file
    echo (status filename)": could not save $output_file" >&2
    exit 1
end

set -l result_count (wc --lines < $output_file | string trim)
echo "Saved $result_count package results to $output_file"
