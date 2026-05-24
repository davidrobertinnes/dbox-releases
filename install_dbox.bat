@echo off
echo Downloading Dogbox Accounting...
powershell -ExecutionPolicy Bypass -Command "irm https://raw.githubusercontent.com/davidrobertinnes/dbox-releases/main/install_stub.ps1 | iex"
pause
