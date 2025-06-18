#!/bin/bash

for port in 2082 8880 8080 2096; do
    cat > /etc/systemd/system/ws-$port.service << EOF
[Unit]
Description=Dropbear WebSocket $port
After=network.target

[Service]
ExecStart=/bin/bash -c 'socat TCP-LISTEN:$port,fork,reuseaddr TCP:127.0.0.1:22'
Restart=always

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reexec
    systemctl enable ws-$port
    systemctl start ws-$port
done
