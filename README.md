# Arch Linux Configuration

My Arch Linux configuration managed with [Config Curator] and [aconfmgr].

[aconfmgr]: https://github.com/CyberShadow/aconfmgr
[Config Curator]: https://github.com/razor-x/config-curator

## Requirements

These requirements are handled automatically when bootstrapping a new system.

* [Aura].
* [aconfmgr].
* [Node.js] with [npm].

[Aura]: https://fosskers.github.io/aura/
[Node.js]: https://nodejs.org/
[npm]: https://www.npmjs.com/

## Maintaining an existing Arch Linux system

Install configuration without adding or removing any packages

```
$ ./install.sh config
```

This will update `aconfmgr/99-unsorted.sh` with any new or removed packages.

After incorporating these changes, install everything

```
$ ./install.sh
```

## Bootstrapping a new Arch Linux system

Before starting, commit a new loader entry to
`boot/loader/entries/arch.<hostname>.conf`.
Leave a placeholder for the root partition UUID so the bootstrapping script
can replace it later, e.g.,

```
title Arch Linux
linux /vmlinuz-linux
initrd /initramfs-linux.img
options root=UUID=__UUID__ rw
```

### First boot into live environment

#### Set the Hardware clock

Check that the time is synchronized with NTP

```
# timedatectl
```

Set the hardware clock to UTC

```
# hwclock --systohc --utc
```

#### Update the mirrorlist

```
# reflector -l 5 -c US -p https --sort rate --save /etc/pacman.d/mirrorlist
# pacman -Syy
```

### Prepare the partitions and file systems

#### Virtualbox

Open gdisk

```
# gdisk /dev/sda
```

Setup a partition table similar to

```
Number  Start (sector)    End (sector)  Size       Code  Name
   1            2048         4196351   2.0 GiB     EF00  EFI system partition
   2         4196352        12584959   4.0 GiB     8200  Linux swap
   3        12584960        61870079   23.5 GiB    8300  Linux filesystem
```

Format the partitions

```
# mkfs.vfat -F 32 -n efi /dev/sda1
# mkfs.ext4 -L root /dev/sda3
# mkswap /dev/sda2
```

Mount the partitions

```
# mount -m /dev/sda3 /mnt
# mount -m /dev/sda1 /mnt/boot
# swapon /dev/sda2
```

### Install the base system

```
# pacstrap -K /mnt base base-devel linux linux-firmware
```

Set the hostname

```
echo "<hostname>" > /etc/hostname
```

Save the fstab to the installed system

```
# genfstab -U /mnt >> /mnt/etc/fstab
```

Install systemd-boot to the ESP

```
# arch-chroot -S /mnt bootctl install
```

Enter arch-chroot

```
# arch-chroot /mnt
```

### Configure the installed system

#### Set the root passwd

```
# passwd
```

#### Install bootstrapping dependencies

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
# git clone https://github.com/razor-x/archrc.git /root
```

Manually install the `sudoers` file

```
# cp /root/archrc/etc/sudoers /etc
# rm -rf /root/archrc
```

```
# useradd -m -G wheel razorx
# passwd razorx
```

Switch to the new user

```
# su -l razorx
```

#### Bootstrap archrc

Clone this repo

```
$ mkdir ~/config
$ cd ~/config
$ git clone https://github.com/razor-x/archrc.git
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

Reinstall linux to ensure all kernal modules are ready for first boot

```
$ sudo pacman -S linux
$ sudo reboot
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
