use std::process::{Command};
use std::fs::{self, File};
use std::io::{self, Write};
use std::env;
use dialoguer::{Confirm};

fn install_package(package_name: &str) {
    println!("Installing {}...", package_name);
    let status = Command::new("sudo")
    .arg("pacman")
    .arg("-S")
    .arg("--noconfirm")
    .arg(package_name)
    .status()
    .expect("Failed to execute command");

    if !status.success() {
        eprintln!("Error installing {}", package_name);
    }
}

fn install_package_aur(package_name: &str) {
    println!("Installing {}...", package_name);
    let status = Command::new("yay")
    .arg("-S")
    .arg("--noconfirm")
    .arg(package_name)
    .status()
    .expect("Failed to execute command");

    if !status.success() {
        eprintln!("Error installing AUR package {}", package_name);
    }
}

fn install_package_flatpak(package_name: &str) {
    println!("Installing {}...", package_name);
    let status = Command::new("flatpak")
    .arg("install")
    .arg("flathub")
    .arg("-y")
    .arg(package_name)
    .status()
    .expect("Failed to execute command");

    if !status.success() {
        eprintln!("Error installing Flatpak package {}", package_name);
    }
}

fn create_desktop_shortcut(app_name: &str, app_id: &str) -> io::Result<()> {
    let desktop_dir = format!("{}/.local/share/applications", env::var("HOME").unwrap());
    let desktop_file = format!("{}/{}.desktop", desktop_dir, app_name);

    // Create the applications directory if it doesn't exist
    fs::create_dir_all(&desktop_dir)?;

    // Check if the app is installed via Flatpak
    let status = Command::new("flatpak")
    .arg("info")
    .arg(app_id)
    .status()
    .expect("Failed to execute command");

    if !status.success() {
        println!("{} is not installed via Flatpak, skipping shortcut creation.", app_name);
        return Ok(());
    }

    // Create the .desktop file
    let content = format!(
        "[Desktop Entry]
        Version=1.0
        Name={}
        Comment=Launch {}
        Exec=flatpak run {}
        Icon={}
        Terminal=false
        Type=Application
        Categories=Utility;
        ",
        app_name, app_name, app_id, app_id
    );

    let mut file = File::create(&desktop_file)?; // Borrow `desktop_file` here
    file.write_all(content.as_bytes())?;

    // Make the file executable
    Command::new("chmod")
    .arg("+x")
    .arg(&desktop_file)  // Borrow `desktop_file` here
    .status()
    .expect("Failed to set executable permission");

    Ok(())
}

fn install_all() {
    install_package("hyprland");
    install_package("docker");
    install_package_aur("ags-hyprpanel-git");
    install_package("gum");
    install_package("flatpak");
    install_package_flatpak("com.jetbrains.PhpStorm");
    install_package_flatpak("com.jetbrains.DataGrip");
    install_package_flatpak("com.jetbrains.RustRover");
    install_package_flatpak("com.jetbrains.WebStorm");
    install_package_flatpak("com.jetbrains.GoLand");
    install_package("vlc");
    install_package("mpv");
    install_package("orcad-slicer");
    install_package_flatpak("com.bitwarden.desktop");
    install_package_aur("obsidian");
    install_package("go");
    install_package("cargo");
    install_package("rustup");
    install_package_aur("ferdium-bin");
    create_desktop_shortcut("PhpStorm", "com.jetbrains.PhpStorm").unwrap();
    create_desktop_shortcut("DataGrip", "com.jetbrains.DataGrip").unwrap();
    create_desktop_shortcut("RustRover", "com.jetbrains.RustRover").unwrap();
    create_desktop_shortcut("WebStorm", "com.jetbrains.WebStorm").unwrap();
    create_desktop_shortcut("GoLand", "com.jetbrains.GoLand").unwrap();
}

fn main() {
    let args: Vec<String> = env::args().collect();

    // If user passes --all, install everything without confirmation
    if args.contains(&"--all".to_string()) {
        println!("Installing all packages without confirmation...");
        install_all();
        return;
    }

    // Confirmations for each package install
    if Confirm::new().with_prompt("Do you want to install Hyprland?").default(true).interact().unwrap() {
        install_package("hyprland");
    }

    if Confirm::new().with_prompt("Do you want to install Docker?").default(true).interact().unwrap() {
        install_package("docker");
    }

    if Confirm::new().with_prompt("Do you want to install Flatpak?").default(true).interact().unwrap() {
        install_package("flatpak");
    }

    if Confirm::new().with_prompt("Do you want to install JetBrains PhpStorm?").default(true).interact().unwrap() {
        install_package_flatpak("com.jetbrains.PhpStorm");
        create_desktop_shortcut("PhpStorm", "com.jetbrains.PhpStorm").unwrap();
    }

    // Add other installations similarly...

    println!("Script execution complete.");
}
