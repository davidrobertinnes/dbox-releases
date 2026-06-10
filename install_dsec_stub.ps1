# Dogbox Securities — Windows Installer
# Downloads the latest release from GitHub and installs.
#
# One-liner (paste into PowerShell):
#   irm https://raw.githubusercontent.com/davidrobertinnes/dbox-releases/main/install_dsec_stub.ps1 | iex
#
# Or: right-click this file → Run with PowerShell

$ErrorActionPreference = "Stop"

$ZipUrl  = "https://github.com/davidrobertinnes/sharetrack/archive/refs/heads/main.zip"
$Dest    = Join-Path $env:USERPROFILE "DogboxSecurities"
$TmpZip  = Join-Path $env:TEMP "dsec_install.zip"
$TmpDir  = Join-Path $env:TEMP "dsec_tmp"

Write-Host ""
Write-Host "  ============================================================"
Write-Host "   Dogbox Securities - Installer"
Write-Host "  ============================================================"
Write-Host ""

# ── Check Python ──────────────────────────────────────────────────────────────
Write-Host "  Checking Python..."
try {
    $pyVer = & python --version 2>&1
    Write-Host "  [  OK  ] $pyVer"
} catch {
    Write-Host "  [ERROR ] Python not found."
    Write-Host "           Download Python 3.10+ from https://python.org and re-run."
    Read-Host "  Press Enter to exit"
    exit 1
}

# ── Download ──────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "  Downloading Dogbox Securities..."
try {
    Invoke-WebRequest -Uri $ZipUrl -OutFile $TmpZip -UseBasicParsing
} catch {
    Write-Host "  [ERROR ] Download failed: $_"
    Write-Host "           Check your internet connection and try again."
    Read-Host "  Press Enter to exit"
    exit 1
}
Write-Host "  [  OK  ] Downloaded."

# ── Extract ───────────────────────────────────────────────────────────────────
Write-Host "  Installing to $Dest ..."
if (Test-Path $Dest) {
    Write-Host "  [ WARN ] $Dest already exists — files will be updated."
    Remove-Item $Dest -Recurse -Force -ErrorAction SilentlyContinue
}
if (Test-Path $TmpDir) { Remove-Item $TmpDir -Recurse -Force }

try {
    Expand-Archive -Path $TmpZip -DestinationPath $TmpDir -Force
} catch {
    Write-Host "  [ERROR ] Extraction failed: $_"
    Read-Host "  Press Enter to exit"
    exit 1
}
Remove-Item $TmpZip -Force -ErrorAction SilentlyContinue

# GitHub archive unpacks as sharetrack-main/
$Inner = Join-Path $TmpDir "sharetrack-main"
if (-not (Test-Path $Inner)) {
    # Fall back to first subfolder if naming differs
    $Inner = (Get-ChildItem $TmpDir -Directory | Select-Object -First 1).FullName
}
Move-Item $Inner $Dest
Remove-Item $TmpDir -Recurse -Force -ErrorAction SilentlyContinue
Write-Host "  [  OK  ] Extracted."

# ── Install Python dependencies ───────────────────────────────────────────────
Write-Host ""
Write-Host "  Installing Python packages (flask, reportlab)..."
try {
    & python -m pip install --quiet --upgrade flask reportlab
    Write-Host "  [  OK  ] Packages installed."
} catch {
    Write-Host "  [ WARN ] pip install encountered an issue: $_"
    Write-Host "           You can install manually: python -m pip install flask reportlab"
}

# ── Create launcher ───────────────────────────────────────────────────────────
$LauncherBat = Join-Path $Dest "DogboxSecurities.bat"
@"
@echo off
cd /d "%~dp0"
start "" pythonw web_server.py
"@ | Set-Content $LauncherBat -Encoding ASCII

# Desktop shortcut
try {
    $WshShell  = New-Object -ComObject WScript.Shell
    $Shortcut  = $WshShell.CreateShortcut("$env:USERPROFILE\Desktop\Dogbox Securities.lnk")
    $Shortcut.TargetPath       = $LauncherBat
    $Shortcut.WorkingDirectory = $Dest
    $Shortcut.Description      = "Dogbox Securities — Share portfolio CGT tracking"
    $Shortcut.Save()
    Write-Host "  [  OK  ] Desktop shortcut created."
} catch {
    Write-Host "  [ WARN ] Could not create desktop shortcut."
}

# ── Done ──────────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "  ============================================================"
Write-Host "   Installation complete!"
Write-Host ""
Write-Host "   Launch:  double-click 'Dogbox Securities' on your Desktop"
Write-Host "       or:  run DogboxSecurities.bat in $Dest"
Write-Host "  ============================================================"
Write-Host ""
Read-Host "  Press Enter to close"
