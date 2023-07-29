#!/bin/bash

# Paths to OpenVPN-AS binaries
ovpn_adduser="/usr/local/openvpn_as/bin/ovpn_adduser"
ovpn_setuserpassword="/usr/local/openvpn_as/bin/ovpn_setuserpassword"
ovpn_deluser="/usr/local/openvpn_as/bin/ovpn_deluser"
ovpn_listusers="/usr/local/openvpn_as/bin/ovpn_listusers"
ovpn_import_userpass="/usr/local/openvpn_as/bin/ovpn_import_userpass"

# Colors
red='\e[1;31m'
green='\e[1;32m'
yellow='\e[1;33m'
purple='\e[1;35m'
cyan='\e[1;36m'
white='\e[1;37m'
reset='\e[0m'

# Get public IP address
public_ip=$(curl -s ifconfig.me)

# Emojis
wave_emoji="😃"
key_emoji="🔑"
user_emoji="👤"
pass_emoji="🔒"
list_emoji="📜"
import_emoji="📤"
delete_emoji="🗑"
error_emoji="❌"
finish_emoji="🏁"

# Banner and Menu
menu(){
  echo -e "${green}OpenVPN-AS User Management Script ${reset}"
  echo -e "================================= "
  echo -e "${yellow}Your Public IP: [ $public_ip ]${reset}"
  echo " "
  echo -e "Quick Menu:"
  echo "1. Add user ${user_emoji} - Add a new user."
  echo "2. Set user password ${key_emoji} - Set password for an existing user."
  echo "3. Delete user ${delete_emoji} - Delete an existing user."
  echo "4. List users ${list_emoji} - List all users."
  echo "5. Import users from CSV ${import_emoji} - Import users from a CSV file."
  echo "6. Quit ${finish_emoji} - Exit the script."
}

# Check if OpenVPN-AS is installed
openvpn_as_installed() {
  [ -d "/usr/local/openvpn_as" ]
}

# Install OpenVPN-AS
install_openvpn_as() {
  echo -e "${green}Installing OpenVPN-AS...${reset}"
  # Update this command based on your system's package manager and installation process
  sudo apt update
  sudo apt install openvpn-as
}

# Add user
adduser(){
  read -p "Enter username: " username

  echo -e "\n\e[0;32mAdding user ${user_emoji} ..."

  sudo "$ovpn_adduser" "$username" ""
  sudo "$ovpn_adduser" -g "$username" ""

  if [ -f "/usr/local/openvpn_as/etc/web-templates/client.ovpn" ]; then
    sudo cp "/usr/local/openvpn_as/etc/web-templates/client.ovpn" "/home/$username.ovpn"
    echo -e "\n\e[0;32mAdded user $username and generated ovpn file"
  else
    echo -e "${error_emoji} File '/usr/local/openvpn_as/etc/web-templates/client.ovpn' not found. Unable to generate ovpn file."
  fi
}

# Set password
setpass(){
  read -p "Enter username: " username
  read -s -p "Enter password: " password

  echo -e "\n\e[0;33mSetting password for $username ${key_emoji} ..."

  sudo "$ovpn_setuserpassword" -u "$username" -p "$password"

  echo -e "\n\e[0;32mPassword set for $username"
}

# Delete user
deluser(){
  read -p "Enter username: " username

  echo -e "\n\e[0;31mDeleting user ${delete_emoji} ..."

  sudo "$ovpn_deluser" "$username"

  echo -e "\n\e[0;31mDeleted user $username"
}

# List users
listusers(){
  echo -e "\nListing all users ${list_emoji}:"

  sudo "$ovpn_listusers"
}

# Import users
importusers(){
  read -p "Enter CSV file path: " csvfile

  echo -e "\nImporting users from $csvfile ${import_emoji} ..."

  sudo "$ovpn_import_userpass" -f "$csvfile"

  echo -e "\nImported users from $csvfile"
}

# Check if OpenVPN-AS is installed
if openvpn_as_installed; then
  # OpenVPN-AS is installed, show menu
  while :
  do
    clear
    menu

    # Read choice
    read -p "Enter option: " choice

    case $choice in
      1) adduser ;;
      2) setpass ;;
      3) deluser ;;
      4) listusers ;;
      5) importusers ;;
      6) break ;;
      *) echo -e "\e[0;31mInvalid option " ;;
    esac

    # Wait for key press
    read -n1 -s -p "Press any key to continue ..."
    echo ""
  done

  echo -e "\n\e[0;32mJob Done ${finish_emoji}"
else
  # OpenVPN-AS is not installed, show installation message
  echo -e "${error_emoji} OpenVPN-AS is not installed."
  echo -e "Please make sure you have OpenVPN-AS installed."
  echo -e "If it is not installed, you can install it using option 6 from the menu."
  echo -e "After installation, run this script again."
  echo " "
  read -p "Do you want to install OpenVPN-AS now? (y/n): " install_choice
  if [[ $install_choice == "y" || $install_choice == "Y" ]]; then
    install_openvpn_as
    if [ $? -eq 0 ]; then
      echo -e "${green}OpenVPN-AS installed successfully.${reset}"
      echo "Please run this script again."
      exit 0
    else
      echo -e "${error_emoji} Installation failed. Please install OpenVPN-AS manually and try again."
      exit 1
    fi
  else
    echo -e "${red}Exiting.${reset}"
    exit 1
  fi
fi
