#!/usr/bin/env bash

# -e: Exit on error
# -u: Exit on unset variables
set -eu

log_color() {
	color_code="$1"
	shift
	printf "\033[${color_code}m%s\033[0m\n" "$*" >&2
}

log_red() { log_color "0;31" "$@"; }
log_blue() { log_color "0;34" "$@"; }
log_task() { log_blue "🔃" "$@"; }
log_error() { log_red "❌" "$@"; }

error() {
	log_error "$@"
	exit 1
}

# Set the directory of the script
script_dir="$(cd -P -- "$(dirname -- "$(command -v -- "$0")")" && pwd -P)"

# Ensure backup directory exists
backup_dir="$script_dir/backup"

# Install bash-it if not already installed
if ! command -v bash-it &>/dev/null && [ ! -d "$HOME/.bash_it" ]; then
	log_task "Installing bash-it..."
	if ! command -v git &>/dev/null; then
		error "Git command not found. Please install Git first."
	fi
	git clone --depth=1 https://github.com/Bash-it/bash-it.git "$HOME/.bash_it"
	"$HOME/.bash_it/install.sh" --silent --no-modify-config
fi

# Restore bash-it configurations with backup
log_task "Setting up bash_it configurations..."
if [ -d "$HOME/.bash_it/enabled" ]; then
	mv "$HOME/.bash_it/enabled" "$backup_dir/enabled.bak"
fi
ln -sf $script_dir/bash_it/enabled $HOME/.bash_it/

if ! [ -d $backup_dir/custom.bak ]; then
	mkdir $backup_dir/custom.bak
fi
mv $HOME/.bash_it/custom/* $backup_dir/custom.bak/ || true
ln -sf $script_dir/bash_it/custom/* $HOME/.bash_it/custom/

# Install basher if not already installed
if ! command -v basher &>/dev/null && [ ! -d "$HOME/.basher" ]; then
	log_task "Installing basher..."
	git clone --depth=1 https://github.com/basherpm/basher.git "$HOME/.basher"
fi

# Installing dotfiles
log_task "Install dotfiles..."
for dotfile in $script_dir/home/.*; do
	target_file=$(basename -- "$dotfile")

	log_task "Backing up $HOME/$target_file to $backup_dir/home/$target_file.bak"
	if ! [ -f $backup_dir/home ]; then
		mkdir -p "$backup_dir/home"
	fi
	if [ -f "$HOME/$target_file" ]; then
		mv "$HOME/$target_file" "$backup_dir/home/$target_file.bak"
	fi

	ln -sf "$dotfile" "$HOME/$target_file"
done
