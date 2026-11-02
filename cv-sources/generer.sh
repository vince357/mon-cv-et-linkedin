#!/bin/bash
# Génère les deux PDF balisés du CV à partir de cv.html, avec Google Chrome (sans Node) :
#   ../CV - Vincent de la Fonchais.pdf          (une page)
#   ../CV - Vincent de la Fonchais - 2 pages.pdf (version aérée)
# Prérequis : Google Chrome, et pikepdf dans .venv (python3 -m venv .venv && .venv/bin/pip install pikepdf)
# Usage : ./generer.sh
set -euo pipefail
cd "$(dirname "$0")"

CHROME="${CHROME:-/Applications/Google Chrome.app/Contents/MacOS/Google Chrome}"
PYTHON=".venv/bin/python"
[ -x "$PYTHON" ] || PYTHON="python3"
[ -x "$CHROME" ] || { echo "Chrome introuvable : $CHROME" >&2; exit 1; }

URL="file://$("$PYTHON" -c 'import os, urllib.parse; print(urllib.parse.quote(os.path.abspath("cv.html")))')"
TMP="$(mktemp -d)"
trap 'rm -rf "$TMP"' EXIT

pdf() { # $1 = suffixe d'URL, $2 = fichier de sortie
  "$CHROME" --headless --disable-gpu --no-pdf-header-footer --generate-pdf-document-outline \
    --virtual-time-budget=3000 --print-to-pdf="$2" "$URL$1" 2>/dev/null
}

pdf ""             "$TMP/1page.pdf"
pdf "?deux-pages"  "$TMP/2pages.pdf"

"$PYTHON" post.py "$TMP/1page.pdf"  "../CV - Vincent de la Fonchais.pdf"
"$PYTHON" post.py "$TMP/2pages.pdf" "../CV - Vincent de la Fonchais - 2 pages.pdf"

"$PYTHON" - <<'PY'
import pikepdf
for f, attendu in [("../CV - Vincent de la Fonchais.pdf", 1), ("../CV - Vincent de la Fonchais - 2 pages.pdf", 2)]:
    n = len(pikepdf.open(f).pages)
    print(("OK " if n == attendu else "ATTENTION ") + f"{f[3:]} : {n} page(s), {attendu} attendue(s)")
PY
