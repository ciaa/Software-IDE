;##############################################################################
;
; Copyright 2014, ACSE & CADIEEL
;    ACSE   : http://www.sase.com.ar/asociacion-civil-sistemas-embebidos/ciaa/
;    CADIEEL: http://www.cadieel.org.ar
;
; This file is part of CIAA Firmware.
;
; Redistribution and use in source and binary forms, with or without
; modification, are permitted provided that the following conditions are met:
;
; 1. Redistributions of source code must retain the above copyright notice,
;    this list of conditions and the following disclaimer.
;
; 2. Redistributions in binary form must reproduce the above copyright notice,
;    this list of conditions and the following disclaimer in the documentation
;    and/or other materials provided with the distribution.
;
; 3. Neither the name of the copyright holder nor the names of its
;    contributors may be used to endorse or promote products derived from this
;    software without specific prior written permission.
;
; THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
; AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
; IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
; ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
; LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
; CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
; SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
; INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
; CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
; ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
; POSSIBILITY OF SUCH DAMAGE.
;
;##############################################################################

; Instalador de las aplicacines que se indiquen con el "define", y busca la
; aplicacion correspondiente en el directorio root de esta carpeta
; para luego copiarla en el directorio destino
; Las aplicaciones son obligatorias y es opcional los accesos directos
;
!define INSTALL_CYGWIN
;
;--------------------------------
;

SetCompressor /SOLID lzma

!include "x64.nsh"

;Include Modern UI
  !include "MUI.nsh"
;
Function .onInit
	# the plugins dir is automatically deleted when the installer exits
	InitPluginsDir
	File /oname=$PLUGINSDIR\splash.bmp "Logo.bmp"
	splash::show 3000 $PLUGINSDIR\splash

	Pop $0 ; $0 has '1' if the user closed the splash screen early,
			; '0' if everything closed normally, and '-1' if some error occurred.
FunctionEnd
;
;--------------------------------
;
;LoadLanguageFile "${NSISDIR}\Contrib\Language files\Spanish.nlf"
;
;
; The name of the installer
Name "CIAA-Firmware-IDE"

; The file to write
OutFile "Setup_CIAA_Firmware_IDE.exe"

; The default installation directory
InstallDir C:\CIAA

; Registry key to check for directory (so if you install again, it will 
; overwrite the old one automatically)
;InstallDirRegKey HKLM "Software\CIAA" "Install_Dir"

;--------------------------------
;Interface Settings

  !define MUI_ABORTWARNING
  !define MUI_FINISHPAGE_NOAUTOCLOSE

;--------------------------------
;Pages

  !insertmacro MUI_PAGE_WELCOME
  !insertmacro MUI_PAGE_LICENSE "License.txt"
  !insertmacro MUI_PAGE_COMPONENTS
  !insertmacro MUI_PAGE_DIRECTORY
  !insertmacro MUI_PAGE_INSTFILES
  !insertmacro MUI_PAGE_FINISH

  !insertmacro MUI_UNPAGE_WELCOME
  !insertmacro MUI_UNPAGE_CONFIRM
  !insertmacro MUI_UNPAGE_INSTFILES
  !insertmacro MUI_UNPAGE_FINISH
;--------------------------------
;Languages

  !insertmacro MUI_LANGUAGE "Spanish"
  ;
  VIAddVersionKey /LANG=${LANG_SPANISH} "ProductName" "CIAA Firmware IDE"
  VIAddVersionKey /LANG=${LANG_SPANISH} "Comments" "Instalador del IDE para CIAA Firmware"
  VIAddVersionKey /LANG=${LANG_SPANISH} "CompanyName" "Proyecto-CIAA"
  VIAddVersionKey /LANG=${LANG_SPANISH} "LegalTrademarks" ""
  VIAddVersionKey /LANG=${LANG_SPANISH} "LegalCopyright" "Proyecto-CIAA © 2014"
  VIAddVersionKey /LANG=${LANG_SPANISH} "FileDescription" "Instalador del IDE para CIAA Firmware"
  VIAddVersionKey /LANG=${LANG_SPANISH} "FileVersion" "1.0.0"
  VIProductVersion "1.0.0.0"
;--------------------------------
; Si termina de instalar Ok,
; pongo el desinstalador !!!
;--------------------------------
Function .onInstSuccess
  ; Write the installation path into the registry
  ;WriteRegStr HKLM SOFTWARE\CIAA "Install_Dir" "$INSTDIR"
  
  ; Write the uninstall keys for Windows
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\CIAA-Firmware-IDE" "DisplayName" "CIAA-Firmware-IDE"
  WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\CIAA-Firmware-IDE" "UninstallString" '"$INSTDIR\uninstall.exe"'
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\CIAA-Firmware-IDE" "NoModify" 1
  WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\CIAA-Firmware-IDE" "NoRepair" 1
  WriteUninstaller "uninstall.exe"
  ; TODO Add driver code here
FunctionEnd

;--------------------------------
;	   Secciones 
;--------------------------------
SectionGroup "Aplicaciones" Sec_Apps
;
!ifdef INSTALL_CYGWIN
Section "Cygwin" Sec_Cygwin

  SectionIn RO ; Este va siempre!!!  
  ; Set output path to the installation directory.
  SetOutPath $INSTDIR
  ;
  ; Put file there
  File /r usbdriver
  File /oname=SetUsers.bat SetUsers.bat.in
  File /r cygwin
  nsExec::ExecToLog "$INSTDIR\SetUsers.bat"
SectionEnd
!endif
;
SectionGroupEnd
;
;--------------------------------
;
;Optional section (can be disabled by the user)
Section "Acceso directo en Menu Inicio" SecMenuInicio

  CreateDirectory "$SMPROGRAMS\CIAA\CIAA-Firmware-IDE"
  CreateShortCut "$SMPROGRAMS\CIAA\CIAA-Firmware-IDE\Uninstall.lnk" "$INSTDIR\uninstall.exe" "" "$INSTDIR\uninstall.exe" 0
;
  !ifdef INSTALL_CYGWIN
  SetOutPath "$INSTDIR\cygwin\"
  CreateShortCut "$SMPROGRAMS\CIAA\CIAA-Firmware-IDE\CIAA cygwin.lnk" "$INSTDIR\cygwin\bin\mintty.exe" "$INSTDIR\cygwin\bin\bash --login" "$INSTDIR\cygwin\bin\mintty.exe" 0
  CreateShortCut "$SMPROGRAMS\CIAA\CIAA-Firmware-IDE\CIAA IDE.lnk" "$INSTDIR\cygwin\StartEclipseIDE.bat" "" "$INSTDIR\cygwin\usr\local\eclipse\eclipse.exe" 0
  !endif
;
SectionEnd

;
;--------------------------------
;
; Optional section (can be disabled by the user)
Section "Acceso directo en Escritorio" SecEscritorio
  ;
  !ifdef INSTALL_CYGWIN
  SetOutPath "$INSTDIR\cygwin\"
  CreateShortCut "$DESKTOP\CIAA cygwin.lnk" "$INSTDIR\cygwin\bin\mintty.exe" "$INSTDIR\cygwin\bin\bash --login" "$INSTDIR\cygwin\bin\mintty.exe" 0
  CreateShortCut "$DESKTOP\CIAA IDE.lnk" "$INSTDIR\cygwin\StartEclipseIDE.bat" "" "$INSTDIR\cygwin\usr\local\eclipse\eclipse.exe" 0
  !endif
;
SectionEnd

;--------------------------------
;   Seccion Desinstalador
;--------------------------------
Section "Uninstall"
  
  ; Remove registry keys
  DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\CIAA-Firmware-IDE"
;  DeleteRegKey HKLM SOFTWARE\CIAA-Firmware-IDE

  ; Remove files and uninstaller
  ;Delete $INSTDIR\uninstall.exe

  ; Remove shortcuts, if any
  Delete "$SMPROGRAMS\CIAA\CIAA-Firmware-IDE"
;
  !ifdef INSTALL_CYGWIN
  Delete "$DESKTOP\CIAA cygwin.lnk"
  Delete "$DESKTOP\CIAA IDE.lnk"
  !endif
;
  ; Remove directories used
  RMDir /r "$SMPROGRAMS\CIAA\CIAA-Firmware-IDE"
  RMDir "$SMPROGRAMS\CIAA\CIAA-Firmware-IDE"
  RMDir /r "$INSTDIR"

SectionEnd

;--------------------------------
;Descriptions

  ;Language strings

  ;Assign language strings to sections
  !insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
    !insertmacro MUI_DESCRIPTION_TEXT ${Sec_Apps} "Aplicaciones fundamentales"
    !ifdef INSTALL_CYGWIN
       !insertmacro MUI_DESCRIPTION_TEXT ${Sec_Cygwin} "Permite trabajar en un entorno posix like, para usar el toolchain gnu"
    !endif
    !insertmacro MUI_DESCRIPTION_TEXT ${SecMenuInicio} "Accesos Directos en el Menu Inicio"
    !insertmacro MUI_DESCRIPTION_TEXT ${SecEscritorio} "Accesos Directos en el Escritorio"
  !insertmacro MUI_FUNCTION_DESCRIPTION_END
  ;