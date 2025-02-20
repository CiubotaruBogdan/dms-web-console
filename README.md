git clone [repository-url]
cd mildocdms-web
```

2. Install and manage the service:
```bash
cd linux_service
chmod +x manage_service.sh
sudo ./manage_service.sh
```

The management script provides an interactive menu with the following options:
1. Install service (creates dms user, sets up files, and starts service)
2. Start service
3. Stop service
4. Check service status
5. View service logs
6. Uninstall service

To monitor the service status:
```bash
chmod +x check_service.sh
./check_service.sh