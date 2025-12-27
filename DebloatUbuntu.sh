#!/bin/sh

# Check if the script is being run as root
if [ "$(whoami)" != "root" ]; then
    echo "Please run this script as root."
    exit 1
fi

# Information message
printf "This script will:\n\n- Remove Snap and Snap-related services\n- Remove the GNOME Help app (yelp)\n- Remove the default Ubuntu file manager (nautilus)\n- Remove Cheese (Camera app)\n- Remove gnome-software (App Manager)\n- Remove gnome-system-monitor (System Monitor)\n- Install Nemo file manager\n- Install Librewolf browser\n- Install htop (system monitor)\n- Install fastfetch (system info)\n\n"
printf "Additionally, you can choose to install media-related applications in the Media section:\n\n- Install GIMP (image editor)\n- Install Kdenlive (video editor)\n- Install OBS Studio (streaming/recording software)\n- Install Audacity (audio editor)\n\n"
printf "You can also choose to install Developer Personal tools:\n\n- Mullvad VPN (privacy tool)\n- PSensor (temperature monitor)\n- TradingView (stock and crypto charting)\n"

# Prompt to continue
read -p "Do you want to proceed with removing Snap, GNOME Help, Nautilus, Cheese, gnome-software, and gnome-system-monitor? (Y/n) " remove_confirm
case $remove_confirm in
  [nN] | [nN][oO] )
    echo "Skipping removal of Snap, GNOME Help, Nautilus, Cheese, gnome-software, and gnome-system-monitor."
    ;;
  "" | [yY] | [yY][eE][sS] )
    # --- REMOVE SECTION ---
    # Disable and remove Snap services
    echo "Disabling Snap-related services..."
    systemctl disable snapd.service
    systemctl disable snapd.socket
    systemctl disable snapd.seeded.service

    # Remove Snap packages
    echo "Removing Snap packages..."
    snap remove --purge $(snap list | awk '!/^Name/ {print $1}')
    rm -rf /var/cache/snapd/
    rm -rf ~/snap

    # Prevent Snap from being reinstalled
    echo "Preventing Snap from being reinstalled..."
    printf "Package: snapd\nPin: release a=*\nPin-Priority: -10" > /etc/apt/preferences.d/nosnap.pref

    # Remove GNOME Help (yelp)
    echo "Removing GNOME Help (yelp)..."
    apt remove --purge yelp -y

    # Remove the default file manager (nautilus)
    echo "Removing default file manager (nautilus)..."
    apt remove --purge nautilus -y

    # Remove Cheese (Camera app)
    echo "Removing Cheese (Camera app)..."
    apt remove --purge cheese -y

    # Remove gnome-software (App Manager)
    echo "Removing gnome-software (App Manager)..."
    apt remove --purge gnome-software -y

    # Remove gnome-system-monitor (System Monitor)
    echo "Removing gnome-system-monitor (System Monitor)..."
    apt remove --purge gnome-system-monitor -y
  ;;
esac

# Prompt to continue with installing Nemo, Librewolf, htop, fastfetch
read -p "Do you want to proceed with installing Nemo, Librewolf, htop, and fastfetch? (Y/n) " install_confirm
case $install_confirm in
  [nN] | [nN][oO] )
    echo "Skipping installation of Nemo, Librewolf, htop, and fastfetch."
    ;;
  "" | [yY] | [yY][eE][sS] )
    # --- INSTALL SECTION ---
    # Install Nemo file manager
    echo "Installing Nemo file manager..."
    apt install nemo -y

    # Set Nemo as the default file manager
    echo "Setting Nemo as the default file manager..."
    xdg-mime default nemo.desktop inode/directory application/x-gnome-saved-search

    # Install Librewolf browser
    echo "Installing Librewolf browser..."
    apt install extrepo -y

    # Enable Librewolf repository
    extrepo enable librewolf

    # Install Librewolf
    apt install librewolf -y

    # Set Librewolf as the default browser
    echo "Setting Librewolf as the default browser..."
    xdg-settings set default-web-browser librewolf.desktop

    # Install htop (system monitor)
    echo "Installing htop (system monitor)..."
    apt install htop -y

    # Install fastfetch (system info)
    echo "Installing fastfetch (system info)..."
    apt install fastfetch -y
  ;;
esac

# --- MEDIA SECTION ---
# Prompt to continue with installing media-related applications (e.g., GIMP, Kdenlive, OBS Studio, Audacity)
read -p "Do you want to proceed with installing media-related applications (e.g., GIMP, Kdenlive, OBS Studio, Audacity)? (Y/n) " media_confirm
case $media_confirm in
  [nN] | [nN][oO] )
    echo "Skipping installation of media-related applications."
    ;;
  "" | [yY] | [yY][eE][sS] )
    # Install GIMP (image editor)
    echo "Installing GIMP (image editor)..."
    apt install gimp -y

    # Install Kdenlive (video editor) from the official PPA
    echo "Installing Kdenlive (video editor)..."
    add-apt-repository ppa:kdenlive/kdenlive-stable -y
    apt update -y
    apt install kdenlive -y

    # Install OBS Studio (streaming/recording software) from Ubuntu's default repositories
    echo "Installing OBS Studio (streaming/recording software) from the default Ubuntu repositories..."
    apt install obs-studio -y

    # Install Audacity (audio editor) from Ubuntu's official repository
    echo "Installing Audacity (audio editor)..."
    apt install audacity -y
  ;;
esac

# --- DEVELOPER PERSONAL SECTION ---
# [Potential Update] Could potentially add visual studio code and intellij idea community in this section
# Prompt to continue with installing PSensor, VirtualBox, and TradingView
read -p "Do you want to proceed with installing PSensor, VirtualBox, and TradingView? (Y/n) " dev_personal_confirm
case $dev_personal_confirm in
  [nN] | [nN][oO] )
    echo "Skipping installation of PSensor, VirtualBox, and TradingView."
    ;;
  "" | [yY] | [yY][eE][sS] )
    # Install PSensor (hardware temperature monitor)
    echo "Installing PSensor..."
    apt install psensor -y

    # Install VirtualBox (via Oracle repository)
    echo "Installing VirtualBox..."

    # Add the Oracle VirtualBox repository to the sources list
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/oracle-virtualbox-2016.gpg] https://download.virtualbox.org/virtualbox/debian <mydist> contrib" | tee -a /etc/apt/sources.list.d/virtualbox.list

    # Download and install the Oracle public key for VirtualBox
    wget -O- https://www.virtualbox.org/download/oracle_vbox_2016.asc | gpg --yes --output /usr/share/keyrings/oracle-virtualbox-2016.gpg --dearmor

    # Update package cache and install VirtualBox
    apt update -y
    apt install virtualbox-7.1 -y

    # Install TradingView
    echo "Installing TradingView..."

    # Download and install the TradingView public signing key
    wget -O - https://tvd-packages.tradingview.com/keyring.gpg | tee /usr/share/keyrings/tradingview-desktop-archive-keyring.gpg >/dev/null

    # Add the TradingView repository to the sources list
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/tradingview-desktop-archive-keyring.gpg] https://tvd-packages.tradingview.com/ubuntu/stable jammy multiverse" | tee /etc/apt/sources.list.d/tradingview-desktop.list >/dev/null

    # Update the package list and install TradingView
    apt update -y
    apt install tradingview -y
  ;;
esac

# Clean up unnecessary packages and cache
echo "Cleaning up unnecessary packages and cache..."
apt autoremove -y
apt clean

# Update package lists and upgrade system
echo "Updating and upgrading system..."
apt update -y
apt upgrade -y
apt dist-upgrade -y

# Reboot prompt
read -p "Reboot now? (Y/n) " reboot_prompt
case $reboot_prompt in
  "" | [yY] | [yY][eE][sS] )
    reboot
  ;;
esac

