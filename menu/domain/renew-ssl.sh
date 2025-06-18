#!/bin/bash

DOMAIN=$(cat /etc/xray/domain)
VPS_IP=$(curl -s ipv4.icanhazip.com)
DOMAIN_IP=$(ping -c 1 "$DOMAIN" | grep PING | awk '{print $3}' | tr -d '()')

echo -e "[ INFO ] Start SSL Renewal"

# Cek apakah domain sudah mengarah ke VPS
if [[ "$DOMAIN_IP" != "$VPS_IP" ]]; then
    echo -e "[ ERROR ] Domain belum mengarah ke VPS"
    echo -e " - Domain Resolve : $DOMAIN_IP"
    echo -e " - VPS IP         : $VPS_IP"
    echo -e "[ HINT ] Ubah DNS di Cloudflare"
    read -n 1 -s -r -p "Tekan tombol apapun untuk keluar..."
    exit 1
fi

# Deteksi siapa yang pakai port 80
PORT80_PID=$(lsof -i :80 -t 2>/dev/null)
if [[ -n "$PORT80_PID" ]]; then
    echo -e "[ WARNING ] Detected port 80 used (PID $PORT80_PID)"
    echo -e "[ INFO ] Stopping service(s) that use port 80..."

    # Hentikan nginx atau socat
    systemctl stop nginx 2>/dev/null
    pkill -f "socat.*:80" 2>/dev/null
    sleep 1
fi

# Pastikan port 80 kosong
if ss -tuln | grep -q ":80"; then
    echo -e "[ ERROR ] Port 80 masih digunakan! Tidak bisa lanjut."
    read -n 1 -s -r -p "Tekan tombol apapun untuk keluar..."
    sleep 1
fi

# Hapus redirect iptables dari port 80 jika ada
iptables -t nat -D PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 2082 2>/dev/null


# Install acme.sh jika belum ada
if [[ ! -d ~/.acme.sh ]]; then
    echo -e "[ INFO ] Installing acme.sh..."
    curl https://get.acme.sh | sh
    ~/.acme.sh/acme.sh --upgrade --auto-upgrade
fi

# Jalankan issuance/renewal cert
echo -e "[ INFO ] Renewing SSL certificate..."
~/.acme.sh/acme.sh --set-default-ca --server letsencrypt
~/.acme.sh/acme.sh --issue --force -d $DOMAIN --standalone --keylength ec-256

# Cek hasil
if [[ ! -f ~/.acme.sh/${DOMAIN}_ecc/fullchain.cer ]]; then
    echo -e "[ ERROR ] Gagal mendapatkan sertifikat!"
    read -n 1 -s -r -p "Tekan tombol apapun untuk keluar..."
    exit 1
fi

# Install cert
echo -e "[ INFO ] Installing cert to /etc/xray/"
~/.acme.sh/acme.sh --install-cert -d $DOMAIN --ecc \
--key-file /etc/xray/private.key \
--fullchain-file /etc/xray/cert.crt

# Restart semua service
echo -e "[ INFO ] Restarting all services..."
for svc in ssh sshd dropbear stunnel4 xray squid cron fail2ban vnstat nginx dropbear-ws udp-custom tls-shunt-proxy; do
    systemctl restart "$svc" 2>/dev/null
done

# Pastikan socat kembali ke port 80 (jika kamu pakai dropbear-ws)
systemctl restart dropbear-ws 2>/dev/null

echo -e "[ DONE ] Certificate renewed & services restored."
read -n 1 -s -r -p "Press any key to continue..."
