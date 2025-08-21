document.addEventListener('DOMContentLoaded', function() {
    const term = new Terminal({
        cursorBlink: true,
        theme: {
            background: '#0d1117',
            foreground: '#ffffff',
            cursor: '#ffffff',
            selection: 'rgba(255, 255, 255, 0.3)',
            black: '#000000',
            red: '#cc0000',
            green: '#4e9a06',
            yellow: '#c4a000',
            blue: '#3465a4',
            magenta: '#75507b',
            cyan: '#06989a',
            white: '#d3d7cf',
            brightBlack: '#555753',
            brightRed: '#ef2929',
            brightGreen: '#8ae234',
            brightYellow: '#fce94f',
            brightBlue: '#729fcf',
            brightMagenta: '#ad7fa8',
            brightCyan: '#34e2e2',
            brightWhite: '#eeeeec'
        },
        fontFamily: 'Menlo, Monaco, "Courier New", monospace',
        fontSize: 14,
        lineHeight: 1.2,
        convertEol: true
    });

    term.open(document.getElementById('terminal'));
    term.focus();

    let socket = null;
    let isConnected = false;

    const connectButton = document.getElementById('connectButton');
    const orchestratorButton = document.getElementById('orchestratorButton');
    const clearButton = document.getElementById('clearButton');
    const commandInput = document.getElementById('commandInput');
    const commandForm = document.getElementById('commandForm');

    function initializeWebSocket() {
        socket = new WebSocket(`ws://${window.location.host}/terminal`);

        socket.onopen = () => {
            console.log('WebSocket connected');
            term.writeln('\x1b[1;32mConnected to terminal.\x1b[0m');
            isConnected = true;
            connectButton.textContent = 'Connected';
            connectButton.classList.replace('btn-primary', 'btn-success');
            connectButton.disabled = true;
            orchestratorButton.disabled = false;
            term.focus();
        };

        socket.onmessage = (event) => {
            term.write(event.data);
        };

        socket.onclose = () => {
            console.log('WebSocket disconnected');
            isConnected = false;
            connectButton.textContent = 'Connect';
            connectButton.classList.replace('btn-success', 'btn-primary');
            connectButton.disabled = false;
            orchestratorButton.disabled = true;
            term.writeln('\x1b[1;31mDisconnected from terminal.\x1b[0m');
            term.focus();
        };

        socket.onerror = (error) => {
            console.error('WebSocket error:', error);
            term.writeln('\x1b[1;31mError: WebSocket connection failed.\x1b[0m');
            isConnected = false;
            connectButton.disabled = false;
            orchestratorButton.disabled = true;
            term.focus();
        };
    }

    // Handle terminal input
    term.onData(data => {
        if (socket && socket.readyState === WebSocket.OPEN) {
            socket.send(data);
        }
    });

    // Handle terminal resize
    term.onResize(size => {
        if (socket && socket.readyState === WebSocket.OPEN) {
            socket.send(JSON.stringify({
                type: 'resize',
                cols: size.cols,
                rows: size.rows
            }));
        }
    });

    connectButton.addEventListener('click', () => {
        if (!isConnected) {
            term.clear();
            term.writeln('\x1b[1;32mConnecting to terminal...\x1b[0m');
            initializeWebSocket();
            term.focus();
        }
    });

    orchestratorButton.addEventListener('click', () => {
        if (isConnected && socket.readyState === WebSocket.OPEN) {
            const command = 'docker exec -it mildocdms-webserver-1 bash';
            socket.send(command);
            term.focus();
        }
    });

    clearButton.addEventListener('click', () => {
        term.clear();
        term.focus();
    });

    // Handle command form submission
    commandForm.addEventListener('submit', (e) => {
        e.preventDefault();
        if (!isConnected) {
            term.writeln('\x1b[1;31mPlease connect to terminal first.\x1b[0m');
            term.focus();
            return;
        }

        const command = commandInput.value;
        const options = Array.from(document.querySelectorAll(`#${command}_options input:checked`))
            .map(input => input.value)
            .join(' ');

        const fullCommand = `${command} ${options}`;
        socket.send(fullCommand);
        term.focus();
    });

    // Show/hide command options based on selection
    commandInput.addEventListener('input', function() {
        document.querySelectorAll('.options-container').forEach(container => {
            container.style.display = 'none';
        });

        const selectedOptionsDiv = document.getElementById(`${this.value}_options`);
        if (selectedOptionsDiv) {
            selectedOptionsDiv.style.display = 'block';
        }
    });

    // Initialize tooltips
    const tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'));
    tooltipTriggerList.map(function (tooltipTriggerEl) {
        return new bootstrap.Tooltip(tooltipTriggerEl);
    });
});
