#!/bin/bash

# Function to install a package with pacman
install_package() {
    echo "Installing $1..."
    sudo pacman -S --noconfirm "$1"
}

install_package_aur() {
    echo "Installing $1..."
    yay -S --noconfirm "$1"
}

install_packageflatpak() {
    echo "Installing $1..."
    flatpak install flathub -y "$1"
}

# Function to create a .desktop file for a Flathub app
create_desktop_shortcut() {
    app_name=$1
    app_id=$2

    # Define the desktop file path
    desktop_file="$HOME/.local/share/applications/$app_name.desktop"

    # Create the applications directory if it doesn't exist
    mkdir -p "$HOME/.local/share/applications"

    # Check if the app is installed via Flatpak
    if flatpak info "$app_id" &> /dev/null; then
        echo "Creating desktop shortcut for $app_name..."

        # Create the .desktop file
        cat << EOF > "$desktop_file"
[Desktop Entry]
Version=1.0
Name=$app_name
Comment=Launch $app_name
Exec=flatpak run $app_id
Icon=$app_id
Terminal=false
Type=Application
Categories=Utility;
EOF

        # Make the file executable
        chmod +x "$desktop_file"
    else
        echo "$app_name is not installed via Flatpak, skipping shortcut creation."
    fi
}


btrfs_install(){
    install_package "snapper"
    install_package "snap-pac"
    install_package "grub-btrfs"
    install_package "inotify-tools"
    install_package_aur "btrfs-assistant"
    install_package_aur "btrfsmaintenance"
    sudo systemctl enable --now grub-btrfsd
    sudo grub-mkconfig -o /boot/grub/grub.cfg
    #add to make snapshots read only
    echo 'GRUB_BTRFS_SNAPSHOT_KERNEL_PARAMETERS="rd.live.overlay.overlayfs=1"' | sudo tee -a /etc/default/grub-btrfs/config > /dev/null
    #regenerate
    sudo /etc/grub.d/41_snapshots-btrfs
}

# Install an all-in-one app manager (Ferdium/Web Catalog)
install_appmanager() {
        app_manager_choice=$(gum choose "Ferdium" "Web Catalog" "None")

        case $app_manager_choice in
            "Ferdium")
                install_package_aur "ferdium-bin"
                ;;
            "Web Catalog")
                install_package_aur "webcatalog-bin"
                ;;
            "None")
                echo "Skipping All-in-One App Manager."
                ;;
        esac
}

# Check if gum is installed
if ! command -v gum &> /dev/null; then
    echo "gum is not installed, installing gum..."
    install_package "gum"
fi

# Check if yay is installed
if ! command -v yay &> /dev/null; then
    echo "yay is not installed, installing yay..."
    install_package "yay"
fi

# If the user passes --all, install everything without confirmation
if [[ "$1" == "--all" ]]; then
    echo "Installing all packages without confirmation..."

    install_package "hyprland"
    install_package "docker"
    install_package "yay"
    install_package_aur "ags-hyprpanel-git"
    install_package "gum"
    install_package "flatpak"
    install_packageflatpak "com.jetbrains.PhpStorm"
    install_packageflatpak "com.jetbrains.DataGrip"
    install_packageflatpak "com.jetbrains.RustRover"
    install_packageflatpak "com.jetbrains.WebStorm"
    install_packageflatpak "com.jetbrains.GoLand"
    install_packageflatpak "com.visualstudio.code"
    install_package "vlc"
    install_package "mpv"
    install_package "orcad-slicer"
    install_packageflatpak "com.bitwarden.desktop"
    install_package_aur "obsidian"
    install_packageyY "ferdium-bin"
    create_desktop_shortcut "PhpStorm" "com.jetbrains.PhpStorm"
    create_desktop_shortcut "DataGrip" "com.jetbrains.DataGrip"
    create_desktop_shortcut "RustRover" "com.jetbrains.RustRover"
    create_desktop_shortcut "WebStorm" "com.jetbrains.WebStorm"
    create_desktop_shortcut "GoLand" "com.jetbrains.GoLand"
    create_desktop_shortcut "Visual Studio Code" "com.visualstudio.code"
    install_package "go"
    exit 0
fi

# Variable to track if all JetBrains software was installed
install_all_jetbrains=false
install_app_manager=false

gum confirm "Do you want to install BTRFS Assitant and Snapper?" && btrfs_install
# Install essential packages with gum options for confirmation
gum confirm "Do you want to install Hyprland?" && install_package "hyprland"
gum confirm "Do you want to install Hyprpanel?" && install_package_aur "ags-hyprpanel-git"
gum confirm "Do you want to install FlatPak?" && install_package "flatpak"

# Interactive package installation choices
gum confirm "Do you want to install All Jetbrains Software?" && {
    install_all_jetbrains=true
    install_packageflatpak "com.jetbrains.GoLand"
    install_packageflatpak "com.jetbrains.PhpStorm"
    install_packageflatpak "com.jetbrains.DataGrip"
    install_packageflatpak "com.jetbrains.RustRover"
    install_packageflatpak "com.jetbrains.WebStorm"
    create_desktop_shortcut "PhpStorm" "com.jetbrains.PhpStorm"
    create_desktop_shortcut "DataGrip" "com.jetbrains.DataGrip"
    create_desktop_shortcut "RustRover" "com.jetbrains.RustRover"
    create_desktop_shortcut "WebStorm" "com.jetbrains.WebStorm"
    create_desktop_shortcut "GoLand" "com.jetbrains.GoLand"
}

# If All JetBrains Software is not installed, proceed with individual JetBrains packages
if ! $install_all_jetbrains; then
    gum confirm "Do you want to install PhpStorm?" && install_packageflatpak "com.jetbrains.PhpStorm" &&  create_desktop_shortcut "PhpStorm" "com.jetbrains.PhpStorm"
    gum confirm "Do you want to install DataGrip?" && install_packageflatpak "com.jetbrains.DataGrip" && create_desktop_shortcut "DataGrip" "com.jetbrains.DataGrip"
    gum confirm "Do you want to install RustRover?" && install_packageflatpak "com.jetbrains.RustRover" && create_desktop_shortcut "RustRover" "com.jetbrains.RustRover"
    gum confirm "Do you want to install WebStorm?" && install_packageflatpak "com.jetbrains.WebStorm" && create_desktop_shortcut "WebStorm" "com.jetbrains.WebStorm"
    gum confirm "Do you want to install GoLand?" && install_packageflatpak "com.jetbrains.GoLand" && create_desktop_shortcut "GoLand" "com.jetbrains.GoLand"
fi


install_appmanager

if [[ "$app_manager_choice" == "None" ]]; then
    # Vesktop and Discord Client Choice
    gum confirm "Do you want to install Vesktop?" && {
        vesktop_choice=$(gum choose "Vesktop" "Dissent" "Qtcord" "Discord" "None")
        case $vesktop_choice in
            "Vesktop")
                install_packageflatpak "dev.vencord.Vesktop"
                ;;
            "Dissent")
                install_packageflatpak "dev.vencord.Dissent"
                ;;
            "Qtcord")
                install_packageflatpak "dev.vencord.Qtcord"
                ;;
            "Discord")
                install_packageflatpak "com.discordapp.Discord"
                ;;
            "None")
                echo "Skipping Vesktop and Discord clients."
                ;;
        esac
    }
    gum confirm "Do you want to install a WhatsApp Web client?" && {
        whatsapp_choice=$(gum choose "Whatsie" "ZapZap" "None")
        case $whatsapp_choice in
            "Whatsie")
                install_packageflatpak "com.whatsie.Whatsie"
                ;;
            "ZapZap")
                install_packageflatpak "com.zapzap.ZapZap"
                ;;
            "None")
                echo "Skipping WhatsApp Web client."
                ;;
        esac
    }
fi

echo "Script execution create"

# Visual Studio Code
gum confirm "Do you want to install Visual Studio Code?" && install_packageflatpak "com.visualstudio.code" && create_desktop_shortcut "Visual Studio Code" "com.visualstudio.code"

# VLC
gum confirm "Do you want to install VLC?" && install_package "vlc"
# MPV
gum confirm "Do you want to install MPV?" && install_package "mpv"

# Option to install Orca Slicer
gum confirm "Do you want to install Orca Slicer?" && install_package_aur "orca-slicer-bin"

# Option to install Obsidian
gum confirm "Do you want to install Obsidian?" && install_package_aur "obsidian"

obsidian

# Option to install Docker (rootless)
gum confirm "Do you want to install Docker with rootless support?" && install_package "docker" && sudo systemctl enable --now docker && sudo usermod -aG docker $USER && newgrp docker

# Option to install KDE Connect
gum confirm "Do you want to install KDE Connect?" && install_package "kdeconnect" && sudo systemctl enable --now kdeconnect

gum confirm "Do you want to install Orca Slicer?" && install_packageflatpak "com.bitwarden.desktop"

gum confirm "Do you want to install BTRFS Assitant and Snapper?" && btrfs_install

gum confirm "Do you want to install BTRFS Assitant and GO?" && install_package "go"

gum confirm "Do you want to install BTRFS Assitant and Snapper?" && btrfs_install

# Option to copy Hyprland config if desired
gum confirm "Do you want to import Hyprland config?" && cp -r ./hypr ~/.config/ &

echo "Script execution complete."
