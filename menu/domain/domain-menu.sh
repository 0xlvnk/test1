#!/bin/bash
while true; do
    clear
    echo -e "\033[1;36m==============================="
    echo -e "      DOMAIN PANEL MENU"
    echo -e "===============================\033[0m"
    echo
    echo -e "  [1] Change Domain"
    echo -e "  [2] Renew SSL Certificate"
    echo -e "  [0] Back"
    echo -ne "\nSelect menu: "; read opt

    case $opt in
        1) bash /root/menu/domain/change-domain.sh ;;
        2) bash /root/menu/domain/renew-ssl.sh ;;
        0) break ;;
        *) echo -e "\n❌ Invalid choice"; sleep 1 ;;
    esac
done
