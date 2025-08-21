#!/bin/bash

SERVICE_NAME="mildocdms-orchestrator"
SERVICE_USER="dms"
INSTALL_DIR="/opt/mildocdms-orchestrator"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to check if script is run as root
check_root() {
    if [ "$EUID" -ne 0 ]; then
        echo -e "${RED}Please run as root or with sudo${NC}"
        exit 1
    fi
}

# Install service
install_service() {
    check_root
    echo -e "${YELLOW}Installing MilDocDMS Orchestrator Service...${NC}"
    
    # Create dms user if it doesn't exist
    if ! id -u $SERVICE_USER >/dev/null 2>&1; then
        useradd -r -s /bin/false $SERVICE_USER
    fi
    
    # Create install directory and set permissions
    mkdir -p $INSTALL_DIR
    cp -r ../* $INSTALL_DIR/
    chown -R $SERVICE_USER:$SERVICE_USER $INSTALL_DIR
    
    # Install service file
    cp mildocdms-orchestrator.service /etc/systemd/system/
    systemctl daemon-reload
    systemctl enable $SERVICE_NAME
    
    echo -e "${GREEN}Service installed successfully${NC}"
    start_service
}

# Start service
start_service() {
    check_root
    echo -e "${YELLOW}Starting $SERVICE_NAME...${NC}"
    systemctl start $SERVICE_NAME
    sleep 2
    check_status
}

# Stop service
stop_service() {
    check_root
    echo -e "${YELLOW}Stopping $SERVICE_NAME...${NC}"
    systemctl stop $SERVICE_NAME
    sleep 2
    check_status
}

# Check service status
check_status() {
    check_root
    echo -e "${YELLOW}Checking $SERVICE_NAME status...${NC}"
    systemctl status $SERVICE_NAME
}

# View service logs
view_logs() {
    check_root
    echo -e "${YELLOW}Showing $SERVICE_NAME logs...${NC}"
    journalctl -u $SERVICE_NAME -f
}

# Uninstall service
uninstall_service() {
    check_root
    echo -e "${YELLOW}Uninstalling $SERVICE_NAME...${NC}"
    systemctl stop $SERVICE_NAME
    systemctl disable $SERVICE_NAME
    rm /etc/systemd/system/$SERVICE_NAME.service
    systemctl daemon-reload
    echo -e "${GREEN}Service uninstalled successfully${NC}"
}

# Show menu
show_menu() {
    echo -e "${YELLOW}MilDocDMS Orchestrator Service Manager${NC}"
    echo "1. Install service"
    echo "2. Start service"
    echo "3. Stop service"
    echo "4. Check service status"
    echo "5. View service logs"
    echo "6. Uninstall service"
    echo "q. Quit"
    echo
    read -p "Select an option: " choice
    
    case $choice in
        1) install_service ;;
        2) start_service ;;
        3) stop_service ;;
        4) check_status ;;
        5) view_logs ;;
        6) uninstall_service ;;
        q) exit 0 ;;
        *) echo -e "${RED}Invalid option${NC}" ;;
    esac
}

# Main loop
while true; do
    show_menu
    echo

done
