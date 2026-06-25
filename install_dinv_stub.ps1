# Dogbox Investments — Windows Installer
# Downloads the latest release from GitHub and installs.
#
# One-liner (paste into PowerShell):
#   irm https://raw.githubusercontent.com/davidrobertinnes/dbox-releases/main/install_dinv_stub.ps1 | iex
#
# Or: right-click this file → Run with PowerShell

$ErrorActionPreference = "Stop"

$ZipUrl  = "https://github.com/davidrobertinnes/dbox-releases/raw/main/dinv.zip"
$Dest    = Join-Path $env:USERPROFILE "DogboxInvestments"
$TmpZip  = Join-Path $env:TEMP "dinv_install.zip"

Write-Host ""
Write-Host "  ============================================================"
Write-Host "   Dogbox Investments - Installer"
Write-Host "  ============================================================"
Write-Host ""

# ── Check Python ──────────────────────────────────────────────────────────────
Write-Host "  Checking Python..."

# Find a real Python — skip the Windows Store stub (WindowsApps), which is an
# app execution alias that silently does nothing when called from a shortcut.
$PythonExe = $null
$candidates = @(
    "$env:LOCALAPPDATA\Programs\Python\Python314\python.exe",
    "$env:LOCALAPPDATA\Programs\Python\Python313\python.exe",
    "$env:LOCALAPPDATA\Programs\Python\Python312\python.exe",
    "$env:LOCALAPPDATA\Programs\Python\Python311\python.exe",
    "$env:LOCALAPPDATA\Programs\Python\Python310\python.exe",
    "C:\Python314\python.exe",
    "C:\Python313\python.exe",
    "C:\Python312\python.exe",
    "C:\Python311\python.exe",
    "C:\Python310\python.exe",
    "$env:ProgramFiles\Python314\python.exe",
    "$env:ProgramFiles\Python313\python.exe",
    "$env:ProgramFiles\Python312\python.exe",
    "$env:ProgramFiles\Python311\python.exe",
    "$env:ProgramFiles\Python310\python.exe"
)
foreach ($c in $candidates) {
    if (Test-Path $c) { $PythonExe = $c; break }
}
# Fall back to whatever 'python' resolves to, but skip WindowsApps stub
if (-not $PythonExe) {
    $resolved = (Get-Command python -ErrorAction SilentlyContinue).Source
    if ($resolved -and $resolved -notlike '*WindowsApps*') { $PythonExe = $resolved }
}
if (-not $PythonExe) {
    Write-Host "  [ERROR ] Python 3.10+ not found."
    Write-Host "           Download from https://python.org — tick 'Add python.exe to PATH'."
    Read-Host "  Press Enter to exit"
    exit 1
}
$pyVer = & "$PythonExe" --version 2>&1
Write-Host "  [  OK  ] $pyVer (at $PythonExe)"

# Use pythonw.exe from the same directory — silent launch (no console window),
# guaranteed same Python that pip installs to.
$PythonW = Join-Path (Split-Path $PythonExe) 'pythonw.exe'
if (-not (Test-Path $PythonW)) { $PythonW = $PythonExe }

# ── Download ──────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "  Downloading Dogbox Investments..."
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
try {
    Expand-Archive -Path $TmpZip -DestinationPath $Dest -Force
} catch {
    Write-Host "  [ERROR ] Extraction failed: $_"
    Read-Host "  Press Enter to exit"
    exit 1
}
Remove-Item $TmpZip -Force -ErrorAction SilentlyContinue
Write-Host "  [  OK  ] Extracted."

# ── Install Python dependencies ───────────────────────────────────────────────
Write-Host ""
Write-Host "  Installing Python packages (flask, reportlab)..."
try {
    & "$PythonExe" -m pip install --quiet --upgrade flask reportlab
    Write-Host "  [  OK  ] Packages installed."
} catch {
    Write-Host "  [ WARN ] pip install encountered an issue: $_"
    Write-Host "           You can install manually: python -m pip install flask reportlab"
}

# ── Create launcher ───────────────────────────────────────────────────────────
$LauncherBat = Join-Path $Dest "DogboxInvestments.bat"
@"
@echo off
cd /d "%~dp0"
python web_server.py
"@ | Set-Content $LauncherBat -Encoding ASCII

# Desktop shortcut — points directly to pythonw.exe so no cmd window appears
try {
    $Desktop   = [System.Environment]::GetFolderPath('Desktop')
    $WshShell  = New-Object -ComObject WScript.Shell
    $Shortcut  = $WshShell.CreateShortcut("$Desktop\Dogbox Investments.lnk")
    $Shortcut.TargetPath       = $PythonW
    $Shortcut.Arguments        = "`"$(Join-Path $Dest 'web_server.py')`""
    $Shortcut.WorkingDirectory = $Dest
    $Shortcut.Description      = "Dogbox Investments"
    $Shortcut.Save()
    Write-Host "  [  OK  ] Desktop shortcut created."
} catch {
    Write-Host "  [ WARN ] Could not create desktop shortcut: $_"
}

# ── Done ──────────────────────────────────────────────────────────────────────
Write-Host ""
Write-Host "  ============================================================"
Write-Host "   Installation complete!"
Write-Host ""
Write-Host "   Launch:  double-click 'Dogbox Investments' on your Desktop"
Write-Host "       or:  run DogboxInvestments.bat in $Dest"
Write-Host "  ============================================================"
Write-Host ""
Read-Host "  Press Enter to close"
