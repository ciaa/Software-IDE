set WGETURL=http://users.ugent.be/~bpuype/cgi-bin/fetch.pl?dl=wget/wget.exe
if not exist wget.exe (
	echo "Obtaning wget"
	powershell -command "& { (New-Object Net.WebClient).DownloadFile('%WGETURL%', 'wget.exe') }"
)