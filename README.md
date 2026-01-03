# Arch Linux Configuration

My Arch Linux configuration managed with [aconfmgr].

## Requirements

* [aconfmgr]: Installed automatically when bootstrapping a new system.
* [just]: Installed automatically when bootstrapping a new system.

[aconfmgr]: https://github.com/CyberShadow/aconfmgr
[just]: https://just.systems/

## Maintaining an existing Arch Linux system

Periodic maintenance consists of running

```
$ just save
```

If this results in uncommitted changes to the `config` directory,
then there are unaccounted system changes.
The changes should be reviewed, sorted, documented, committed and pushed.

After incorporating these changes, apply the system configuration

```
$ just apply
```

## Managing systemd units

Use `SystemdEnable` to enable systemd units
and `SystemdDisable` to disable systemd units.

### Limitations

- The units are only enabled or disabled.
  They are not started, stopped, or restarted.
- When updating the configuration to change which units are active,
  do not remove the entry, instead switch `SystemdEnable` to `SystemdDisable` and vice versa.
  This ensures the unit state is updated and not orphaned.
- The `SystemdEnable` helper does not fail on missing units.
  This is intentional because the unit may not exist until
  the corresponding packages are installed.
  To work around this, `aconfmgr apply` will be run twice to ensure all units are enabled.
- The `SystemdDisable` helper does not fail on missing units.
  This is intentional as the helper only guarantees that the unit is not enabled.

## Bootstrapping a new Arch Linux system

### Add the new system to this configuration

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

After bootstrapping, some files will be added and updated in the locally cloned repo.
Commit and push them back once git is fully configured and authorized.

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
# mkfs.vfat -F 32 -n boot /dev/sda1
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
# pacstrap -K /mnt base base-devel linux linux-firmware git inetutils
```

Save the fstab to the installed system

```
# genfstab -U /mnt >> /mnt/etc/fstab
```

Create link to systemd-resolved stub resolver

```
# ln -sf ../run/systemd/resolve/stub-resolv.conf /mnt/etc/resolv.conf
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

#### Set the hostname

```
# hostname <hostname>
```

#### Set the root passwd

```
# passwd
```

#### Setup non-root user

Clone this repo

```
# git clone https://github.com/razor-x/archrc.git /root/archrc
```

Manually install the `sudoers` file

```
# cp /root/archrc/config/files/etc/sudoers /etc
# rm -rf /root/archrc
```

Create the non-root user

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
$ ./bootstrap.sh
```

Install configuration and packages

```
$ just apply
```

#### Reboot into your new Arch Linux system!

> [!TIP]
> For systems with wireless cards, ensure `iwctl` will be available on first boot
> ```
> $ sudo pacman -S iwd
> ```

```
$ exit
# exit
# reboot
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
