#!/bin/bash
clear
echo "========================="
echo "   SET SSH LOGIN BANNER"
echo "========================="

echo "Silakan masukkan isi banner. Tekan CTRL+D jika sudah selesai:"
cat > /etc/issue.net

# Aktifkan banner di sshd_config jika belum
if ! grep -q "^Banner /etc/issue.net" /etc/ssh/sshd_config; then
    echo "Banner /etc/issue.net" >> /etc/ssh/sshd_config
fi

systemctl restart ssh
echo -e "\\n✅ Banner berhasil diperbarui & SSH telah direstart!"
