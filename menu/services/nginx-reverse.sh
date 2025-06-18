#!/bin/bash

# Pastikan nginx terinstall
apt install -y nginx

# Buat direktori webroot jika belum ada
mkdir -p /var/www/html/.well-known/acme-challenge
chown -R www-data:www-data /var/www/html

# Ambil domain
DOMAIN=$(cat /etc/xray/domain)

# Buat file konfigurasi reverse proxy Xray + webroot
cat > /etc/nginx/sites-available/xray-reverse << EOF
server {
    listen 80;
    server_name $DOMAIN;

    # Untuk validasi SSL acme.sh
    location /.well-known/acme-challenge/ {
        root /var/www/html;
        allow all;
    }

    location /vmess {
        proxy_pass http://127.0.0.1:10000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
    }

    location /vless {
        proxy_pass http://127.0.0.1:10001;
        proxy_http_version 1.1;
        proxy_set_header Upgrade \$http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host \$host;
    }
}
EOF

# Aktifkan site config
ln -sf /etc/nginx/sites-available/xray-reverse /etc/nginx/sites-enabled/xray-reverse

# Nonaktifkan default config jika ada
rm -f /etc/nginx/sites-enabled/default

# Tes config & restart
nginx -t && systemctl restart nginx && echo "✅ Nginx reverse proxy aktif untuk domain: $DOMAIN"
