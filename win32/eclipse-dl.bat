set PATH=%CD%;%PATH%
set LOCALFILE=eclipse-cdt.zip
set LOCALDIR=eclipse-cdt
set LOCALJRE=jre.tar.gz
set URL=http://mirrors.ibiblio.org/pub/mirrors/eclipse/technology/epp/downloads/release/luna/R/eclipse-cpp-luna-R-win32.zip
set JREURL=http://download.oracle.com/otn-pub/java/jdk/8u20-b26/jre-8u20-windows-i586.tar.gz?AuthParam=1408745698_94829a63b0cfb90a6dbf8c3cfe4ad2ac
if not exist tar.exe (
	powershell -command "& { (New-Object Net.WebClient).DownloadFile('http://www2.cs.uidaho.edu/~jeffery/win32/tar.exe', 'tar.exe') }"
)
if not exist gunzip.exe (
	powershell -command "& { (New-Object Net.WebClient).DownloadFile('http://www2.cs.uidaho.edu/~jeffery/win32/gunzip.exe', 'gunzip.exe') }"
)
if not exist unzip.exe (
	powershell -command "& { (New-Object Net.WebClient).DownloadFile('http://stahlworks.com/dev/unzip.exe', 'unzip.exe') }"
)
if not exist %LOCALFILE% (
 	powershell -command "& { (New-Object Net.WebClient).DownloadFile('%URL%', '%LOCALFILE%') }"
)
if  not exist %LOCALJRE% (
 	powershell -command "& { (New-Object Net.WebClient).DownloadFile('%JREURL%', '%LOCALJRE%') }"
)
if not exist eclipse (
	unzip %LOCALFILE%
)
gunzip %LOCALJRE%
tar -x -f jre.tar
move jre1.8.0_20 eclipse

pause
