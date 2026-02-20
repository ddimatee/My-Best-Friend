@echo off
cd /d "%~dp0frontend"
flutter run -d chrome --web-port 7357 --web-browser-flag="--user-data-dir=C:/Users/Braya/AppData/Local/MBFChromeProfile"
