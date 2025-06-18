#!/bin/bash

DOMAIN=$(cat /etc/xray/domain)
WEBROOT="/var/www/html"

vps_ip=$(curl -s ipv4.icanhazip.com)
domain_ip=$(ping -c 1 "$DOMAIN" | grep PING | awk '{print $3}' | tr -d '()')

if [[ "$domain_ip" != "$vps_ip" ]]; then
    echo -e "\n❌ Domain TIDAK mengarah ke IP VPS ini!"
    echo -e "Domain resolve ke: $domain_ip"
    echo -e "VPS IP saat ini  : $vps_ip"
    echo -e "Silakan ubah domain di menu [9] atau arahkan DNS Cloudflare ke VPS ini."
    echo
    read -n 1 -s -r -p "Tekan tombol apapun untuk kembali..."
    exit 1
fi

# Pastikan nginx aktif
systemctl restart nginx

# Cek acme.sh
if [[ ! -d ~/.acme.sh ]]; then
    curl https://get.acme.sh | sh
    source ~/.bashrc
    ~/.acme.sh/acme.sh --upgrade --auto-upgrade
fi

echo -e "\n🚀 Mencoba validasi Let's Encrypt via Webroot..."
~/.acme.sh/acme.sh --set-default-ca --server letsencrypt
~/.acme.sh/acme.sh --issue -d $DOMAIN --webroot $WEBROOT --keylength ec-256

# Verifikasi
if [[ ! -f ~/.acme.sh/$DOMAIN_ecc/fullchain.cer ]]; then
    echo -e "\n❌ Gagal mendapatkan sertifikat. Cek domain & folder webroot."
    read -n 1 -s -r -p "Tekan tombol apapun untuk kembali..."
    exit 1
fi

# Install cert
~/.acme.sh/acme.sh --install-cert -d $DOMAIN \
--ecc \
--key-file /etc/xray/private.key \
--fullchain-file /etc/xray/cert.crt

echo -e "\n✅ Sertifikat berhasil dipasang!"

# Restart semua layanan penting
for svc in nginx ssh sshd dropbear stunnel4 xray squid cron fail2ban vnstat dropbear-ws udp-custom tls-shunt-proxy; do
    systemctl restart "$svc" 2>/dev/null
done

echo -e "✅ Semua layanan berhasil direstart."
read -n 1 -s -r -p "Tekan tombol apapun untuk kembali..."
