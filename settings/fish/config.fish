# Aliases

alias ls "exa --group-directories-first"
alias cat "batcat"
alias tree "exa -T"
alias update-system "sudo apt update && sudo apt upgrade -y && sudo apt autoremove"
alias install-program "sudo apt install"
alias poweroff-pc "systemctl poweroff"
alias restart-pc "systemctl reboot"

# Functions

function set-wallpaper
	cp $argv ~/.nirit/wallpaper.jpg
	feh --bg-scale ~/.nirit/wallpaper.jpg
end

function set-sink
	set ACTUAL_SINK $(grep "sink =" ~/.config/qtile/config.py | cut -d " " -f 3)
	sed -i "s/sink = $ACTUAL_SINK/sink = $argv/g" ~/.config/qtile/config.py
	echo "Reload Qtile to Update Sink"
end

function uninstall-program
	sudo apt purge $argv && sudo apt autoremove
end

function fix-opera
	wget $(wget -qO - https://api.github.com/repos/Ld-Hagen/fix-opera-linux-ffmpeg-widevine/releases | grep browser_download_url | cut -d '"' -f 4 | grep linux-x64 | head -n 1) -O libffmpeg.so.zip > /dev/null
        unzip libffmpeg.so.zip > /dev/null
        sudo mv libffmpeg.so /usr/lib/x86_64-linux-gnu/opera/libffmpeg.so
        rm libffmpeg.so.zip
end
