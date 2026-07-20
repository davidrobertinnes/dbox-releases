# Dogbox Mailman — Windows Install Stub
# Downloads the latest release and runs the Windows installer.
#
# One-liner (paste into PowerShell):
#   irm https://raw.githubusercontent.com/davidrobertinnes/dbox-releases/main/install_mailman_stub.ps1 | iex
#
# Or: right-click this file → Run with PowerShell

$ErrorActionPreference = "Stop"

$ZipUrl = "https://github.com/davidrobertinnes/dbox-releases/raw/main/postbox.zip"
$Dest   = Join-Path $env:USERPROFILE "DogboxMailman"
$TmpZip = Join-Path $env:TEMP "mailman_install.zip"

Write-Host ""
Write-Host "  ============================================================"
Write-Host "   Dogbox Mailman - AI Email Client - Installer"
Write-Host "  ============================================================"
Write-Host ""

# ── Download ──────────────────────────────────────────────────────────────────
Write-Host "  Downloading Dogbox Mailman..."
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
Write-Host "  Extracting to $Dest ..."
if (Test-Path $Dest) {
    Write-Host "  [ WARN ] $Dest already exists - files will be updated."
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
Write-Host ""

# ── Hand off to platform installer ────────────────────────────────────────────
$Installer = Join-Path $Dest "wininstall.bat"
if (Test-Path $Installer) {
    Write-Host "  Launching installer..."
    Start-Process -FilePath "cmd.exe" `
        -ArgumentList "/c `"$Installer`"" `
        -WorkingDirectory $Dest `
        -Wait
} else {
    Write-Host "  [ WARN ] wininstall.bat not found in $Dest"
    Write-Host "           Open the DogboxMailman folder and run wininstall.bat manually."
    Read-Host "  Press Enter to exit"
}
