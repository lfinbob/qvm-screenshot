#!/bin/bash
# 
# Prerequisits:
# Install xclip in the guests (i.e. in a template) if you want the screenshots to be pushed to your guest's clipboard automatically (optional)
# Install ksnip and zenity (qube selection dialog) in dom0:
# sudo qubes-dom0-update --setopt=install_weak_deps=false ksnip zenity
# I chose ksnip because it has 0 dependencies in my pretty-vanilla Qubes install and it has a nice graphical editor to draw arrows, boxes, underlines, text, etc
#
# Usage:
# 1) Call this script (usually via a keyboard shortcut of your liking (like ctrl+alt+s) in dom0. Can be mapped in the keyboard settings applet
# 2) Ksnip editor will pop up. Edit the image if you like, then save the image
# 3) A dialog will popup asking you to which Qube the screenshot should be sent

# This is where screenshots are saved if you select dom0 as target
SCREENSHOT_NAME="screenshot-`date \"+%F %H%M%S\"`.png"
SCREENSHOT_DOM0="$HOME/Pictures/$SCREENSHOT_NAME"

# The directory where ksnip needs to be configured to save the screenshot upon exiting. We'll just find the newest file in there
# This workaround is only required because ksnip can't be told where to save the directory, otherwise the editor does not open
SCREENSHOT_SAVEDIR="$HOME/ksnip"

SCREENSHOT_CMD="/usr/bin/ksnip -r"

eval $SCREENSHOT_CMD

# Get a list of all qubes
qubes=$(qvm-ls --raw-list | tr '\n' ' ')

# Dirty workaround: Ksnip editor can't be told where to save the file, so we just find the latest. This is racy, so don't create & edit screenshots in parallel
screenshot="$SCREENSHOT_SAVEDIR/$(ls -Art "$SCREENSHOT_SAVEDIR" | tail -n 1)"

if [ ! -f "$screenshot" ]
then
	notify-send "`basename $0` error" "Temp screenshot file not found: $screenshot"
	exit 1
elif [ ! -s "$screenshot" ]
then
	notify-send "`basename $0` error" "Screenshot command did not write it's screenshot to $screenshot"
	rm -f "$screenshot"
	exit 1
fi

# ask which VM to send to 
# try to set height so that all options visible in the Qube selection dialog. Zenity upper-bounds to screen height for us
height=$(($(echo $qubes | wc -w) * 29))
destQube=$(zenity --list --height $height --title="Screenshot destination" --text="Qube to send screenshot to:" --column="Options" ${qubes[@]})

if [ -z "$destQube" ]
then
	notify-send "Aborted, deleting screenshot"
	rm -f "$screenshot"
	exit 1
elif [ "$destQube" = "dom0" ]
then
	mv "$screenshot" "$SCREENSHOT_DOM0"
	notify-send "Screenshot saved locally: $SCREENSHOT_DOM0"
	exit 0
fi

notify-send "Sending screenshot to $destQube"

qvm-move-to-vm "$destQube" "$screenshot" || exit 1
# copy it into Qube's clipboard
qvm-run "$destQube" --no-auto --no-gui -- "xclip -selection clipboard -t image/png /home/user/QubesIncoming/dom0/`basename $screenshot`"
