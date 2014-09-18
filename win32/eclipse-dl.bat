::##############################################################################
::
:: Copyright 2014, ACSE & CADIEEL
::    ACSE   : http://www.sase.com.ar/asociacion-civil-sistemas-embebidos/ciaa/
::    CADIEEL: http://www.cadieel.org.ar
::
:: This file is part of CIAA Firmware.
::
:: Redistribution and use in source and binary forms, with or without
:: modification, are permitted provided that the following conditions are met:
::
:: 1. Redistributions of source code must retain the above copyright notice,
::    this list of conditions and the following disclaimer.
::
:: 2. Redistributions in binary form must reproduce the above copyright notice,
::    this list of conditions and the following disclaimer in the documentation
::    and/or other materials provided with the distribution.
::
:: 3. Neither the name of the copyright holder nor the names of its
::    contributors may be used to endorse or promote products derived from this
::    software without specific prior written permission.
::
:: THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
:: AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
:: IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
:: ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
:: LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
:: CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
:: SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
:: INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
:: CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
:: ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
:: POSSIBILITY OF SUCH DAMAGE.
::
::##############################################################################
@echo off
CD %~dp0
set PATH=%CD%;%PATH%
set LOCALFILE=eclipse-cdt.zip
set LOCALDIR=eclipse-cdt
set LOCALJRE=jre.tar.gz
set ECLIPSE_INSTDIR=%CD%\cygwin\usr\local\
set ECLIPSEPKGS=ilg.gnuarmeclipse.debug.gdbjtag.openocd,ilg.gnuarmeclipse.managedbuild.cross
set ECLIPSEREPOS= http://download.eclipse.org/releases/kepler,http://gnuarmeclipse.sourceforge.net/updates
set ECLPISEURL=http://mirrors.ibiblio.org/pub/mirrors/eclipse/technology/epp/downloads/release/luna/R/eclipse-cpp-luna-R-win32.zip
set JREURL=http://download.oracle.com/otn-pub/java/jdk/8u20-b26/jre-8u20-windows-i586.tar.gz
call get-tools.bat
if not exist %LOCALFILE% (
	echo Download eclipse
	wget %ECLPISEURL% -O %LOCALFILE%
)
if not exist %ECLIPSE_INSTDIR%\eclipse (
	echo Uncompress eclipse
	unzip %LOCALFILE% -d %ECLIPSE_INSTDIR%
)
if  not exist %LOCALJRE% (
	echo Download jre
	wget --no-check-certificate --no-cookies --header "Cookie: oraclelicense=accept-securebackup-cookie" %JREURL% -O %LOCALJRE%
)
if  not exist %ECLIPSE_INSTDIR%\eclipse\jre (
	echo Uncompress jre
	gunzip -c %LOCALJRE% > tmp.tar
	tar -x -f tmp.tar
	move jre1.8.0_20 %ECLIPSE_INSTDIR%\eclipse\jre
	del/Q tmp.tar
)
if not exist %ECLIPSE_INSTDIR%\eclipse\plugins\ilg.gnuarmeclipse.managedbuild.cross* (
	echo Install eclipse plugins
	%ECLIPSE_INSTDIR%\eclipse\eclipse -clean -purgeHistory -nosplash -consolelog -application org.eclipse.equinox.p2.director -repository %ECLIPSEREPOS% -installIU %ECLIPSEPKGS%
)
