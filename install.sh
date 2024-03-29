#!/bin/bash

clear

echo -e "MY PERSONAL ARCH APPS"

# The main packages
main_stage=(
    keyd
    lsd
    zoxide
    fzf
    neovim
    gnome-disk-utility
    enpass-bin
    google-chrome
    microsoft-edge-stable-bin
    ms-365-electron-bin
    zapzap
    telegram-desktop
    ytmdesktop
)

# Set some colors
CNT="[\e[1;36mNOTE\e[0m]"
COK="[\e[1;32mOK\e[0m]"
CER="[\e[1;31mERROR\e[0m]"
CAT="[\e[1;37mATTENTION\e[0m]"
CWR="[\e[1;35mWARNING\e[0m]"
CAC="[\e[1;33mACTION\e[0m]"
INSTLOG="install.log"

# Function that would show a progress bar to the user
show_progress() {
    while ps | grep $1 &> /dev/null;
    do
        echo -n "."
        sleep 2
    done
    echo -en "Done!\n"
    sleep 2
}

# Function that will test for a package and if not found it will attempt to install it
install_software() {
    # First lets see if the package is there
    if yay -Q $1 &>> /dev/null ; then
        echo -e "$COK - $1 is already installed."
    else
        # No package found so installing
        echo -en "$CNT - Now installing $1 ."
        if [[ $1 == "ytmdesktop" ]]; then
            sudo rm -f /usr/lib/debug/.build-id/32/*
            sudo rm -f /usr/lib/debug/.build-id/36/*
            sudo rm -f /usr/lib/debug/.build-id/73/*
            sudo rm -f /usr/lib/debug/.build-id/5c/*
            sudo rm -f /usr/lib/debug/.build-id/a2/*
            sudo rm -f /usr/lib/debug/.build-id/c0/*
            sudo rm -f /usr/lib/debug/.build-id/f4/*
        fi
        yay -S --noconfirm $1 &>> $INSTLOG &
        show_progress $!
        # Test to make sure package installed
        if yay -Q $1 &>> /dev/null ; then
            echo -e "\e[1A\e[K$COK - $1 was installed."
        else
            # If this is hit then a package is missing, exit to review log
            echo -e "\e[1A\e[K$CER - $1 install had failed, please check the install.log"
            exit
        fi
    fi
}

# Give the user an option to exit out
read -rep $'[\e[1;33mACTION\e[0m] - Would you like to continue with the install (y,n) ' CONTINST
if [[ $CONTINST == "Y" || $CONTINST == "y" ]]; then
    echo -e "$CNT - Starting..."
    sudo touch /tmp/simple-hypr.tmp
else
    echo -e "$CNT - This script will now exit, no changes were made to your system."
    exit
fi

# Update pacman
echo -en "$CNT - Updating pacman."
sudo pacman -Syy &>> $INSTLOG &
show_progress $!
echo -e "\e[1A\e[K$COK - pacman updated."

# Update applications
echo -en "$CNT - Upgrading applications."
sudo pacman -Suy &>> $INSTLOG &
show_progress $!
echo -e "\e[1A\e[K$COK - applications updated."

# Check for package manager
if [ ! -f /sbin/yay ]; then
    echo -en "$CNT - Configuring yay."
    git clone https://aur.archlinux.org/yay.git &>> $INSTLOG
    cd yay
    makepkg -si --noconfirm &>> ../$INSTLOG &
    show_progress $!
    if [ -f /sbin/yay ]; then
        echo -e "\e[1A\e[K$COK - yay configured"
        cd ..

        # Update the yay database
        echo -en "$CNT - Updating yay."
        yay -Suy --noconfirm &>> $INSTLOG &
        show_progress $!
        echo -e "\e[1A\e[K$COK - yay updated."
    else
        # If this is hit then a package is missing, exit to review log
        echo -e "\e[1A\e[K$CER - yay install failed, please check the install.log"
        exit
    fi
fi

# Main components
echo -e "$CNT - Installing components, this may take a while..."
for SOFTWR in ${main_stage[@]}; do
    install_software $SOFTWR
done

# Copy .bachrc
echo -e "$CNT - Coping zsh config..."
cp -raf configs/zsh/. ~/.config/zsh/
zsh &

# Enable and congif keyd
echo -e "$CNT - Coping keyd.config file and enable it..."
sudo cp configs/keyd.config /etc/keyd/default.conf
sudo systemctl enable keyd

# Copy hypr autostart
echo -e "$CNT - Coping hypr's files..."
cp -f configs/hypr/autostart.conf ~/.config/hypr/configs/autostart.conf
cp -f configs/hypr/window.conf ~/.config/hypr/configs/window.conf

# Copy .desktop files
echo -e "$CNT - Coping .desktop files..."
cp -f configs/*.desktop ~/.local/share/applications/

# Script is done
echo -e "$CNT - Script had completed!"
