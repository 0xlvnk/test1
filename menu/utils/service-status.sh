#!/bin/bash

# Warna
GREEN='\033[0;32m'
RED='\033[0;31m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'

# Fungsi cek status
check_status() {
    systemctl is-active --quiet "$1" && echo -e "${GREEN}Running${NC}" || echo -e "${RED}Not Running${NC}"
}

clear
echo -e "${MAGENTA}==============================="
echo -e "     Service Status Menu"
echo -e "===============================${NC}"

# Deteksi service SSH yang tersedia
if systemctl list-units --type=service | grep -q sshd; then
    ssh_service="sshd"
else
    ssh_service="ssh"
fi

# Daftar layanan yang ingin ditampilkan
declare -A services=(
  ["SSH / TUN"]="$ssh_service"
  ["UDP Service"]="udp-custom"
  ["Dropbear"]="dropbear"
  ["Stunnel4"]="stunnel4"
  ["Fail2Ban"]="fail2ban"
  ["Crons"]="cron"
  ["Vnstat"]="vnstat"
  ["XRAY Vmess"]="xray"
  ["XRAY Vless"]="xray"
  ["XRAY Trojan"]="xray"
  ["Websocket TLS"]="xray"
  ["Websocket Dropbear"]="dropbear-ws"
  ["Proxy Server"]="squid"
)

# Tampilkan status per layanan
for name in "${!services[@]}"; do
  printf "  %-25s : %s\n" "$name" "$(check_status "${services[$name]}")"
done

# Footer branding
echo -e "${MAGENTA}==============================="
echo -e "       Project by ${CYAN}KAL${NC}"
echo -e "${MAGENTA}===============================${NC}"
