#!/bin/bash
cd /usr/local/bin
wget -qO udp-custom https://github.com/ardzz/udp-custom/releases/latest/download/udp-custom-linux-amd64
chmod +x udp-custom

cat > /etc/systemd/system/udp-custom.service << EOF
[Unit]
Description=UDP Custom Service
After=network.target

[Service]
ExecStart=/usr/local/bin/udp-custom server --listen 5300 --proxy-proto
Restart=always
User=root

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reexec
systemctl enable udp-custom
systemctl start udp-custom
