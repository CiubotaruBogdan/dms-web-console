FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt ./
RUN pip install --no-cache-dir -r requirements.txt
COPY aplicatie_web /app/aplicatie_web
EXPOSE 5000
CMD ["python", "aplicatie_web/main.py"]
