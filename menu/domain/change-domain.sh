#!/bin/bash
clear
echo -e "\033[1;36m==============================="
echo -e "      CHANGE YOUR DOMAIN"
echo -e "===============================\033[0m"

CURRENT_DOMAIN=$(cat /etc/xray/domain 2>/dev/null)
IP=$(curl -s ipv4.icanhazip.com)
ISP=$(curl -s ipinfo.io/org | cut -d " " -f2-)

echo -e "Current Domain : \033[1;33m$CURRENT_DOMAIN\033[0m"
echo -e "Server IP      : \033[1;33m$IP\033[0m"
echo -e "ISP            : \033[1;33m$ISP\033[0m"
echo

# Input domain baru
read -rp "New Domain     : " NEW_DOMAIN
NEW_DOMAIN=$(echo "$NEW_DOMAIN" | tr -d '[:space:]')

# Validasi domain sederhana
if [[ "$NEW_DOMAIN" =~ ^[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$ ]]; then
    echo "$NEW_DOMAIN" > /etc/xray/domain
    echo -e "\n✅ Domain updated to: \033[1;32m$NEW_DOMAIN\033[0m"
else
    echo -e "\n❌ Invalid domain format. Domain not changed."
fi

read -n 1 -s -r -p "Tekan tombol apapun untuk kembali..."
