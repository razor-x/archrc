# Arch Linux Configuration

My Arch Linux configuration managed with [Config Curator] and [aconfmgr].

[aconfmgr]: https://github.com/CyberShadow/aconfmgr
[Config Curator]: https://github.com/razor-x/config-curator

## Requirements

* [Aura].
* [aconfmgr].
* [Node.js] with [npm].

> These requirements are handled automatically when bootstrapping a new system.

[Aura]: https://fosskers.github.io/aura/
[Node.js]: https://nodejs.org/
[npm]: https://www.npmjs.com/

## Installation and Usage

Clone the repo

```
$ git clone git@github.com:razor-x/archrc.git
```

Install configuration first without adding or removing any packages

```
$ ./install.sh config
```

This will update `aconfmgr/99-unsorted.sh` with any new or removed packages.
After incorporating these changes, install everything

```
$ ./install.sh
```

## Bootstrapping a new Arch Linux system

### First book into live environment

#### Set the Hardware clock

```
# timedatectl
# hwclock --systohc --utc
```

#### Update the mirrorlist

```
# pacman -S reflector
# reflector -l 5 -c US -p https --sort rate --save /etc/pacman.d/mirrorlist
# pacman -Syy
```

### Install the base system

TODO

### Inside arch-chroot

#### Set the root passwd

```
# passwd
```

#### Install dependencies

```
# pacman-key --init
# pacman-key --populate archlinux
# pacman -S git inetutils openssh
```

For systems with wireless cards, ensure `iwctl` will be available on first boot

```
# pacman -S iwd
```

#### Setup non-root user

Clone this repo

```
# git clone https://github.com/razor-x/archrc.git /root/archrc
```

Manually install the `sudoers` file

```
# cp /root/archrc/etc/sudoers /etc/sudoers
# rm -rf /root/archrc
```

```
# useradd -m -G wheel razorx
# passwd razorx
```

Switch to the new user

```
# su -l not-root
```

#### Bootstrapping

Clone this repo

```
$ mkdir ~/config
$ cd ~/config
$ git clone git@github.com:razor-x/archrc.git
$ cd archrc
```

Bootstrap the dependencies for archrc

```
./bootstrap.sh
```

Install configuration and packages

```
./install.sh
```

## License

These configuration files are licensed under the MIT license.

## Warranty

This software is provided by the copyright holders and contributors "as is" and
any express or implied warranties, including, but not limited to, the implied
warranties of merchantability and fitness for a particular purpose are
disclaimed. In no event shall the copyright holder or contributors be liable for
any direct, indirect, incidental, special, exemplary, or consequential damages
(including, but not limited to, procurement of substitute goods or services;
loss of use, data, or profits; or business interruption) however caused and on
any theory of liability, whether in contract, strict liability, or tort
(including negligence or otherwise) arising in any way out of the use of this
software, even if advised of the possibility of such damage.
