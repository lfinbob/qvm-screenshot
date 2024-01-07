# About qvm-screenshot
A simple script to take screenshtos in dom0, edit them in a GUI and move them to a Qube of your via a selection menu.
The script uses ksnip as the screenshot tool because it can be installed with 0 dependencies and has a nice editor for drawing arrows, boxes, text etc.

# Prerequists (do this before using the script)
In dom0: Install ksnip (to take and edit screenshots) and zenity (qube selection dialog):

`sudo qubes-dom0-update --setopt=install_weak_deps=false ksnip zenity`

In guests (optional): Install xclip in the guests (i.e. in a template) if you want the screenshots to be pushed to your guest's clipboard automatically.

# How to use:
1) Call this script in dom0. Usually done via a keyboard shortcut of your liking (like ctrl+alt+s). Can be mapped in the keyboard settings applet in dom0.
2) Ksnip editor will pop up. Edit the image if you like, then save the image. If you don't save the screenshot will be discarded.
3) A dialog will popup asking you to which Qube the screenshot should be sent

That's it, your screenshot is in the QubesIncoming/dom0 folder of the Qube you selected or in dom0's $HOME/Pictures folder if you selected dom0 as destination.
