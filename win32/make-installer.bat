@echo off
CD %~dp0
echo creating installer
nsis\makensis.exe /V1 Inst_MUI_CIAA_Firmware_IDE_v1'0'0.nsi
pause
