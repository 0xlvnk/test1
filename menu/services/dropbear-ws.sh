#!/bin/bash

# Service Dropbear WebSocket (port 2082)
cat > /etc/systemd/system/dropbear-ws.service << EOF
[Unit]
Description=Dropbear WebSocket via socat
After=network.target

[Service]
ExecStart=/usr/bin/socat TCP-LISTEN:80,reuseaddr,fork TCP:127.0.0.1:22
Restart=always

[Install]
WantedBy=multi-user.target

EOF

# Enable & Start
systemctl daemon-reexec
systemctl enable dropbear-ws
systemctl start dropbear-ws

# Redirect port 80 → 2082
iptables -t nat -A PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 2082
apt install -y iptables-persistent netfilter-persistent
netfilter-persistent save
