
# Paperless Web Interface

Interfață web pentru gestionarea și procesarea documentelor folosind serviciul MilDocDMS. Oferă acces la comenzi de procesare documente prin intermediul unui terminal web interactiv.

## Caracteristici

- Terminal web interactiv pentru comenzi
- Interfață pentru gestionarea documentelor
- Comenzi predefinite pentru procesarea documentelor
- Istoric comenzi executate
- Suport pentru instalare offline

## Instalare

### 1. Instalare Dependențe
```bash
cd offline_packages
pip3 install --no-index --find-links=. -r requirements.txt
```

### 2. Configurare Serviciu

Folosiți scriptul de management pentru instalare și configurare:

```bash
cd linux_service
chmod +x manage_service.sh
sudo ./manage_service.sh
```

Scriptul oferă următoarele opțiuni:
1. Instalare serviciu
2. Pornire serviciu
3. Oprire serviciu
4. Verificare status
5. Vizualizare log-uri
6. Dezinstalare serviciu

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

### Verificare Status

Pentru a verifica statusul serviciului:
```bash
./check_service.sh
```

### Acces Interfață Web

După instalare și pornire, interfața web este disponibilă la:
- Port: 5000
- URL: http://localhost:5000

## Configurare

### Setări Implicite
- Utilizator serviciu: `dms`
- Director instalare: `/opt/mildocdms-web`
- Port: 5000

### Variabile de Mediu
```
FLASK_APP=app.py
FLASK_ENV=production
PYTHONUNBUFFERED=1
SESSION_SECRET=[your-secret-key]
```
