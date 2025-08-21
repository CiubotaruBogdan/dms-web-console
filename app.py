import os
import logging
import pty
import select
import termios
import struct
import fcntl
import json
import threading
from flask import Flask, render_template, request, jsonify
from flask_sock import Sock

# Set up logging
log_dir = "logs"
if not os.path.exists(log_dir):
    os.makedirs(log_dir)

logging.basicConfig(
    level=logging.DEBUG,
    format='%(asctime)s - %(message)s',
    handlers=[
        logging.FileHandler(os.path.join(log_dir, 'commands.log')),
        logging.StreamHandler()
    ]
)

app = Flask(__name__)
sock = Sock(app)
app.secret_key = os.environ.get("SESSION_SECRET", "default_secret_key")

# Global variables for PTY management
pty_master_fd = None
process_pid = None

def write_to_pty(data):
    """Write data to the PTY master."""
    global pty_master_fd
    if pty_master_fd is not None:
        try:
            os.write(pty_master_fd, data.encode())
            # Only log important commands
            if '\r' in data and not data.strip().startswith(('ls', 'cd', 'clear')):
                cmd = data.strip()
                if cmd:
                    logging.info(f"executed command: {cmd}")
        except Exception as e:
            logging.error(f"Error writing to PTY: {str(e)}")

@sock.route('/terminal')
def terminal_socket(ws):
    """Handle WebSocket connection for terminal."""
    global pty_master_fd, process_pid

    try:
        # Create PTY with larger buffer
        master_fd, slave_fd = pty.openpty()
        pty_master_fd = master_fd

        # Optimize terminal settings
        attrs = termios.tcgetattr(slave_fd)
        attrs[1] = attrs[1] & ~termios.OPOST  # Disable output processing
        # attrs[3] = attrs[3] & ~termios.ECHO   # Disable echo (removed as requested)
        termios.tcsetattr(slave_fd, termios.TCSANOW, attrs)

        # Set terminal size
        term_size = struct.pack('HHHH', 24, 80, 0, 0)
        fcntl.ioctl(slave_fd, termios.TIOCSWINSZ, term_size)

        # Start bash in the PTY
        pid = os.fork()
        if pid == 0:  # Child process
            os.close(master_fd)
            os.setsid()
            os.dup2(slave_fd, 0)
            os.dup2(slave_fd, 1)
            os.dup2(slave_fd, 2)
            os.close(slave_fd)
            try:
                env = os.environ.copy()
                env['TERM'] = 'xterm-256color'
                os.execvpe('bash', ['bash'], env)
            except Exception as e:
                logging.error(f"Child process error: {str(e)}")
                os._exit(1)
        else:  # Parent process
            process_pid = pid
            os.close(slave_fd)

            # Thread to continuously read from PTY and send data to the WebSocket
            def read_from_pty():
                while True:
                    try:
                        r, _, _ = select.select([master_fd], [], [], 0.01)
                        if master_fd in r:
                            data = os.read(master_fd, 4096)
                            if data:
                                ws.send(data.decode(errors='replace'))
                    except Exception as e:
                        logging.error(f"PTY thread error: {str(e)}")
                        break

            reader_thread = threading.Thread(target=read_from_pty, daemon=True)
            reader_thread.start()

            # Main loop: handle incoming WebSocket messages (user input, resize events)
            while True:
                try:
                    message = ws.receive()
                    if message:
                        # Attempt to parse JSON for resize events
                        try:
                            parsed = json.loads(message)
                            if isinstance(parsed, dict) and parsed.get('type') == 'resize':
                                rows = parsed.get('rows', 24)
                                cols = parsed.get('cols', 80)
                                term_size = struct.pack('HHHH', rows, cols, 0, 0)
                                fcntl.ioctl(master_fd, termios.TIOCSWINSZ, term_size)
                                continue
                        except (json.JSONDecodeError, TypeError):
                            # Not a JSON message; treat it as direct command input.
                            pass

                        write_to_pty(message)
                except Exception as e:
                    logging.error(f"Socket error: {str(e)}")
                    break

    except Exception as e:
        logging.error(f"Terminal error: {str(e)}")
    finally:
        if pty_master_fd:
            os.close(pty_master_fd)
            pty_master_fd = None
        if process_pid:
            try:
                os.kill(process_pid, 9)
            except Exception:
                pass
            process_pid = None

def parse_command_logs():
    """Parse the command log file and return the command history."""
    history = []
    try:
        with open(os.path.join(log_dir, 'commands.log'), 'r') as f:
            for line in f:
                if "executed command:" in line:
                    timestamp = line.split(" - ")[0]
                    command = line.split("executed command: ")[1].strip()
                    history.append({
                        'timestamp': timestamp,
                        'command': command
                    })
    except Exception as e:
        logging.error(f"Error reading command history: {str(e)}")
        return []
    return history[-100:]  # Return last 100 commands

@app.route('/history')
def get_command_history():
    """Return the command execution history."""
    history = parse_command_logs()
    if request.headers.get('X-Requested-With') == 'XMLHttpRequest':
        return jsonify(history)
    return render_template('history.html', history=history)

@app.route('/')
def index():
    return render_template('index.html', command_options=COMMAND_OPTIONS)

COMMAND_OPTIONS = {
    'document_retagger': {
        '-c': 'Match document correspondents',
        '-T': 'Match document tags',
        '-t': 'Match document types',
        '-s': 'Match document storage paths',
        '-i': 'Process only documents with inbox tags',
        '--id-range': 'Process specific document ID range (e.g. 1 100)',
        '--use-first': 'Use first match for correspondents/types',
        '-f': 'Overwrite existing metadata'
    },
    'document_exporter': {
        '-c': 'Compare file checksums',
        '-cj': 'Compare manifest JSON',
        '-d': 'Delete files not in current export',
        '-f': 'Use filename format',
        '-na': 'Skip archive files',
        '-nt': 'Skip thumbnails',
        '-p': 'Use folder prefixes',
        '-sm': 'Split manifest into individual files',
        '-z': 'Create ZIP archive',
        '-zn': 'Specify ZIP filename',
        '--data-only': 'Export database only',
        '--no-progress-bar': 'Hide progress bar',
        '--passphrase': 'Encrypt export with passphrase'
    },
    'document_importer': {
        '--no-progress-bar': 'Hide progress bar',
        '--data-only': 'Import database only',
        '--passphrase': 'Passphrase for encrypted export'
    },
    'document_consumer': {
        '--delete': 'Delete source files after processing',
        '--watch': 'Continuously watch for new documents',
        '--no-progress': 'Hide progress information'
    },
    'document_create_classifier': {},
    'document_thumbnails': {
        '--document': 'Generate thumbnails for specific document ID',
        '--processes': 'Number of processes to use'
    },
    'document_index': {
        'reindex': 'Rebuild the document index from scratch',
        'optimize': 'Optimize the existing index'
    },
    'invalidate_cachalot': {},
    'document_renamer': {},
    'document_sanity_checker': {},
    'mail_fetcher': {},
    'document_archiver': {
        '--overwrite': 'Recreate archived files even if present',
        '--document': 'Process specific document ID'
    },
    'decrypt_documents': {
        '--passphrase': 'Passphrase used for decryption'
    },
    'document_fuzzy_match': {
        '--ratio': 'Similarity ratio threshold (0-100)',
        '--processes': 'Number of processes to use',
        '--delete': 'Delete one document from each matched pair'
    },
    'prune_audit_logs': {},
    'createsuperuser': {}
}

if __name__ == '__main__':
    app.run(host="0.0.0.0", port=5000, debug=True)
