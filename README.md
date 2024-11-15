# bashrc

Jons' personal bash configuration enhanced with [Bash-it](https://bash-it.readthedocs.io/en/latest/#) and [Basher](https://www.basher.it/)

## Table of contents

- [bashrc](#bashrc)
  - [Table of contents](#table-of-contents)
  - [Installation](#installation)
    - [Pre-Install](#pre-install)
    - [Install](#install)
    - [Post-Install](#post-install)
    - [Uninstallation](#uninstallation)

## Installation

### Pre-Install

- Requirement:
  - git

### Install

Run installation script

```bash
./install.sh
```

Above command will install `bash it` and `basher` at $HOME directory. and symlink `.bashrc`, `.bash_profile` and `other dotfiles`.

### Post-Install

Enable and disable bash it plugins, completions and aliases.

### Uninstallation

```bash
./uninstall.sh
rm -rf /path/to/bashrc
```
