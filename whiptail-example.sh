#!/usr/bin/env bash
# For more info on 'whiptail' see:
#https://en.wikibooks.org/wiki/Bash_Shell_Scripting/Whiptail

# These exports are the only way to specify colors with whiptail.
# See this thread for more info: 
# https://askubuntu.com/questions/776831/whiptail-change-background-color-dynamically-from-magenta/781062
export NEWT_COLORS='
root=,blue
window=,black
shadow=,blue
border=blue,black
title=blue,black
textbox=blue,black
radiolist=black,black
label=black,blue
checkbox=black,blue
compactbutton=black,blue
button=black,red'

programchoices () {
    choices=()
    for key in "${!checkboxes[@]}"
    do
        spacer=$(for i in $(seq 1 38); do echo -n " "; done)
        # A portable way to check if a command exists in $PATH and is executable.
        # If it doesn't exist, we set the tick box to OFF.
        # If it exists, then we set the tick box to ON.
        if ! [ -x "$(command -v ${checkboxes[$key]})" ]; then
            choices+=("${key}" "${spacer}" "OFF")
        else
            choices+=("${key}" "${spacer}" "ON")
        fi
    done
}

selectedprograms() {
    result=$(
        # Creates the whiptail checklist. Also, we use a nifty
        # trick to swap stdout and stderr.
        whiptail --title "$title" \
                 --checklist "$text" 22 78 12 \
                 "${choices[@]}" \
                 3>&2 2>&1 1>&3-
    )
}

exitorinstall() {
    exitstatus=$?
    # Check the exit status, if 0 we will install the selected
    # packages. A command which exits with zero (0) has succeeded.
    # A non-zero (1-255) exit status indicates failure.
    if [ $exitstatus = 0 ]; then
        # Take the results and remove the "'s and add new lines.
        # Otherwise, pacman is not going to like how we feed it.
        programs=$(echo $result | sed 's/" /\n/g' | sed 's/"//g' )
        echo $programs
        paru --needed --ask 4 -Sy $programs || \
        echo "Failed to install required packages."
    else
        echo "User selected Cancel."
    fi
}


browsers () {
    title="Web Browsers"
    text="Select one or more web browsers to install.\nAll programs marked with '*' are already installed.\nUnselecting them will NOT uninstall them."

    # Create an array with KEY/VALUE pairs.
    # The first ["KEY] is the name of the package to install.
    # The second ="VALUE" is the executable binary.
    local -A checkboxes
    checkboxes["brave-bin"]="brave"
    checkboxes["chromium"]="chromium"
    checkboxes["firefox"]="firefox"
    checkboxes["google-chrome"]="google-chrome-stable"
    checkboxes["icecat-bin"]="icecat"
    checkboxes["librewolf-bin"]="librewolf"
    checkboxes["microsoft-edge-stable-bin"]="microsoft-edge-stable"
    checkboxes["opera"]="opera"
    checkboxes["qutebrowser"]="qutebrowser"
    checkboxes["ungoogled-chromium-bin"]="ungoogled-chromium"
    checkboxes["vivaldi"]="vivaldi"

    programchoices && selectedprograms && exitorinstall
}

otherinternet () {
    title="Other Internet Programs"
    text="Other Internet programs available for installation.\nAll programs marked with '*' are already installed.\nUnselecting them will NOT uninstall them."

    # Create an array with KEY/VALUE pairs.
    # The first ["KEY] is the name of the package to install.
    # The second ="VALUE" is the executable binary.
    local -A checkboxes
    checkboxes["deluge"]="deluge"
    checkboxes["discord"]="discord"
    checkboxes["element-desktop"]="element-desktop"
    checkboxes["filezilla"]="filezilla"
    checkboxes["geary"]="geary"
    checkboxes["hexchat"]="hexchat"
    checkboxes["jitsi-meet-bin"]="jitsi-meet-desktop"
    checkboxes["mailspring"""]="mailspring"
    checkboxes["telegram-desktop"]="telegram"
    checkboxes["thunderbird"]="thunderbird"
    checkboxes["transmission-gtk"]="transmission-gtk"

    programchoices && selectedprograms && exitorinstall
}

multimedia() {
    title="Multimedia Programs"
    text="Multimedia programs available for installation.\nAll programs marked with '*' are already installed.\nUnselecting them will NOT uninstall them."

    # Create an array with KEY/VALUE pairs.
    # The first ["KEY] is the name of the package to install.
    # The second ="VALUE" is the executable binary.
    local -A checkboxes
    checkboxes["blender"]="blender"
    checkboxes["deadbeef"]="deadbeef"
    checkboxes["gimp"]="gimp"
    checkboxes["inkscape"]="inkscape"
    checkboxes["kdenlive"]="kdenlive"
    checkboxes["krita"]="krita"
    checkboxes["mpv"]="mpv"
    checkboxes["obs-studio"]="obs"
    checkboxes["rhythmbox"]="rhythmbox"
    checkboxes["ristretto"]="ristretto"
    checkboxes["vlc"]="vlc"

    programchoices && selectedprograms && exitorinstall
}

office() {
    title="Office Programs"
    text="Office and productivity programs available for installation.\nAll programs marked with '*' are already installed.\nUnselecting them will NOT uninstall them."

    # Create an array with KEY/VALUE pairs.
    # The first ["KEY] is the name of the package to install.
    # The second ="VALUE" is the executable binary.
    local -A checkboxes
    checkboxes["abiword"]="abiword"
    checkboxes["evince"]="evince"
    checkboxes["gnucash"]="gnucash"
    checkboxes["gnumeric"]="gnumeric"
    checkboxes["libreoffice-fresh"]="lowriter"
    checkboxes["libreoffice-still"]="lowriter"
    checkboxes["scribus"]="scribus"
    checkboxes["zathura"]="zathura"

    programchoices && selectedprograms && exitorinstall
}

games () {
    title="Games"
    text="Gaming programs available for installation.\nAll programs marked with '*' are already installed.\nUnselecting them will NOT uninstall them."

    # Create an array with KEY/VALUE pairs.
    # The first ["KEY] is the name of the package to install.
    # The second ="VALUE" is the executable binary.
    local -A checkboxes
    checkboxes["0ad"]="0ad"
    checkboxes["gnuchess"]="gnuchess"
    checkboxes["lutris"]="lutris"
    checkboxes["neverball"]="neverball"
    checkboxes["openarena"]="openarena"
    checkboxes["steam"]="steam"
    checkboxes["supertuxkart"]="supertuxkart"
    checkboxes["sauerbraten"]="sauerbraten-client"
    checkboxes["teeworlds"]="teeworlds"
    checkboxes["veloren-bin"]="veloren"
    checkboxes["wesnoth"]="wesnoth"
    checkboxes["xonotic"]="xonotic-glx"

    programchoices && selectedprograms && exitorinstall
}

browsers
otherinternet
multimedia
office
games
