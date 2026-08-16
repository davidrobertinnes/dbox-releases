#!/usr/bin/env bash
# Dogbox Accounting — macOS Installer
# Double-click this file to install.

ZIP_URL="https://github.com/davidrobertinnes/dbox-releases/raw/main/dbox.zip"
DEST="$HOME/Dogbox"
TMP_ZIP="/tmp/dbox_install_$$.zip"

BOLD='\033[1m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
RESET='\033[0m'

echo ""
echo -e "${BOLD}  ============================================================${RESET}"
echo -e "${BOLD}   Dogbox Accounting - macOS Installer${RESET}"
echo -e "${BOLD}  ============================================================${RESET}"
echo ""

# ── Download ──────────────────────────────────────────────────────────────────
echo "  Downloading Dogbox Accounting..."

if ! curl -fsSL "$ZIP_URL" -o "$TMP_ZIP"; then
    echo -e "${RED}  [ERROR ]${RESET} Download failed. Check your internet connection."
    read -rp "  Press Enter to close..."
    exit 1
fi

echo -e "${GREEN}  [  OK  ]${RESET} Downloaded."

# ── Extract ───────────────────────────────────────────────────────────────────
echo "  Extracting to $DEST ..."

if [ -d "$DEST" ]; then
    echo -e "${YELLOW}  [ WARN ]${RESET} $DEST already exists — files will be updated."
fi

mkdir -p "$DEST"

if ! unzip -q -o "$TMP_ZIP" -d "$DEST"; then
    echo -e "${RED}  [ERROR ]${RESET} Extraction failed."
    rm -f "$TMP_ZIP"
    read -rp "  Press Enter to close..."
    exit 1
fi

rm -f "$TMP_ZIP"
echo -e "${GREEN}  [  OK  ]${RESET} Extracted."
echo ""

# ── Hand off to macOS installer ───────────────────────────────────────────────
INSTALLER="$DEST/macinstall.sh"
# Strip Windows CRLF line endings — zip was built on Windows so scripts may have \r
sed -i '' 's/\r//' "$INSTALLER" 2>/dev/null || true
chmod +x "$INSTALLER"
exec "$INSTALLER"
