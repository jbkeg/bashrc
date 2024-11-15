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
if command -v basher &>/dev/null; then
	log_task "Uninstalling basher..."
	rm -rf "$HOME/.basher"
	# Remove basher from PATH if added in the .bashrc or other shell profile
	sed -i '' '/basher/d' ~/.bashrc || true
	sed -i '' '/basher/d' ~/.bash_profile || true
fi

# Restore original .bash_profile if a backup exists
log_task "Restoring .bash_profile..."
if [ -f "$backup_dir/.bash_profile.back" ]; then
	rm -f ~/.bash_profile
	mv "$backup_dir/.bash_profile.back" ~/.bash_profile
else
	rm -f ~/.bash_profile
fi

# Restore original .bashrc if a backup exists
log_task "Restoring .bashrc..."
if [ -f "$backup_dir/.bashrc.back" ]; then
	rm -f ~/.bashrc
	mv "$backup_dir/.bashrc.back" ~/.bashrc
else
	rm -f ~/.bashrc
fi

# Restore bash-it enabled and custom folders
log_task "Restoring bash-it configurations..."
if [ -f "$backup_dir/enabled.back" ]; then
	rm -rf ~/.bash_it/enabled
	mv "$backup_dir/enabled.back" ~/.bash_it/enabled
fi
if [ -f "$backup_dir/custom.back" ]; then
	rm -rf ~/.bash_it/custom
	mv "$backup_dir/custom.back" ~/.bash_it/custom
fi

# Clean up backup directory
log_task "Cleaning up backup directory..."
find . ! -name ".gitkeep" -delete

echo "Uninstallation complete. All configurations have been restored to their original state."
