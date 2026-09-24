@echo off
setlocal
title Dogbox Accounting - Installer

REM Downloads the latest release and runs its setup (wininstall.bat).
REM Uses only curl and tar, which are built into Windows 10 and 11. Avoids
REM PowerShell "download and run" (irm | iex), which Microsoft Defender
REM blocks as Trojan:Win32/Commando.

set "DEST=%USERPROFILE%\Dogbox"
set "ZIP=%TEMP%\dbox_install.zip"

echo.
echo  Downloading Dogbox Accounting...
curl.exe -fL --retry 2 -o "%ZIP%" "https://github.com/davidrobertinnes/dbox-releases/raw/main/dbox.zip"
if errorlevel 1 (
    echo.
    echo  [ERROR ] Download failed. Check your internet connection and try again.
    pause
    exit /b 1
)

echo  Extracting to %DEST% ...
if not exist "%DEST%" mkdir "%DEST%"
tar -xf "%ZIP%" -C "%DEST%"
if errorlevel 1 (
    echo.
    echo  [ERROR ] Extraction failed. Close Dogbox Accounting if it is open, then try again.
    pause
    exit /b 1
)
del /f /q "%ZIP%" >nul 2>&1

if not exist "%DEST%\wininstall.bat" (
    echo  [ERROR ] Setup file missing - open %DEST% and run wininstall.bat.
    pause
    exit /b 1
)
call "%DEST%\wininstall.bat"
