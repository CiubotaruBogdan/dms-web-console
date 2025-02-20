sudo apt update
sudo apt install python3 python3-pip
```

2. Navigate to this directory:
```bash
cd path/to/offline_packages
```

3. Install packages using pip with the offline flags:
```bash
pip3 install --no-index --find-links=. -r requirements.txt
```

## Package List
The following packages and their dependencies are included:
- Flask (3.0.2)
- Flask-SQLAlchemy (3.1.1)
- gunicorn (21.2.0)
- psycopg2-binary (2.9.9)
- email-validator (2.1.0.post1)

## Downloading Packages for Offline Use
To update the offline package repository:

1. On a machine with internet access, run:
```bash
pip3 download -r requirements.txt -d .