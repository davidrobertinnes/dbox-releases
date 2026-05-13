#!/usr/bin/env bash
# Dogbox Accounting — macOS / Linux Install Stub
# Downloads the latest release and runs the platform installer.
#
# macOS one-liner (paste into Terminal):
#   curl -fsSL https://raw.githubusercontent.com/davidrobertinnes/dbox-releases/main/install_stub.sh | bash
#
# Linux one-liner:
#   curl -fsSL https://raw.githubusercontent.com/davidrobertinnes/dbox-releases/main/install_stub.sh | bash
#
# Or: chmod +x install_stub.sh && ./install_stub.sh

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
echo -e "${BOLD}   Dogbox Accounting - Installer${RESET}"
echo -e "${BOLD}  ============================================================${RESET}"
echo ""

# ── Download ──────────────────────────────────────────────────────────────────
echo "  Downloading Dogbox Accounting..."

if command -v curl &>/dev/null; then
    if ! curl -fsSL "$ZIP_URL" -o "$TMP_ZIP"; then
        echo -e "${RED}  [ERROR ]${RESET} Download failed. Check your internet connection."
        exit 1
    fi
elif command -v wget &>/dev/null; then
    if ! wget -q "$ZIP_URL" -O "$TMP_ZIP"; then
        echo -e "${RED}  [ERROR ]${RESET} Download failed. Check your internet connection."
        exit 1
    fi
else
    echo -e "${RED}  [ERROR ]${RESET} Neither curl nor wget is installed."
    echo "           Install one (e.g. brew install curl) and try again."
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
    echo -e "${RED}  [ERROR ]${RESET} Extraction failed. Is unzip installed?"
    echo "           Ubuntu/Debian: sudo apt install unzip"
    rm -f "$TMP_ZIP"
    exit 1
fi

rm -f "$TMP_ZIP"
echo -e "${GREEN}  [  OK  ]${RESET} Extracted."
echo ""

# ── Hand off to platform installer ────────────────────────────────────────────
OS="$(uname -s)"

if [ "$OS" = "Darwin" ]; then
    INSTALLER="$DEST/macinstall.sh"
    chmod +x "$INSTALLER"
    exec "$INSTALLER"
else
    INSTALLER="$DEST/lininstall.sh"
    # Fix CRLF line endings (zip may have been built on Windows)
    sed -i 's/\r//' "$INSTALLER" 2>/dev/null || true
    chmod +x "$INSTALLER"
    exec "$INSTALLER"
fi
