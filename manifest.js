const ioType = 'linux'
const pkgType = 'pacman'

const targetRoot = '/'

const defaults = {
  dmode: '0755',
  fmode: '0644',
  user: 'root',
  group: 'root'
}

const files = [{
  src: 'etc/sudoers',
  fmode: '0440',
  pkgs: ['sudo']
}]

export default {
  files,
  targetRoot,
  ioType,
  pkgType,
  defaults
}
