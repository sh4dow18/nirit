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
	set LOGFILE ~/.config/nirit/logs/nirit-set-wallpaper.log
	echo Executed on: (date +"%Y-%m-%d %H:%M:%S %Z") >> $LOGFILE 2>&1
	echo "Input: $argv" >> $LOGFILE
	set HELP "Usage: nirit-set-wallpaper NEW-WALLPAPER-PATH"
	if test (count $argv) -lt 1
    echo $HELP | tee -a $LOGFILE
    return
	end
	if contains -- "--help" $argv
		echo $HELP | tee -a $LOGFILE
		return
	end
	set WALLPAPER $argv[1]
	/bin/cp $WALLPAPER ~/.config/nirit/wallpaper.jpg >> $LOGFILE 2>&1
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
	set LOGFILE ~/.config/nirit/logs/nirit-set-sink.log
	echo Executed on: (date +"%Y-%m-%d %H:%M:%S %Z") >> $LOGFILE 2>&1
	echo "Input: $argv" >> $LOGFILE
	if contains -- "--help" $argv
		echo "Usage: nirit-set-sink" | tee -a $LOGFILE
		return
	end
	pamixer --list-sinks | tee -a $LOGFILE
	echo -e "\nWhich number of sink do you choose to use?" | tee -a $LOGFILE
	read ANSWER
	pamixer --list-sinks | grep alsa | cut -d " " -f 1 | grep $ANSWER >> $LOGFILE 2>&1
	if test $status != 0
		echo -e "\nSink $ANSWER is not valid" | tee -a $LOGFILE
		echo "------------------------------------------" >> $LOGFILE
		return
	end
	set ACTUAL_SINK $(grep "sink =" ~/.config/qtile/config.py | cut -d " " -f 3) >> $LOGFILE 2>&1
	sed -i "s/sink = $ACTUAL_SINK/sink = $ANSWER/g" ~/.config/qtile/config.py >> $LOGFILE 2>&1
	echo -e "\nRestarting Qtile..." | tee -a $LOGFILE
	pkill -USR1 qtile >> $LOGFILE 2>&1
	echo "Sink changed to $ANSWER successfully" | tee -a $LOGFILE 2>&1
	echo "------------------------------------------" >> $LOGFILE
end

# Helps to add a program to rofi category easier and prettier
function nirit-add-to-category
	set LOGFILE ~/.config/nirit/logs/nirit-add-to-category.log
  echo Executed on: (date +"%Y-%m-%d %H:%M:%S %Z") >> $LOGFILE 2>&1
	echo "Input: $argv" >> $LOGFILE
	set HELP "Usage: nirit-add-to-category PROGRAM CATEGORY"
	if test (count $argv) -lt 2
    echo $HELP | tee -a $LOGFILE
    return
	end
	if contains -- "--help" $argv
		echo $HELP | tee -a $LOGFILE
		return
	end
	set FOUND false
	set PROGRAM $argv[1]
	set CATEGORY $argv[2]
	for DESKTOPFILE in (grep -l "Exec=$PROGRAM" /usr/share/applications/*.desktop)
		set FOUND true
		if grep -q "^Categories=" $DESKTOPFILE
			sudo sed -i "/^Categories=/c\Categories=$CATEGORY" $DESKTOPFILE
		else
			echo "Categories=$CATEGORY" | sudo tee -a $DESKTOPFILE > /dev/null
		end
	end
	if test $FOUND = true
		echo "$PROGRAM added in $CATEGORY category" | tee -a $LOGFILE
	else
		echo "$PROGRAM cannot be added in $CATEGORY category" | tee -a $LOGFILE
	end
end

# Helps to install programs easier and prettier
function nirit-install
	set INSTALLLOGFILE ~/.config/nirit/logs/nirit-install.log
  echo Executed on: (date +"%Y-%m-%d %H:%M:%S %Z") >> $INSTALLLOGFILE 2>&1
	echo "Input: $argv" >> $INSTALLLOGFILE
	set HELP "Usage: nirit-install PROGRAM CATEGORY"
	if test (count $argv) -lt 2
    echo $HELP | tee -a $INSTALLLOGFILE
    return
	end
	if contains -- "--help" $argv
		echo $HELP | tee -a $INSTALLLOGFILE
		return
	end
	set CATEGORIESLIST "Audio" "Communication" "Development" "Devices" "Files" "Games" "Internet" "Multimedia" "Office" "Utilities" "Other"
	set CATEGORY $argv[2]
	if ! contains $CATEGORY $CATEGORIESLIST
		echo "$CATEGORY is not a valid category" | tee -a $INSTALLLOGFILE
		return
	end
	set PROGRAM $argv[1]
	echo "Installing $PROGRAM..."
	sudo apt-get install -y $PROGRAM >> $INSTALLLOGFILE 2>&1
	if test $status != 0
		echo "$PROGRAM cannot be installed" | tee -a $INSTALLLOGFILE
		echo "------------------------------------------" >> $INSTALLLOGFILE
		return
	end
	echo "$PROGRAM installed" | tee -a $INSTALLLOGFILE
	echo "Adding $PROGRAM to $CATEGORY category..." | tee -a $INSTALLLOGFILE
	nirit-add-to-category $PROGRAM $CATEGORY | tee -a $INSTALLLOGFILE
	echo "------------------------------------------" >> $INSTALLLOGFILE
end

# Helps to uninstall programs easier and prettier
function nirit-uninstall
	set LOGFILE ~/.config/nirit/logs/nirit-uninstall.log
  echo Executed on: (date +"%Y-%m-%d %H:%M:%S %Z") >> $LOGFILE 2>&1
	echo "Input: $argv" >> $LOGFILE
	set HELP "Usage: nirit-uninstall PROGRAM"
	if test (count $argv) -lt 1
    echo $HELP | tee -a $LOGFILE
    return
	end
	if contains -- "--help" $argv
		echo $HELP | tee -a $LOGFILE
		return
	end
	set PROGRAM $argv[1]
	echo -e "Uninstalling all programs that start with $PROGRAM..." | tee -a $LOGFILE
	bash -c "sudo apt-get purge -y $PROGRAM* && sudo apt-get autoremove -y" >> $LOGFILE 2>&1
	if test $status != 0
		echo "$PROGRAM cannot be uninstalled" | tee -a $LOGFILE
		echo "------------------------------------------" >> $LOGFILE
		return
	end
	echo "$PROGRAM uninstalled" | tee -a $LOGFILE
	echo "------------------------------------------" >> $LOGFILE
end

# Helps to fix multimedia players in opera browser
function nirit-fix-opera
	set LOGFILE ~/.config/nirit/logs/nirit-fix-opera.log
  echo Executed on: (date +"%Y-%m-%d %H:%M:%S %Z") >> $LOGFILE 2>&1
	echo "Input: $argv" >> $LOGFILE
	if contains -- "--help" $argv
		echo "Usage: nirit-fix-opera" | tee -a $LOGFILE
		return
	end
	ls /usr/bin/opera >> $LOGFILE 2>&1
	if test $status != 0
		echo "Opera is not Installed, install first to use this function" | tee -a $LOGFILE
		echo "------------------------------------------" >> $LOGFILE
	end
	echo "Downloading FFMPEG Library..." | tee -a $LOGFILE
	set RELEASE (wget -qO - https://api.github.com/repos/Ld-Hagen/fix-opera-linux-ffmpeg-widevine/releases)
	if test $status != 0
		echo "FFMPEG Library not Found in Github Releases"
		echo "------------------------------------------" >> $LOGFILE
		return
	end
	wget $(echo $RELEASE | jq | grep browser_download_url | cut -d '"' -f 4 | grep linux-x64 | head -n 1) -O libffmpeg.so.zip >> $LOGFILE 2>&1
	unzip libffmpeg.so.zip >> $LOGFILE 2>&1
	echo "Installing FFMPEG Library..." | tee -a $LOGFILE
	sudo mv libffmpeg.so /usr/lib/x86_64-linux-gnu/opera/libffmpeg.so >> $LOGFILE 2>&1
	if test $status -eq 0
		echo "Opera Fixed, Restart Opera" | tee -a $LOGFILE
	else
		echo "Opera cannot be fixed"
	end
	rm libffmpeg.so.zip >> $LOGFILE 2>&1
	echo "------------------------------------------" >> $LOGFILE
end

# Helps to clone github repositories easily
function nirit-clone-repository
	set LOGFILE ~/.config/nirit/logs/nirit-clone-repository.log
  echo Executed on: (date +"%Y-%m-%d %H:%M:%S %Z") >> $LOGFILE 2>&1
	echo "Input: $argv" >> $LOGFILE
	set HELP "Usage: nirit-clone-repository GITHUB-USER/REPOSITORY-NAME [--dev Clone to Develop]"
	if test (count $argv) -lt 1
    echo $HELP | tee -a $LOGFILE
    return
	end
	if contains -- "--help" $argv
		echo $HELP | tee -a $LOGFILE
		return
	end
	set REPOSITORY $argv[1] >> $LOGFILE 2>&1
	if contains -- "--dev" $argv
		echo "Cloning as Dev..." | tee -a $LOGFILE
		git clone https://github.com/$REPOSITORY >> $LOGFILE 2>&1
	else
		echo "Cloning as Release..." | tee -a $LOGFILE
		git clone --depth 1 https://github.com/$REPOSITORY >> $LOGFILE 2>&1
	end
	if test $status != 0
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
	set LOGFILE ~/.config/nirit/logs/nirit-github-install.log
  echo Executed on: (date +"%Y-%m-%d %H:%M:%S %Z") >> $LOGFILE 2>&1
	echo "Input: $argv" >> $LOGFILE
	set HELP "Usage: nirit-github-install GITHUB-USER/REPOSITORY-NAME"
	if test (count $argv) -lt 1
    echo $HELP | tee -a $LOGFILE
    return
	end
	if contains -- "--help" $argv
		echo $HELP | tee -a $LOGFILE
		return
	end
	set REPOSITORY $argv[1]
	echo "Searching Last Release of $REPOSITORY" | tee -a $LOGFILE
	set RELEASE $(wget -qO - https://api.github.com/repos/$REPOSITORY/releases) >> $LOGFILE 2>&1
	if test $status != 0
		echo "$REPOSITORY release not found" | tee -a $LOGFILE
		echo "------------------------------------------" >> $LOGFILE
		return
	end
	set TAG $(echo $RELEASE | jq | grep tag_name | cut -d '"' -f 4 | head -n 1) >> $LOGFILE 2>&1
	echo "$REPOSITORY $TAG found, downloading..." | tee -a $LOGFILE
	wget $(echo $RELEASE | jq | grep browser_download_url | cut -d '"' -f 4 | grep "amd64" | grep ".deb" | head -n 1) -O release.deb >> $LOGFILE 2>&1
	echo "$REPOSITORY $TAG downloaded, trying to install..." | tee -a $LOGFILE
	sudo apt-get install -y ./release.deb >> $LOGFILE 2>&1
	if test $status -eq 0
		echo "$REPOSITORY $TAG installed" | tee -a $LOGFILE
	else
		echo "$REPOSITORY $TAG was not installed" | tee -a $LOGFILE
	end
	rm release.deb >> $LOGFILE 2>&1
	echo "------------------------------------------" >> $LOGFILE
end

# Helps to init a github project faster and easily
function nirit-init-github-project
	set LOGFILE ~/.config/nirit/logs/nirit-init-github-project.log
  echo Executed on: (date +"%Y-%m-%d %H:%M:%S %Z") >> $LOGFILE 2>&1
	echo "Input: $argv" >> $LOGFILE
	set HELP "Usage: nirit-init-github-project GITHUB-USER"
	if test (count $argv) -lt 1
    echo $HELP | tee -a $LOGFILE
    return
	end
	if contains -- "--help" $argv
		echo $HELP | tee -a $LOGFILE
		return
	end
	set USER $argv[1]
	set REPOSITORY (pwd | sed "s/\//\n/g" | tail -n 1)
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
	set LOGFILE ~/.config/nirit/logs/nirit-install-from-url.log
  echo Executed on: (date +"%Y-%m-%d %H:%M:%S %Z") >> $LOGFILE 2>&1
	echo "Input: $argv" >> $LOGFILE
	set HELP "Usage: nirit-install-from-url URL"
	if test (count $argv) -lt 1
    echo $HELP | tee -a $LOGFILE
    return
	end
	if contains -- "--help" $argv
		echo $HELP | tee -a $LOGFILE
		return
	end
	set URL $argv[1]
	set FROMDOMAIN $(echo $URL | cut -d "/" -f 3) >> $LOGFILE 2>&1
	set DEB "$FROMDOMAIN.deb"
	echo "Getting Program from $FROMDOMAIN..." | tee -a $LOGFILE
	wget $URL -O $DEB >> $LOGFILE 2>&1
	if test $status != 0
		echo "$DEB not found" | tee -a $LOGFILE
		echo "------------------------------------------" >> $LOGFILE
		return
	end
	echo "Installing $DEB..." | tee -a $LOGFILE
	sudo apt-get install -y ./$DEB >> $LOGFILE 2>&1
	if test $status != 0
		echo "$DEB cannot be installed" | tee -a $LOGFILE
		echo "------------------------------------------" >> $LOGFILE
		return
	end
	rm $DEB >> $LOGFILE 2>&1
	echo "$DEB Installed" | tee -a $LOGFILE
	echo "------------------------------------------" >> $LOGFILE
end

# Helps to update all apps in nirit system faster and easily
function nirit-update-system
	set UPDATELOGFILE ~/.config/nirit/logs/nirit-update-system.log
  echo Executed on: (date +"%Y-%m-%d %H:%M:%S %Z") >> $UPDATELOGFILE 2>&1
	echo "Input: $argv" >> $UPDATELOGFILE
	if contains -- "--help" $argv
		echo "Usage: nirit-update-system" | tee -a $UPDATELOGFILE
		return
	end
	echo "Updating APT Programs..." | tee -a $UPDATELOGFILE
	sudo apt-get update >> $UPDATELOGFILE 2>&1
	sudo apt-get upgrade -y >> $UPDATELOGFILE 2>&1
	if test $status != 0
		echo "APT Programs cannot be updated"
	end
	sudo apt-get autoremove -y >> $UPDATELOGFILE 2>&1
	echo "Updating DEB Programs outside APT..." | tee -a $UPDATELOGFILE
	ls /usr/bin/onlyoffice-desktopeditors >> $UPDATELOGFILE 2>&1
	set ONLYOFFICE $status
	if test $ONLYOFFICE -eq 0
		echo -e "\nUpdating Onlyoffice..." | tee -a $UPDATELOGFILE
		nirit-install-from-url "https://download.onlyoffice.com/install/desktop/editors/linux/onlyoffice-desktopeditors_amd64.deb" | tee -a $UPDATELOGFILE
		echo "" | tee -a $UPDATELOGFILE
	end
	ls /usr/bin/discord >> $UPDATELOGFILE 2>&1
	if test $status -eq 0
		if test $ONLYOFFICE != 0
			echo -e "\n" | tee -a $UPDATELOGFILE
		end
		echo "Updating Discord..." | tee -a $UPDATELOGFILE
		nirit-install-from-url "https://discord.com/api/download?platform=linux&format=deb" | tee -a $UPDATELOGFILE
		echo "" | tee -a $UPDATELOGFILE
	end
	echo "Updating Github Releases..." | tee -a $UPDATELOGFILE
	ls /usr/bin/heroic >> $UPDATELOGFILE 2>&1
	set HEROIC $status
	if test $HEROIC -eq 0
		echo -e "\nUpdating Heroic Games Launcher..." | tee -a $UPDATELOGFILE
		nirit-github-install Heroic-Games-Launcher/HeroicGamesLauncher | tee -a $UPDATELOGFILE
		echo "" | tee -a $UPDATELOGFILE
	end
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
	echo "Repository URL: https://github.com/sh4dow18/nirit"
	echo "Created By: Ramsés Solano (sh4dow18)"
	echo "Last Update: 11/21/2024"
end

# Helps to update Nirit Project faster and easily
function nirit-update-project
	set LOGFILE ~/.config/nirit/logs/nirit-update-project.log
  echo Executed on: (date +"%Y-%m-%d %H:%M:%S %Z") >> $LOGFILE 2>&1
	echo "Input: $argv" >> $LOGFILE
	if contains -- "--help" $argv
		echo "Usage: nirit-update-project" | tee -a $LOGFILE
		return
	end
	echo "Searching Nirit Project Updates..."
	set RELEASE (wget -qO - https://api.github.com/repos/sh4dow18/nirit/releases) >> $LOGFILE 2>&1
	if test $status != 0
		echo "Nirit Releases not Found" | tee -a $LOGFILE
		echo "------------------------------------------" >> $LOGFILE
		return
	end
  set TAG (echo $RELEASE | jq | grep tag_name | cut -d '"' -f 4 | head -n 1) >> $LOGFILE 2>&1
	set BODY (echo $RELEASE | jq | grep body | cut -d '"' -f 4) >> $LOGFILE 2>&1
	if test "$TAG" = "v2.0.0"
		echo "Nirit Project is up to date" | tee -a $LOGFILE
	else
		echo -e "\nNew Nirit Release $TAG Found\n" | tee -a $LOGFILE
		echo "$TAG Description:" | tee -a $LOGFILE
		echo $BODY | tee -a $LOGFILE
    echo -e "\nDo you want to update Nirit Project? (y/n): "
		read ANSWER
		if test "$ANSWER" = "y"
			echo -e "\nCloning Nirit $TAG..." | tee -a $LOGFILE
			git clone --depth 1 https://github.com/sh4dow18/nirit.git >> $LOGFILE 2>&1
			echo "Opening Nirit $TAG Updater..." | tee -a $LOGFILE
			sudo bash nirit/nirit-installer.sh -u | tee -a $LOGFILE
			if test $pipestatus[1] != 0
				echo "Nirit not Updated" | tee -a $LOGFILE
			else
				echo "Nirit Updated" | tee -a $LOGFILE
			end
			sudo rm -r nirit/ >> $LOGFILE 2>&1
		else
			echo "Nirit not Updated" | tee -a $LOGFILE
		end
	end
	echo "------------------------------------------" >> $LOGFILE
end

# Helps to Clean Nirit File System
function nirit-cleaner
	set CLEANLOGFILE ~/.config/nirit/logs/nirit-cleaner.log
  echo Executed on: (date +"%Y-%m-%d %H:%M:%S %Z") >> $CLEANLOGFILE 2>&1
	echo "Input: $argv" >> $CLEANLOGFILE
	if contains -- "--help" $argv
		echo "Usage: nirit-cleaner" | tee -a $CLEANLOGFILE
		return
	end
	echo "Removing Temp Files..." | tee -a $CLEANLOGFILE
	bash -c "sudo rm -r /tmp/*" >> $CLEANLOGFILE 2>&1
	echo "Cleaning APT..." | tee -a $CLEANLOGFILE
	sudo apt-get clean -y >> $CLEANLOGFILE 2>&1
	sudo apt-get autoremove -y --purge >> $CLEANLOGFILE 2>&1
	echo "Erasing Trash Bin Files..." | tee -a $CLEANLOGFILE
	bash -c "sudo rm -r /home/sh4dow18/.local/share/Trash/files/*" >> $CLEANLOGFILE 2>&1
	bash -c "sudo rm -r /home/sh4dow18/.local/share/Trash/info/*" >> $CLEANLOGFILE 2>&1
	echo "Removing Terminal Desktop Files..." | tee -a $CLEANLOGFILE
	grep -l "Terminal=true" /usr/share/applications/*.desktop | xargs sudo rm -f >> $CLEANLOGFILE 2>&1
	echo "Cleaning Complete" | tee -a $CLEANLOGFILE
	echo "------------------------------------------" >> $CLEANLOGFILE
end

# Helps to show nirit logs from all nirit programs
function nirit-log
	set HELP "Usage: nirit-log NIRIT-PROGRAM"
	if test (count $argv) -lt 1
    echo $HELP
    return
	end
	if contains -- "--help" $argv
		echo $HELP
		return
	end
	if test "$argv" = "--clean"
		bash -c "rm ~/.config/nirit/logs/* > /dev/null 2>&1"
		echo "Nirit Logs Removed"
		return
	end
	set PROGRAM $argv[1]
	set NOLOGSLIST "nirit-log" "nirit-information" "nirit-shutdown" "nirit-reboot"
	if contains $PROGRAM $NOLOGSLIST
		echo "$PROGRAM does not keep logs"
		return
	end
	if not string match -q "nirit*" $PROGRAM
		echo "$PROGRAM is not a Nirit App"
		return
	end
	ls ~/.config/nirit/logs/$PROGRAM.log > /dev/null 2>&1
	if test $status != 0
		echo "$PROGRAM have no logs"
		return
	end
	cat ~/.config/nirit/logs/$PROGRAM.log
end