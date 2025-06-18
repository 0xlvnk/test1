#!/bin/bash

# Install tls-shunt-proxy
wget -O /usr/local/bin/tls-shunt-proxy https://github.com/liberal-boy/tls-shunt-proxy/releases/latest/download/tls-shunt-proxy-linux-amd64
chmod +x /usr/local/bin/tls-shunt-proxy

# Contoh config dasar
mkdir -p /etc/tls-shunt-proxy
cat > /etc/tls-shunt-proxy/config.yaml << EOF
listen: 0.0.0.0:443
proxy:
  - match:
      sni: "tls.yourdomain.com"
    forward: "127.0.0.1:8443"
  - match:
      sni: "ws.yourdomain.com"
    forward: "127.0.0.1:2083"
EOF

# Buat service
cat > /etc/systemd/system/tls-shunt-proxy.service << EOF
[Unit]
Description=TLS Shunt Proxy
After=network.target

[Service]
ExecStart=/usr/local/bin/tls-shunt-proxy run -c /etc/tls-shunt-proxy/config.yaml
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reexec
systemctl enable tls-shunt-proxy
systemctl start tls-shunt-proxy
