#!/bin/bash
clear
echo -e "====================================="
echo -e " 🔧 VPS MENU INSTALLER by Kalvin"
echo -e "====================================="

# Cegah konflik dpkg
while fuser /var/lib/dpkg/lock >/dev/null 2>&1 ; do
   echo "⏳ Menunggu proses lain selesai (dpkg lock)..."
   sleep 2
done

# Update & Install dependensi
apt update && apt upgrade -y
apt install -y curl wget screen cron unzip socat gnupg2 ca-certificates lsb-release \
  iptables software-properties-common dropbear stunnel4 fail2ban vnstat squid \
  openssh-server iptables-persistent netfilter-persistent nginx lsof

# Salin folder menu
rm -rf /root/menu
cp -r menu /root/menu

# Set permission
chmod -R +x /root/menu
chmod +x /root/menu/*.sh /root/menu/*/*.sh /root/menu/*/*/*.sh

# Shortcut ke /usr/bin
ln -sf /root/menu/menu.sh /usr/bin/menu

# Domain default acak
RANDOM_DOMAIN="vps-$(date +%s | sha256sum | head -c 6).exampledomain.com"
mkdir -p /etc/xray
echo "$RANDOM_DOMAIN" > /etc/xray/domain
echo "✅ Domain default: $RANDOM_DOMAIN"
echo "⚠️  Silahkan ganti domain kamu di menu [9]"

# Buat folder user SSH
mkdir -p /etc/ssh-db
touch /etc/ssh-db/users.db

# Tambahkan info login otomatis
cat > /root/menu/utils/info.sh << EOF
#!/bin/bash
clear
if [[ -f /etc/ssh-db/users.db ]]; then
    ssh_count=\$(wc -l < /etc/ssh-db/users.db)
else
    ssh_count=0
fi
ISP=\$(curl -s ipinfo.io/org | cut -d ' ' -f2-)
CITY=\$(curl -s ipinfo.io/city)
COUNTRY=\$(curl -s ipinfo.io/country)

echo -e "••••• MEMBER INFORMATION •••••"
echo -e "SSH Account     : \$ssh_count"
echo -e "Vmess Account   : 0"
echo -e "Vless Account   : 0"
echo -e "Trojan Account  : 0"
echo
echo -e "••••• SCRIPT INFORMATION •••••"
echo -e "Owner  : Kalvin"
echo -e "User   : \$(whoami)"
echo -e "ISP    : \$ISP"
echo -e "Region : \$CITY/\$COUNTRY"
EOF

chmod +x /root/menu/utils/info.sh

# Tampilkan info + menu saat login
if ! grep -q "utils/info.sh" ~/.bashrc; then
    echo "bash /root/menu/utils/info.sh" >> ~/.bashrc
fi
if ! grep -q "menu" ~/.bashrc; then
    echo "menu" >> ~/.bashrc
fi

# Konfigurasi Dropbear agar listen juga di localhost (::1)
sed -i '/DROPBEAR_EXTRA_ARGS/d' /etc/default/dropbear
echo 'DROPBEAR_EXTRA_ARGS="-p 22 -p 109 -p 143 -p 69 -p ::1:22"' >> /etc/default/dropbear
systemctl restart dropbear

# Pindahkan nginx dari port 80 ke 81 jika perlu
NGINX_CONF="/etc/nginx/sites-available/default"
if grep -q "listen 80;" "$NGINX_CONF"; then
    sed -i 's/listen 80;/listen 81;/g' "$NGINX_CONF"
    systemctl restart nginx
fi

# ===== AKTIFKAN LAYANAN DASAR =====
for svc in dropbear stunnel4 cron vnstat fail2ban squid ssh sshd nginx; do
    systemctl enable $svc 2>/dev/null
    systemctl start $svc 2>/dev/null
done

# ===== JALANKAN LAYANAN MODULAR =====
echo -e "\n🔧 Menyiapkan layanan tambahan..."
bash /root/menu/services/dropbear-config.sh
bash /root/menu/services/xray.sh
bash /root/menu/services/dropbear-ws.sh
bash /root/menu/services/udp-custom.sh
bash /root/menu/services/badvpn.sh
bash /root/menu/services/nginx-reverse.sh
bash /root/menu/services/tls-shunt-proxy.sh

echo -e "\n✅ Install selesai! Memulai ulang"
sleep 2
# ===== REBOOT VPS =====
reboot