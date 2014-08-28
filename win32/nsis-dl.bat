@echo off
call get-tools.bat

set NSISURL=http://ufpr.dl.sourceforge.net/project/nsis/NSIS%%202/2.46/nsis-2.46.zip

if not exist nsis-2.46.zip (
	echo Downloading Nullsoft Scriptable Install System...
	wget "%NSISURL%"
)
echo Uncompress...
unzip nsis-2.46.zip
move/Y .\nsis-2.46 nsis
