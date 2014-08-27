@echo off
CD %~dp0
echo Download prerequisites to create installer
call get-tools.bat
call cyg-download.bat
call cyg-install.bat
call eclipse-dl.bat
call arm-embedded-dl.bat
pause
