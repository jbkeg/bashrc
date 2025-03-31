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

# Backup directory for restored files
backup_dir="$script_dir/backup"

# Uninstall bash-it
if [ -d "$HOME/.bash_it" ]; then
	log_task "Uninstalling bash-it..."
	rm -rf "$HOME/.bash_it"
fi

# Remove basher installation
if [ -d "$HOME/.basher" ]; then
	log_task "Uninstalling basher..."
	rm -rf "$HOME/.basher"
fi

# Restore dotfiles
log_task "Restoring dotfiles..."
for dotfile in $script_dir/home/.*; do
	target_file=$(basename -- "$dotfile")

	log_task "Restoring $HOME/$target_file from $backup_dir/home/$target_file.bak"
	if [ -f "$backup_dir/home/$target_file.bak" ]; then
		rm -f "$HOME/$target_file"
		mv "$backup_dir/home/$target_file.bak" "$HOME/$target_file"
	fi
done

# Clean up backup directory
log_task "Cleaning up backup directory..."
find "$backup_dir" ! -name ".gitkeep" -delete

echo "Uninstallation complete. All configurations have been restored to their original state."
