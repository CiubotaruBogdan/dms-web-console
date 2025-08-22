#!/bin/bash

if [ "$EUID" -ne 0 ]; then
    echo -e "\e[31mAcest script trebuie rulat cu sudo.\e[0m"
    exit 1
fi

install_requirements() {
    if command -v pip3 >/dev/null 2>&1; then
        pip3 install -r requirements.txt
    else
        echo -e "\e[31mpip3 nu este instalat\e[0m"
    fi
}

manage_service() {
    if [ -x linux_service/manage_service.sh ]; then
        linux_service/manage_service.sh
    else
        echo "Scriptul de gestionare a serviciului nu a fost găsit."
    fi
}

while true; do
    echo "MilDocDMS Orchestrator - Inițializare"
    echo "1. Instalează dependențele"
    echo "2. Administrare serviciu Linux"
    echo "q. Ieșire"
    read -p "Alege o opțiune: " choice
    case "$choice" in
        1) install_requirements ;;
        2) manage_service ;;
        q|Q) exit 0 ;;
        *) echo "Opțiune invalidă" ;;
    esac
    echo
done
