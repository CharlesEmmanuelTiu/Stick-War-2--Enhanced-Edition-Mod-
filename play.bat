@echo off
title Stick War 2 - LAN Co-op

:: Grant Flash Player trusted access for local socket connections
set TRUST_DIR=%APPDATA%\Macromedia\Flash Player\#Security\FlashPlayerTrust
if not exist "%TRUST_DIR%" mkdir "%TRUST_DIR%" 2>nul
echo %~dp0> "%TRUST_DIR%\stickwar_mod.cfg" 2>nul

:: Check for Node.js
set NODE_CMD=node
where %NODE_CMD% >nul 2>nul
if %errorlevel% equ 0 goto run_relay
if exist "%~dp0node\node.exe" set NODE_CMD="%~dp0node\node.exe" && goto run_relay
if exist "%~dp0node.exe" set NODE_CMD="%~dp0node.exe" && goto run_relay

echo Node.js is not installed or not found in PATH.
echo The LAN relay requires Node.js to run.
echo.
set /P INSTALL_NODE=Download portable node.exe to "node\node.exe"? (y/n):
if /I "%INSTALL_NODE%" neq "y" goto no_node

echo Downloading node.exe from nodejs.org (approx 35-40 MB)...
powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri 'https://nodejs.org/dist/latest/win-x64/node.exe' -OutFile '%~dp0node\node.exe'}"
if %errorlevel% neq 0 (
    echo Download failed. Try manual download to "node\node.exe"
    goto no_node
)
set NODE_CMD="%~dp0node\node.exe"
goto run_relay

:no_node
echo.
echo Co-op LAN requires Node.js. Download manually to:
echo   %~dp0node\node.exe
echo Or install from: https://nodejs.org
echo.
pause
exit /b 1

:run_relay
taskkill /F /IM node.exe 2>nul
echo Starting LAN Relay Server...
start "" /B /MIN %NODE_CMD% "%~dp0lan-relay.js"

:: Wait for relay to be ready (port 9333 listening)
:wait_relay
timeout /T 1 /NOBREAK >nul
netstat -an | find "9333" >nul 2>nul
if errorlevel 1 goto wait_relay

echo Starting Game...
start /WAIT "" "%~dp0flashplayer_32_sa.exe" "%~dp0Stick_War_2_Upgrades.swf"
echo Waiting for game to close...
taskkill /F /IM node.exe 2>nul
echo Done.
pause
