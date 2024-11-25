#!/bin/bash

# Created by Ramsés Solano (sh4dow18)
# My Github: https://www.github.com/sh4dow18

# Function to set color to some message with echo command
color() {
    echo -n "\e[${1}m"
}
# Function to colorize echo
colorize() {
    echo -e "$1$2$RESET_COLOR"
}
# Function to display script help information
help() {
    colorize "\nUsage: $0 INSTALLATION_METHOD\n"
    echo "Options:"
    echo -e "\t-o\tOnly Core Method"
    echo -e "\t-n\tNormal Method"
    echo -e "\t-u\tUpdate Method\n"
}
# Function to check if the program sent is installed
is_installed() {
    dpkg -l | grep -q "^ii  $1 "
}
# Function to display a message with a percentage of progress
progress_status() {
    colorize $1 "\n\t- $2 ($3%)" | tee -a $LOG_FILE
}
# Function to install programs with a message
install_programs() {
    INSTALL_MESSAGE=""
    if [[ $5 == true ]]; then
        INSTALL_MESSAGE="Programs to "
    fi
    progress_status $1 "Installing $INSTALL_MESSAGE$2" $3
    apt-get install -y $4 >> $LOG_FILE 2>&1
}
# Function to install a github release
install_github_program() {
    progress_status $1 "Installing $2" $3
    URL=$(wget -qO - https://api.github.com/repos/$4/releases | grep "browser_download_url" | cut -d '"' -f 4 | grep ".deb" | head -n 1)
    wget $URL -O "$2.deb" >> $LOG_FILE 2>&1
    apt-get install -y "./$2.deb" >> $LOG_FILE 2>&1
    rm "./$2.deb" >> $LOG_FILE 2>&1
}
install_program_from_url() {
    wget $1 -O release.deb >> $LOG_FILE 2>&1
    apt-get install -y ./release.deb >> $LOG_FILE 2>&1
    rm release.deb >> $LOG_FILE 2>&1
}
# Function to set that the user agree to install a program
no_questions() {
    echo "$1" | debconf-set-selections >> $LOG_FILE 2>&1
}
# Function to add a program to a rofi category
add_to_rofi_category() {
    # If the Desktop File exists, add a rofy category
    if [[ -e "/usr/share/applications/$1.desktop" ]]; then
        # If Categories section is in the file, change it, if not, add it
        if grep -q "^Categories=" "/usr/share/applications/$1.desktop"; then
            sed -i "/^Categories=/c\Categories=$2" "/usr/share/applications/$1.desktop" 2>> $LOG_FILE
        else
            echo "Categories=$2" >> "/usr/share/applications/$1.desktop" 2>> $LOG_FILE
        fi
    fi
}
# Main Menu
main() {
    # Color Variables
    RED=$(color "0;31")
    GREEN=$(color "0;32")
    BROWN=$(color "0;33")
    YELLOW=$(color "1;33")
    PURPLE=$(color "0;35")
    ORANGE=$(color "38;5;214")
    WHITE=$(color "1;37")
    BLUE=$(color "0;34")
    GRAY=$(color "0;37")
    LIGHT_BLUE=$(color "0;36")
    HIGH_RED=$(color "1;31")
    HIGH_BLUE=$(color "1;34")
    HIGH_GREEN=$(color "1;32")
    HIGH_PURPLE=$(color "1;35")
    RESET_COLOR=$(color "0")
    # Logs Variables
    LOG_FILE="nirit-installer.log"
    # Hello Command
    echo "     __  _        _  _   " | tee $LOG_FILE
    echo "  /\ \ \(_) _ __ (_)| |_ " | tee -a $LOG_FILE
    echo " /  \/ /| || '__|| || __|" | tee -a $LOG_FILE
    echo "/ /\  / | || |   | || |_ " | tee -a $LOG_FILE
    echo "\_\ \/  |_||_|   |_| \__|" | tee -a $LOG_FILE
    echo "Welcome to the Nirit Installer!" | tee -a $LOG_FILE
    echo "Version: 2.0.0" | tee -a $LOG_FILE
    # Main Verifications
    # Check if nirit is being run with an installation method already installed
    if [[ -e /etc/X11/nirit && $1 != "-u" ]]; then
        colorize $RED "\nNirit is already installed" | tee -a $LOG_FILE
        exit 1
    fi
    OPERATING_SYSTEM=$(cat /etc/os-release | grep PRETTY_NAME | cut -d "=" -f 2 | sed 's/"//g' | cut -d " " -f 1)
    # Check if the operating system is Debian
    if [[ $OPERATING_SYSTEM != "Debian" ]]; then
        colorize $RED "\nThis Installer is only Compatible with Debian, not $OPERATING_SYSTEM at the moment\n" | tee -a $LOG_FILE
        exit 1
    fi
    # Check if the installer was run with sudo privileges
    if [[ $EUID != 0 ]]; then
        colorize $RED "\nYou must run this installer with Superuser permissions (sudo)\n" | tee -a $LOG_FILE
        exit 1
    fi
    # Check if the user submitted an installation method
    if [[ $# -lt 1 ]]; then
        help
        exit 1
    fi
    # Nirit Core Programs
    LOGIN="xorg lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings"
    DESKTOP="x11-xserver-utils python3-pip python3-xcffib python3-cairocffi libpangocairo-1.0-0 python3-psutil apt-show-versions"
    FILES="zip unzip gnome-text-editor nautilus gcp feh"
    MENUS="rofi"
    DEVICES="udiskie ntfs-3g policykit-1-gnome gnome-disk-utility lxrandr blueman cbatticon gvfs-backends"
    TERMINAL="exa fish bat alacritty"
    AUDIO="pulseaudio pamixer pavucontrol pasystray"
    NOTIFICATIONS="dunst libnotify-bin"
    UTILITIES="flameshot ibus gnome-system-monitor connman connman-gtk git jq"
    # Nirit Important Variables
    BROWSER="firefox-esr"
    LIBREOFFICE="libreoffice"
    DRIVERS=""
    IDE=""
    STEAM=""
    HEROIC=""
    STORES=""
    DISCORD=false
    TEAMS=false
    # Verify if it is the Only Core Method
    if [[ $1 == "-o" ]]; then
        colorize $BROWN "\nChosen Method: Only Core" | tee -a $LOG_FILE
    # Verify if it is the Normal Method
    elif [[ $1 == "-n" ]]; then
        colorize $BROWN "\nChosen Method: Normal" | tee -a $LOG_FILE
        # Nirit Core Recommended Programs to Better Experience
        MULTIMEDIA="vlc gpicview audacious"
        THEMES="lxappearance"
        OFFICE="qalculate-gtk evince gnome-calendar kolourpaint"
        # Ask Questions to Know if install some optional programs
        echo -e "\nCustom Questions:\n"
        QUESTIONS=(
            "Do you want to install Opera Browser instead Firefox? (y/n): "
            "Do you want to install Only-Office Desktop Editors instead Libreoffice? (y/n): "
            "Do you want to install the Nvidia Drivers? (y/n): "
            "Do you want to install Visual Studio Code? (y/n): "
            "Do you want to install Steam? (y/n): "
            "Do you want to install Heroic Game Launcher that allows to play games from Epic Games? (y/n): "
            "Do you want to install Apps Stores? (y/n): "
            "Do you want to install Discord? (y/n): "
            "Do you want to install Microsoft Teams (y/n): "
        )
        for QUESTION in "${QUESTIONS[@]}"; do
            echo -n "$QUESTION"
            read ANSWER
            if [[ $ANSWER == [yY] ]]; then
                case $QUESTION in
                    "${QUESTIONS[0]}")
                        BROWSER="opera-stable"
                        ;;
                    "${QUESTIONS[1]}")
                        LIBREOFFICE=""
                        ;;
                    "${QUESTIONS[2]}")
                        DRIVERS="linux-headers-amd64 nvidia-detect nvidia-driver linux-image-amd64"
                        ;;
                    "${QUESTIONS[3]}")
                        IDE="code"
                        ;;
                    "${QUESTIONS[4]}")
                        STEAM="mesa-vulkan-drivers libglx-mesa0:i386 mesa-vulkan-drivers:i386 libgl1-mesa-dri:i386 steam-installer"
                        ;;
                    "${QUESTIONS[5]}")
                        HEROIC=true
                        ;;
                    "${QUESTIONS[6]}")
                        STORES="plasma-discover"
                        ;;
                    "${QUESTIONS[7]}")
                        DISCORD=true
                        ;;
                    "${QUESTIONS[8]}")
                        TEAMS=true
                        ;;
                esac
            fi
        done
    # Verify if it is the Update Method
    elif [[ $1 == "-u" ]]; then
        colorize $BROWN "\nChosen Method: Update" | tee -a $LOG_FILE
        {
            # Gets the current Version Installed
            CURRENT_VERSION=$(cat /home/$(who | head -n 1 | cut -d " " -f 1)/.config/fish/config.fish | grep "Nirit Version" | cut -d ":" -f 2 | sed "s/  *//g" | cut -d '"' -f 1)
            # Gets the Current Mode to update the current version with the same mode
            METHOD=$(cat /home/$(who | head -n 1 | cut -d " " -f 1)/.config/fish/config.fish | grep "Mode Installed" | cut -d ":" -f 2 | sed "s/  *//g" | cut -d '"' -f 1)
        } 2>> $LOG_FILE
        # Check if the current version was found
        if [[ $CURRENT_VERSION == "" ]]; then
            # If the current version was not found, check if nirit is installed
            if [[ ! -e /etc/X11/nirit ]]; then
                colorize $RED "No Nirit Installation Detected\n" | tee -a $LOG_FILE
                exit 1
            fi
            # If nirit is installed, but the actual version cannot be found, it means it is version v1.0.0
            CURRENT_VERSION="v1.0.0"
            METHOD="Normal"
        fi
        colorize $LIGHT_BLUE "Current Version Detected: $CURRENT_VERSION" | tee -a $LOG_FILE
        # Check if the current version is the latest
        if [[ $CURRENT_VERSION == "v2.0.0" ]]; then
            colorize $GREEN "\nNirit is updated to its latest version v2.0.0" | tee -a $LOG_FILE
            exit 1
        fi
        # Check if the current version is newer than the installation version
        UPDATED_VERSION=$(printf "%s\n%s\n" "$CURRENT_VERSION" "v2.0.0" | sort -V | tail -n 1)
        if [[ $UPDATED_VERSION != "v2.0.0" ]]; then
            colorize $RED "\nThe version you are trying to install is an older version than the current one you have installed" | tee -a $LOG_FILE
            exit 1
        fi
    # If it is a Invalid Argument, show help and exit with code 1
    else
        colorize $RED "\nInvalid Argument $1" | tee -a $LOG_FILE
        help
        exit 1
    fi
    colorize $HIGH_PURPLE "\nAdding Init Settings..."
    # If the User want to install Opera Browser, the program verifies if opera exists already, and if this one
    # was not installed, add the necesarry code to the apt repository
    is_installed $BROWSER
    if [[ $BROWSER == "opera-stable" && $? != 0 ]]; then
        progress_status $HIGH_RED "Adding Opera Repository" "0"
        apt-get install software-properties-common apt-transport-https curl ca-certificates -y >> $LOG_FILE 2>&1
        curl -fSsL https://deb.opera.com/archive.key | gpg --dearmor | tee /usr/share/keyrings/opera.gpg >> $LOG_FILE 2>&1
        echo deb [arch=amd64 signed-by=/usr/share/keyrings/opera.gpg] https://deb.opera.com/opera-stable/ stable non-free >> /etc/apt/sources.list.d/opera.list
    fi
    # If the User want to install the Nvidia Drivers, the program verifies if the drivers exists already, and if this one
    # was not installed, add the necesarry code to the apt repository
    is_installed "nvidia-driver"
    if [[ $DRIVERS != "" && $? != 0 ]]; then
        progress_status $HIGH_GREEN "Adding Nvidia Driver's Repository" "25"
        apt-get install software-properties-common -y >> $LOG_FILE 2>&1
        add-apt-repository contrib non-free-firmware -y >> $LOG_FILE 2>&1
        add-apt-repository contrib non-free -y >> $LOG_FILE 2>&1
    fi
    # If the User want to install Visual Studio Code, the program verifies if vscode exists already, and if this one
    # was not installed, add the necesarry code to the apt repository
    is_installed $IDE
    if [[ $IDE != "" && $? != 0 ]]; then
        progress_status $LIGHT_BLUE "Adding Visual Studio Code Repository" "50"
        apt-get install curl gpg -y >> $LOG_FILE 2>&1
        curl -s https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
        install -o root -g root -m 644 microsoft.gpg /etc/apt/keyrings/microsoft-archive-keyring.gpg >> $LOG_FILE 2>&1
        sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/microsoft-archive-keyring.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
        rm microsoft.gpg >> $LOG_FILE 2>&1
    fi
    # If the User want to install Steam, the program verifies if steam exists already, and if this one
    # was not installed, add the necesarry code to the apt repository
    is_installed "steam-installer"
    if [[ $STEAM != "" && $? != 0 ]]; then
        progress_status $HIGH_BLUE "Adding Steam Repository" "75"
        FILE=/etc/apt/sources.list
        if ! grep -v "#" $FILE | grep -q "contrib"; then
            ORIGINAL_LINE=$(grep -v "#" $FILE | grep "deb" | head -n 1)
            NEW_LINE="$ORIGINAL_LINE contrib non-free"
            sed -i "s|^$ORIGINAL_LINE|$NEW_LINE|" $FILE
            dpkg --add-architecture i386
        fi
    fi
    progress_status $GREEN "Repositories Updated" "100"
    # System Update
    colorize $YELLOW "\nSearching System Updates..." | tee -a $LOG_FILE
    progress_status $BROWN "Updating Apt Repository" "0"
    apt-get update >> $LOG_FILE 2>&1
    progress_status $HIGH_BLUE "Installing Packages Updates" "33"
    apt-get upgrade -y >> $LOG_FILE 2>&1
    progress_status $PURPLE "Removing Unnecessary Packages" "66"
    apt-get autoremove -y >> $LOG_FILE 2>&1
    progress_status $GREEN "Update Finished" "100"
    # Install Programs
    # Installing Nirit Core
    colorize $BROWN "\nInstalling Nirit Core..." | tee -a $LOG_FILE
    install_programs $HIGH_BLUE "Log In" "0" "$LOGIN" true
    install_programs $ORANGE "Have a Desktop" "10" "$DESKTOP" true
    pip install --no-cache-dir --break-system-packages qtile >> $LOG_FILE 2>&1
    install_programs $WHITE "Manipulate Files" "20" "$FILES" true
    install_programs $HIGH_PURPLE "Have a Menu to Launch Apps" "30" "$MENUS" true
    install_programs $BROWN "Maniputate Devices" "40" "$DEVICES" true
    install_programs $HIGH_GREEN "Have a Better Experience in a Terminal" "50" "$TERMINAL" true
    install_programs $PURPLE "Have Audio" "60" "$AUDIO" true
    install_programs $HIGH_BLUE "Have Notifications" "70" "$NOTIFICATIONS" true
    install_programs $GRAY "Utilities" "80" "$UTILITIES" false
    # If the user wants to install opera, accepts that opera can be updated with apt
    if [[ $BROWSER == "opera-stable" ]]; then
        no_questions "opera-stable opera-stable/add-deb-source boolean false"
    fi
    install_programs $HIGH_RED "Browser" "90" "$BROWSER" false
    progress_status $GREEN "Instalation Completed" "100"
    # If the installation method is "Normal Method" or it is an update with "Normal Method", do this
    if [[ $1 == "-n" || $METHOD == "Normal" ]]; then
        # Installing Nirit Recommended
        colorize $HIGH_PURPLE "\nInstalling Nirit Recommended..." | tee -a $LOG_FILE
        install_programs $ORANGE "View Multimedia Files" "0" "$MULTIMEDIA" true
        install_programs $HIGH_BLUE "Change Themes" "33" "$THEMES" true
        install_programs $HIGH_RED "Office" "66" "$OFFICE $LIBREOFFICE" true
        # If the user has chosen Onlyoffice instead of Libreoffice in the normal method, install it
        # If Onlyoffice is already installed, update it
        is_installed "onlyoffice-desktopeditors"
        if [[ $LIBREOFFICE == "" || $? == 0 ]]; then
            install_program_from_url "https://download.onlyoffice.com/install/desktop/editors/linux/onlyoffice-desktopeditors_amd64.deb"
        fi
        progress_status $GREEN "Instalation Completed" "100"
        # Installing Nirit Extras
        colorize $WHITE "\nInstalling Nirit Extras..." | tee -a $LOG_FILE
        # If the user has chosen nvidia drivers in the normal method, install it
        # If the Nvidia Drivers are already installed, update it
        is_installed "nvidia-driver"
        if [[ $DRIVERS != "" || $? == 0 ]]; then
            no_questions "nvidia-driver nvidia-driver/accept-terms boolean true"
            install_programs $HIGH_GREEN "Nvidia Drivers" "0" "$DRIVERS" true
        fi
        # If the user has chosen Visual Studio Code in the normal method, install it
        # If Visual Studio Code is already installed, update it
        is_installed "code"
        if [[ $IDE != "" || $? == 0 ]]; then
            install_programs $LIGHT_BLUE "Visual Studio Code" "14" "$IDE" false
        fi
        # If the user has chosen Steam in the normal method, install it
        # If Steam is already installed, update it
        if [[ $STEAM != "" ]]; then
            no_questions "steam-installer steam/license select true"
            install_programs $HIGH_BLUE "Steam" "28" "$STEAM" false
            if [[ $DRIVERS != "" ]]; then
                apt-get install -y "nvidia-driver-libs:i386" >> $LOG_FILE 2>&1
            fi
        fi
        # If the user has chosen Heroic Games Launcher in the normal method, install it
        # If Heroic Games Launcher is already installed, update it
        is_installed "heroic"
        if [[ $HEROIC == true || $? == 0 ]]; then
            install_github_program $WHITE "Heroic Games Launcher" "42" "Heroic-Games-Launcher/HeroicGamesLauncher"
            dpkg --add-architecture i386 >> $LOG_FILE 2>&1
            apt-get update >> $LOG_FILE 2>&1
            apt-get install -y wine wine32 wine64 libwine libwine:i386 fonts-wine >> $LOG_FILE 2>&1
        fi
        # If the user has chosen to have Stores in the normal method, install it
        # If the Stores are already installed, update it
        is_installed "plasma-discover"
        if [[ $STORES != "" || $? == 0 ]]; then
            install_programs $HIGH_PURPLE "App Stores" "56" "$STORES" false
        fi
        # If the user has chosen Discord in the normal method, install it
        # If Discord is already installed, update it
        is_installed "discord"
        if [[ $DISCORD == true || $? == 0 ]]; then
            progress_status $ORANGE "Installing Discord..." "70"
            install_program_from_url "https://discord.com/api/download?platform=linux&format=deb"
        fi
        # If the user has chosen Teams for Linux in the normal method, install it
        # If Teams for Linux is already installed, update it
        is_installed "teams-for-linux"
        if [[ $TEAMS == true || $? == 0 ]]; then
            install_github_program $LIGHT_BLUE "Microsoft Teams" "84" "IsmaelMartinez/teams-for-linux"
        fi
        progress_status $GREEN "Instalation Completed" "100"
    fi
    # If the installation method is the Update Method, asks if the user want to install the settings too
    if [[ $1 == "-u" ]]; then
        echo -e "\nIt is highly recommended to do a clean installation of Nirit Settings to make sure everything works well"
        echo "If you have custom settings, make sure you have a backup to merge with the new settings later"
        echo -n "Do you want to do a clean installation of Nirit Settings right now? (y/n): "
        read ANSWER
        # If the user doesn't want to install new Nirit Settings, put the new version in fish config
        if [[ $ANSWER == [nN] ]]; then
            sed -i "s/Nirit Version: $CURRENT_VERSION/Nirit Version: v2.0.0/g" cat /home/$(who | head -n 1 | cut -d " " -f 1)/.config/fish/config.fish 2>> $LOG_FILE
            echo "Nirit Updated without Settings" | tee -a $LOG_FILE
            exit 0
        fi
    fi
    colorize $HIGH_RED "\nInstalling Nirit Configuration..." | tee -a $LOG_FILE
    progress_status $ORANGE "Creating Config Directory..." "0"
    # Creating User Home's Variable
    USER=$(who | head -n 1 | cut -d " " -f 1)
    HOME=/home/$USER
    # Creating Configuration Directory
    mkdir $HOME/.config >> $LOG_FILE 2>&1
    # Changing Fonts
    progress_status $PURPLE "Installing Fonts..." "9"
    mkdir $HOME/.local >> $LOG_FILE 2>&1
    mkdir $HOME/.local/share >> $LOG_FILE 2>&1
    cp -r settings/fonts/ $HOME/.local/share/ >> $LOG_FILE 2>&1
    fc-cache -f
    # Installing Lightdm Configuration
    progress_status $LIGHT_BLUE "Installing Lightdm Configuration..." "18"
    mkdir /usr/share/xsessions >> $LOG_FILE 2>&1
    systemctl enable lightdm >> $LOG_FILE 2>&1
    cp settings/lightdm/lightdm-gtk-greeter.conf /etc/lightdm/ >> $LOG_FILE 2>&1
    mkdir /usr/share/pictures >> $LOG_FILE 2>&1
    cp settings/lightdm/lightdm-background.jpg /usr/share/pictures/ >> $LOG_FILE 2>&1
    cp settings/lightdm/lightdm-user.png /usr/share/pictures/ >> $LOG_FILE 2>&1
    sed -i "s/#user-session=default/user-session=Nirit/g" /etc/lightdm/lightdm.conf 2>> $LOG_FILE
    # Installing Qtile Configuration
    progress_status $ORANGE "Installing Qtile Configuration..." "27"
    sed -i "s|/home/sh4dow18|/home/$USER|g" settings/qtile/config.py 2>> $LOG_FILE
    # Getting CPU Sensor validating if it is an Intel CPU or AMD CPU
    CPU_SENSOR=$(lsmod | grep -E 'coretemp|k10temp' | head -n 1 | cut -d " " -f 1)
    # If it is an AMD CPU, use "Tctl"
    # If it is an Intel CPU, use "Core 0"
    CPU_SENSOR_TAG="Tctl"
    if [[ $CPU_SENSOR_TAG == "coretemp" ]]; then
        CPU_SENSOR_TAG="Core 0"
    fi
    # Change CPU Sensor in Qtile Config
    sed -i "s/tag_sensor=\"CPU_SENSOR_TAG\"/tag_sensor=\"$CPU_SENSOR_TAG\"/g" settings/qtile/config.py 2>> $LOG_FILE
    # Getting the Primary Network Interface
    INTERFACE=$(ip addr | grep "^2" | cut -d " " -f 2 | cut -d ":" -f 1)
    # Changing Network Interface in Qtile Config
    sed -i "s/interface=\"INTERFACE\"/interface=\"$INTERFACE\"/g" settings/qtile/config.py 2>> $LOG_FILE
    # Uncomments all lines that have Nvidia if it detects that Nvidia drivers have been installed
    if [[ $DRIVERS != "" ]]; then
        sed -i "/#.*Nvidia/s/^# //" settings/qtile/config.py 2>> $LOG_FILE
    fi
    # If the Opera Browser was chosen, switch firefox to opera in Qtile Config
    if [[ $BROWSER == "opera-stable" ]]; then
        sed -i 's/browser = "firefox"/browser = "opera"/g' settings/qtile/config.py 2>> $LOG_FILE
    fi
    # If Visual Studio Code was Chosen, add "code" into "ide" variable
    if [[ $IDE == "code" ]]; then
        sed -i 's/ide = ""/ide = "code"/' settings/qtile/config.py 2>> $LOG_FILE
    fi
    # Continue with Qtile Config
    cp -r settings/qtile $HOME/.config/ >> $LOG_FILE 2>&1
    cp settings/start/Nirit.desktop /usr/share/xsessions/ >> $LOG_FILE 2>&1
    cp settings/start/nirit /etc/X11/ >> $LOG_FILE 2>&1
    # Installing Alacritty Configuration
    progress_status $BROWN "Installing Alacritty Configuration..." "36"
    cp -r settings/alacritty $HOME/.config/ >> $LOG_FILE 2>&1
    # Installing Rofi Menu Configuration
    progress_status $HIGH_PURPLE "Installing Rofi Configuration..." "45"
    cp settings/rofi/nirit.rasi /usr/share/rofi/themes/ >> $LOG_FILE 2>&1
    mkdir $HOME/.config/rofi >> $LOG_FILE 2>&1
    cp settings/rofi/config.rasi $HOME/.config/rofi/ >> $LOG_FILE 2>&1
    cp settings/rofi/rofi-with-categories.sh $HOME/.config/rofi/ >> $LOG_FILE 2>&1
    grep -l "Terminal=true" /usr/share/applications/*.desktop | xargs rm >> $LOG_FILE 2>&1
    add_to_rofi_category "org.gnome.TextEditor" "Files"
    add_to_rofi_category "org.gnome.Nautilus" "Files"
    add_to_rofi_category "org.gnome.DiskUtility" "Devices"
    add_to_rofi_category "lxrandr" "Devices"
    add_to_rofi_category "blueman-adapters" "Devices"
    add_to_rofi_category "blueman-manager" "Devices"
    add_to_rofi_category "pavucontrol" "Audio"
    add_to_rofi_category "libreoffice-base" "Office"
    add_to_rofi_category "libreoffice-calc" "Office"
    add_to_rofi_category "libreoffice-draw" "Office"
    add_to_rofi_category "libreoffice-impress" "Office"
    add_to_rofi_category "libreoffice-math" "Office"
    add_to_rofi_category "libreoffice-startcenter" "Office"
    add_to_rofi_category "libreoffice-writer" "Office"
    add_to_rofi_category "libreoffice-xsltfilter" "Office"
    add_to_rofi_category "qalculate-gtk" "Office"
    add_to_rofi_category "org.gnome.Evince" "Office"
    add_to_rofi_category "org.gnome.Calendar" "Office"
    add_to_rofi_category "org.kde.kolourpaint" "Office"
    add_to_rofi_category "vlc" "Multimedia"
    add_to_rofi_category "gpicview" "Multimedia"
    add_to_rofi_category "audacious" "Multimedia"
    add_to_rofi_category "code" "Development"
    mv $HOME/.local/share/applications/steam.desktop /usr/share/applications/ >> $LOG_FILE 2>&1
    rm $HOME/.local/share/applications/* >> $LOG_FILE 2>&1
    add_to_rofi_category "steam" "Games"
    add_to_rofi_category "heroic" "Games"
    add_to_rofi_category "discord" "Communication"
    add_to_rofi_category "teams-for-linux" "Communication"
    add_to_rofi_category "opera" "Internet"
    add_to_rofi_category "firefox-esr" "Internet"
    add_to_rofi_category "Alacritty" "Utilities"
    add_to_rofi_category "org.flameshot.Flameshot" "Utilities"
    add_to_rofi_category "gnome-system-monitor" "Utilities"
    add_to_rofi_category "lxappearance" "Utilities"
    add_to_rofi_category "nvidia-driver" "Utilities"
    add_to_rofi_category "org.kde.discover" "Utilities"
    # Changing to the "Fish" shell and Installing "Fish" Configuration
    progress_status $HIGH_GREEN "Installing Fish Configuration..." "54"
    chsh -s /bin/fish $USER >> $LOG_FILE 2>&1
    mkdir $HOME/.config/fish >> $LOG_FILE 2>&1
    cp settings/fish/config.fish $HOME/.config/fish >> $LOG_FILE 2>&1
    # Installing Dunst Configuration
    progress_status $HIGH_BLUE "Installing Dunst Configuration..." "63"
    mkdir $HOME/.config/dunst >> $LOG_FILE 2>&1
    cp settings/dunst/dunstrc $HOME/.config/dunst >> $LOG_FILE 2>&1
    cp -r settings/dunst/icons /usr/share/icons/nirit >> $LOG_FILE 2>&1
    # Installing New Cursor
    progress_status $WHITE "Installing Cursor..." "72"
    unzip settings/gtk/cursor/ComixCursors-Opaque-White.zip >> $LOG_FILE 2>&1
    mkdir /usr/share/icons/ >> $LOG_FILE 2>&1
    mv ComixCursors-Opaque-White/ /usr/share/icons/ >> $LOG_FILE 2>&1
    mkdir /usr/share/icons/default/ >> $LOG_FILE 2>&1
    cp settings/gtk/cursor/index.theme /usr/share/icons/default/ >> $LOG_FILE 2>&1
    # Installing Adwaita-Dark
    cp -r settings/gtk/install/* $HOME/.config/
    # Installing Grub Theme
    progress_status $LIGHT_BLUE "Installing Grub Theme..." "81"
    unzip settings/grub/darkmatter.zip >> $LOG_FILE 2>&1
    mkdir /boot/grub/themes >> $LOG_FILE 2>&1
    mv darkmatter/ /boot/grub/themes >> $LOG_FILE 2>&1
    echo 'GRUB_THEME="/boot/grub/themes/darkmatter/theme.txt"' >> /etc/default/grub
    echo "GRUB_GFXMODE=1920x1080" >> /etc/default/grub
    update-grub >> $LOG_FILE 2>&1
    # Init Final Configuration
    progress_status $GRAY "Installing Final Files..." "90"
    # Creating Nirit Directory
    mkdir $HOME/.config/nirit >> $LOG_FILE 2>&1
    # Creating Nirit Logs Directory
    mkdir $HOME/.config/nirit/logs >> $LOG_FILE 2>&1
    # Installing Default Wallpaper
    cp settings/start/wallpaper.jpg $HOME/.config/nirit/ >> $LOG_FILE 2>&1
    # Installing Nirit Logo
    cp settings/start/logo.png $HOME/.config/nirit/ >> $LOG_FILE 2>&1
    # Changing the new files owner
    chown -R $USER:$USER $HOME/.config >> $LOG_FILE 2>&1
    chown -R $USER:$USER /usr/share/icons >> $LOG_FILE 2>&1
    chown -R $USER:$USER /usr/share/rofi/themes >> $LOG_FILE 2>&1
    chown -R $USER:$USER $HOME/.local >> $LOG_FILE 2>&1
    progress_status $GREEN "Instalation Completed" "100"
    colorize $GREEN "\nThe System Needs to be Rebooted to Apply Changes"
    echo -n "Do you want to reboot your system now? (Y,n): "
    read WANT_REBOOT
    if [[ $WANT_REBOOT == [yY] ]]; then
        echo "Rebooting the system on:"
        echo "3"
        sleep 1
        echo "2"
        sleep 1
        echo "1"
        sleep 1
        colorize $GREEN "\nReboot" >> $LOG_FILE
        reboot
    fi
    colorize $GREEN "\nNo Reboot" >> $LOG_FILE
    colorize $GREEN "\nFinishing the Install..." | tee -a $LOG_FILE
}

main "$@"