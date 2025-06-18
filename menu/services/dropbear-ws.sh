#!/bin/bash

# Install socat jika belum ada
apt install -y socat

# Buat systemd template service untuk multi-port
cat > /etc/systemd/system/dropbear-ws@.service << EOF
[Unit]
Description=Dropbear WebSocket via socat on port %%i
After=network.target

[Service]
ExecStart=/usr/bin/socat TCP-LISTEN:%%i,reuseaddr,fork TCP:127.0.0.1:22
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd
systemctl daemon-reload

# Daftar port yang akan diaktifkan
ports=(80 8880 8080 2082 2096)

# Aktifkan service untuk tiap port
for port in "${ports[@]}"; do
    echo "Mengaktifkan dropbear-ws di port $port"
    systemctl enable --now dropbear-ws@${port}
done
