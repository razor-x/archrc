#!/usr/bin/env zsh

set -e
set -u

curate_str="puts Gem.bin_path('config_curator', 'curate')"
hostname="${1:-}"

function puts () {
  echo "\n-- [$1] $2"
}

function pacin () {
  if ! (pacman -Q $1 >/dev/null); then
    pacman -S --noconfirm $1
  fi
}

if [[ -z ${hostname} ]]; then
  echo 'Must give hostname as first argument.'
  exit 1
fi

if [[ $(id -u) -ne 0 ]]; then
  echo 'Must run as root.'
  exit 1
fi

echo $hostname > /etc/hostname
hostname $hostname
puts 'Hostname' $hostname

puts 'Installing' 'Config Curator requirements'

pacin ruby
pacin npm

ruby -e $curate_str >/dev/null 2>&1 || gem install --no-document config_curator
npm install yarn
./node_modules/.bin/yarn

ruby -e $curate_str >/dev/null 2>&1 && \
  puts 'Installed' 'Config Curator requirements'

puts 'Installing' 'Node modules'
./node_modules/.bin/yarn
puts 'Installed' 'Node modules'

puts 'Installing' 'Config'

$(ruby -e $curate_str) -v

if [[ -d node_modules ]]; then
  rm -rf node_modules
  puts 'Cleaned' 'Node modules'
fi

if [[ -z "${SUDO_COMMAND:-}" && -d /root/.gem ]]; then
  gem uninstall --all --force --executables
  rm -rf /root/.gem
  rm -rf /usr/lib/ruby/gems/*/cache/*
  puts 'Cleaned' 'Ruby gems'
fi

puts 'Installing' 'archutil requirements'

pacin curl
pacin python
pacin python-yaml

puts 'Installed' 'archutil requirements'

if ! [[ -e /usr/local/bin/archutil ]]; then
  puts 'Installing' 'archutil'
  curl -L -o /usr/local/bin/archutil https://io.evansosenko.com/archutil/archutil
fi

if [[ -e /usr/local/bin/archutil ]]; then
  chmod +x /usr/local/bin/archutil
  puts 'Installed' 'archutil'
fi

puts 'Setting' 'Locale'

locale-gen
export $(cat /etc/locale.conf)

puts 'Done' ''

exit
