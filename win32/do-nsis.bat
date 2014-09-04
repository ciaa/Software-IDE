@echo off
set SCRIPT=Inst_MUI_CIAA_Firmware_IDE_v1'0'0.nsi

cd %~dp0
set BASE=%CD%
echo Executing NSIS...
%BASE%\nsis\makensis.exe /V4 /Onsis-build-process.log %SCRIPT%
pause