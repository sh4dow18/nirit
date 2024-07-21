# Qtile Configuration File
# http://www.qtile.org/

# Created by Sh4dow18
# My Github: https://www.github.com/sh4dow18
# My Website: https://sh4dow18.vercel.app

# Libraries Needed
from typing import List
from libqtile import bar, layout, widget
from libqtile.config import Click, Drag, Group, Key, Match, Screen
from libqtile.lazy import lazy
# Helpful Keys
super_key = "mod4"
alt_gr_key = "mod5"
shift = "shift"
# Default Apps
terminal = "alacritty"
browser = "opera"
ide = "code"
screen_capture = "flameshot gui"
file_manager = "thunar"
menu = "rofi -disable-history -show drun"
# My Information Variables
documentation_page = "{} https://digital-me.vercel.app/nirit".format(browser)
# Volume Variables
# Change Sink value to your Own
sink = 2
volume = "pamixer --sink {}".format(sink)
getVolume = "{} --get-volume-human".format(volume)
muteVolume = "{} --toggle-mute".format(volume)
increaseVolume = "{} -i 5".format(volume)
decreseVolume = "{} -d 5".format(volume)
# ---------- Key Bindings Settings ----------
keys = [Key(key[0], key[1], *key[2:]) for key in [
    # Windows Behavior in Layouts
    ([super_key], "j", lazy.layout.down()),
    ([super_key], "k", lazy.layout.up()),
    # Windows Behavior Regardless of Layouts
    ([alt_gr_key], "w", lazy.window.kill()),
    # Change Between Layouts
    ([alt_gr_key], "Tab", lazy.next_layout()),
    # Spawn Apps
    ([alt_gr_key], "F1", lazy.spawn(documentation_page)),
    ([super_key], "Return", lazy.spawn(terminal)),
    ([super_key], "m", lazy.spawn(menu)),
    ([alt_gr_key], "f", lazy.spawn(browser)),
    ([alt_gr_key], "c", lazy.spawn(ide)),
    ([alt_gr_key], "s", lazy.spawn(screen_capture)),
    ([alt_gr_key], "t", lazy.spawn(file_manager)),
    # Manage Volume
    ([super_key], "F9", lazy.spawn(muteVolume)),
    ([super_key], "F10", lazy.spawn(decreseVolume)),
    ([super_key], "F11", lazy.spawn(increaseVolume)),
    # Qtile Behavior
    ([super_key, "control"], "r", lazy.restart()),
    ([super_key, "control"], "q", lazy.shutdown())
]]
# ---------- Windows Groups Settings ----------
# Groups List
# Get the icons at https://www.nerdfonts.com/cheat-sheet (you need a Nerd Font)
# Opera Icon: nf-fa-opera ( )
# Visual Studio Icon: nf-dev-visualstudio ( )
# Terminar Icon: nf-dev-terminal ( )
# Group Icon: nf-fa-group ( )
# Controller Icon: nf-fa-gamepad ( )
# Video Camera Icon: nf-fa-video_camera ( )
# Layers Icon: nf-fae-layers ( )
groups = [Group(i) for i in ["", "", "", "", "","", ""]]
# Asign Key Bindings to Each Group that allows to Manipulate Windows in Groups
for i, j in enumerate(groups):
    number_key = str(i + 1)
    keys.extend([Key(key[0], key[1], *key[2:]) for key in [
        # Allows to Change into Groups
        ([alt_gr_key], number_key, lazy.group[j.name].toscreen()),
        # Allows to Move a Window form a Group to Another Group
        ([alt_gr_key, "shift"], number_key, lazy.window.togroup(j.name)),
    ]])

# ---------- Windows Layouts Settings ----------
# Remove the # and reset qtile to active layout
layouts = [
    # layout.Bsp(),
    # layout.Columns(),
    # layout.Floating(),
    # layout.Matrix(),
    layout.Max(),
    # layout.MonadTall(),
    # layout.MonadThreeCol(),
    # layout.MonadWide(),
    # layout.Plasma(),
    # layout.RatioTile(),
    # layout.ScreenSplit(),
    # layout.Slice(),
    # layout.Spiral(),
    # layout.Stack(),
    # layout.Tile(),
    # layout.TreeTab(),
    # layout.VerticalTile(),
    # layout.Zoomy(),
]

# ---------- Widgets Settings ------------
# Widgets Default Initial Settings
widget_defaults = dict(
    font="Agave Nerd Font Bold",
    fontsize=15,
    padding=0
)
# Common Params of Volume Widget
# Change sink value to change the volume
widgetVolumeParams = {
    "get_volume_command": getVolume,
    "mute_command": muteVolume,
    "volume_up_command": increaseVolume,
    "volume_down_command": decreseVolume
}
# Function that creates a Widgets Section
def widgetsSection(previousColor, backgroundColor, widgetsList, padding=3, fontsize=20):
    # Common Params to all Widgets in this Section
    commonParams = {
        "background": backgroundColor,
        "fontshadow": "000000",
        "padding": padding,
    }
    # Adding common params to each widget in widgets list
    for widgetInstance in widgetsList:
        for param, value in commonParams.items():
            setattr(widgetInstance, param, value)
    # Return a new list with an arrow, the widgets list and a spacer
    return [
        widget.TextBox(
            text="",
            fontsize=40,
            background=previousColor,
            foreground=backgroundColor,
            padding=-1
        ),
        *widgetsList,
        widget.Spacer(
            length=5,
            background=backgroundColor
        ),
    ]

# ---------- Screens Settings ----------
screens = [
    Screen(
        # Top bar Settings
        top=bar.Bar(
            [
                # Nirit Logo With Spacers
                widget.Spacer(
                    length=5
                ),
                widget.Image(
                    filename="~/.nirit/logo.png",
                    margin=1,
                ),
                widget.Spacer(
                    length=5
                ),
                # Desktop Environment's Name
                widget.TextBox(
                    text="Nirit"
                ),
                # Window's Name Information
                widget.WindowName(
                    padding=5,
                    format="| {name}"
                ),
                # CPU Information Section
                *widgetsSection(previousColor="000000", backgroundColor="0055AA", widgetsList=[
                    widget.CPU(
                        format="CPU: {freq_current}GHz {load_percent}%"
                    ),
                    # Change tag sensor to your CPU Sensor
                    # This Can Be Known with "sensors" command, but it is not the name, it is the tag
                    widget.ThermalSensor(
                        tag_sensor="Tctl",
                        threshold=80,
                        foreground_alert="AA0000"
                    )
                ]),
                # Ram Information Section
                *widgetsSection(previousColor="0055AA", backgroundColor="AA0000", widgetsList=[widget.Memory(
                    format="RAM: {MemUsed:.0f}{mm}B {MemPercent}%"
                )]),
                # Disk Information Section
                *widgetsSection(previousColor="AA0000", backgroundColor="444444", widgetsList=[
                    # Change the device to your own
                    # This can be Known with "ls /dev" command
                    widget.HDD(
                        device="nvme0n1",
                        format="NVME: {HDDPercent}%"
                    ),
                    # Change tag sensor to your Disk Sensor
                    # This Can Be Known with "sensors" command, but it is not the name, it is the tag
                    widget.ThermalSensor(
                        tag_sensor="Composite"
                    )
                ]),
                # Web Connection Information Section
                # Change the Interface to your own
                # This Can Be Known with "ip addr" command
                *widgetsSection(previousColor="444444", backgroundColor="006600", widgetsList=[widget.Net(
                    interface="enp34s0",
                    format=" :  {down:2.1f}{down_suffix} -  {up:2.1f}{up_suffix}",
                    prefix="M"
                )]),
            ],
            # Bar height in Pixels
            20
        ),
        # Bottom bar Settings
        bottom=bar.Bar(
            [
                # Main Group Box
                widget.GroupBox(
                    active="FFFFFF",
                    block_highlight_text_color="FFFFFF",
                    this_current_screen_border=["215578", "FF0000"],
                    fontshadow="000000",
                    fontsize=35,
                    highlight_method="block",
                    inactive="AAAAAA",
                    padding=5
                ),
                # Spacer to Separate Group Box from other Widgets Sections
                widget.Spacer(),
                # Check Updates Information Section
                *widgetsSection(previousColor="000000", backgroundColor="AA0000", widgetsList=[widget.CheckUpdates(
                    distro="Debian",
                    display_format="  {updates}",
                    no_update_string="  0",
                    fontsize=18,
		    update_interval=5
                )], padding=5),
                # Current Layout  Information Section
                *widgetsSection(previousColor="AA0000", backgroundColor="0055AA", widgetsList=[
                    widget.CurrentLayoutIcon(
                        scale=0.7,
                    ),
                    widget.CurrentLayout()
                ]),
                # Volume Information Section
                *widgetsSection(previousColor="0055AA", backgroundColor="572364", widgetsList=[
                    widget.Volume(
                        emoji=True,
                        emoji_list=["", "", "", " "],
                        fontsize=20,
                        **widgetVolumeParams
                    ),
                    widget.Volume(
                        fontsize=18,
                        **widgetVolumeParams
                    )
                ]),
                # System Tray Information Section
                *widgetsSection(previousColor="572364", backgroundColor="EEEEEE", widgetsList=[widget.Systray()]),
                # Clock Information Section
                *widgetsSection(previousColor="EEEEEE", backgroundColor="673400", widgetsList=[
                    widget.TextBox(
                        text=" ",
                        fontsize=20,
                    ),
                    widget.Clock(
                        format="%d-%m-%Y %a %I:%M %p",
                    )
                ]),
                # Quick Important Events Information Section
                *widgetsSection(previousColor="673400", backgroundColor="e67600", widgetsList=[
                    widget.LaunchBar(
                        text_only=True,
                        progs=[(
                            "⏻ ",
                            "systemctl poweroff",
                            "Shutdown PC",
                        )],
                        fontsize=20
                    ),
                    widget.QuickExit(
                        default_text=" ",
                        countdown_format="{} ",
                        fontsize=20
                    )
                ]),
            ],
            # Bar height in Pixels
            30,
        ),
    ),
]
# Mouse Configuration to Floating Windows
mouse = [
    Drag([super_key], "Button1", lazy.window.set_position_floating(), start=lazy.window.get_position()),
    Drag([super_key], "Button3", lazy.window.set_size_floating(), start=lazy.window.get_size()),
]

# Qtile Settings
dgroups_key_binder = None
dgroups_app_rules = []
follow_mouse_focus = True
bring_front_click = False
cursor_warp = False
auto_fullscreen = True
focus_on_window_activation = "smart"
floats_kept_above = True
reconfigure_screens = True
auto_minimize = True
wl_input_rules = None
wl_xcursor_theme = None
wl_xcursor_size = 24
wmname = "LG3D"
