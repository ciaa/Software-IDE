@echo off
echo Cleanup downloaded files
rmdir/S/Q local-repo
rmdir/S/Q work
rmdir/S/Q tmp
rmdir/S/Q gcc-arm
rmdir/S/Q eclipse
del/Q *.exe 
del/Q *.zip
del/Q *.tar.gz
del/Q *.7z
pause