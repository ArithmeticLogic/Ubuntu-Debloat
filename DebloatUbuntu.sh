#!/usr/bin/env bash
set -e

# --------------------------------------------------
# ROOT CHECK
# --------------------------------------------------
if [ "$(id -u)" != "0" ]; then
    echo "Please run this script as root."
    exit 1
fi

# --------------------------------------------------
# REMOVE SNAP (OPTIONAL, PERMANENT)
# --------------------------------------------------
read -p "Do you want to remove Snap from your system? (Y/n) " remove_snap
case $remove_snap in
  [nN]* )
    echo "Skipping Snap removal."
    ;;
  * )
    echo "Removing Snap..."

    rm -rf /var/cache/snapd/
    apt autoremove --purge -y snapd gnome-software-plugin-snap
    rm -rf /home/*/snap
    rm -rf /root/snap

    echo "Blocking Snap from being reinstalled..."

    # Prevent snapd from ever being installed again
    apt-mark hold snapd gnome-software-plugin-snap

    cat << 'EOF' > /etc/apt/preferences.d/nosnap.pref
Package: snapd
Pin: release a=*
Pin-Priority: -10
EOF

    # Disable any remaining snap services (defensive)
    systemctl disable --now snapd.service snapd.socket snapd.seeded.service 2>/dev/null || true

    echo "Snap removal complete and permanently blocked."
    ;;
esac

# --------------------------------------------------
# SCRIPT HEADER / SUMMARY
# --------------------------------------------------
printf "\nUbuntu Setup Script - Sections Included:\n"
printf "Remove GNOME components • Core Installs (Nemo, Librewolf, htop, fastfetch, gnome-tweaks) • Media Apps (GIMP, Kdenlive, OBS, Audacity) • Developer/Personal Tools (PSensor, TradingView)\n\n"

# --------------------------------------------------
# REMOVE GNOME COMPONENTS
# --------------------------------------------------
read -p "Proceed with removing GNOME components? (Y/n) " remove_confirm
case $remove_confirm in
  [nN]* )
    echo "Skipping GNOME component removal."
    ;;
  * )
    echo "Removing GNOME components..."
    apt remove --purge -y \
      yelp \
      nautilus \
      cheese \
      gnome-software \
      gnome-system-monitor
    ;;
esac

# --------------------------------------------------
# CORE INSTALLS
# --------------------------------------------------
read -p "Install Nemo, Librewolf, htop, gnome-tweaks (Y/n) " core_confirm
case $core_confirm in
  [nN]* )
    echo "Skipping core installs."
    ;;
  * )
    echo "Installing core utilities..."
    apt install -y nemo htop extrepo gnome-tweaks software-properties-common

    echo "Enabling Librewolf repository and installing..."
    extrepo enable librewolf
    apt update
    apt install -y librewolf
    ;;
esac

# --------------------------------------------------
# MEDIA APPLICATIONS
# --------------------------------------------------
read -p "Install media apps (GIMP, Kdenlive, OBS, Audacity) (Y/n) " media_confirm
case $media_confirm in
  [nN]* )
    echo "Skipping media apps."
    ;;
  * )
    echo "Installing GIMP, OBS, Audacity..."
    apt install -y gimp obs-studio audacity

    echo "Installing Kdenlive via PPA..."
    add-apt-repository -y ppa:kdenlive/kdenlive-stable
    apt update
    apt install -y kdenlive
    ;;
esac

# --------------------------------------------------
# DEVELOPER / PERSONAL TOOLS
# --------------------------------------------------
read -p "Install PSensor, TradingView, Mullvad VPN (Y/n) " dev_confirm
case $dev_confirm in
  [nN]* )
    echo "Skipping developer/personal tools."
    ;;
  * )
    echo "Installing PSensor..."
    apt install -y psensor wget curl

    echo "Installing TradingView via APT..."
    wget -qO- https://tvd-packages.tradingview.com/keyring.gpg \
      | tee /usr/share/keyrings/tradingview-desktop-archive-keyring.gpg >/dev/null

    echo "Adding TradingView repository..."
    echo "deb [arch=amd64 signed-by=/usr/share/keyrings/tradingview-desktop-archive-keyring.gpg] \
https://tvd-packages.tradingview.com/ubuntu/stable jammy multiverse" \
      > /etc/apt/sources.list.d/tradingview-desktop.list

    apt update
    apt install -y tradingview

    # --------------------------------------------------
    # MULLVAD VPN INSTALLATION
    # --------------------------------------------------
    echo "Downloading Mullvad signing key..."
    curl -fsSLo /usr/share/keyrings/mullvad-keyring.asc https://repository.mullvad.net/deb/mullvad-keyring.asc

    echo "Adding Mullvad repository to APT..."
    echo "deb [signed-by=/usr/share/keyrings/mullvad-keyring.asc arch=$(dpkg --print-architecture)] https://repository.mullvad.net/deb/stable stable main" | tee /etc/apt/sources.list.d/mullvad.list

    echo "Updating package list and installing Mullvad VPN..."
    apt update
    apt install -y mullvad-vpn

    echo "Mullvad VPN installation complete."
    ;;
esac

# --------------------------------------------------
# CLEANUP AND SYSTEM UPDATE
# --------------------------------------------------
echo "Cleaning up unnecessary packages..."
apt remove yelp
apt autoremove -y
apt clean

echo "Updating system..."
apt update
apt upgrade -y
apt dist-upgrade -y

# --------------------------------------------------
# OPTIONAL / MANUAL TODO LIST
# --------------------------------------------------
echo ""
echo "=================================================="
echo "Manual post-install TODO items:"
echo ""
echo " - Install Papirus icon theme"
echo " - Install VirtualBox"
echo " - Install Visual Studio Code"
echo " - Install IntelliJ IDEA"
echo ""
echo "These steps are intentionally not automated."
echo "=================================================="

# --------------------------------------------------
# REBOOT PROMPT
# --------------------------------------------------
read -p "Reboot now? (Y/n) " reboot_prompt
case $reboot_prompt in
  "" | [yY] | [yY][eE][sS] )
    reboot
    ;;
  * )
    echo "Reboot skipped."
    ;;
esac
