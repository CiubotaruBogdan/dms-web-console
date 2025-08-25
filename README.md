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

## Instalare pas cu pas

1. **Instalați dependențele**
   ```bash
   pip3 install -r requirements.txt
   ```

   Sau utilizați scriptul de inițializare:
   ```bash
   pip3 install -r requirements.txt
   ```

   Sau utilizați scriptul de inițializare:
   ```bash
   ./init.sh
   ```

2. **Instalați și porniți serviciul**
   ```bash
   cd linux_service
   chmod +x manage_service.sh
   sudo ./manage_service.sh
   ```
   Din meniul scriptului selectați:
   1. *Instalare serviciu*
   2. *Pornire serviciu* (dacă nu pornește automat)

3. **Verificați statusul serviciului**
   ```bash
   ./check_service.sh
   ```

4. **Accesați interfața web**
   Navigați în browser la `http://localhost:5000`.

### Rulare manuală (opțional)
Pentru a porni aplicația fără instalarea serviciului systemd:
```bash
python3 aplicatie_web/app.py
```

## Docker

Aplicația poate fi rulată în containere Docker, inclusiv pe Windows prin Docker Desktop. Asigură-te că serviciul `mildocdms` rulează separat și expune portul `8000` (ex.: `docker run -p 8000:8000 --name mildocdms mildocdms:latest`).

1. Instalează [Docker Desktop](https://www.docker.com/products/docker-desktop/).
2. Din directorul proiectului rulează:
   ```bash
   docker compose up --build
   ```

Această comandă construiește imaginea **mildocdms-orchestrator** și pornește containerul cu același nume pe portul `5000`. Containerul se conectează la serviciul `mildocdms` prin `http://host.docker.internal:8000`.

Imaginea include utilitarul Docker CLI și montează socket-ul Docker al gazdei, permițând rularea comenzilor `docker` din terminalul web.
Alternativ, poți construi și rula manual:

```bash
docker build -t mildocdms-orchestrator .
docker run -p 5000:5000 \
  -e MILDOC_SERVICE_URL=http://host.docker.internal:8000 \
  -v /var/run/docker.sock:/var/run/docker.sock \
  mildocdms-orchestrator
```
## Instalare offline a dependențelor

1. Asigurați-vă că aveți instalate `python3` și `pip`:
   ```bash
   sudo apt update
   sudo apt install python3 python3-pip
   ```

2. Navigați în directorul ce conține pachetele descărcate:
   ```bash
   cd path/to/pachete_offline
   ```

3. Instalați pachetele folosind pip fără acces la internet:
   ```bash
   pip3 install --no-index --find-links=. -r requirements.txt
   ```

### Listă pachete
- Flask (3.0.2)
- Flask-SQLAlchemy (3.1.1)
- gunicorn (21.2.0)
- psycopg2-binary (2.9.9)
- email-validator (2.1.0.post1)

### Actualizarea arhivei de pachete offline
Pe un sistem cu acces la internet, rulați:
```bash
pip3 download -r requirements.txt -d .
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
  - `-c` - Match document correspondents
  - `-T` - Match document tags
  - `-t` - Match document types
  - `-s` - Match document storage paths
  - `-i` - Procesează doar documentele cu eticheta inbox
  - `--id-range` - Procesează un interval de ID-uri (ex. `1 100`)
  - `--use-first` - Folosește primul rezultat potrivit
  - `-f` - Suprascrie metadatele existente

- `document_exporter` - Exportă documente și metadate
  - `-c`, `--compare-checksums` - Compară checksum-urile
  - `-cj`, `--compare-json` - Compară fișierul manifest
  - `-d`, `--delete` - Șterge fișierele care nu mai sunt în export
  - `-f`, `--use-filename-format` - Folosește formatul definit în `PAPERLESS_FILENAME_FORMAT`
  - `-na`, `--no-archive` - Omite fișierele arhivate
  - `-nt`, `--no-thumbnail` - Omite thumbnail-urile
  - `-p`, `--use-folder-prefix` - Exportă în directoare separate
  - `-sm`, `--split-manifest` - Manifest separat per document
  - `-z`, `--zip` - Creează un fișier ZIP
  - `-zn`, `--zip-name` - Nume personalizat pentru arhivă
  - `--data-only` - Exportă doar baza de date
  - `--no-progress-bar` - Ascunde bara de progres
  - `--passphrase` - Criptează exportul cu o parolă

- `document_importer` - Importă un export existent
  - `--no-progress-bar` - Ascunde bara de progres
  - `--data-only` - Importă doar baza de date
  - `--passphrase` - Parolă pentru exportul criptat

- `document_consumer` - Procesează documentele din directorul de import
  - `--delete` - Șterge fișierele sursă după procesare
  - `--watch` - Monitorizează continuu pentru documente noi
  - `--no-progress` - Ascunde informațiile de progres

- `document_create_classifier` - Reantrenează clasificatorul automat (fără opțiuni)

- `document_thumbnails` - Regenerare thumbnail-uri
  - `--document` - ID-ul documentului de procesat
  - `--processes` - Numărul de procese utilizate

- `document_index` - Administrarea indexului de căutare
  - `reindex` - Reconstruiește indexul de la zero
  - `optimize` - Optimizează indexul existent

- `invalidate_cachalot` - Golește cache-ul de citire (fără opțiuni)

- `document_renamer` - Aplică noul format de denumire (fără opțiuni)

- `document_sanity_checker` - Verifică integritatea colecției (fără opțiuni)

- `mail_fetcher` - Rulează manual consumatorul de email (fără opțiuni)

- `document_archiver` - Creează fișiere PDF/A
  - `--overwrite` - Suprascrie arhivele existente
  - `--document` - ID-ul documentului de procesat

- `decrypt_documents` - Dezactivează criptarea documentelor
  - `--passphrase` - Parola folosită la criptare

- `document_fuzzy_match` - Detectează duplicate aproximative
  - `--ratio` - Prag de similaritate (0-100)
  - `--processes` - Număr de procese utilizate
  - `--delete` - Șterge un document din perechea găsită

- `prune_audit_logs` - Curăță intrările vechi din audit (fără opțiuni)

- `createsuperuser` - Creează un cont administrativ (fără opțiuni)

## Configurare

### Setări Implicite
- Utilizator serviciu: `dms`
- Director instalare: `/opt/mildocdms-orchestrator`
- Port: 5000

