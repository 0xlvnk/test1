#!/bin/bash
clear

# Hitung jumlah akun SSH dari database
if [[ -f /etc/ssh-db/users.db ]]; then
    ssh_count=$(wc -l < /etc/ssh-db/users.db)
else
    ssh_count=0
fi

# Ambil info ISP dan lokasi
ISP=$(curl -s ipinfo.io/org | cut -d " " -f2-)
CITY=$(curl -s ipinfo.io/city)
REGION=$(curl -s ipinfo.io/country)

# Tampilkan
echo -e "••••• MEMBER INFORMATION •••••"
echo -e "SSH Account     : $ssh_count"
echo -e "Vmess Account   : 0"
echo -e "Vless Account   : 0"
echo -e "Trojan Account  : 0"
echo
echo -e "••••• SCRIPT INFORMATION •••••"
echo -e "Owner  : Kalvin"
echo -e "User   : $(whoami)"
echo -e "ISP    : $ISP"
echo -e "Region : $CITY / $REGION"
