# MilDocDMS Orchestrator

Interfață web pentru gestionarea și procesarea documentelor folosind serviciul MilDocDMS Orchestrator. Oferă un terminal web interactiv pentru executarea comenzilor de administrare a documentelor.

## Caracteristici

- Terminal web interactiv pentru comenzi
- Interfață pentru gestionarea documentelor
- Comenzi predefinite pentru procesarea documentelor
- Istoric comenzi executate
- Suport pentru instalare offline

## Cerințe preliminare

- Python 3 și `pip`
- Acces la pachetul de dependențe din directorul `offline_packages`

## Instalare pas cu pas

1. **Clonați repository-ul**
   ```bash
   git clone <URL-repo>
   cd mildocdms-orchestrator
   ```

2. **Instalați dependențele**
   ```bash
   cd offline_packages
   pip3 install --no-index --find-links=. -r requirements.txt
   cd ..
   ```

3. **Instalați și porniți serviciul**
   ```bash
   cd linux_service
   chmod +x manage_service.sh
   sudo ./manage_service.sh
   ```
   Din meniul scriptului selectați:
   1. *Instalare serviciu*
   2. *Pornire serviciu* (dacă nu pornește automat)

4. **Verificați statusul serviciului**
   ```bash
   ./check_service.sh
   ```

5. **Accesați interfața web**
   Navigați în browser la `http://localhost:5000`.

### Rulare manuală (opțional)
Pentru a porni aplicația fără instalarea serviciului systemd:
```bash
python3 app.py
```

## Administrarea Serviciului Linux

Scriptul `manage_service.sh` oferă opțiuni pentru administrarea serviciului `mildocdms-orchestrator`:

- **Pornire:** `sudo systemctl start mildocdms-orchestrator`
- **Oprire:** `sudo systemctl stop mildocdms-orchestrator`
- **Status:** `sudo systemctl status mildocdms-orchestrator`
- **Log-uri:** `sudo journalctl -u mildocdms-orchestrator -f`
- **Dezinstalare:** Rulați `./manage_service.sh` și selectați opțiunea `Uninstall service`

## Utilizare

### Comenzi Disponibile

- `document_retagger` - Gestionare metadata documente
  - `-c` - Match document content
  - `-T` - Match document tags
  - `-t` - Match document types
  - `-s` - Match document storage paths
  - `-i` - Process only documents with inbox tags
  
- `document_index` - Indexare documente
  - `--no-progress` - Nu arată progresul indexării
  - `--no-checksum` - Nu verifica checksum-urile
  - `--clean` - Șterge și recrează indexul

- `document_sanity_checker` - Verificare integritate
  - `--delete` - Șterge fișierele corupte
  - `--no-progress` - Nu arată progresul verificării

## Configurare

### Setări Implicite
- Utilizator serviciu: `dms`
- Director instalare: `/opt/mildocdms-orchestrator`
- Port: 5000

### Variabile de Mediu
```
FLASK_APP=app.py
FLASK_ENV=production
PYTHONUNBUFFERED=1
SESSION_SECRET=[your-secret-key]
```
