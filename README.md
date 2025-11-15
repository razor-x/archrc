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
