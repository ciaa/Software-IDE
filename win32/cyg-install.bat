@ECHO OFF
REM -- Automates cygwin installation
REM -- Change to the directory of the executing batch file
CD %~dp0

if exist cygwin\bin\cygwin1.dll goto out

REM -- Configure our paths
SET LOCALDIR=%CD%
SET ROOTDIR=%LOCALDIR%\cygwin
SET LOCALREPO=%CD%\local-repo

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
REM                                   software packages during execution.
SET INSTALLOPTS=-q -d -L -B -X -N -A -r

REM -- These are the packages we will install (in addition to the default packages)
SET PACKAGES=mintty,wget,ctags,diffutils,git,git-completion,gcc-g++,make,ruby,perl

REM -- Do it!
ECHO *** INSTALLING Cygwin
start /wait setup-x86 %INSTALLOPTS% -l "%LOCALREPO%" -R "%ROOTDIR%" -P %PACKAGES%
copy %LOCALDIR%\Cygwin.bat.in %ROOTDIR%
copy %LOCALDIR%\arm-none-eabi.sh %ROOTDIR%\etc\profile.d
copy %LOCALDIR%\eclipse.sh %ROOTDIR%\etc\profile.d
:out
