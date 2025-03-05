# Created by Ramsés Solano (sh4dow18)
# My Github: https://www.github.com/sh4dow18

# Aliases

alias ls "exa --group-directories-first"
alias cat "batcat"
alias tree "exa -T"
alias cp "gcp"
alias nirit-shutdown "systemctl poweroff"
alias nirit-reboot "systemctl reboot"

# Functions

# Helps to set custom wallpaper on nirit desktop
function nirit-set-wallpaper
	# Set a log file that saves the time the function was executed, as well as the arguments sent
	set LOGFILE ~/.config/nirit/logs/nirit-set-wallpaper.log
	echo Executed on: (date +"%Y-%m-%d %H:%M:%S %Z") >> $LOGFILE 2>&1
	echo "Input: $argv" >> $LOGFILE
	# If the user submitted less than 1 argument or submitted a "--help" argument, show help and exit
	set HELP "Usage: nirit-set-wallpaper NEW-WALLPAPER-PATH"
	if test (count $argv) -lt 1
    echo $HELP | tee -a $LOGFILE
    return
	end
	if contains -- "--help" $argv
		echo $HELP | tee -a $LOGFILE
		return
	end
	# Set the first argument as wallpaper
	set WALLPAPER $argv[1]
	# Copy wallpaper to Nirit Directory
	/bin/cp $WALLPAPER ~/.config/nirit/wallpaper.jpg >> $LOGFILE 2>&1
	# If the copy was successful, set the wallpaper, if not, no
	if test $status != 0
		echo "Wallpaper not Changed, $WALLPAPER not Found" | tee -a $LOGFILE
		echo "------------------------------------------" >> $LOGFILE
		return
	end
	feh --bg-scale ~/.config/nirit/wallpaper.jpg >> $LOGFILE 2>&1
	echo "Wallpaper Changed to $WALLPAPER" | tee -a $LOGFILE
	echo "------------------------------------------" >> $LOGFILE
end

# Helps set up an audio "Sink" in Qtile settings to manage it with keybinds
function nirit-set-sink
	# Set a log file that saves the time the function was executed, as well as the arguments sent
	set LOGFILE ~/.config/nirit/logs/nirit-set-sink.log
	echo Executed on: (date +"%Y-%m-%d %H:%M:%S %Z") >> $LOGFILE 2>&1
	echo "Input: $argv" >> $LOGFILE
	# If the user submitted a "--help" argument, show help and exit
	if contains -- "--help" $argv
		echo "Usage: nirit-set-sink" | tee -a $LOGFILE
		return
	end
	# Display Pamixer Sinks
	pamixer --list-sinks | tee -a $LOGFILE
	# Ask the user which sink wants to use
	echo -e "\nWhich number of sink do you choose to use?" | tee -a $LOGFILE
	read ANSWER
	# Check if the sink sent by the user is valid or not
	pamixer --list-sinks | grep alsa | cut -d " " -f 1 | grep $ANSWER >> $LOGFILE 2>&1
	if test $status != 0
		echo -e "\nSink $ANSWER is not valid" | tee -a $LOGFILE
		echo "------------------------------------------" >> $LOGFILE
		return
	end
	# If it is a valid sink, add it to qtile settings
	set CURRENT_SINK $(grep "sink =" ~/.config/qtile/config.py | cut -d " " -f 3) >> $LOGFILE 2>&1
	sed -i "s/sink = $CURRENT_SINK/sink = $ANSWER/g" ~/.config/qtile/config.py >> $LOGFILE 2>&1
	# Restart Qtile to apply changes
	echo -e "\nRestarting Qtile..." | tee -a $LOGFILE
	pkill -USR1 qtile >> $LOGFILE 2>&1
	echo "Sink changed to $ANSWER successfully" | tee -a $LOGFILE 2>&1
	echo "------------------------------------------" >> $LOGFILE
end

# Helps to add a program to rofi category easier and prettier
function nirit-add-to-category
	# Set a log file that saves the time the function was executed, as well as the arguments sent
	set LOGFILE ~/.config/nirit/logs/nirit-add-to-category.log
  echo Executed on: (date +"%Y-%m-%d %H:%M:%S %Z") >> $LOGFILE 2>&1
	echo "Input: $argv" >> $LOGFILE
	# If the user submitted less than 2 arguments or submitted a "--help" argument, show help and exit
	set HELP "Usage: nirit-add-to-category PROGRAM CATEGORY"
	if test (count $argv) -lt 2
    echo $HELP | tee -a $LOGFILE
    return
	end
	if contains -- "--help" $argv
		echo $HELP | tee -a $LOGFILE
		return
	end
	# Set found variable as not found
	set FOUND false
	# Set the first argument as the program
	set PROGRAM $argv[1]
	# Set the second argument as the category
	set CATEGORY $argv[2]
	# Find every desktop file that runs the program
	for DESKTOPFILE in (grep -l "Exec=.*$PROGRAM" /usr/share/applications/*.desktop)
		# If found a desktop file, set found as true
		set FOUND true
		# If the Categories section is in the file, change the categories to the submitted category, if not, add the category
		if grep -q "^Categories=" $DESKTOPFILE
			sudo sed -i "/^Categories=/c\Categories=$CATEGORY" $DESKTOPFILE
		else
			echo "Categories=$CATEGORY" | sudo tee -a $DESKTOPFILE > /dev/null
		end
	end
	# If a desktop file was found, it shows success, if not, the error
	if test $FOUND = true
		echo "$PROGRAM added in $CATEGORY category" | tee -a $LOGFILE
	else
		echo "$PROGRAM cannot be added in $CATEGORY category" | tee -a $LOGFILE
		echo "Reason: No desktop file found to run $PROGRAM"
	end
end

# Helps to install programs easier and prettier
function nirit-install
	# Set a log file that saves the time the function was executed, as well as the arguments sent
	set INSTALLLOGFILE ~/.config/nirit/logs/nirit-install.log
  echo Executed on: (date +"%Y-%m-%d %H:%M:%S %Z") >> $INSTALLLOGFILE 2>&1
	echo "Input: $argv" >> $INSTALLLOGFILE
	# If the user submitted less than 1 argument or submitted a "--help" argument, show help and exit
	set HELP "Usage: nirit-install PROGRAM [CATEGORY]"
	if test (count $argv) -lt 1
    echo $HELP | tee -a $INSTALLLOGFILE
    return
	end
	if contains -- "--help" $argv
		echo $HELP | tee -a $INSTALLLOGFILE
		return
	end
	# Set the second argument as the category
	set CATEGORY $argv[2]
	# Check if the category was submitted
	if test "$CATEGORY" != ""
		# Check if the submitted category is valid or not
		set CATEGORIESLIST "Audio" "Communication" "Development" "Devices" "Files" "Games" "Internet" "Multimedia" "Office" "Utilities" "Other"
		if ! contains $CATEGORY $CATEGORIESLIST
			echo "$CATEGORY is not a valid category" | tee -a $INSTALLLOGFILE
			return
		end
	end
	# Set the first argument as the program
	set PROGRAM $argv[1]
	# Try to install the program
	echo "Installing $PROGRAM..." | tee -a $INSTALLLOGFILE
	sudo apt-get install -y $PROGRAM >> $INSTALLLOGFILE 2>&1
	# Check if the program was installed or not
	if test $status != 0
		set REASON (cat $INSTALLLOGFILE | tail -n 1)
		echo "$PROGRAM cannot be installed" | tee -a $INSTALLLOGFILE
		echo "Reason: $REASON" | tee -a $INSTALLLOGFILE
		echo "------------------------------------------" >> $INSTALLLOGFILE
		return
	end
	echo "$PROGRAM installed" | tee -a $INSTALLLOGFILE
	# If the category was submitted, try adding the program to the submitted rofi category
	if test "$CATEGORY" != ""
		echo "Adding $PROGRAM to $CATEGORY category..." | tee -a $INSTALLLOGFILE
		nirit-add-to-category $PROGRAM $CATEGORY | tee -a $INSTALLLOGFILE
	end
	echo "------------------------------------------" >> $INSTALLLOGFILE
end

# Helps to uninstall programs easier and prettier
function nirit-uninstall
	# Set a log file that saves the time the function was executed, as well as the arguments sent
	set LOGFILE ~/.config/nirit/logs/nirit-uninstall.log
  echo Executed on: (date +"%Y-%m-%d %H:%M:%S %Z") >> $LOGFILE 2>&1
	echo "Input: $argv" >> $LOGFILE
	# If the user submitted less than 1 argument or submitted a "--help" argument, show help and exit
	set HELP "Usage: nirit-uninstall PROGRAM"
	if test (count $argv) -lt 1
    echo $HELP | tee -a $LOGFILE
    return
	end
	if contains -- "--help" $argv
		echo $HELP | tee -a $LOGFILE
		return
	end
	# Set the first argument as the program
	set PROGRAM $argv[1]
	# Try to uninstall the program and all those related to it
	echo "Uninstalling all programs that start with $PROGRAM..." | tee -a $LOGFILE
	bash -c "sudo apt-get purge -y $PROGRAM* && sudo apt-get autoremove -y" >> $LOGFILE 2>&1
	# Check if the program or programs were uninstalled or not
	if test $status != 0
		set REASON (cat $LOGFILE | tail -n 1)
		echo "$PROGRAM cannot be uninstalled" | tee -a $LOGFILE
		echo "Reason: $REASON" | tee -a $LOGFILE
		echo "------------------------------------------" >> $LOGFILE
		return
	end
	echo "$PROGRAM uninstalled" | tee -a $LOGFILE
	echo "------------------------------------------" >> $LOGFILE
end

# Helps to fix multimedia players in opera browser
function nirit-fix-opera
	# Set a log file that saves the time the function was executed, as well as the arguments sent
	set LOGFILE ~/.config/nirit/logs/nirit-fix-opera.log
  echo Executed on: (date +"%Y-%m-%d %H:%M:%S %Z") >> $LOGFILE 2>&1
	echo "Input: $argv" >> $LOGFILE
	# If the user submitted a "--help" argument, show help and exit
	if contains -- "--help" $argv
		echo "Usage: nirit-fix-opera" | tee -a $LOGFILE
		return
	end
	# Check if Opera Browser is installed
	ls /usr/bin/opera >> $LOGFILE 2>&1
	if test $status != 0
		echo "Opera is not Installed, install first to use this function" | tee -a $LOGFILE
		echo "------------------------------------------" >> $LOGFILE
	end
	# If Opera Browser is installed, try to get the FFMPEG Library release information
	echo "Downloading FFMPEG Library..." | tee -a $LOGFILE
	set RELEASE (wget -qO - https://api.github.com/repos/Ld-Hagen/fix-opera-linux-ffmpeg-widevine/releases)
	if test $status != 0
		echo "FFMPEG Library not Found in Github Releases"
		echo "------------------------------------------" >> $LOGFILE
		return
	end
	# If the FFMPEG Library release information was found, download the latest release
	wget $(echo $RELEASE | jq | grep browser_download_url | cut -d '"' -f 4 | grep linux-x64 | head -n 1) -O libffmpeg.so.zip >> $LOGFILE 2>&1
	unzip libffmpeg.so.zip >> $LOGFILE 2>&1
	# Then install the library
	echo "Installing FFMPEG Library..." | tee -a $LOGFILE
	sudo mv libffmpeg.so /usr/lib/x86_64-linux-gnu/opera/libffmpeg.so >> $LOGFILE 2>&1
	# Check if the installation was successful
	if test $status -eq 0
		echo "Opera Fixed, Restart Opera" | tee -a $LOGFILE
	else
		echo "Opera cannot be fixed"
	end
	# Remove the Zip Downloaded
	rm libffmpeg.so.zip >> $LOGFILE 2>&1
	echo "------------------------------------------" >> $LOGFILE
end

# Helps to clone github repositories easily
function nirit-clone-repository
	# Set a log file that saves the time the function was executed, as well as the arguments sent
	set LOGFILE ~/.config/nirit/logs/nirit-clone-repository.log
  echo Executed on: (date +"%Y-%m-%d %H:%M:%S %Z") >> $LOGFILE 2>&1
	echo "Input: $argv" >> $LOGFILE
	# If the user submitted less than 1 argument or submitted a "--help" argument, show help and exit
	set HELP "Usage: nirit-clone-repository GITHUB-USER/REPOSITORY-NAME [--dev Clone to Develop]"
	if test (count $argv) -lt 1
    echo $HELP | tee -a $LOGFILE
    return
	end
	if contains -- "--help" $argv
		echo $HELP | tee -a $LOGFILE
		return
	end
	# Set the first argument as the repository
	set REPOSITORY $argv[1] >> $LOGFILE 2>&1
	# If the "--dev" argument was sent, clone the repository with all commits, if not, clone it only with the latest commit
	if contains -- "--dev" $argv
		echo "Cloning as Dev..." | tee -a $LOGFILE
		git clone https://github.com/$REPOSITORY >> $LOGFILE 2>&1
	else
		echo "Cloning as Release..." | tee -a $LOGFILE
		git clone --depth 1 https://github.com/$REPOSITORY >> $LOGFILE 2>&1
	end
	# Check if the repository was cloned
	if test $status != 0
		# Check if the repository was not cloned because it is already cloned
		ls (echo $REPOSITORY | cut -d "/" -f 2) >> $LOGFILE 2>&1
		if test $status -eq 0
			echo "Repository $REPOSITORY already cloned" | tee -a $LOGFILE
		else
			echo "Repository $REPOSITORY not found" | tee -a $LOGFILE
		end
		echo "------------------------------------------" >> $LOGFILE
		return
	end
	echo "$REPOSITORY cloned successfully" | tee -a $LOGFILE
	echo "------------------------------------------" >> $LOGFILE
end

# Helps to install a github release from the repository sent
function nirit-github-install
	# Set a log file that saves the time the function was executed, as well as the arguments sent
	set LOGFILE ~/.config/nirit/logs/nirit-github-install.log
  echo Executed on: (date +"%Y-%m-%d %H:%M:%S %Z") >> $LOGFILE 2>&1
	echo "Input: $argv" >> $LOGFILE
	# If the user submitted less than 1 argument or submitted a "--help" argument, show help and exit
	set HELP "Usage: nirit-github-install GITHUB-USER/REPOSITORY-NAME [CATEGORY]"
	if test (count $argv) -lt 1
    echo $HELP | tee -a $LOGFILE
    return
	end
	if contains -- "--help" $argv
		echo $HELP | tee -a $LOGFILE
		return
	end
	# Set the second argument as the category
	set CATEGORY $argv[2]
	# Check if the category was submitted
	if test "$CATEGORY" != ""
		# Check if the submitted category is valid or not
		set CATEGORIESLIST "Audio" "Communication" "Development" "Devices" "Files" "Games" "Internet" "Multimedia" "Office" "Utilities" "Other"
		if ! contains $CATEGORY $CATEGORIESLIST
			echo "$CATEGORY is not a valid category" | tee -a $LOGFILE
			return
		end
	end
	# Set the first argument as the repository
	set REPOSITORY $argv[1]
	# Try to get the Release information
	echo "Searching Last Release of $REPOSITORY" | tee -a $LOGFILE
	set RELEASE $(wget -qO - https://api.github.com/repos/$REPOSITORY/releases) >> $LOGFILE 2>&1
	if test $status != 0
		echo "$REPOSITORY release not found" | tee -a $LOGFILE
		echo "------------------------------------------" >> $LOGFILE
		return
	end
	# If the Release information was found, set the release tag
	set TAG $(echo $RELEASE | jq | grep tag_name | cut -d '"' -f 4 | head -n 1) >> $LOGFILE 2>&1
	# Download the release found
	echo "$REPOSITORY $TAG found, downloading..." | tee -a $LOGFILE
	wget $(echo $RELEASE | jq | grep browser_download_url | cut -d '"' -f 4 | grep "amd64" | grep ".deb" | head -n 1) -O release.deb >> $LOGFILE 2>&1
	# Try to install release as a deb file
	echo "$REPOSITORY $TAG downloaded, trying to install..." | tee -a $LOGFILE
	sudo apt-get install -y ./release.deb >> $LOGFILE 2>&1
	# Check if the program was installed or not
	if test $status -eq 0
		echo "$REPOSITORY $TAG installed" | tee -a $LOGFILE
		# If the category was submitted, try adding the program to the submitted rofi category
		if test "$CATEGORY" != ""
			set PROGRAM (echo $REPOSITORY | cut -d "/" -f 2)
			echo "Adding $PROGRAM to $CATEGORY category..." | tee -a $LOGFILE
			nirit-add-to-category $PROGRAM $CATEGORY | tee -a $LOGFILE
		end
	else
		set REASON (cat $LOGFILE | tail -n 1)
		echo "$REPOSITORY $TAG was not installed" | tee -a $LOGFILE
		echo "Reason: $REASON" | tee -a $LOGFILE
	end
	rm release.deb >> $LOGFILE 2>&1
	echo "------------------------------------------" >> $LOGFILE
end

# Helps to init a github project faster and easily
function nirit-init-github-project
	# Set a log file that saves the time the function was executed, as well as the arguments sent
	set LOGFILE ~/.config/nirit/logs/nirit-init-github-project.log
  echo Executed on: (date +"%Y-%m-%d %H:%M:%S %Z") >> $LOGFILE 2>&1
	echo "Input: $argv" >> $LOGFILE
	# If the user submitted less than 1 argument or submitted a "--help" argument, show help and exit
	set HELP "Usage: nirit-init-github-project GITHUB-USER"
	if test (count $argv) -lt 1
    echo $HELP | tee -a $LOGFILE
    return
	end
	if contains -- "--help" $argv
		echo $HELP | tee -a $LOGFILE
		return
	end
	# Set the first argument as the Github user
	set USER $argv[1]
	# Set directory name as repository name
	set REPOSITORY (pwd | sed "s/\//\n/g" | tail -n 1)
	# Initialize a Git Project
	echo "Starting Git Project..." | tee -a $LOGFILE
	git init >> $LOGFILE 2>&1
	echo "Adding Project Files to Staged Area..." | tee -a $LOGFILE
	git add . >> $LOGFILE 2>&1
	echo "Making First Commit..." | tee -a $LOGFILE
	git commit -m "add: init project" >> $LOGFILE 2>&1
	echo "Changing Branch Name to Main..." | tee -a $LOGFILE
	git branch -m main >> $LOGFILE 2>&1
	echo "Adding Github Remote Origin..." | tee -a $LOGFILE
	git remote add origin "https://github.com/$USER/$REPOSITORY.git" >> $LOGFILE 2>&1
	echo "Pushing Project to Github..." | tee -a $LOGFILE
	git push -u origin main >> $LOGFILE 2>&1
	# Check if the repository was pushed to Github
	if test $status != 0
		echo "Project Created as $REPOSITORY, but cannot push to Github" | tee -a $LOGFILE
		echo "------------------------------------------" >> $LOGFILE
		return
	end
	echo "Project Created and Pushed Successfully in https://github.com/$USER/$REPOSITORY" | tee -a $LOGFILE
	echo "------------------------------------------" >> $LOGFILE
end

# Helps to install a deb app from url faster and easily
function nirit-install-from-url
	# Set a log file that saves the time the function was executed, as well as the arguments sent
	set LOGFILE ~/.config/nirit/logs/nirit-install-from-url.log
  echo Executed on: (date +"%Y-%m-%d %H:%M:%S %Z") >> $LOGFILE 2>&1
	echo "Input: $argv" >> $LOGFILE
	# If the user submitted less than 1 argument or submitted a "--help" argument, show help and exit
	set HELP "Usage: nirit-install-from-url URL"
	if test (count $argv) -lt 1
    echo $HELP | tee -a $LOGFILE
    return
	end
	if contains -- "--help" $argv
		echo $HELP | tee -a $LOGFILE
		return
	end
	# Set the first argument as the program URL
	set URL $argv[1]
	# Set the from domain variable with the URL domain
	set FROMDOMAIN $(echo $URL | cut -d "/" -f 3) >> $LOGFILE 2>&1
	# Set DEB variable as the domain with a ".deb"
	set DEB "$FROMDOMAIN.deb"
	# Try to download the program
	echo "Getting Program from $FROMDOMAIN..." | tee -a $LOGFILE
	wget $URL -O $DEB >> $LOGFILE 2>&1
	# Check if the program was downloaded
	if test $status != 0
		echo "$DEB not found" | tee -a $LOGFILE
		echo "------------------------------------------" >> $LOGFILE
		return
	end
	# Try to install the program
	echo "Installing $DEB..." | tee -a $LOGFILE
	sudo apt-get install -y ./$DEB >> $LOGFILE 2>&1
	# Check if the program was installed
	if test $status != 0
		set REASON (cat $LOGFILE | tail -n 1)
		echo "$DEB cannot be installed" | tee -a $LOGFILE
		echo "Reason: $REASON" | tee -a $LOGFILE
		return
	else
		echo "$DEB Installed" | tee -a $LOGFILE
	end
	# Remove the deb file downloaded
	rm $DEB >> $LOGFILE 2>&1
	echo "------------------------------------------" >> $LOGFILE
end

# Helps to update all apps in nirit system faster and easily
function nirit-update-system
	# Set a log file that saves the time the function was executed, as well as the arguments sent
	set UPDATELOGFILE ~/.config/nirit/logs/nirit-update-system.log
  echo Executed on: (date +"%Y-%m-%d %H:%M:%S %Z") >> $UPDATELOGFILE 2>&1
	echo "Input: $argv" >> $UPDATELOGFILE
	# If the user submitted "--help" argument, show help and exit
	if contains -- "--help" $argv
		echo "Usage: nirit-update-system [-v (More Verbose)]" | tee -a $UPDATELOGFILE
		return
	end
	# Try to Update Deb Apps
	echo "Updating APT Programs..." | tee -a $UPDATELOGFILE
	if test "$argv[1]" = "-v"
		sudo apt-get update | tee -a $UPDATELOGFILE 2>&1
		sudo apt-get upgrade -y | tee -a $UPDATELOGFILE 2>&1
		echo "" | tee -a $UPDATELOGFILE 2>&1
	else
		sudo apt-get update >> $UPDATELOGFILE 2>&1
		sudo apt-get upgrade -y >> $UPDATELOGFILE 2>&1
	end
	# Check if the update did
	if test $status != 0
		echo "APT Programs cannot be updated"
	end
	# Remove all junk programs
	sudo apt-get autoremove -y >> $UPDATELOGFILE 2>&1
	# Try to Update Deb Apps outsite APT
	echo "Updating DEB Programs outside APT..." | tee -a $UPDATELOGFILE
	# Check if Onlyoffice is installed, if it is, update it
	ls /usr/bin/onlyoffice-desktopeditors >> $UPDATELOGFILE 2>&1
	set ONLYOFFICE $status
	if test $ONLYOFFICE -eq 0
		echo -e "\nUpdating Onlyoffice..." | tee -a $UPDATELOGFILE
		nirit-install-from-url "https://download.onlyoffice.com/install/desktop/editors/linux/onlyoffice-desktopeditors_amd64.deb" | tee -a $UPDATELOGFILE
		echo "" | tee -a $UPDATELOGFILE
	end
	# Check if Discord is installed, if it is, update it
	ls /usr/bin/discord >> $UPDATELOGFILE 2>&1
	if test $status -eq 0
		if test $ONLYOFFICE != 0
			echo -e "\n" | tee -a $UPDATELOGFILE
		end
		echo "Updating Discord..." | tee -a $UPDATELOGFILE
		nirit-install-from-url "https://discord.com/api/download?platform=linux&format=deb" | tee -a $UPDATELOGFILE
		echo "" | tee -a $UPDATELOGFILE
	end
	# Try to Update Github releases to latest
	echo "Updating Github Releases..." | tee -a $UPDATELOGFILE
	# Check if Heroic is installed, if it is, update it
	ls /usr/bin/heroic >> $UPDATELOGFILE 2>&1
	set HEROIC $status
	if test $HEROIC -eq 0
		echo -e "\nUpdating Heroic Games Launcher..." | tee -a $UPDATELOGFILE
		nirit-github-install Heroic-Games-Launcher/HeroicGamesLauncher | tee -a $UPDATELOGFILE
		echo "" | tee -a $UPDATELOGFILE
	end
	# Check if Teams for Linux is installed, if it is, update it
	ls /usr/bin/teams-for-linux >> $UPDATELOGFILE 2>&1
	if test $status -eq 0
		if test $HEROIC != 0
			echo -e "\n" | tee -a $UPDATELOGFILE
		end
		echo "Updating Teams for Linux..." | tee -a $UPDATELOGFILE
		nirit-github-install IsmaelMartinez/teams-for-linux | tee -a $UPDATELOGFILE
		echo "" | tee -a $UPDATELOGFILE
	end
	echo -e "Update Complete" | tee -a $UPDATELOGFILE
	echo "------------------------------------------" >> $UPDATELOGFILE
end

# Helps to show Nirit actual information
function nirit-information
	echo "Nirit Version: v2.0.0"
	echo "Mode Installed: Normal"
	echo "Repository URL: https://github.com/sh4dow18/nirit"
	echo "Created By: Ramsés Solano (sh4dow18)"
	echo "Last Update: 11/21/2024"
end

# Helps to update Nirit Project faster and easily
function nirit-update-project
	# Set a log file that saves the time the function was executed, as well as the arguments sent
	set LOGFILE ~/.config/nirit/logs/nirit-update-project.log
  echo Executed on: (date +"%Y-%m-%d %H:%M:%S %Z") >> $LOGFILE 2>&1
	echo "Input: $argv" >> $LOGFILE
	# If the user submitted "--help" argument, show help and exit
	if contains -- "--help" $argv
		echo "Usage: nirit-update-project" | tee -a $LOGFILE
		return
	end
	# Try to get the Last Nirit Release information
	echo "Searching Nirit Project Updates..."
	set RELEASE (wget -qO - https://api.github.com/repos/sh4dow18/nirit/releases) >> $LOGFILE 2>&1
	if test $status != 0
		echo "Nirit Releases not Found" | tee -a $LOGFILE
		echo "------------------------------------------" >> $LOGFILE
		return
	end
	# If the Last Nirit Release information was found, set the tag and body information
	set TAG (echo $RELEASE | jq | grep tag_name | cut -d '"' -f 4 | head -n 1 | string trim) >> $LOGFILE 2>&1
	set CURRENT_VERSION (cat ~/.config/fish/config.fish | grep "Nirit Version" | cut -d ":" -f 2 | sed "s/  *//g" | cut -d '"' -f 1 | head -n 1)
	# Check if the tag of the latest version is the same as the current one
	if test "$CURRENT_VERSION" = "$TAG"
		echo "Nirit Project is up to date" | tee -a $LOGFILE
		return
	else
		# If a newer version is found, displays the latest version information
		echo -e "\nNew Nirit Release $TAG Found\n" | tee -a $LOGFILE
		echo "$TAG Description: https://github.com/sh4dow18/nirit/releases/tag/$TAG" | tee -a $LOGFILE
		# Ask the user if wants to install the new version
    echo -e "\nDo you want to update Nirit Project? (y/n): "
		read ANSWER
		# Check if the user wants to install the release
		if test "$ANSWER" = "y"
			# Clone the Nirit last release
			echo -e "\nCloning Nirit $TAG..." | tee -a $LOGFILE
			git clone --depth 1 https://github.com/sh4dow18/nirit.git >> $LOGFILE 2>&1
			# Run the Nirit Installer with Update Method
			echo "Opening Nirit $TAG Updater..." | tee -a $LOGFILE
			sudo bash nirit/nirit-installer.sh -u | tee -a $LOGFILE
			# Check if the Nirit Update was successful
			if test $pipestatus[1] != 0
				echo "Nirit not Updated" | tee -a $LOGFILE
			else
				echo "Nirit Updated" | tee -a $LOGFILE
			end
			# Remove Nirit Local Repository
			sudo rm -r nirit/ >> $LOGFILE 2>&1
		else
			echo "Nirit not Updated" | tee -a $LOGFILE
		end
	end
	echo "------------------------------------------" >> $LOGFILE
end

# Helps to Clean Nirit File System
function nirit-cleaner
	# Set a log file that saves the time the function was executed, as well as the arguments sent
	set CLEANLOGFILE ~/.config/nirit/logs/nirit-cleaner.log
  echo Executed on: (date +"%Y-%m-%d %H:%M:%S %Z") >> $CLEANLOGFILE 2>&1
	echo "Input: $argv" >> $CLEANLOGFILE
	# If the user submitted "--help" argument, show help and exit
	if contains -- "--help" $argv
		echo "Usage: nirit-cleaner" | tee -a $CLEANLOGFILE
		return
	end
	# Try to remove tmp directory files
	echo "Removing Temp Files..." | tee -a $CLEANLOGFILE
	bash -c "sudo rm -r /tmp/*" >> $CLEANLOGFILE 2>&1
	# Delete all junk programs and cache
	echo "Cleaning APT..." | tee -a $CLEANLOGFILE
	sudo apt-get clean -y >> $CLEANLOGFILE 2>&1
	sudo apt-get autoremove -y --purge >> $CLEANLOGFILE 2>&1
	# Delete all files from the trash
	echo "Erasing Trash Bin Files..." | tee -a $CLEANLOGFILE
	bash -c "sudo rm -r /home/sh4dow18/.local/share/Trash/files/*" >> $CLEANLOGFILE 2>&1
	bash -c "sudo rm -r /home/sh4dow18/.local/share/Trash/info/*" >> $CLEANLOGFILE 2>&1
	# Delete all desktop files that are for cli applications
	echo "Removing Terminal Desktop Files..." | tee -a $CLEANLOGFILE
	grep -l "Terminal=true" /usr/share/applications/*.desktop | xargs sudo rm -f >> $CLEANLOGFILE 2>&1
	echo "Cleaning Complete" | tee -a $CLEANLOGFILE
	echo "------------------------------------------" >> $CLEANLOGFILE
end

# Helps to show nirit logs from all nirit programs
function nirit-log
	# If the user submitted less than 1 argument or submitted a "--help" argument, show help and exit
	set HELP "Usage: nirit-log NIRIT-PROGRAM"
	if test (count $argv) -lt 1
    echo $HELP
    return
	end
	if contains -- "--help" $argv
		echo $HELP
		return
	end
	# If the only argument sent is "--clean", delete all nirit logs
	if test "$argv" = "--clean"
		bash -c "rm ~/.config/nirit/logs/* > /dev/null 2>&1"
		echo "Nirit Logs Removed"
		return
	end
	# Set the first argument as the program
	set PROGRAM $argv[1]
	# Set a list with all nirit programs that do not keep logs
	set NOLOGSLIST "nirit-log" "nirit-information" "nirit-shutdown" "nirit-reboot"
	# Check if the program keeps logs
	if contains $PROGRAM $NOLOGSLIST
		echo "$PROGRAM does not keep logs"
		return
	end
	# Check if the program is a nirit application
	if not string match -q "nirit*" $PROGRAM
		echo "$PROGRAM is not a Nirit App"
		return
	end
	# Check if the nirit app already has logs
	ls ~/.config/nirit/logs/$PROGRAM.log > /dev/null 2>&1
	if test $status != 0
		echo "$PROGRAM have no logs"
		return
	end
	# Show nirit application logs
	cat ~/.config/nirit/logs/$PROGRAM.log
end
# Helps create a desktop file for new apps without one
function nirit-create-desktop-file
	# Set a log file that saves the time the function was executed, as well as the arguments sent
	set LOGFILE ~/.config/nirit/logs/nirit-create-desktop-file.log
  echo Executed on: (date +"%Y-%m-%d %H:%M:%S %Z") >> $LOGFILE 2>&1
	echo "Input: $argv" >> $LOGFILE
	# If the user submitted less than 1 argument or submitted a "--help" argument, show help and exit
	set HELP "Usage: nirit-create-desktop-file PROGRAM_NAME PROGRAM_PATH ICON_PATH"
	if test (count $argv) -lt 3
    echo $HELP | tee -a $LOGFILE
    return
	end
	if contains -- "--help" $argv
		echo $HELP | tee -a $LOGFILE
		return
	end
	# Set the first argument as the program's name
	set PROGRAM_NAME $argv[1]
	# Set the second argument as the program's path
	set PROGRAM_PATH $argv[2]
	# Set the first argument as the program's icon path
	set ICON_PATH $argv[3]
	# Creating File
	echo "Creating Desktop File..." | tee -a $LOGFILE
	echo -e "[Desktop Entry]\nName=$PROGRAM_NAME\nExec=$PROGRAM_PATH\nType=Application\nIcon=$ICON_PATH" | sudo tee /usr/share/applications/$PROGRAM_NAME.desktop >> $LOGFILE 2>&1
	# Check if the desktop file was created or not
	if test $status != 0
		set REASON (cat $LOGFILE | tail -n 1)
		echo "Desktop file was not created to $PROGRAM_NAME" | tee -a $LOGFILE
		echo "Reason: $REASON" | tee -a $LOGFILE
		return
	end
	echo "Desktop file was created to $PROGRAM_NAME" | tee -a $LOGFILE
end
# Helps to easily install packages that are not easy to install with apt
function nirit-package-manager
 	# Set a log file that saves the time the function was executed, as well as the arguments sent
	set NPG_LOGFILE ~/.config/nirit/logs/nirit-package-manager.log
  echo Executed on: (date +"%Y-%m-%d %H:%M:%S %Z") >> $NPG_LOGFILE 2>&1
	echo "Input: $argv" >> $NPG_LOGFILE
	# If the user submitted less than 1 argument or submitted a "--help" argument, show help and exit
	set HELP "Usage: nirit-package-manager PROGRAM_NAME\n\nAvailable Programs:\n\n\t- Onlyoffice Desktop Editors (use: onlyoffice)\n\t- Steam (use: steam)\n\t- Heroic Games Launcher (use: heroic)\n\t- Discord (use: discord)\n\t- Microsoft Teams (use: teams)\n"
	if test (count $argv) -lt 1
    echo -e $HELP | tee -a $NPG_LOGFILE
    return
	end
	if contains -- "--help" $argv
		echo -e $HELP | tee -a $NPG_LOGFILE
		return
	end
	# Set the first argument as the program
	set PROGRAM "$argv[1]"
	echo -e "Installing $PROGRAM..." | tee -a $NPG_LOGFILE
	# Check what package is to download it and install it
	if test $PROGRAM = "onlyoffice"
		nirit-install-from-url "https://download.onlyoffice.com/install/desktop/editors/linux/onlyoffice-desktopeditors_amd64.deb" | tee -a $NPG_LOGFILE
		nirit-add-to-category "onlyoffice-desktopeditors" "Office" | tee -a $NPG_LOGFILE
	else if test $PROGRAM = "discord"
		nirit-install-from-url "https://discord.com/api/download?platform=linux&format=deb" | tee -a $NPG_LOGFILE
		nirit-add-to-category "discord" "Communication" | tee -a $NPG_LOGFILE
	else if test $PROGRAM = "heroic"
		nirit-github-install Heroic-Games-Launcher/HeroicGamesLauncher | tee -a $NPG_LOGFILE
		nirit-add-to-category "heroic" "Games" | tee -a $NPG_LOGFILE
	else if test $PROGRAM = "teams"
		nirit-github-install IsmaelMartinez/teams-for-linux | tee -a $NPG_LOGFILE
		nirit-add-to-category "teams-for-linux" "Communication" | tee -a $NPG_LOGFILE
	else if test $PROGRAM = "steam"
		# If it is steam, check if it is available to install it from apt
		set FILE /etc/apt/sources.list
		set ORIGINAL_LINE (grep -v "#" $FILE | grep "deb" | head -n 1)
		set NEW_LINE "$ORIGINAL_LINE contrib non-free"
		sudo sed -i "s|^$ORIGINAL_LINE|$NEW_LINE|" $FILE
		sudo dpkg --add-architecture i386
		sudo apt-get update >> $NPG_LOGFILE 2>&1
		sudo apt-get install -y mesa-vulkan-drivers libglx-mesa0:i386 mesa-vulkan-drivers:i386 libgl1-mesa-dri:i386 steam-installer >> $NPG_LOGFILE 2>&1
		if test $status -eq 0
			echo "Steam was installed sucessfully" | tee -a $NPG_LOGFILE
		else
			echo "Steam Cannot be installed" | tee -a $NPG_LOGFILE
		end
		nirit-add-to-category "steam" "Games" | tee -a $NPG_LOGFILE
	else
		echo "Program not Found in Available Programs" | tee -a $NPG_LOGFILE
	end
end