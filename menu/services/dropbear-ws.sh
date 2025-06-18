#!/bin/bash

# Install socat
apt install -y socat

# Buat systemd service langsung di port 80
cat > /etc/systemd/system/dropbear-ws.service << EOF
[Unit]
Description=Dropbear WebSocket via socat
After=network.target

[Service]
ExecStart=/bin/bash -c 'socat TCP-LISTEN:80,fork,reuseaddr TCP:127.0.0.1:22'
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Enable & Start
systemctl daemon-reexec
systemctl enable dropbear-ws
systemctl restart dropbear-ws
