@echo on
set BASE_PATH=.\cygwin\usr\local\eclipse\plugins\
set BASE_NAME=org.eclipse.platform_
set ECLIPSE_SPLASH_FOLDER=""

for /f "delims=" %%a in ('dir %BASE_PATH%%BASE_NAME%"*" /on /ad /b') do @set ECLIPSE_SPLASH_FOLDER=%%a

@echo %BASE_PATH%%ECLIPSE_SPLASH_FOLDER%

copy /y "./splash.bmp" "%BASE_PATH%%ECLIPSE_SPLASH_FOLDER%/splash.bmp"