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
CD %~dp0
set SETUPURL=http://cygwin.com/setup-x86.exe
call get-tools.bat
if not exist setup-x86.exe (
	wget %SETUPURL% -O setup-x86.exe
)

if exist local-repo\x86\setup.ini goto out

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
:out
