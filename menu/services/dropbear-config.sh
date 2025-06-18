#!/bin/bash
cat > /etc/default/dropbear << EOF
NO_START=0
DROPBEAR_PORT=109
DROPBEAR_EXTRA_ARGS="-p 143 -p 69 -p 222 -p 777"
EOF

systemctl restart dropbear
