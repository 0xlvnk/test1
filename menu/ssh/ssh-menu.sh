#!/bin/bash
ROOT=$(dirname "$(readlink -f "$0")")/..
source "$ROOT/utils/ssh-header.sh"

while true; do
    clear
    print_header "SSH MENU"
    echo -e "[1]  Create SSH Account"
    echo -e "[2]  List SSH Member"
    echo -e "[3]  Delete SSH Account"
    echo -e "[4]  Lock SSH User"
    echo -e "[5]  Unlock SSH User"
    echo -e "[6]  Extend SSH Expiry"
    echo -e "[7]  Check Active SSH & IP Login"
    echo -e "[8]  Change SSH Password"
    echo -e "[x]  Back"
    echo -ne "\\nSelect option: "; read opt

    case $opt in
    1) clear; bash "$ROOT/ssh/create.sh" ;;
    2) clear; bash "$ROOT/ssh/list.sh" ;;
    3) clear; bash "$ROOT/ssh/delete.sh" ;;
    4) clear; bash "$ROOT/ssh/lock.sh" ;;
    5) clear; bash "$ROOT/ssh/unlock.sh" ;;
    6) clear; bash "$ROOT/ssh/extend.sh" ;;
    7) clear; bash "$ROOT/ssh/online.sh" ;;
    8) clear; bash "$ROOT/ssh/passwd.sh" ;;
    x) break ;;
    *) echo -e "❌ Pilihan tidak valid!"; sleep 1 ;;
esac
done
