@echo off
CD %~dp0
rem Prereq
call get-tools.bat
rem call cyg-download.bat
rem call cyg-install.bat

rem PHP URL
set PHPURL=http://pci.imaglabs.org/php.exe

if not exist cygwin\bin\php.exe wget %PHPURL% -O cygwin/bin/php.exe
