#!/usr/bin/env bash
# Dogbox Investments — macOS / Linux Installer
# Downloads the latest release from GitHub and installs.
#
# macOS one-liner (paste into Terminal):
#   curl -fsSL https://raw.githubusercontent.com/davidrobertinnes/dbox-releases/main/install_dinv_stub.sh | bash
#
# Linux one-liner:
#   curl -fsSL https://raw.githubusercontent.com/davidrobertinnes/dbox-releases/main/install_dinv_stub.sh | bash
#
# Or: chmod +x install_dinv_stub.sh && ./install_dinv_stub.sh

ZIP_URL="https://github.com/davidrobertinnes/dbox-releases/raw/main/dinv.zip"
DEST="$HOME/DogboxInvestments"
TMP_ZIP="/tmp/dinv_install_$$.zip"

BOLD='\033[1m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
RESET='\033[0m'

echo ""
echo -e "${BOLD}  ============================================================${RESET}"
echo -e "${BOLD}   Dogbox Investments - Installer${RESET}"
echo -e "${BOLD}  ============================================================${RESET}"
echo ""

# ── Check Python ──────────────────────────────────────────────────────────────
echo "  Checking Python..."
if command -v python3 &>/dev/null; then
    PY="python3"
elif command -v python &>/dev/null && python --version 2>&1 | grep -q "Python 3"; then
    PY="python"
else
    echo -e "${RED}  [ERROR ]${RESET} Python 3 not found."
    echo "           macOS: install via https://python.org or 'brew install python3'"
    echo "           Linux: sudo apt install python3  (or equivalent)"
    exit 1
fi
echo -e "${GREEN}  [  OK  ]${RESET} $($PY --version)"

# ── Check unzip ───────────────────────────────────────────────────────────────
if ! command -v unzip &>/dev/null; then
    echo -e "${RED}  [ERROR ]${RESET} unzip not installed."
    echo "           Ubuntu/Debian: sudo apt install unzip"
    exit 1
fi

# ── Download ──────────────────────────────────────────────────────────────────
echo ""
echo "  Downloading Dogbox Investments..."
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
    echo -e "${RED}  [ERROR ]${RESET} Neither curl nor wget is available."
    exit 1
fi
echo -e "${GREEN}  [  OK  ]${RESET} Downloaded."

# ── Extract ───────────────────────────────────────────────────────────────────
echo "  Installing to $DEST ..."
if [ -d "$DEST" ]; then
    echo -e "${YELLOW}  [ WARN ]${RESET} $DEST already exists — files will be updated."
    rm -rf "$DEST"
fi

mkdir -p "$DEST"
if ! unzip -q -o "$TMP_ZIP" -d "$DEST"; then
    echo -e "${RED}  [ERROR ]${RESET} Extraction failed."
    rm -f "$TMP_ZIP"
    exit 1
fi
rm -f "$TMP_ZIP"
echo -e "${GREEN}  [  OK  ]${RESET} Extracted."

# ── Install Python dependencies ───────────────────────────────────────────────
echo ""
echo "  Installing Python packages (flask, reportlab)..."
if ! $PY -m pip install --quiet --upgrade flask reportlab 2>/dev/null; then
    # Try with --user if system pip is restricted
    $PY -m pip install --quiet --upgrade --user flask reportlab 2>/dev/null || \
        echo -e "${YELLOW}  [ WARN ]${RESET} pip install had issues. Try: $PY -m pip install flask reportlab"
fi
echo -e "${GREEN}  [  OK  ]${RESET} Packages installed."

# ── Create launcher ───────────────────────────────────────────────────────────
LAUNCHER="$DEST/run.sh"
cat > "$LAUNCHER" << EOF
#!/usr/bin/env bash
cd "\$(dirname "\$0")"
$PY web_server.py
EOF
chmod +x "$LAUNCHER"

OS="$(uname -s)"

if [ "$OS" = "Darwin" ]; then
    # macOS: .command file is double-clickable in Finder
    MACOS_LAUNCHER="$DEST/DogboxInvestments.command"
    cat > "$MACOS_LAUNCHER" << EOF
#!/usr/bin/env bash
cd "\$(dirname "\$0")"
$PY web_server.py
EOF
    chmod +x "$MACOS_LAUNCHER"

    # Desktop alias
    DESKTOP_LINK="$HOME/Desktop/Dogbox Investments.command"
    cp "$MACOS_LAUNCHER" "$DESKTOP_LINK"
    chmod +x "$DESKTOP_LINK"
    echo -e "${GREEN}  [  OK  ]${RESET} Desktop shortcut created."
fi

# ── Done ──────────────────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}  ============================================================${RESET}"
echo -e "${BOLD}   Installation complete!${RESET}"
echo ""
if [ "$OS" = "Darwin" ]; then
    echo "   Launch:  double-click 'Dogbox Investments' on your Desktop"
    echo "       or:  open $DEST/DogboxInvestments.command"
else
    echo "   Launch:  bash $DEST/run.sh"
fi
echo -e "${BOLD}  ============================================================${RESET}"
echo ""
