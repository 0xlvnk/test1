#!/bin/bash
DOMAIN=$(cat /etc/xray/domain)
VPS_IP=$(curl -s ipv4.icanhazip.com)
RESOLVE_IP=$(ping -c 1 "$DOMAIN" | grep PING | awk '{print $3}' | tr -d '()')
ACME=~/.acme.sh/acme.sh
LOG_TAG="[ INFO ]"

echo "$LOG_TAG Start"
sleep 1

# 🔍 Validasi domain
if [[ "$RESOLVE_IP" != "$VPS_IP" ]]; then
    echo "[ ERROR ] Domain tidak mengarah ke IP VPS"
    echo "[ ERROR ] Domain: $DOMAIN -> $RESOLVE_IP"
    echo "[ ERROR ] VPS IP : $VPS_IP"
    read -n 1 -s -r -p "Tekan tombol apapun untuk kembali..."
    exit 1
fi

# 🔧 Deteksi port 80
PORT80_PID=$(lsof -i :80 -sTCP:LISTEN -t || echo "")
if [[ -n "$PORT80_PID" ]]; then
    SERVICE=$(ps -o comm= -p "$PORT80_PID")
    echo "[ WARNING ] Detected port 80 used by $SERVICE"
    echo "$LOG_TAG Processing to stop $SERVICE"
    systemctl stop "$SERVICE" 2>/dev/null || pkill -f "socat.*:80"
    sleep 1
fi

# 🔧 Stop iptables redirect port 80 jika ada
iptables -t nat -D PREROUTING -p tcp --dport 80 -j REDIRECT --to-port 2082 2>/dev/null

# 🔄 Install acme.sh jika belum ada
if [[ ! -f $ACME ]]; then
    echo "$LOG_TAG Installing acme.sh..."
    curl https://get.acme.sh | sh
    source ~/.bashrc
    $ACME --upgrade --auto-upgrade
fi

# 🚀 Mulai renew
echo "$LOG_TAG Starting renew cert..."
$ACME --set-default-ca --server letsencrypt
$ACME --renew -d $DOMAIN --standalone --force \
  --key-file /etc/xray/private.key \
  --fullchain-file /etc/xray/cert.crt

# 🔁 Restart semua layanan port 80
for svc in nginx dropbear-ws xray ssh sshd stunnel4 udp-custom squid cron vnstat fail2ban tls-shunt-proxy; do
    systemctl restart $svc 2>/dev/null
done

echo "$LOG_TAG Renew cert done..."
echo "$LOG_TAG All finished..."
echo "RSV Project"
read -n 1 -s -r -p "Press any key to continue..."
