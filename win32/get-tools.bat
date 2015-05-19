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
set WGETURL=http://users.ugent.be/~bpuype/cgi-bin/fetch.pl?dl=wget/wget.exe
if not exist %CD%\bin\wget.exe (
	echo "Obtaning wget"
	powershell -command "& { (New-Object Net.WebClient).DownloadFile('%WGETURL%', 'wget.exe') }"
)
set PATH=.;.\bin\;%PATH%
if not exist tar.exe (
	echo "Obtaning tar.exe ..."
	wget http://www2.cs.uidaho.edu/~jeffery/win32/tar.exe
)
if not exist gunzip.exe (
	echo "Obtaning gunzip.exe ..."
	wget http://www2.cs.uidaho.edu/~jeffery/win32/gunzip.exe
)
if not exist unzip.exe (
	echo "Obtaning unzip.exe ..."
	wget http://stahlworks.com/dev/unzip.exe
)
if not exist 7za.exe (
	echo "Obtaning 7za920.zip ..."
	wget http://ufpr.dl.sourceforge.net/project/sevenzip/7-Zip/9.20/7za920.zip
	echo "extracting 7za.exe ..."
	unzip 7za920.zip 7za.exe
)