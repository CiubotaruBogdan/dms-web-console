FROM docker:27-cli AS docker
FROM python:3.10-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update \
    && apt-get install -y --no-install-recommends bash \
    && rm -rf /var/lib/apt/lists/*

# Copy Docker CLI and compose plugin
COPY --from=docker /usr/local/bin/docker /usr/local/bin/docker
COPY --from=docker /usr/local/lib/docker/cli-plugins /usr/local/lib/docker/cli-plugins

# Install Python dependencies
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Copy application source
COPY aplicatie_web/ ./aplicatie_web/

EXPOSE 5000

CMD ["python", "aplicatie_web/app.py"]
