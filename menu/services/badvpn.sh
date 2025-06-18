#!/bin/bash
wget -qO /usr/bin/badvpn-udpgw https://github.com/ambrop72/badvpn/releases/download/v1.999.130/badvpn-udpgw
chmod +x /usr/bin/badvpn-udpgw

for port in 7100 7200 7300; do
    cat > /etc/systemd/system/badvpn-$port.service << EOF
[Unit]
Description=BadVPN UDPGW $port
After=network.target

[Service]
ExecStart=/usr/bin/badvpn-udpgw --listen-addr 127.0.0.1:$port --max-clients 500
Restart=always

[Install]
WantedBy=multi-user.target
EOF

    systemctl daemon-reexec
    systemctl enable badvpn-$port
    systemctl start badvpn-$port
done
