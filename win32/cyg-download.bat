@ECHO OFF
CD %~dp0
set SETUPURL=http://cygwin.com/setup-x86.exe

if not exist setup-x86.exe (
	powershell -command "& { (New-Object Net.WebClient).DownloadFile('%SETUPURL%', 'setup-x86.exe') }"
	pause
)

REM -- Configure our paths
SET SITE=http://cygwin.mirrors.pair.com/
SET SITE_LOCALDIR=http%%3a%%2f%%2fcygwin.mirrors.pair.com%%2f
SET LOCALDIR=%CD%\tmp
SET ROOTDIR=%LOCALDIR%\work
SET REPODIR=%CD%\local-repo

REM Command Line Options:
REM -D --download                     Download from internet
REM -L --local-install                Install from local directory
REM -s --site                         Download site
REM -O --only-site                    Ignore all sites except for -s
REM -R --root                         Root installation directory
REM -x --remove-packages              Specify packages to uninstall
REM -c --remove-categories            Specify categories to uninstall
REM -P --packages                     Specify packages to install
REM -C --categories                   Specify entire categories to install
REM -p --proxy                        HTTP/FTP proxy (host:port)
REM -a --arch                         architecture to install (x86_64 or x86)
REM -q --quiet-mode                   Unattended setup mode
REM -M --package-manager              Semi-attended chooser-only mode
REM -B --no-admin                     Do not check for and enforce running as
REM                                   Administrator
REM -W --wait                         When elevating, wait for elevated child
REM                                   process
REM -h --help                         print help
REM -l --local-package-dir            Local package directory
REM -r --no-replaceonreboot           Disable replacing in-use files on next
REM                                   reboot.
REM -X --no-verify                    Don't verify setup.ini signatures
REM -n --no-shortcuts                 Disable creation of desktop and start menu
REM                                   shortcuts
REM -N --no-startmenu                 Disable creation of start menu shortcut
REM -d --no-desktop                   Disable creation of desktop shortcut
REM -K --pubkey                       URL of extra public key file (gpg format)
REM -S --sexpr-pubkey                 Extra public key in s-expr format
REM -u --untrusted-keys               Use untrusted keys from last-extrakeys
REM -U --keep-untrusted-keys          Use untrusted keys and retain all
REM -g --upgrade-also                 also upgrade installed packages
REM -o --delete-orphans               remove orphaned packages
REM -A --disable-buggy-antivirus      Disable known or suspected buggy anti virus
REM      software packages during execution.
SET INSTALLOPTS=-q -D -X -A -B

REM -- These are the packages we will install (in addition to the default packages)
SET PACKAGES=mintty,wget,ctags,diffutils,git,git-completion,gcc-g++,make,ruby,perl

REM -- Do it!
ECHO *** DOWNLOADING PACKAGES
start /WAIT setup-x86 %INSTALLOPTS% -s %SITE% -l "%LOCALDIR%" -P %PACKAGES% -R "%ROOTDIR%"

move/Y %LOCALDIR%\%SITE_LOCALDIR% %REPODIR%
rmdir/S/Q %LOCALDIR%
