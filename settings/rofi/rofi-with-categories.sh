#!/bin/bash

# Created by Ramsés Solano (sh4dow18)
# My Github: https://www.github.com/sh4dow18

# Categories Array
CATEGORIES=("Audio" "Communication" "Development" "Devices" "Files" "Games" "Internet" "Multimedia" "Office" "Utilities" "Other")
# Icons to each category
ICONS=("" "" "" "" "" "" "" "" "" "" "")
# Combine icons and categories into a single list of menu items.
MENU_ITEMS=$(paste -d ' ' <(printf "%s  \n" "${ICONS[@]}") <(printf "%s\n" "${CATEGORIES[@]}"))
# Display the menu in Rofi with the menu items and Store the user's selection in the "selected" variable.
SELECTED=$(printf "%s\n" "$MENU_ITEMS" | rofi -dmenu -markup-rows -p "Categorías")
# If no selection, exit Rofi
[[ -z $SELECTED ]] && exit
# Extract the category name from the user's selection
CATEGORY=$(echo "$SELECTED" | awk '{$1=""; print $0}' | sed "s/^ *//")
# Launch Rofi in application mode, filtered by the selected category
rofi -disable-history -show drun -drun-categories "$CATEGORY"

