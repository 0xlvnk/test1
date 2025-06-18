#!/bin/bash

# Install nginx
apt install -y nginx

# Buat config reverse proxy (misalnya untuk xray ws di 127.0.0.1:10000)
cat > /etc/nginx/sites-available/xray-reverse << EOF
server {
    listen 80;
    server_name $(cat /etc/xray/domain);

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

ln -sf /etc/nginx/sites-available/xray-reverse /etc/nginx/sites-enabled/xray-reverse

# Restart nginx
systemctl enable nginx
systemctl restart nginx
