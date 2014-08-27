set PATH=%CD%;%PATH%
set LOCALFILE=eclipse-cdt.zip
set LOCALDIR=eclipse-cdt
set LOCALJRE=jre.tar.gz
set ECLIPSEPKGS=ilg.gnuarmeclipse.debug.gdbjtag.openocd,ilg.gnuarmeclipse.managedbuild.cross
set ECLIPSEREPOS= http://download.eclipse.org/releases/kepler,http://gnuarmeclipse.sourceforge.net/updates
set ECLPISEURL=http://mirrors.ibiblio.org/pub/mirrors/eclipse/technology/epp/downloads/release/luna/R/eclipse-cpp-luna-R-win32.zip
set JREURL=http://download.oracle.com/otn-pub/java/jdk/8u20-b26/jre-8u20-windows-i586.tar.gz
call get-tools.bat
if not exist %LOCALFILE% (
	wget %ECLPISEURL% -O %LOCALFILE%
)
if  not exist %LOCALJRE% (
	wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" %JREURL% -O %LOCALJRE%
)
if not exist eclipse (
	unzip %LOCALFILE%
)
gunzip %LOCALJRE%
tar -x -f jre.tar
move jre1.8.0_20 eclipse
cd eclipse
.\eclipse -clean -purgeHistory -nosplash -consolelog -application org.eclipse.equinox.p2.director -repository %ECLIPSEREPOS% -installIU %ECLIPSEPKGS%
cd ..
