@echo off
CD %~dp0
call get-tools.bat
set PHPURL=http://pci.imaglabs.org/php.exe
if not exist cygwin\bin\php.exe wget %PHPURL% -O cygwin/bin/php.exe
