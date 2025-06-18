#!/bin/bash

# Install Xray binary
if [[ ! -f /usr/local/bin/xray ]]; then
    curl -L -o /tmp/xray.zip https://github.com/XTLS/Xray-core/releases/latest/download/Xray-linux-64.zip
    unzip /tmp/xray.zip -d /usr/local/bin/
    chmod +x /usr/local/bin/xray
    rm -f /tmp/xray.zip
fi

# Buat service
cat > /etc/systemd/system/xray.service << EOF
[Unit]
Description=Xray Service
After=network.target nss-lookup.target

[Service]
ExecStart=/usr/local/bin/xray run -config /etc/xray/config.json
Restart=on-failure
LimitNOFILE=51200

[Install]
WantedBy=multi-user.target
EOF

# Config minimal (biar service aktif meski belum dipakai)
mkdir -p /etc/xray
cat > /etc/xray/config.json << EOF
{
  "log": { "loglevel": "warning" },
  "inbounds": [],
  "outbounds": []
}
EOF

# Enable dan start
systemctl daemon-reexec
systemctl enable xray
systemctl start xray
