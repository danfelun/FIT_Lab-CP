#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

if [ ! -f .env ]; then
  echo "[ERROR] Falta el archivo .env"
  exit 1
fi

set -a
. ./.env
set +a

mkdir -p mysql/init

echo "[INFO] Exportando cms..."
docker exec lab-db sh -lc "mysqldump -uroot -p$MYSQL_ROOT_PASSWORD --databases cms --routines --events --triggers --single-transaction" > mysql/init/03_cms.sql

echo "[INFO] Exportando unad..."
docker exec lab-db sh -lc "mysqldump -uroot -p$MYSQL_ROOT_PASSWORD --databases unad --routines --events --triggers --single-transaction" > mysql/init/02_unad.sql

echo "[OK] Dumps guardados en mysql/init/"
