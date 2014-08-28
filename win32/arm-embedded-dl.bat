@echo off
CD %~dp0
call get-tools.bat

set ARMGCCURL=https://launchpad.net/gcc-arm-embedded/4.8/4.8-2014-q2-update/+download/gcc-arm-none-eabi-4_8-2014q2-20140609-win32.zip

if not exist arm-gcc-embedded.zip (
	echo Downloading arm gcc...
	wget --no-check-certificate  %ARMGCCURL% -O arm-gcc-embedded.zip
)
if not exist cygwin\usr\arm-none-eabi\bin\arm-none-eabi-gcc.exe (
	echo Uncompress...
	unzip arm-gcc-embedded.zip -d cygwin\usr\arm-none-eabi
)
