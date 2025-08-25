FROM python:3.10-slim

WORKDIR /app

# Install system dependencies and Docker CLI
RUN apt-get update \
    && apt-get install -y --no-install-recommends bash docker.io \

    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt

# Copy application source
COPY aplicatie_web/ ./aplicatie_web/

EXPOSE 5000

CMD ["python", "aplicatie_web/app.py"]
