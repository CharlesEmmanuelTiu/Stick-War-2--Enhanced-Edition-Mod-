@echo off
title Stick War 2 - LAN Co-op

:: Grant Flash Player trusted access for local socket connections
set TRUST_DIR=%APPDATA%\Macromedia\Flash Player\#Security\FlashPlayerTrust
if not exist "%TRUST_DIR%" mkdir "%TRUST_DIR%" 2>nul
echo %~dp0> "%TRUST_DIR%\stickwar_mod.cfg" 2>nul

echo Starting LAN Relay Server...
start /B /MIN node "%~dp0lan-relay.js"

:: Wait for relay to be ready (port 9333 listening)
:wait_relay
timeout /T 1 /NOBREAK >nul
netstat -an | find "0.0.0.0:9333" >nul 2>nul
if errorlevel 1 goto wait_relay

echo Starting Game...
start /WAIT "" "%~dp0flashplayer_32_sa.exe" "%~dp0Stick_War_2_Upgrades.swf"
echo Waiting for game to close...
taskkill /F /IM node.exe 2>nul
echo Done.
pause
