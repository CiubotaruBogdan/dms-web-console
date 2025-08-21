#!/bin/bash

SERVICE_NAME="mildocdms-orchestrator"
PORT=5000

# Check if service is installed
if ! systemctl list-unit-files | grep -q "^$SERVICE_NAME.service"; then
    echo "Installing $SERVICE_NAME service..."
    # Copy service file
    sudo cp mildocdms-orchestrator.service /etc/systemd/system/
    sudo systemctl daemon-reload
    sudo systemctl enable $SERVICE_NAME
fi

# Check if service is running
if ! systemctl is-active --quiet $SERVICE_NAME; then
    echo "Starting $SERVICE_NAME service..."
    sudo systemctl start $SERVICE_NAME
fi

# Check if port is listening
if netstat -tuln | grep -q ":$PORT "; then
    echo "Service is healthy and running on port $PORT"
else
    echo "Service is not responding on port $PORT"
    echo "Checking logs..."
    sudo journalctl -u $SERVICE_NAME -n 50
fi
