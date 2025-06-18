#!/bin/bash
echo "===== User Aktif & IP Login ====="
who | awk '{print $1, $5}' | sort | uniq
read -n 1 -s -r -p "Tekan tombol apapun untuk kembali..."
