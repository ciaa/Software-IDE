@echo off
CD %~dp0
set WGETURL=http://users.ugent.be/~bpuype/cgi-bin/fetch.pl?dl=wget/wget.exe
if not exist wget.exe (
	echo "Obtaning wget"
	powershell -command "& { (New-Object Net.WebClient).DownloadFile('%WGETURL%', 'wget.exe') }"
)
set PATH=.;%PATH%
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