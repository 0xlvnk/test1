#!/bin/bash
clear
echo -e "\033[1;36m======= DAFTAR AKUN SSH =======\033[0m"
printf "%-15s %-15s\n" "Username" "Expired Date"
echo "-------------------------------"

count=0

if [[ -f /etc/ssh-db/users.db ]]; then
    while IFS='|' read -r user pass exp owner limit; do
        printf "%-15s %-15s\n" "$user" "$exp"
        ((count++))
    done < /etc/ssh-db/users.db

    echo "-------------------------------"
    echo -e "Total Akun SSH: $count"
else
    echo "Belum ada akun yang dibuat."
    exit 1
fi

echo
read -rp "Username yang ingin diperpanjang: " user
if id "$user" &>/dev/null; then
    read -rp "Tambah hari berapa: " days
    chage -E $(date -d "+$days days" +%Y-%m-%d) "$user"

    # Update exp di database
    new_exp=$(date -d "+$days days" +"%Y-%m-%d")
    tmpfile=$(mktemp)
    while IFS='|' read -r u p e o l; do
        [[ "$u" == "$user" ]] && e="$new_exp"
        echo "$u|$p|$e|$o|$l" >> "$tmpfile"
    done < /etc/ssh-db/users.db
    mv "$tmpfile" /etc/ssh-db/users.db

    echo "✅ Masa aktif user '$user' diperpanjang $days hari."
else
    echo "❌ User '$user' tidak ditemukan!"
fi

read -n 1 -s -r -p "Tekan tombol apapun untuk kembali..."
