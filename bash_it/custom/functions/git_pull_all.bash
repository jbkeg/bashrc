#!/usr/bin/env bash

git_pull_all() {
	# Define the parent directory as the current working directory
	parent_directory=$(pwd)

	# Iterate through each subdirectory
	for directory in */; do
		# Check if it's a directory and a Git repository
		if [[ -d "$directory/.git" ]]; then
			echo "Updating Git repository: $directory"
			# Change into the Git repository
			cd "$directory" || exit
			# Fetch all branches and pull the latest changes
			git fetch --all
			git pull --all
			# Change back to the original directory
			cd "$parent_directory" || exit
		else
			echo "$directory is not a Git repository"
		fi
	done
}
