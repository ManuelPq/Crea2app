#!/usr/bin/env bash
# Sube los cambios de Voley Score / Crea2app a GitHub (ManuelPq/Crea2app).
# Uso:  bash tools/sync_github.sh "mensaje del commit"
# Si no se pasa mensaje, se usa uno por defecto con la fecha.

set -e
cd "$(dirname "$0")/.."

MSG="${1:-Actualizacion $(date '+%Y-%m-%d %H:%M')}"

echo "==> Comprobando cambios..."
git add -A

if git diff --cached --quiet; then
  echo "==> No hay cambios que subir."
else
  git commit -m "$MSG"
fi

echo "==> Subiendo a GitHub (origin/main)..."
git push origin main

echo "==> Hecho. Repo: https://github.com/ManuelPq/Crea2app"
