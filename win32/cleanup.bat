@echo off
CD %~dp0
echo Cleanup downloaded files
rmdir/S/Q local-repo
rmdir/S/Q work
rmdir/S/Q tmp
rmdir/S/Q cygwin
rmdir/S/Q eclipse
rmdir/S/Q nsis
rmdir/S/Q openocd
del/Q *.exe 
del/Q *.zip
del/Q *.tar.gz
del/Q *.7z
