#!/usr/bin/env bash
#  ____ _____ ___  ____
# |  _ \_   _/ _ \/ ___|   Derek Taylor (DistroTube)
# | | | || || | | \___ \   http://www.youtube.com/c/DistroTube
# | |_| || || |_| |___) |  http://www.gitlab.com/dwt1/dtos
# |____/ |_| \___/|____/
#
# NAME: DTOS
# DESC: An installation and deployment script for DT's Xmonad desktop.
# WARNING: Run this script at your own risk.

if [ "$(id -u)" = 0 ]; then
    echo "##################################################################"
    echo "This script MUST NOT be run as root user since it makes changes"
    echo "to the \$HOME directory of the \$USER executing this script."
    echo "The \$HOME directory of the root user is, of course, '/root'."
    echo "We don't want to mess around in there. So run this script as a"
    echo "normal user. You will be asked for a sudo password when necessary."
    echo "##################################################################"
    exit 1
fi

error() { \
    clear; printf "ERROR:\\n%s\\n" "$1" >&2; exit 1;
}

welcome() { \
    dialog --colors --title "\Z5\ZbInstalling DTOS!" --msgbox "\Z2This is a script that will install what I sarcastically call \Z5DTOS (DT's operating system)\Zn\Z2. It's really just an installation script for those that want to try out my XMonad desktop.  We will add DTOS repos to Pacman and install the XMonad tiling window manager, the Xmobar panel, the Alacritty terminal, the Fish shell, Doom Emacs and many other essential programs needed to make my dotfiles work correctly.\\n\\n-DT (Derek Taylor, aka DistroTube)" 16 60
    dialog --colors --title "\Z5\ZbStay near your computer!" --yes-label "Continue" --no-label "Exit" --yesno "\Z2This script is not allowed to be run as root. But you will be asked to enter your root password at various points during this installation. This is to give PACMAN the necessary permissions to install the software." 8 60
}

welcome || error "User choose to exit."

lastchance() { \
    dialog --colors --title "\Z5\ZbAre You Sure You Want To Do This?" --yes-label "Begin Installation" --no-label "Exit" --yesno "\Z2Shall we begin installing DTOS?" 8 60 || { clear; exit 1; }
}

lastchance || error "User choose to exit."

addrepo() { \
    echo "#########################################################"
    echo "## Adding the DTOS core repository to /etc/pacman.conf ##"
    echo "#########################################################"
    grep -qxF "^[dtos-core-repo]" /etc/pacman.conf ||
        (echo "[dtos-core-repo]"; echo "SigLevel = Required DatabaseOptional"; echo "Server = https://gitlab.com/dwt1/\$repo/-/raw/main/\$arch") | sudo tee -a /etc/pacman.conf
}

addrepo || error "Error adding DTOS repo to /etc/pacman.conf."

addkeyserver() { \
    echo "#######################################################"
    echo "## Adding keyservers to /etc/pacman.d/gnupg/gpg.conf ##"
    echo "#######################################################"
    grep -qxF "keyserver hkp://keyserver.ubuntu.com:80" /etc/pacman.d/gnupg/gpg.conf || echo "keyserver hkp://keyserver.ubuntu.com:80" | sudo tee -a /etc/pacman.d/gnupg/gpg.conf
    grep -qxF "keyserver hkps://keyserver.ubuntu.com:443" /etc/pacman.d/gnupg/gpg.conf || echo "keyserver hkps://keyserver.ubuntu.com:443" | sudo tee -a /etc/pacman.d/gnupg/gpg.conf
}

addkeyserver || error "Error adding keyservers to /etc/pacman.d/gnupg/gpg.conf"

receive_key() { \
    echo "#####################################"
    echo "## Adding PGP key C71486C31555B12E ##"
    echo "#####################################"
    sudo pacman-key --recv-key C71486C31555B12E
    sudo pacman-key --lsign-key C71486C31555B12E
}

receive_key || error "Error receiving PGP key C71486C31555B12E"

sudo pacman --noconfirm --needed -Sy dialog || error "Error syncing the repos."

declare -a dtospkgs=("adobe-source-code-pro-fonts"
"adobe-source-sans-fonts"
"alacritty"
"awesome"
"aura"
"bluez"
"bluez-utils"
"bash"
"bat"
"cups"
"dmenu-distrotube"
"dwm-distrotube"
"dwmblocks-distrotube"
"dmscripts"
"dtos-backgrounds"
"dtos-bash"
"dtos-fish"
"dtos-local-bin"
"dtos-xmobar"
"dtos-xmonad"
"dtos-xwallpaper"
"dtos-zsh"
"emacs"
"exa"
"fd"
"fish"
"git"
"libxft-bgra"
"lolcat"
"lxappearance"
"lxsession"
"maim"
"mpv"
"neovim"
"network-manager-applet"
"opendoas"
"otf-font-awesome"
"paru"
"pcmanfm"
"picom"
"qalculate-gtk"
"qtile"
"qt5ct"
"qutebrowser"
"ripgrep"
"rust"
"sddm"
"shell-color-scripts"
"shellcheck"
"starship"
"st-distrotube"
"stack"
"sxiv"
"ttf-hack"
"ttf-joypixels"
"ttf-mononoki"
"ttf-ms-fonts"
"ttf-ubuntu-font-family"
"trayer"
"vim"
"volumeicon"
"xf86-video-qxl"
"xf86-video-intel"
"xf86-video-amdgpu"
"xf86-video-nouveau"
"xmonad"
"xmonad-contrib"
"xmobar"
"xorg-server"
"xorg-xkill"
"xorg-xmessage"
"xorg-xprop"
"xterm"
"xwallpaper"
"yad"
"zathura"
"zsh")

for x in "${dtospkgs[@]}"; do
    sudo pacman --noconfirm --needed -S "$x"
done

echo "#########################################################"
echo "## Installing Doom Emacs. This may take a few minutes. ##"
echo "#########################################################"
[ -d ~/.emacs.d ] && mv ~/.emacs.d ~/.emacs.d.bak.$(date +"%Y%m%d_%H%M%S")
[ -f ~/.emacs ] && mv ~/.emacs ~/.emacs.bak.$(date +"%Y%m%d_%H%M%S")
git clone --depth 1 https://github.com/hlissner/doom-emacs ~/.emacs.d
~/.emacs.d/bin/doom install

echo "################################################################"
echo "## Copying DTOS configuration files from /etc/skel into \$HOME ##"
echo "################################################################"
mkdir ~/skel-backup-$(date +%Y.%m.%d-%H%M) && cp -Rf /etc/skel ~/skel-backup-$(date +%Y.%m.%d-%H%M)
[ -d ~/.config ] && mkdir ~/.config
[ -d ~/.config ] && mkdir ~/.config-backup-$(date +%Y.%m.%d-%H%M) && cp -Rf ~/.config ~/.config-backup-$(date +%Y.%m.%d-%H%M)
cd /etc/skel && cp -Rf . ~ && cd -

cp /etc/skel/.xmonad/pacman-hooks/recompile-xmonad.hook /etc/pacman.d/hooks/
cp /etc/skel/.xmonad/pacman-hooks/recompile-xmonadh.hook /etc/pacman.d/hooks/

xmonad_recompile() { \
    echo "########################"
    echo "## Recompiling XMonad ##"
    echo "########################"
    xmonad --recompile
}

xmonad_recompile || error "Error recompiling Xmonad!"

xmonadctl_compile() { \
    echo "####################################"
    echo "## Compiling the xmonadctl script ##"
    echo "####################################"
    ghc -dynamic "$HOME"/.xmonad/xmonadctl.hs
}

xmonadctl_compile || error "Error compiling the xmonadctl script!"

loginmanager() { \
    dialog --colors --title "\Z5\ZbInstallation Complete!" --msgbox "\Z2Now logout of your current desktop environment or window manager and choose XMonad from your login manager.  ENJOY!" 10 60
}

loginmanager && echo "DTOS has been installed!"
