#!/usr/bin/env bash

# Logging functions
log_color() { printf "\033[%sm%s\033[0m\n" "$1" "$2" >&2; }
log_info() { log_color "0;32" "📘 $1"; }
log_task() { log_color "0;34" "⏳ $1"; }
log_error() { log_color "0;31" "🚨 $1"; }

error() {
	log_error "$1"
	exit 1
}

confirm() {
	local prompt="$1"
	local response
	read -r -p "$prompt [y/N]: " response
	[[ "${response,,}" =~ ^(y|yes)$ ]]
}

# Paths
script_dir="$(cd -P -- "$(dirname -- "$0")" && pwd -P)"
themes_dir="$script_dir/themes"
terminal_plist="$HOME/Library/Preferences/com.apple.Terminal.plist"

# Select theme
IFS= mapfile -t themes < <(find "$themes_dir" -maxdepth 1 -type f -exec basename {} \;)
log_info "Available Terminal.app theme/profile:"
select theme in "${themes[@]}"; do
	[[ -n "$theme" ]] && break
	log_error "Invalid selection. Please try again."
done

[[ -z $theme ]] && exit 1
theme_file="$themes_dir/$theme"
log_task "Selected theme: $theme"

# Import the selected theme
log_task "Importing theme into Terminal.app..."
open "$theme_file"
sleep 1

# Set the selected theme as default
if confirm "Do you want to make selected theme ($theme) the default?"; then
	profile_name="${theme%.terminal}"
	defaults write com.apple.Terminal "Startup Window Settings" -string "$profile_name"
	defaults write com.apple.Terminal "Default Window Settings" -string "$profile_name"
	log_task "Set $profile_name as the default profile."
fi

# Modify specific profile settings
if confirm "Do you want to modify settings for profile ($profile_name)?"; then
	declare -A profile_settings=(
		["BackgroundAlphaInactive"]=real:0.49
		["BackgroundBlur"]=real:0.15
		["BackgroundBlurInactive"]=integer:1
		["BackgroundSettingsForInactiveWindows"]=integer:0
		["Bell"]=integer:0
		["BellBadge"]=integer:0
		["BellBounce"]=integer:0
		["BookmarkRestorations"]=integer:0
		["CommandString"]=string:""
		["ConvertNewlinesOnPaste"]=integer:1
		["CursorBlink"]=integer:1
		["CursorType"]=integer:0
		["FontAntialias"]=integer:1
		["RestoreLines"]=integer:5000
		["RunCommandAsShell"]=integer:1
		["ShouldLimitScrollback"]=integer:0
		["ShouldRestoreContent"]=integer:0
		["ShowActiveProcessArgumentsInTabTitle"]=integer:0
		["ShowActiveProcessArgumentsInTitle"]=integer:0
		["ShowActiveProcessInTabTitle"]=integer:0
		["ShowActiveProcessInTitle"]=integer:0
		["ShowActivityIndicatorInTab"]=integer:1
		["ShowCommandKeyInTitle"]=integer:0
		["ShowComponentsWhenTabHasCustomTitle"]=integer:0
		["ShowDimensionsInTitle"]=integer:0
		["ShowRepresentedURLInTabTitle"]=integer:0
		["ShowRepresentedURLInTitle"]=integer:0
		["ShowRepresentedURLPathInTabTitle"]=integer:0
		["ShowRepresentedURLPathInTitle"]=integer:0
		["ShowShellCommandInTitle"]=integer:0
		["ShowTTYNameInTabTitle"]=integer:0
		["ShowTTYNameInTitle"]=integer:0
		["ShowTerminalInDockIcon"]=integer:0
		["ShowWindowSettingsNameInTitle"]=integer:0
		["UseBrightBold"]=integer:1
		["VisualBell"]=integer:1
		["VisualBellOnlyWhenMuted"]=integer:0
		["WindowTitle"]=string:""
		["columnCount"]=integer:80
		["rowCount"]=integer:24
		["shellExitAction"]=integer:1
		["useOptionAsMetaKey"]=integer:0

	)

	for key in "${!profile_settings[@]}"; do
		IFS=":" read -r type value <<<"${profile_settings[$key]}"
		/usr/libexec/PlistBuddy -c "Add :\"Window Settings\":\"$profile_name\":$key $type $value" "$terminal_plist" 2>/dev/null || {
			/usr/libexec/PlistBuddy -c "Set :\"Window Settings\":\"$profile_name\":$key $value" "$terminal_plist"
		}
		log_task "Updated $key to $value for profile ($profile_name)."
	done
fi

# Modify global defaults for Terminal
if confirm "Do you want to modify global Terminal settings?"; then
	defaults write com.apple.Terminal AutoMarkPromptLines -bool false
	defaults write com.apple.Terminal HasMigratedDefaults -bool true
	defaults write com.apple.Terminal NewTabSettingsBehavior -int 1
	defaults delete com.apple.Terminal NewTabWorkingDirectoryBehavior
	defaults write com.apple.Terminal SecureKeyboardEntry -bool false
	defaults write com.apple.Terminal Shell -string "/opt/homebrew/bin/bash -l"
	defaults write com.apple.Terminal ShowLineMarks -bool false
	log_task "Global Terminal settings updated."
fi

log_info "Custom settings applied successfully. Restart Terminal for changes to take effect."
