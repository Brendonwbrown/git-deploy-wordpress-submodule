#!/bin/bash

# Tweaked and tested on 6/16/14 by Brendon W. Brown
# Credits to Ryan Sechrest for original script.
# Deploys pushed branch from the origin repository to webdir

if [[ (-n $1) && (-n $2) && (-n $3) ]]; then

	# Change homedir username
	homedir="/home/username"

	# No need to edit these variables
	webdir="$homedir/public_html/$3/$2"
	gitdir="$homedir/repositories/$1.git"

	# For each branch that was pushed
	while read oldrev newrev refname
	do
		# Get branch name
		branch=$(git rev-parse --symbolic --abbrev-ref $refname)
		echo "> Received $branch branch"

		echo "> Processing $branch branch"

		# Unset global GIT_DIR so script can leave repository
		unset GIT_DIR
		echo "> Unset GIT_DIR"

		# Make then move into webdir
		if [ ! -d "$webdir" ]; then
			echo "> Had to create $webdir"
			mkdir "$webdir"
		fi

		cd $webdir
		echo "> Moved into $webdir"

		# If webdir is empty
		if find . -maxdepth 0 -empty | read; then
			echo "> Determined webdir is empty"

			# Clone branch from origin repository into webdir
			git clone $gitdir -b $branch .
			echo "> Cloned origin/$branch branch from $1.git repository into webdir"

			# Create empty file to remember created date
			touch $webdir/.created
			echo "> Created .created file in webdir"

		# If webdir is not empty	
		else
			echo "> Determined webdir contains files"

			# Get HEAD of working directory
			current_branch=$(git rev-parse --abbrev-ref HEAD)
			echo "> Determined working directory is on $current_branch branch"

			# If branch matches HEAD of working directory
			if [ "$branch" == "$current_branch" ]; then
				echo "> Determined updates affect current branch"

				# Fetch and merge changes into webdir
				git pull origin $branch
				echo "> Pulled origin/$branch into $branch branch in webdir"

			# If branch does not match HEAD of working directory
			else
				echo "> Determined updates belong to new branch"

				# Fetch changes from origin
				git fetch origin
				echo "> Fetched changes from origin"

				# Checkout new branch
				git checkout $branch
				echo "> Checked out $branch branch in webdir"
			fi				

			# Create or update empty file to remember last updated date
			touch $webdir/.updated
			echo "> Updated .updated file in webdir"
		fi
		
		# Fetch commits and tags for each submodule
		git submodule foreach git fetch --tags
		echo "> Fetched commits and tags for each submodule"

		# Update all submodules
		git submodule update --init --recursive
		echo "> Initialized and updated all submodules"

		# If website is WordPress powered
		if [ -d "$webdir/wordpress" ]; then
			echo "> Determined website runs WordPress"

			# If uploads directory does not exist
			if [ ! -d "$webdir/content/uploads" ]; then
				echo '> Determined webdir/content/uploads does not exist'

				# Create uploads directory
				mkdir $webdir/content/uploads
				echo '> Created uploads directory in webdir/content'

				# Give Apache permissions to write to uploads
				chmod g+w $webdir/content/uploads
				echo '> Added write permissions to webdir/content/uploads'
			fi

			# If w3-total-cache directory exists
			if [ -d "$webdir/content/plugins/w3-total-cache" ]; then
				echo "> Determined WordPress has W3 Total Cache installed"

				# If cache directory does not exist
				if [ ! -d "$webdir/content/cache" ]; then
					echo "> Determined webdir/content/cache does not exist"

					# Create cache directory for cache files
					mkdir $webdir/content/cache
					echo "> Created cache directory in webdir/content"

					# Allow Apache to write to cache
					chmod g+w $webdir/content/cache
					echo "> Added write permissions to webdir/content/cache"
				fi

				# If w3tc-config directory does not exist
				if [ ! -d "$webdir/content/w3tc-config" ]; then
					echo "> Determined webdir/content/w3tc-config does not exist"

					# Create w3tc-config directory for configuration files
					mkdir $webdir/content/w3tc-config
					echo "> Created w3tc-config directory in webdir/content"

					# Allow Apache to write to w3tc-config
					chmod g+w $webdir/content/w3tc-config
					echo "> Added write permissions to webdir/content/w3tc-config"
				fi
			fi
		fi
	done

# Print arguments to debug
else
	echo "Not all required variables have values:"
	echo "> FULL_DOMAIN: $1"
	echo "> ROOT_DOMAIN: $2"
	echo "> SUB_DOMAIN: $3"
fi