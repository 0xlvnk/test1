#!/bin/bash

# Warna
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m'

os=$(grep "^PRETTY_NAME" /etc/os-release | cut -d= -f2 | tr -d '"')
kernel=$(uname -r)
uptime=$(uptime -p | cut -d " " -f2-)
ip=$(curl -s ipv4.icanhazip.com)
domain=$(cat /etc/xray/domain 2>/dev/null || echo "N/A")
country=$(curl -s ipinfo.io/country)
region=$(curl -s ipinfo.io/region)
loc="${region}/${country}"
ram_used=$(free -m | awk 'NR==2 {print $3}')
ram_total=$(free -m | awk 'NR==2 {print $2}')
ram_percent=$(( $ram_used * 100 / $ram_total ))
bw_today=$(vnstat | grep "today" | awk '{print $2 " " $3}')
bw_month=$(vnstat -m | grep "`date +%b`" | awk '{print $2 " " $3}')
isp=$(curl -s ipinfo.io/org | cut -d " " -f2-)
ssh_status=$(systemctl is-active ssh)
nginx_status=$(systemctl is-active nginx)
xray_status=$(systemctl is-active xray)

clear
echo -e "${YELLOW}••••• SYSTEM INFORMATION •••••${NC}"
echo -e "${CYAN}OS System     ${NC}: $os"
echo -e "${CYAN}Kernel        ${NC}: $kernel"
echo -e "${CYAN}Uptime        ${NC}: $uptime"
echo -e "${CYAN}ISP           ${NC}: $isp"
echo -e "${CYAN}IP VPS        ${NC}: $ip"
echo -e "${CYAN}Domain        ${NC}: $domain"
echo -e "${CYAN}Country       ${NC}: $loc"
echo -e "${CYAN}RAM Usage     ${NC}: ${ram_used} MB / ${ram_total} MB (${ram_percent}%)"
echo -e "${CYAN}Bandwidth D   ${NC}: $bw_today"
echo -e "${CYAN}Bandwidth M   ${NC}: $bw_month"
echo -e "${CYAN}SSH Status    ${NC}: ${GREEN}$ssh_status${NC}"
echo -e "${CYAN}Nginx Status  ${NC}: ${GREEN}$nginx_status${NC}"
echo -e "${CYAN}Xray Status   ${NC}: ${GREEN}$xray_status${NC}"

