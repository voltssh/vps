#!/bin/bash

# Colors
red='\e[0;31m'
green='\e[0;32m'
yellow='\e[0;33m'
reset='\e[0m'

# Update packages
echo -e "${green}Updating and upgrading packages...${reset}"
apt update && apt upgrade -y

# Install dependencies
echo -e "${green}Installing dependencies...${reset}"
apt install ca-certificates wget net-tools gnupg

# Add OpenVPN repo
echo -e "${green}Adding OpenVPN repository...${reset}"
wget -qO - https://as-repository.openvpn.net/as-repo-public.gpg | apt-key add -
echo "deb http://as-repository.openvpn.net/as/debian focal main" >/etc/apt/sources.list.d/openvpn-as-repo.list

# Update packages
echo -e "${green}Updating packages...${reset}"
apt update

# Install OpenVPN
echo -e "${green}Installing OpenVPN...${reset}"
apt install openvpn-as

# Get public IP
clear
echo ""
public_ip=$(dig +short myip.opendns.com @resolver1.opendns.com)
echo -e "${yellow}Your Public IP: [ $public_ip ]${reset}"
echo ""
# Print URLs
echo -e "${yellow}OpenVPN Access Server Web UIs:${reset}"
echo -e "${green}-----------------------------${reset}"
echo -e "Admin UI: https://$public_ip:943/admin"
echo -e "Client UI: https://$public_ip:943/"
echo -e "${green}-----------------------------${reset}"
echo -e "${green}TCP Port: 443${reset}"
echo -e "${green}UDP Port: 1194${reset}"