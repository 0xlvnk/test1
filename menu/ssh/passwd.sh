#!/bin/bash
clear

# Tampilkan daftar akun SSH
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
read -rp "Username yang ingin diganti passwordnya: " user
if [[ -z "$user" ]]; then
    echo "❌ Username tidak boleh kosong."
    read -n 1 -s -r -p "Tekan tombol apapun untuk kembali..."
    exit 1
fi

# Validasi dan ganti password
if id "$user" &>/dev/null; then
    echo -e "\nMasukkan password baru:"
    passwd "$user"

    echo -e "\n✅ Password untuk user '$user' berhasil diubah!"
else
    echo "❌ User '$user' tidak ditemukan!"
fi

if [[ "$user" == "root" ]]; then
    echo "❌ Tidak boleh mengubah password root lewat menu ini!"
    exit 1
fi

read -n 1 -s -r -p "Tekan tombol apapun untuk kembali..."
