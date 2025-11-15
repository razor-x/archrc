import os from 'os'

const host = os.hostname().toLowerCase()

const ioType = 'linux'
const pkgType = 'pacman'

const targetRoot = '/'

const defaults = {
  dmode: '0755',
  fmode: '0644',
  user: 'root',
  group: 'root',
}

const files = [
  {
    src: `etc/fstab.${host}`,
    dst: 'etc/fstab'
  },
  {
    src: 'etc/locale.gen'
  },
  {
    src: 'etc/locale.conf'
  },
  {
    src: 'etc/systemd/network/10-dhcp.network',
  },
  {
    src: 'etc/sudoers',
    fmode: '0440',
    pkgs: ['sudo'],
  },
  {
    src: 'etc/ssh/sshd_config',
    pkgs: ['openssh']
  },
]

export default {
  files,
  targetRoot,
  ioType,
  pkgType,
  defaults,
}
