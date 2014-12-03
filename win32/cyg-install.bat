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
@ECHO OFF
:: -- Automates cygwin installation
:: -- Change to the directory of the executing batch file
CD %~dp0

:: -- Configure our paths
SET LOCALDIR=%CD%
SET ROOTDIR=%LOCALDIR%\cygwin
SET LOCALREPO=%CD%\local-repo

if exist cygwin\bin\cygwin1.dll goto out

:: Command Line Options:
:: -D --download                     Download from internet
:: -L --local-install                Install from local directory
:: -s --site                         Download site
:: -O --only-site                    Ignore all sites except for -s
:: -R --root                         Root installation directory
:: -x --remove-packages              Specify packages to uninstall
:: -c --remove-categories            Specify categories to uninstall
:: -P --packages                     Specify packages to install
:: -C --categories                   Specify entire categories to install
:: -p --proxy                        HTTP/FTP proxy (host:port)
:: -a --arch                         architecture to install (x86_64 or x86)
:: -q --quiet-mode                   Unattended setup mode
:: -M --package-manager              Semi-attended chooser-only mode
:: -B --no-admin                     Do not check for and enforce running as
::                                   Administrator
:: -W --wait                         When elevating, wait for elevated child
::                                   process
:: -h --help                         print help
:: -l --local-package-dir            Local package directory
:: -r --no-replaceonreboot           Disable replacing in-use files on next
::                                   reboot.
:: -X --no-verify                    Don't verify setup.ini signatures
:: -n --no-shortcuts                 Disable creation of desktop and start menu
::                                   shortcuts
:: -N --no-startmenu                 Disable creation of start menu shortcut
:: -d --no-desktop                   Disable creation of desktop shortcut
:: -K --pubkey                       URL of extra public key file (gpg format)
:: -S --sexpr-pubkey                 Extra public key in s-expr format
:: -u --untrusted-keys               Use untrusted keys from last-extrakeys
:: -U --keep-untrusted-keys          Use untrusted keys and retain all
:: -g --upgrade-also                 also upgrade installed packages
:: -o --delete-orphans               remove orphaned packages
:: -A --disable-buggy-antivirus      Disable known or suspected buggy anti virus
::                                   software packages during execution.
SET INSTALLOPTS=-q -d -L -B -X -N -A -r

:: -- These are the packages we will install (in addition to the default packages)
call cyg-package.bat

:: -- Do it!
ECHO *** INSTALLING Cygwin
start /wait setup-x86 %INSTALLOPTS% -l "%LOCALREPO%" -R "%ROOTDIR%" -P %PACKAGES%
:out
copy/Y %LOCALDIR%\Cygwin.bat.in %ROOTDIR%\Cygwin.bat
copy/Y %LOCALDIR%\StartEclipseIDE.bat.in %ROOTDIR%\StartEclipseIDE.bat
copy/Y %LOCALDIR%\arm-none-eabi.sh %ROOTDIR%\etc\profile.d\arm-none-eabi.sh
copy/Y %LOCALDIR%\eclipse.sh %ROOTDIR%\etc\profile.d\eclipse.sh
copy/Y %LOCALDIR%\testbench.sh %ROOTDIR%\usr\local\bin\testbench.sh
