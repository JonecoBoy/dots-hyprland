package main

import (
	"fmt"
	"os"
	"os/exec"
	"github.com/manifoldco/promptui"
)

// Function to install a package using pacman
func installPackage(packageName string) {
	fmt.Printf("Installing %s...\n", packageName)
	cmd := exec.Command("sudo", "pacman", "-S", "--noconfirm", packageName)
	err := cmd.Run()
	if err != nil {
		fmt.Printf("Error installing %s: %v\n", packageName, err)
	}
}

// Function to install a package using yay (AUR)
func installPackageAUR(packageName string) {
	fmt.Printf("Installing AUR package %s...\n", packageName)
	cmd := exec.Command("yay", "-S", "--noconfirm", packageName)
	err := cmd.Run()
	if err != nil {
		fmt.Printf("Error installing AUR package %s: %v\n", packageName, err)
	}
}

// Function to install a package using Flatpak
func installPackageFlatpak(packageName string) {
	fmt.Printf("Installing Flatpak package %s...\n", packageName)
	cmd := exec.Command("flatpak", "install", "flathub", "-y", packageName)
	err := cmd.Run()
	if err != nil {
		fmt.Printf("Error installing Flatpak package %s: %v\n", packageName, err)
	}
}

// Function to confirm installation with promptui
func confirmInstall(promptMessage string) bool {
	prompt := promptui.Prompt{
		Label:     promptMessage,
		IsConfirm: true,
	}

	_, err := prompt.Run()
	if err != nil {
		return false
	}

	return true
}

// Function to handle all installations when `--all` flag is passed
func installAllPackages() {
	// Install all packages without confirmation
	installPackage("hyprland")
	installPackage("docker")
	installPackageAUR("ags-hyprpanel-git")
	installPackage("gum")
	installPackage("flatpak")
	installPackageFlatpak("com.jetbrains.PhpStorm")
	installPackageFlatpak("com.jetbrains.DataGrip")
	installPackageFlatpak("com.jetbrains.RustRover")
	installPackageFlatpak("com.jetbrains.WebStorm")
	installPackageFlatpak("com.jetbrains.GoLand")
	installPackage("vlc")
	installPackage("mpv")
	installPackage("orcad-slicer")
	installPackageFlatpak("com.bitwarden.desktop")
	installPackageAUR("obsidian")
	installPackage("go")
	installPackage("cargo")
	installPackage("rustup")
	installPackageAUR("ferdium-bin")
}

// Main function
func main() {
	args := os.Args

	// If the `--all` flag is present, install everything without confirmation
	if len(args) > 1 && args[1] == "--all" {
		fmt.Println("Installing all packages without confirmation...")
		installAllPackages()
		return
	}

	// Individual package confirmations
	if confirmInstall("Do you want to install Hyprland?") {
		installPackage("hyprland")
	}

	if confirmInstall("Do you want to install Docker?") {
		installPackage("docker")
	}

	if confirmInstall("Do you want to install Flatpak?") {
		installPackage("flatpak")
	}

	if confirmInstall("Do you want to install PhpStorm?") {
		installPackageFlatpak("com.jetbrains.PhpStorm")
	}

	if confirmInstall("Do you want to install DataGrip?") {
		installPackageFlatpak("com.jetbrains.DataGrip")
	}

	if confirmInstall("Do you want to install RustRover?") {
		installPackageFlatpak("com.jetbrains.RustRover")
	}

	if confirmInstall("Do you want to install WebStorm?") {
		installPackageFlatpak("com.jetbrains.WebStorm")
	}

	if confirmInstall("Do you want to install GoLand?") {
		installPackageFlatpak("com.jetbrains.GoLand")
	}

	if confirmInstall("Do you want to install VLC?") {
		installPackage("vlc")
	}

	if confirmInstall("Do you want to install MPV?") {
		installPackage("mpv")
	}

	if confirmInstall("Do you want to install Orca Slicer?") {
		installPackageAUR("orca-slicer-bin")
	}

	if confirmInstall("Do you want to install Obsidian?") {
		installPackageAUR("obsidian")
	}

	if confirmInstall("Do you want to install Docker with rootless support?") {
		installPackage("docker")
	}

	if confirmInstall("Do you want to install KDE Connect?") {
		installPackage("kdeconnect")
	}

	// Add more installation prompts here as needed

	fmt.Println("Installation complete.")
}
