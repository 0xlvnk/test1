#!/bin/bash

# Warna
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

# Pastikan path dinamis
BASE_DIR=$(dirname "$(readlink -f "$0")")

clear

# Tampilkan informasi sistem
source "$BASE_DIR/utils/menu-header.sh"

# Pembatas Menu
echo -e "${YELLOW}\n========================================"
echo -e "============== VPS MENU ================"
echo -e "========================================${NC}\n"

echo -e "${CYAN}1)  SSH Menu"
echo -e "2)  Vmess Menu"
echo -e "3)  Vless Menu"
echo -e "4)  Trojan Menu"
echo -e "5)  Banner SSH"
echo -e "6)  Running Status"
echo -e "7)  Restart Program"
echo -e "8)  Speedtest VPS"
echo -e "9) Domain Menu"
echo -e "10) Backup Menu"
echo -e "x)  Exit${NC}"

echo -ne "\nSelect menu: "; read menu

case $menu in
    1) bash "$BASE_DIR/ssh/ssh-menu.sh" ;;
    2) bash "$BASE_DIR/vmess/create.sh" ;;
    3) echo -e "${YELLOW}Vless Menu (coming soon)${NC}" ;;
    4) echo -e "${YELLOW}Trojan Menu (coming soon)${NC}" ;;
    5) bash "$BASE_DIR/utils/banner.sh" ;;
    6) bash "$BASE_DIR/utils/service-status.sh" ;;
    7) systemctl restart ssh && echo "${GREEN}SSH Restarted${NC}" ;;
    8) speedtest-cli ;;
    9) bash "$BASE_DIR/domain/domain-menu.sh" ;;
    10) echo -e "${YELLOW}Backup Menu (coming soon)${NC}" ;;
    x) exit ;;
    *) echo -e "${RED}Invalid menu${NC}"; sleep 1 ;;
esac

