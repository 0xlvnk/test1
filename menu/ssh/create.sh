#!/bin/bash
clear
BASE_DIR=$(dirname "$(readlink -f "$0")")
ROOT_DIR=$(dirname "$BASE_DIR")
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/../utils/ssh-header.sh"

clear
print_header "Create SSH  Account"

if [[ -f /etc/xray/domain ]]; then
    DOMAIN=$(cat /etc/xray/domain)
else
    DOMAIN="(Domain belum diset)"
fi

ISP=$(curl -s ipinfo.io/org | cut -d " " -f 2-10)
CITY=$(curl -s ipinfo.io/city)
REGION=$(curl -s ipinfo.io/country)

read -rp "Username      : " user
read -rp "Password      : " pass
read -rp "Expired (days): " exp

useradd -e $(date -d "$exp days" +"%Y-%m-%d") -s /bin/false -M "$user"
echo -e "$pass\n$pass" | passwd "$user" &>/dev/null
exp_date=$(date -d "$exp days" +"%b %d, %Y")

clear
print_header "Detail SSH  Account"
echo -e "Domain        : $DOMAIN"
echo -e "Username      : $user"
echo -e "Password      : $pass"
echo -e "========================"
echo -e "ISP           : $ISP"
echo -e "Region        : $CITY / $REGION"
echo -e "========================"
echo -e "Port HTTPS    : 443,8443,2083,2053,2095"
echo -e "Port HTTP     : 80,8880,8080,2082,2096"
echo -e "Port TLS/SSL  : 222,777"
echo -e "Port Dropbear : 109,143,69"
echo -e "Port UDP      : 1-65535"
echo -e "UDPGW         : 7100-7300"
echo -e "========================"
echo -e "Exp           : $exp_date"
echo ""
# Simpan ke database users.db
mkdir -p /etc/ssh-db
echo "$user|$pass|$(date -d "$exp days" +"%Y-%m-%d")|$USER|1" >> /etc/ssh-db/users.db

read -n 1 -s -r -p "Tekan tombol apapun untuk kembali..."