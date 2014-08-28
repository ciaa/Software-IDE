@echo off
CD %~dp0
set PATH=%CD%;%PATH%
set LOCALFILE=eclipse-cdt.zip
set LOCALDIR=eclipse-cdt
set LOCALJRE=jre.tar.gz
set FINALECLIPSE_DST=%CD%\cygwin\usr\local\eclipse
set ECLIPSEPKGS=ilg.gnuarmeclipse.debug.gdbjtag.openocd,ilg.gnuarmeclipse.managedbuild.cross
set ECLIPSEREPOS= http://download.eclipse.org/releases/kepler,http://gnuarmeclipse.sourceforge.net/updates
set ECLPISEURL=http://mirrors.ibiblio.org/pub/mirrors/eclipse/technology/epp/downloads/release/luna/R/eclipse-cpp-luna-R-win32.zip
set JREURL=http://download.oracle.com/otn-pub/java/jdk/8u20-b26/jre-8u20-windows-i586.tar.gz
call get-tools.bat
if not exist %LOCALFILE% (
	echo Download eclipse
	wget %ECLPISEURL% -O %LOCALFILE%
)
if not exist eclipse (
	echo Uncompress eclipse
	unzip %LOCALFILE%
)
if  not exist %LOCALJRE% (
	echo Download jre
	wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" %JREURL% -O %LOCALJRE%
)
if  not exist eclipse\jre (
	echo Uncompress jre
	gunzip -c %LOCALJRE% > tmp.tar
	tar -x -f tmp.tar
	move jre1.8.0_20 eclipse\jre
	del/Q tmp.tar
)
if not exist eclipse\plugins\ilg.gnuarmeclipse.managedbuild.cross* (
	echo Install eclipse plugins
	cd eclipse
	$dp0\eclipse -clean -purgeHistory -nosplash -consolelog -application org.eclipse.equinox.p2.director -repository %ECLIPSEREPOS% -installIU %ECLIPSEPKGS%
	cd ..
)
if not exist %FINALECLIPSE_DST% move eclipse %FINALECLIPSE_DST%
