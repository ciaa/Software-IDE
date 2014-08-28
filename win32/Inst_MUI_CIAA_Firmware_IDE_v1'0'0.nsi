; Instalador de las aplicacines que se indiquen con el "define", y busca la
; aplicacion correspondiente en el directorio root de esta carpeta
; para luego copiarla en el directorio destino
; Las aplicaciones son obligatorias y es opcional los accesos directos
;
!define INSTALL_CYGWIN
;
;--------------------------------
;

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
InstallDir $PROGRAMFILES\CIAA

; Registry key to check for directory (so if you install again, it will 
; overwrite the old one automatically)
;InstallDirRegKey HKLM "Software\CIAA" "Install_Dir"

;--------------------------------
;Interface Settings

  !define MUI_ABORTWARNING

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
  File /r "Cygwin"
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
  CreateShortCut "$SMPROGRAMS\CIAA\CIAA-Firmware-IDE\cygwin.lnk" "$INSTDIR\cygwin\bin\mintty.exe" "" "$INSTDIR\cygwin\bin\mintty.exe" 0
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
  CreateShortCut "$DESKTOP\cygwin.lnk" "$INSTDIR\cygwin\bin\mintty.exe" "" "$INSTDIR\cygwin\bin\mintty.exe" 0
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
  Delete "$DESKTOP\cygwin.lnk"
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