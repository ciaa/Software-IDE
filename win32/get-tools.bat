set WGETURL=http://users.ugent.be/~bpuype/cgi-bin/fetch.pl?dl=wget/wget.exe
if not exist wget.exe (
	echo "Obtaning wget"
	powershell -command "& { (New-Object Net.WebClient).DownloadFile('%WGETURL%', 'wget.exe') }"
)
set PATH=.;%PATH%
if not exist tar.exe (
	wget http://www2.cs.uidaho.edu/~jeffery/win32/tar.exe
)
if not exist gunzip.exe (
	wget http://www2.cs.uidaho.edu/~jeffery/win32/gunzip.exe
)
if not exist unzip.exe (
	wget http://stahlworks.com/dev/unzip.exe
)
