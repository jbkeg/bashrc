#!/usr/bin/env bash

# Save history on logout
history -a

# Clear temporary files (optional, customize path as needed)
rm -f "$HOME/tmp/*"

# Display a goodbye message
echo "Goodbye, $(whoami)! You logged out at $(date)."

# Optionally unmount network drives (example only)
# umount /Volumes/SomeNetworkDrive

# Clear the screen to protect privacy
clear
