#!/bin/bash
# Help Function
color() {
    echo -n "\e[${1}m"
}
colorize() {
    echo -e "$1$2$RESET_COLOR"
}
help() {
    colorize "\nUse: $0 INSTALLATION_METHOD\n"
    echo "Options:"
    echo -e "\t-o\tOnly Core Method"
    echo -e "\t-n\tNormal Method\n"
}
is_installed() {
    dpkg -l | grep -q "^ii  $1 "
}
progress_status() {
    colorize $1 "\n\t- $2 ($3%)" | tee -a $LOG_FILE
}
install_programs() {
    INSTALL_MESSAGE=""
    if [[ $5 == true ]]; then
        INSTALL_MESSAGE="Programs to "
    fi
    progress_status $1 "Installing $INSTALL_MESSAGE$2" $3
    sudo apt-get install -y $4 >> $LOG_FILE 2>&1
}
install_github_program() {
    progress_status $1 "Installing $2" $3
    URL=$(wget -qO - https://api.github.com/repos/$4/releases | grep "browser_download_url" | cut -d '"' -f 4 | grep ".deb" | head -n 1)
    wget $URL -O "$2.deb" >> $LOG_FILE 2>&1
    sudo apt-get install -y "./$2.deb" >> $LOG_FILE 2>&1
    rm "./$2.deb" >> $LOG_FILE 2>&1
}
no_questions() {
    echo "$1" | sudo debconf-set-selections >> $LOG_FILE 2>&1
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
    # Main Verifications
    OPERATING_SYSTEM=$(cat /etc/os-release | grep PRETTY_NAME | cut -d "=" -f 2 | sed 's/"//g' | cut -d " " -f 1)
    if [[ $OPERATING_SYSTEM != "Debian" ]]; then
        colorize $RED "\nEste Instalador solo es Compatible con Debian, no con '$OPERATING_SYSTEM' por el momento\n" | tee -a $LOG_FILE
        exit 1
    fi
    if [[ $EUID != 0 ]]; then
        colorize $RED "\nDebe ejecutar este instalador con permisos de Super Usuario (sudo)\n" | tee -a $LOG_FILE
        exit 1
    fi
    if [[ $# -lt 1 ]]; then
        help
        exit 1
    fi
    # Nirit Core Programs
    LOGIN="xorg lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings"
    DESKTOP="x11-xserver-utils python3-pip python3-xcffib python3-cairocffi libpangocairo-1.0-0 python3-psutil apt-show-versions"
    FILES="zip unzip gnome-text-editor thunar"
    MENUS="rofi"
    DEVICES="udiskie ntfs-3g policykit-1-gnome gnome-disk-utility lxrandr blueman cbatticon gvfs-backends"
    TERMINAL="exa fish bat alacritty"
    AUDIO="pulseaudio pamixer"
    NOTIFICATIONS="dunst libnotify-bin"
    UTILITIES="flameshot ibus gnome-system-monitor connman connman-gtk"
    # Nirit Important Variables
    BROWSER="firefox-esr"
    LIBREOFFICE="libreoffice"
    DRIVERS=""
    IDE=""
    STEAM=""
    HEROIC=""
    # Verify if it is the Only Core Method
    if [[ $1 == "-o" ]]; then
        colorize $BROWN "\nChosen Method: Only Core" | tee -a $LOG_FILE
    # Verify if it is the Normal Method
    elif [[ $1 == "-n" ]]; then
        colorize $BROWN "\nChosen Method: Normal" | tee -a $LOG_FILE
        # Nirit Core Recommended Programs to Better Experience
        MULTIMEDIA="vlc feh gpicview audacious"
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
                esac
            fi
        done
    # If it is a Invalid Argument, show help and exit with code 1
    else
        colorize $RED "\nInvalid Argument $1" | tee -a $LOG_FILE
        help
        exit 1
    fi
    colorize $HIGH_PURPLE "\nAdding Init Settings..."
    # If the User want to install Opera Browser, the program verifies if opera exists already, and if this one
    # was not installed, add the necesarry code to the apt repository
    if [[ $BROWSER == "opera-stable" ]]; then
        if ! is_installed $BROWSER; then
            progress_status $HIGH_RED "Adding Opera Repository" "0"
            sudo apt-get install software-properties-common apt-transport-https curl ca-certificates -y >> $LOG_FILE 2>&1
            curl -fSsL https://deb.opera.com/archive.key | gpg --dearmor | sudo tee /usr/share/keyrings/opera.gpg >> $LOG_FILE 2>&1
            echo deb [arch=amd64 signed-by=/usr/share/keyrings/opera.gpg] https://deb.opera.com/opera-stable/ stable non-free >> /etc/apt/sources.list.d/opera.list
        fi
    fi
    # If the User want to install the Nvidia Drivers, the program verifies if the drivers exists already, and if this one
    # was not installed, add the necesarry code to the apt repository
    if [[ $DRIVERS != "" ]]; then
        if ! is_installed "nvidia-driver"; then
            progress_status $HIGH_GREEN "Adding Nvidia Driver's Repository" "25"
            sudo apt-get install software-properties-common -y >> $LOG_FILE 2>&1
            sudo add-apt-repository contrib non-free-firmware -y >> $LOG_FILE 2>&1
            sudo add-apt-repository contrib non-free -y >> $LOG_FILE 2>&1
        fi
    fi
    # If the User want to install Visual Studio Code, the program verifies if vscode exists already, and if this one
    # was not installed, add the necesarry code to the apt repository
    if [[ $IDE != "" ]]; then
        if ! is_installed $IDE; then
            progress_status $LIGHT_BLUE "Adding Visual Studio Code Repository" "50"
            sudo apt-get install curl gpg -y >> $LOG_FILE 2>&1
            curl -s https://packages.microsoft.com/keys/microsoft.asc | gpg --dearmor > microsoft.gpg
            sudo install -o root -g root -m 644 microsoft.gpg /etc/apt/keyrings/microsoft-archive-keyring.gpg >> $LOG_FILE 2>&1
            sudo sh -c 'echo "deb [arch=amd64,arm64,armhf signed-by=/etc/apt/keyrings/microsoft-archive-keyring.gpg] https://packages.microsoft.com/repos/vscode stable main" > /etc/apt/sources.list.d/vscode.list'
            sudo rm microsoft.gpg >> $LOG_FILE 2>&1
        fi
    fi
    # If the User want to install Steam, the program verifies if steam exists already, and if this one
    # was not installed, add the necesarry code to the apt repository
    if [[ $STEAM != "" ]]; then
        if ! is_installed "steam-installer"; then
            progress_status $HIGH_BLUE "Adding Steam Repository" "75"
            FILE=/etc/apt/sources.list
            if ! grep -v "#" $FILE | grep -q "contrib"; then
                ORIGINAL_LINE=$(grep -v "#" $FILE | grep "deb" | head -n 1)
                NEW_LINE="$ORIGINAL_LINE contrib non-free"
                sudo sed -i "s|^$ORIGINAL_LINE|$NEW_LINE|" $FILE
                sudo dpkg --add-architecture i386
            fi
        fi
    fi
    progress_status $GREEN "Repositories Updated" "100"
    # System Update
    colorize $YELLOW "\nSearching System Updates..." | tee -a $LOG_FILE
    progress_status $BROWN "Updating Apt Repository" "0"
    sudo apt-get update >> $LOG_FILE 2>&1
    progress_status $HIGH_BLUE "Installing Packages Updates" "33"
    sudo apt-get upgrade -y >> $LOG_FILE 2>&1
    progress_status $PURPLE "Removing Unnecessary Packages" "66"
    sudo apt-get autoremove >> $LOG_FILE 2>&1
    progress_status $GREEN "Update Finished" "100"
    # Install Programs
    # Installing Nirit Core
    colorize $BROWN "\nInstalling Nirit Core..." | tee -a $LOG_FILE
    install_programs $HIGH_BLUE "Log In" "0" "$LOGIN" true
    install_programs $ORANGE "Have a Desktop" "10" "$DESKTOP" true
    sudo pip install --no-cache-dir --break-system-packages qtile >> $LOG_FILE 2>&1
    install_programs $WHITE "Manipulate Files" "20" "$FILES" true
    install_programs $HIGH_PURPLE "Have a Menu to Launch Apps" "30" "$MENUS" true
    install_programs $BROWN "Maniputate Devices" "40" "$DEVICES" true
    install_programs $HIGH_GREEN "Have a Better Experience in a Terminal" "50" "$TERMINAL" true
    install_programs $PURPLE "Have Audio" "60" "$AUDIO" true
    install_programs $HIGH_BLUE "Have Notifications" "70" "$NOTIFICATIONS" true
    install_programs $GRAY "Utilities" "80" "$UTILITIES" false
    if [[ $BROWSER == "opera-stable" ]]; then
        no_questions "opera-stable opera-stable/add-deb-source boolean false"
    fi
    install_programs $HIGH_RED "Browser" "90" "$BROWSER" false
    progress_status $GREEN "Instalation Completed" "100"
    if [[ $1 == "-n" ]]; then
        # Installing Nirit Recommended
        colorize $HIGH_PURPLE "\nInstalling Nirit Recommended..." | tee -a $LOG_FILE
        install_programs $ORANGE "View Multimedia Files" "0" "$MULTIMEDIA" true
        install_programs $HIGH_BLUE "Change Themes" "33" "$THEMES" true
        install_programs $HIGH_RED "Office" "66" "$OFFICE $LIBREOFFICE" true
        if [[ $LIBREOFFICE == "" ]]; then
            wget https://download.onlyoffice.com/install/desktop/editors/linux/onlyoffice-desktopeditors_amd64.deb -O onlyoffice.deb >> $LOG_FILE 2>&1
            sudo apt-get install -y ./onlyoffice.deb >> $LOG_FILE 2>&1
            rm onlyoffice.deb >> $LOG_FILE 2>&1
        fi
        progress_status $GREEN "Instalation Completed" "100"
        # Installing Nirit Extras
        colorize $WHITE "\nInstalling Nirit Extras..." | tee -a $LOG_FILE
        if [[ $DRIVERS != "" ]]; then
            no_questions "nvidia-driver nvidia-driver/accept-terms boolean true"
            install_programs $HIGH_GREEN "Nvidia Drivers" "0" "$DRIVERS" true
        fi
        if [[ $IDE != "" ]]; then
            install_programs $LIGHT_BLUE "Visual Studio Code" "25" "$IDE" false
        fi
        if [[ $STEAM != "" ]]; then
            no_questions "steam-installer steam/license select true"
            install_programs $HIGH_BLUE "Steam" "50" "$STEAM" false
            if [[ $DRIVERS != "" ]]; then
                sudo apt-get install "nvidia-driver-libs:i386" >> $LOG_FILE 2>&1
            fi
        fi
        if [[ $HEROIC == true ]]; then
            install_github_program $WHITE "Heroic Games Launcher" "75" "Heroic-Games-Launcher/HeroicGamesLauncher"
        fi
        progress_status $GREEN "Instalation Completed" "100"
    fi
    colorize $HIGH_RED "\nInstalling Nirit Configuration..." | tee -a $LOG_FILE
    progress_status $ORANGE "Creating Config Directory..." "0"
    # Creating User Home's Variable
    USER=$(who | head -n 1 | cut -d " " -f 1)
    HOME=/home/$USER
    # Creating Configuration Directory
    sudo mkdir $HOME/.config >> $LOG_FILE 2>&1
    # Changing Fonts
    progress_status $PURPLE "Installing Fonts..." "9"
    mkdir $HOME/.local >> $LOG_FILE 2>&1
    mkdir $HOME/.local/share >> $LOG_FILE 2>&1
    cp -r settings/fonts/ $HOME/.local/share/ >> $LOG_FILE 2>&1
    fc-cache -f
    # Installing Lightdm Configuration
    progress_status $LIGHT_BLUE "Installing Lightdm Configuration..." "18"
    sudo mkdir /usr/share/xsessions >> $LOG_FILE 2>&1
    sudo systemctl enable lightdm >> $LOG_FILE 2>&1
    sudo cp settings/lightdm/lightdm-gtk-greeter.conf /etc/lightdm/ >> $LOG_FILE 2>&1
    sudo mkdir /usr/share/pictures >> $LOG_FILE 2>&1
    sudo cp settings/lightdm/epic.jpg /usr/share/pictures/ >> $LOG_FILE 2>&1
    sudo cp settings/lightdm/user.png /usr/share/pictures/ >> $LOG_FILE 2>&1
    sudo sed -i "s/#user-session=default/user-session=Nirit/g" /etc/lightdm/lightdm.conf 2>> $LOG_FILE
    #user-session=default
    # Installing Qtile Configuration
    progress_status $ORANGE "Installing Qtile Configuration..." "27"
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
    # Getting Disk Part's Major to Know in which Disk is Mounted root
    DISK_PART_MAJ=$(lsblk -o NAME,MAJ:MIN,MOUNTPOINT | sed "s/  */ /g" | grep ' /$' | cut -d " " -f 2 | cut -d ":" -f 1)
    # Getting Disk with Disk Part's Major
    DISK=$(lsblk -o NAME,MAJ:MIN,MOUNTPOINT | sed "s/  */ /g" | grep "$DISK_PART_MAJ:0" | cut -d " " -f 1)
    # Changing Disk in Qtile Config
    sed -i "s/device=\"DISK\"/device=\"$DISK\"/g" settings/qtile/config.py 2>> $LOG_FILE
    sed -i "s/format=\"DISK: {HDDPercent}%\"/format=\"$DISK: {HDDPercent}%\"/g" settings/qtile/config.py 2>> $LOG_FILE
    # Getting the Primary Network Interface
    INTERFACE=$(ip addr | grep "^2" | cut -d " " -f 2 | cut -d ":" -f 1)
    # Changing Network Interface in Qtile Config
    sed -i "s/interface=\"INTERFACE\"/interface=\"$INTERFACE\"/g" settings/qtile/config.py 2>> $LOG_FILE
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
    sudo cp settings/start/Nirit.desktop /usr/share/xsessions/ >> $LOG_FILE 2>&1
    sudo cp settings/start/nirit /etc/X11/ >> $LOG_FILE 2>&1
    # Installing Alacritty Configuration
    progress_status $BROWN "Installing Alacritty Configuration..." "36"
    sudo cp -r settings/alacritty $HOME/.config/ >> $LOG_FILE 2>&1
    # Installing Rofi Menu Configuration
    progress_status $HIGH_PURPLE "Installing Rofi Configuration..." "45"
    sudo cp settings/rofi/launcher.rasi /usr/share/rofi/themes/ >> $LOG_FILE 2>&1
    mkdir $HOME/.config/rofi >> $LOG_FILE 2>&1
    cp settings/rofi/config.rasi $HOME/.config/rofi/ >> $LOG_FILE 2>&1
    # Changing to the "Fish" shell and Installing "Fish" Configuration
    progress_status $HIGH_GREEN "Installing Fish Configuration..." "54"
    sudo chsh -s /bin/fish $USER >> $LOG_FILE 2>&1
    mkdir $HOME/.config/fish >> $LOG_FILE 2>&1
    cp settings/fish/config.fish $HOME/.config/fish >> $LOG_FILE 2>&1
    # Installing Dunst Configuration
    progress_status $HIGH_BLUE "Installing Dunst Configuration..." "63"
    mkdir $HOME/.config/dunst
    cp settings/dunst/dunstrc $HOME/.config/dunst >> $LOG_FILE 2>&1
    sudo cp -r settings/dunst/icons /usr/share/icons/nirit
    # Installing New Cursor
    progress_status $WHITE "Installing Cursor..." "72"
    sudo unzip settings/gtk/cursor/ComixCursors-Opaque-White.zip >> $LOG_FILE 2>&1
    sudo mkdir /usr/share/icons/ >> $LOG_FILE 2>&1
    sudo mv ComixCursors-Opaque-White/ /usr/share/icons/ >> $LOG_FILE 2>&1
    sudo mkdir /usr/share/icons/default/ >> $LOG_FILE 2>&1
    sudo cp settings/gtk/cursor/index.theme /usr/share/icons/default/ >> $LOG_FILE 2>&1
    # Installing Grub Theme
    progress_status $LIGHT_BLUE "Installing Grub Theme..." "81"
    sudo unzip settings/grub/darkmatter.zip >> $LOG_FILE 2>&1
    sudo mkdir /boot/grub/themes >> $LOG_FILE 2>&1
    sudo mv darkmatter/ /boot/grub/themes >> $LOG_FILE 2>&1
    sudo echo 'GRUB_THEME="/boot/grub/themes/darkmatter/theme.txt"' >> /etc/default/grub
    sudo echo 'GRUB_GFXMODE=1920x1080' >> /etc/default/grub
    sudo update-grub >> $LOG_FILE 2>&1
    # Init Final Configuration
    progress_status $GRAY "Installing Final Files..." "90"
    # Creating Nirit Directory
    sudo mkdir $HOME/.nirit >> $LOG_FILE 2>&1
    # Installing Default Wallpaper
    cp settings/start/wallpaper.jpg $HOME/.nirit/ >> $LOG_FILE 2>&1
    # Installing Nirit Logo
    cp settings/start/logo.png $HOME/.nirit/ >> $LOG_FILE 2>&1
    # Changing the new files owner
    sudo chown -R $USER:$USER $HOME/.config >> $LOG_FILE 2>&1
    sudo chown -R $USER:$USER $HOME/.nirit >> $LOG_FILE 2>&1
    sudo chown -R $USER:$USER /usr/share/icons >> $LOG_FILE 2>&1
    sudo chown $USER:$USER $HOME/gtkrc-2.0 >> $LOG_FILE 2>&1
    sudo chown $USER:$USER /usr/share/rofi/themes >> $LOG_FILE 2>&1
    sudo chown -R $USER:$USER $HOME/.local >> $LOG_FILE 2>&1
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