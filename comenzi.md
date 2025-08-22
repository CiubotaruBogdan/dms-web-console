# Comenzi Linux

```bash
pip3 install -r requirements.txt
./init.sh
cd linux_service
chmod +x manage_service.sh
sudo ./manage_service.sh
./check_service.sh
python3 aplicatie_web/app.py
sudo apt update
sudo apt install python3 python3-pip
cd path/to/pachete_offline
pip3 install --no-index --find-links=. -r requirements.txt
pip3 download -r requirements.txt -d .
sudo systemctl start mildocdms-orchestrator
sudo systemctl stop mildocdms-orchestrator
sudo systemctl status mildocdms-orchestrator
sudo journalctl -u mildocdms-orchestrator -f
./manage_service.sh
```
