# Comenzi instalare

```bash
sudo apt update
sudo apt install python3 python3-pip
pip3 install -r requirements.txt
pip3 download -r requirements.txt -d pachete_offline
pip3 install --no-index --find-links=pachete_offline -r requirements.txt
```

