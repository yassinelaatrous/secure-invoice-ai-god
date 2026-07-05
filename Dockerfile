# --- Stage 1 : Build du frontend React ---
FROM node:20-alpine AS frontend-build
WORKDIR /app/frontend
COPY frontend/package*.json ./
RUN npm ci
COPY frontend/ ./
RUN npm run build

# --- Stage 2 : Backend Python + fichiers frontend compilés ---
FROM python:3.11-slim

# Installation de Tesseract OCR pour l'extraction réelle
RUN apt-get update && \
    apt-get install -y --no-install-recommends tesseract-ocr tesseract-ocr-fra && \
    rm -rf /var/lib/apt/lists/*

WORKDIR /app

# Copie et installation des dépendances Python
COPY backend/requirements.txt ./requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Copie du code backend
COPY backend/ ./backend/

# Copie du frontend compilé (depuis le stage 1)
COPY --from=frontend-build /app/frontend/dist ./frontend/dist

# Création du répertoire d'uploads
RUN mkdir -p /app/backend/uploads

# Exposition du port FastAPI
EXPOSE 8000

# Démarrage du serveur
CMD ["python", "backend/main.py"]
