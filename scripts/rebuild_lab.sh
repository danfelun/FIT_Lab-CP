#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

if [ ! -f .env ]; then
  cp .env.example .env
  echo "[OK] .env creado a partir de .env.example"
fi

echo "[INFO] Eliminando contenedores y volumenes para forzar reimportacion..."
docker compose down -v

echo "[INFO] Reconstruyendo laboratorio..."
docker compose up -d --build

echo "[INFO] Estado actual:"
docker compose ps

echo ""
echo "[INFO] URLs:"
echo "  Joomla/FIT:        http://localhost:8080"
echo "  Portal Academico:  http://localhost:8081"
echo "  phpMyAdmin:        http://localhost:8082"
