@echo off
call get-tools.bat

set LOCALFILE=FTDI.zip
set FTDI_INSTDIR=%CD%\FTDI\
set FTDI_URL=http://www.ftdichip.com/Drivers/CDM/CDM%%20v2.10.00%%20WHQL%%20Certified.zip

if not exist %LOCALFILE% (
	echo Downloading FTDI Drivers...
	wget %FTDI_URL% -O %LOCALFILE%
)
if not exist FTDI (
	echo Uncompress FTDI...
	unzip %LOCALFILE% -d %FTDI_INSTDIR%
)
echo FTDI downloaded!