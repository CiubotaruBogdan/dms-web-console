#!/bin/bash

SERVICE_NAME="mildocdms-orchestrator"
SERVICE_USER="dms"
INSTALL_DIR="/opt/mildocdms-orchestrator"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
SERVICE_FILE="$SCRIPT_DIR/mildocdms-orchestrator.service"

# Culori pentru output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo -e "${RED}Te rugăm să rulezi ca root sau cu sudo${NC}"
        exit 1
    fi
}

install_service() {
    check_root
    echo -e "${YELLOW}Instalare serviciu MilDocDMS Orchestrator...${NC}"

    # Creează utilizatorul dms dacă nu există
    if ! id -u "$SERVICE_USER" >/dev/null 2>&1; then
        useradd -r -s /bin/false "$SERVICE_USER"
    fi

    # Creează directorul de instalare și setează permisiunile
    mkdir -p "$INSTALL_DIR"
    cp -r "$REPO_DIR"/* "$INSTALL_DIR/"
    chown -R "$SERVICE_USER":"$SERVICE_USER" "$INSTALL_DIR"

    # Instalează fișierul de serviciu
    cp "$SERVICE_FILE" /etc/systemd/system/
    systemctl daemon-reload
    systemctl enable "$SERVICE_NAME"

    start_service
    echo -e "${GREEN}Serviciu instalat cu succes${NC}"
    read -p "Apasă Enter pentru a reveni la meniu" -r
}

start_service() {
    check_root
    echo -e "${YELLOW}Pornire $SERVICE_NAME...${NC}"
    systemctl start "$SERVICE_NAME"
    sleep 2
    check_status
}

stop_service() {
    check_root
    echo -e "${YELLOW}Oprire $SERVICE_NAME...${NC}"
    systemctl stop "$SERVICE_NAME"
    sleep 2
    check_status
}

check_status() {
    check_root
    echo -e "${YELLOW}Verificare stare $SERVICE_NAME...${NC}"
    systemctl status "$SERVICE_NAME" --no-pager --lines=0
}

view_logs() {
    check_root
    echo -e "${YELLOW}Afișare loguri $SERVICE_NAME...${NC}"
    journalctl -u "$SERVICE_NAME" -f
}

uninstall_service() {
    check_root
    echo -e "${YELLOW}Dezinstalare $SERVICE_NAME...${NC}"
    systemctl stop "$SERVICE_NAME"
    systemctl disable "$SERVICE_NAME"
    rm "/etc/systemd/system/$SERVICE_NAME.service"
    systemctl daemon-reload
    echo -e "${GREEN}Serviciu dezinstalat cu succes${NC}"
}

show_menu() {
    echo -e "${YELLOW}Manager Serviciu MilDocDMS Orchestrator${NC}"
    echo "1. Instalează serviciul"
    echo "2. Pornește serviciul"
    echo "3. Oprește serviciul"
    echo "4. Verifică starea serviciului"
    echo "5. Vezi logurile serviciului"
    echo "6. Dezinstalează serviciul"
    echo "q. Ieșire"
    echo
    read -p "Selectează o opțiune: " choice

    case "$choice" in
        1) install_service ;;
        2) start_service ;;
        3) stop_service ;;
        4) check_status ;;
        5) view_logs ;;
        6) uninstall_service ;;
        q|Q) exit 0 ;;
        *) echo -e "${RED}Opțiune invalidă${NC}" ;;
    esac
}

while true; do
    show_menu
    echo

done
