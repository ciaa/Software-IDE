@echo off
call get-tools.bat

set LOCALFILE=openocd-0.8.0.7z
set OPENOCD_URL=http://www.freddiechopin.info/en/download/category/4-openocd?download=109%3Aopenocd-0.8.0

if not exist %LOCALFILE% (
	echo Downloading OpenOCD 'On Chip Debugger'...
	wget "%OPENOCD_URL%" -O %LOCALFILE%
)
echo Uncompress...
7za x %LOCALFILE%
move/Y .\openocd-0.8.0 openocd