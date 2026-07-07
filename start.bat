@echo off
cd /d "%~dp0"
start "" powershell -NoProfile -ExecutionPolicy Bypass -Command "Start-Sleep -Milliseconds 800; Start-Process 'http://localhost:3317'"
node server.js
pause
