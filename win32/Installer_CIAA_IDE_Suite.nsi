;##############################################################################
;
; Copyright 2014, 2015, Juan Cecconi
; Copyright 2014, 2015, Martin Ribelotta
; Copyright 2014, 2015, Natalia Requejo
;
; This file is part of CIAA IDE.
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
;
SetCompressor /SOLID lzma

; Rename Config_Installer_CIAA_IDE_Suite.config as Config_Installer_CIAA_IDE_Suite.nsh
; and define which sections and files you want to include
!include "Config_Installer_CIAA_IDE_Suite.nsh"
;
!include "x64.nsh"
!include "WinVer.nsh"

;Include Modern UI
!include "MUI.nsh"
;

; Installer_Versions.bat must be executed to define Vars with version of each section

; Vars
Var Firmware_Section_Last_Sel ; Mutually Exclusive Section (Repo / Copy)
;
;--------------------------------
;
;LoadLanguageFile "${NSISDIR}\Contrib\Language files\Spanish.nlf"
;
;
; The name of the installer
Name "CIAA-IDE-Suite v$%CIAA_IDE_SUITE_VERSION%"

; The file to write
OutFile "Setup_CIAA_IDE_Suite_v$%CIAA_IDE_SUITE_VERSION%.exe"

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
   VIAddVersionKey /LANG=${LANG_SPANISH} "ProductName" "CIAA IDE Suite v$%CIAA_IDE_SUITE_VERSION%"
   VIAddVersionKey /LANG=${LANG_SPANISH} "Comments" "Instalador de CIAA-IDE-Suite"
   VIAddVersionKey /LANG=${LANG_SPANISH} "CompanyName" "Proyecto-CIAA"
   VIAddVersionKey /LANG=${LANG_SPANISH} "LegalTrademarks" ""
   VIAddVersionKey /LANG=${LANG_SPANISH} "LegalCopyright" "Proyecto-CIAA © 2015"
   VIAddVersionKey /LANG=${LANG_SPANISH} "FileDescription" "Instalador del IDE completo para la CIAA"
   VIAddVersionKey /LANG=${LANG_SPANISH} "FileVersion" $%CIAA_IDE_SUITE_VERSION%
   VIProductVersion "1.0.0.0"
;--------------------------------
; Si termina de instalar Ok,
; pongo el desinstalador !!!
;--------------------------------
Function .onInstSuccess
   ; Write the installation path into the registry
   ;WriteRegStr HKLM SOFTWARE\CIAA "Install_Dir" "$INSTDIR"
  
   ; Write the uninstall keys for Windows
   WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\CIAA-IDE-Suite" "DisplayName" "CIAA-IDE-Suite"
   WriteRegStr HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\CIAA-IDE-Suite" "UninstallString" '"$INSTDIR\uninstall.exe"'
   WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\CIAA-IDE-Suite" "NoModify" 1
   WriteRegDWORD HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\CIAA-IDE-Suite" "NoRepair" 1
   WriteUninstaller "uninstall.exe"
   ; TODO Add driver code here
FunctionEnd
 
;--------------------------------
;	   Secciones 
;--------------------------------
!ifdef INSTALL_CYGWIN
Section "Cygwin-Eclipse" Sec_Cygwin

   ; Set output path to the installation directory.
   SetOutPath $INSTDIR
   ;
!ifndef SKIP_INSTALL_CYGWIN_FILES
   ; Put file there
   File /oname=SetUsers.bat SetUsers.bat.in
   File /a /r cygwin

   ; Redirect $HOME to X:/Users/
   nsExec::ExecToLog "$INSTDIR\SetUsers.bat"

   ; Correct openocd version name
   ${If} ${RunningX64}
      File /oname=cygwin\etc\profile.d\openocd.sh openocd-x64.sh
   ${Else}
      File /oname=cygwin\etc\profile.d\openocd.sh openocd-x86.sh
   ${EndIf}
!endif
SectionEnd
!endif
;
!ifdef INSTALL_FIRMWARE
SubSection "Firmware v$%FIRMWARE_VERSION%" Sec_Firmware
   ;
   Section "Firmware Clone Repo" Sec_Firmware_Repo
!ifndef SKIP_CLONE_FIRMWARE_REPO
   ; Set output path to the installation directory.
   SetOutPath $INSTDIR
   System::Call 'Kernel32::SetEnvironmentVariable(t, t) i("FIRMWARE_VERSION", "$%FIRMWARE_VERSION%").r0'
   System::Call 'Kernel32::SetEnvironmentVariable(t, t) i("CIAA_SUITE_PATH", "$INSTDIR").r0'
   StrCmp $0 0 Env_Var_Error
      File /oname=Firmware_Clone.bat Firmware_Clone.bat
      ExecWait '"$INSTDIR\Firmware_Clone.bat"' $0
      Delete "$INSTDIR\Firmware_Clone.bat"
      Goto done
   Env_Var_Error:
      MessageBox MB_OK "No puede definirse la variable de entorno para el Path de instalacion"
   done:
!endif   
   SectionEnd
   
   Section /o "Copia de Firmware v$%FIRMWARE_VERSION%" Sec_Firmware_Copy
!ifndef SKIP_INSTALL_FIRMWARE_FILES
   ; Set output path to the installation directory.
   SetOutPath $INSTDIR
   ; Put file there
   File /r Firmware
!endif
   SectionEnd
SubSectionEnd   
!endif
;
!ifdef INSTALL_IDE4PLC
Section "IDE4PLC v$%IDE4PLC_VERSION%" Sec_IDE4PLC

   ; Set output path to the installation directory.
   SetOutPath $INSTDIR
   ;
!ifndef SKIP_INSTALL_IDE4PLC_FILES
   ; Put file there
   File /r IDE4PLC
!endif
SectionEnd
!endif
;
!ifdef INSTALL_LINUX
Section "CIAA-Linux" Sec_Linux

   ; Set output path to the installation directory.
   SetOutPath $INSTDIR
   ;
!ifndef SKIP_INSTALL_LINUX_FILES
   ; Put file there
   File /r Linux
!endif
SectionEnd
!endif
;
!ifdef INSTALL_DRIVERS
Section "Drivers" Sec_Drivers

   ; Set output path to the installation directory.
   SetOutPath $INSTDIR
  
!ifndef SKIP_INSTALL_DRIVERS_FILES
   ;  Put file there
   File /r usbdriver
   ; Install FTDI Drivers first

   ; We know that host is at least Win XP
   ${If} ${IsWinXP}
      ; Host is Win XP
      File /oname=Setup_Win_XP_FTDI_$%FTDI_XP_VERSION%.exe FTDI_Driver\CDM_v$%FTDI_XP_VERSION%_WHQL_Certified.exe
   ${Else}
      ; Host is newer than XP
      File /oname=Setup_Win_7_FTDI_$%FTDI_WIN7_VERSION%.exe FTDI_Driver\CDM_v$%FTDI_WIN7_VERSION%_WHQL_Certified.exe
   ${EndIf}      
   MessageBox MB_ICONQUESTION|MB_YESNO "Dispone del hardware para realizar la instalación" IDNO FTDI_Installed_failed
   MessageBox MB_ICONINFORMATION "Por favor conecte su Hardware ahora, y luego continue cuando el sistema lo haya detectado"
   ; We know that host is at least Win XP
   ${If} ${IsWinXP}
      ; Host is Win XP
      ClearErrors
      ExecWait "$INSTDIR\Setup_Win_XP_FTDI_$%FTDI_XP_VERSION%.exe"
   ${Else}
      ; Host is newer than XP
      ClearErrors
      ExecWait "$INSTDIR\Setup_Win_7_FTDI_$%FTDI_WIN7_VERSION%.exe"
   ${EndIf}  
   IfErrors 0 FTDI_Installed_ok
   FTDI_Installed_failed:
   MessageBox MB_ICONSTOP "El driver FTDI pudo no haber sido instalado correctamente. Por favor vea en la web del Proyecto-CIAA para realizarlo manualmente si hiciera falta. Los drivers quedarán disponible en el directorio elegido para su instalación manual posterior"   
   ;
   ; We know that host is at least Win XP
   ${If} ${IsWinXP}
      ; Host is Win XP
      File /oname=zadig_Win_XP_$%ZADIG_XP_VERSION%.exe FTDI_Driver\zadig_xp_$%ZADIG_XP_VERSION%.exe
   ${Else}
      ; Host is newer than XP
      File /oname=zadig_Win_7_$%ZADIG_WIN7_VERSION%.exe FTDI_Driver\zadig_$%ZADIG_WIN7_VERSION%.exe      
   ${EndIf}
   File /oname=driver_winusb_zadig_ft2232h.png "Images\driver_winusb_zadig_ft2232h.png"
   ; Shows Instructions, web page and files to do the job!
   MessageBox MB_ICONINFORMATION "El reemplazo del driver FTDI debería hacerse como se mostrará a continuación. Esta imagen permanecerá disponible en el directorio elegido para su instalación manual posterior"
   File /oname=driver_winusb_zadig_ft2232h.png "Images\driver_winusb_zadig_ft2232h.png"
   ExecShell "open" "$INSTDIR\driver_winusb_zadig_ft2232h.png"
   ExecShell "open" "http://proyecto-ciaa.com.ar/devwiki/doku.php?id=desarrollo:firmware:instalacion_sw#openocd"
   ExecShell "open" "$INSTDIR\"
   ;
   Goto FTDI_done
   FTDI_Installed_ok:
   Delete "$INSTDIR\Setup_Win_XP_FTDI_$%FTDI_XP_VERSION%.exe"
   Delete "$INSTDIR\Setup_Win_7_FTDI_$%FTDI_WIN7_VERSION%.exe"
   Delete "$INSTDIR\usbdriver"
  
   ; Install WinUSB driver for FTDI 2232H & correct openocd version name
   ${If} ${RunningX64}
      nsExec::ExecToLog "$INSTDIR\usbdriver\amd64\install-filter.exe install --inf=$INSTDIR\usbdriver\FTDI-CIAA.inf"
   ${Else}
      nsExec::ExecToLog "$INSTDIR\usbdriver\x86\install-filter.exe install --inf=$INSTDIR\usbdriver\FTDI-CIAA.inf"
   ${EndIf}
   FTDI_done:
!endif   
SectionEnd   
!endif
;
;--------------------------------
;
;Optional section (can be disabled by the user)
Section "Acceso directo en Menu Inicio" SecMenuInicio

   CreateDirectory "$SMPROGRAMS\CIAA\"
   CreateShortCut "$SMPROGRAMS\CIAA\Uninstall.lnk" "$INSTDIR\uninstall.exe" "" "$INSTDIR\uninstall.exe" 0
;
   !ifdef INSTALL_CYGWIN
   SetOutPath "$INSTDIR\cygwin\"
   CreateDirectory "$SMPROGRAMS\CIAA\CIAA-IDE"
   CreateShortCut "$SMPROGRAMS\CIAA\CIAA-IDE\CIAA cygwin.lnk" "$INSTDIR\cygwin\bin\mintty.exe" "$INSTDIR\cygwin\bin\bash --login" "$INSTDIR\cygwin\bin\mintty.exe" 0
   CreateShortCut "$SMPROGRAMS\CIAA\CIAA-IDE\CIAA Eclipse.lnk" "$INSTDIR\cygwin\StartEclipseIDE.bat" "" "$INSTDIR\cygwin\usr\local\eclipse\eclipse.exe" 0
   !endif

   !ifdef INSTALL_IDE4PLC
   SetOutPath "$INSTDIR\IDE4PLC\"
   CreateDirectory "$SMPROGRAMS\CIAA\IDE4PLC"
   CreateShortCut "$SMPROGRAMS\CIAA\IDE4PLC\CIAA IDE4PLC.lnk" "$INSTDIR\IDE4PLC\Pharo.exe" "" "$INSTDIR\IDE4PLC\Pharo.ico" 0 SW_SHOWNORMAL 
   !endif

   !ifdef INSTALL_LINUX
   SetOutPath "$INSTDIR\Linux\"
   CreateDirectory "$SMPROGRAMS\CIAA\Linux"
   CreateShortCut "$SMPROGRAMS\CIAA\Linux\Readme.lnk" "Notepad.exe" "$INSTDIR\Linux\README" "Notepad.exe" 0
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
   CreateShortCut "$DESKTOP\CIAA Eclipse.lnk" "$INSTDIR\cygwin\StartEclipseIDE.bat" "" "$INSTDIR\cygwin\usr\local\eclipse\eclipse.exe" 0
   !endif

   !ifdef INSTALL_IDE4PLC
   SetOutPath "$INSTDIR\IDE4PLC\"
   CreateShortCut "$DESKTOP\CIAA IDE4PLC.lnk" "$INSTDIR\IDE4PLC\Pharo.exe" "" "$INSTDIR\IDE4PLC\Pharo.ico" 0 SW_SHOWNORMAL 
   !endif

;
SectionEnd

;--------------------------------
;   Seccion Desinstalador
;--------------------------------
Section "Uninstall"
  
   ; Remove registry keys
   DeleteRegKey HKLM "Software\Microsoft\Windows\CurrentVersion\Uninstall\CIAA-IDE-Suite"

   ;Remove shortcuts, if any
   Delete "$SMPROGRAMS\CIAA\CIAA-IDE"
   Delete "$SMPROGRAMS\CIAA\IDE4PLC"
   Delete "$SMPROGRAMS\CIAA\Linux"   
   Delete "$SMPROGRAMS\CIAA\"      
;
   !ifdef INSTALL_CYGWIN
   Delete "$DESKTOP\CIAA cygwin.lnk"
   Delete "$DESKTOP\CIAA Eclipse.lnk"
   !endif

   !ifdef INSTALL_IDE4PLC
   Delete "$DESKTOP\CIAA IDE4PLC.lnk"
   !endif
     
   ; Remove directories used
   RMDir /r "$SMPROGRAMS\CIAA"
   RMDir /r "$INSTDIR\cygwin"
   RMDir /r "$INSTDIR\usbdriver"
   MessageBox MB_ICONQUESTION|MB_YESNO "¿Está seguro que desea eliminar el directorio 'Firmware' con todo su contenido?" IDNO Uninstall_Skip_Firmware
   RMDir /r "$INSTDIR\Firmware"
   Uninstall_Skip_Firmware:
   RMDir /r "$INSTDIR\IDE4PLC"
   RMDir /r "$INSTDIR\Linux"   
   
   ; Remove file...if it doens't exist, it fails and continue
   Delete "$INSTDIR\driver_winusb_zadig_ft2232h.png"
   Delete "$INSTDIR\Setup_Win_7_FTDI_$%FTDI_WIN7_VERSION%.exe"
   Delete "$INSTDIR\Setup_Win_XP_FTDI_$%FTDI_XP_VERSION%.exe"
   Delete "$INSTDIR\zadig_Win_7_$%ZADIG_WIN7_VERSION%.exe"
   Delete "$INSTDIR\zadig_Win_XP_$%ZADIG_XP_VERSION%.exe"  
   Delete "$INSTDIR\SetUsers.bat"
  
  ; Remove uninstaller
   Delete_Uninstaller:
   Delete "$INSTDIR\uninstall.exe"

   ; Remove install dir only if it is empty...
   RMDir "$INSTDIR"
SectionEnd

;--------------------------------
;Descriptions

  ;Language strings

  ;Assign language strings to sections
  !insertmacro MUI_FUNCTION_DESCRIPTION_BEGIN
    !ifdef INSTALL_CYGWIN
       !insertmacro MUI_DESCRIPTION_TEXT ${Sec_Cygwin} "Permite trabajar en un entorno posix like y Eclipse, para usar el toolchain gnu"
    !endif
    !ifdef INSTALL_FIRMWARE
       !insertmacro MUI_DESCRIPTION_TEXT ${Sec_Firmware} "Permite programar la CIAA mediente lenguaje C, basado en el CIAA Firmware"
       !insertmacro MUI_DESCRIPTION_TEXT ${Sec_Firmware_Repo} "Descarga online del repositorio mediante 'git clone' de CIAA Firmware, y hace un branch al tag v$%FIRMWARE_VERSION%"
       !insertmacro MUI_DESCRIPTION_TEXT ${Sec_Firmware_Copy} "Instala solo UNA COPIA de CIAA Firmware v$%FIRMWARE_VERSION%"
    !endif
    !ifdef INSTALL_DRIVERS
       !insertmacro MUI_DESCRIPTION_TEXT ${Sec_Drivers} "Permite instalar los drivers, pero debe contar con el Hardware!!!"
    !endif
    !ifdef INSTALL_IDE4PLC
       !insertmacro MUI_DESCRIPTION_TEXT ${Sec_IDE4PLC} "Permite programar la CIAA mediante lenguaje LADDER como un PLC"
    !endif    
    !ifdef INSTALL_LINUX
       !insertmacro MUI_DESCRIPTION_TEXT ${Sec_Linux} "Ejemplo para CIAA-NXP de Linux"
    !endif    
    !insertmacro MUI_DESCRIPTION_TEXT ${SecMenuInicio} "Accesos Directos en el Menu Inicio"
    !insertmacro MUI_DESCRIPTION_TEXT ${SecEscritorio} "Accesos Directos en el Escritorio"
  !insertmacro MUI_FUNCTION_DESCRIPTION_END
  ;
;--------------------------------
; 
;--------------------------------  
Function .onInit
	# the plugins dir is automatically deleted when the installer exits
	InitPluginsDir
	File /oname=$PLUGINSDIR\splash.bmp "Images\Logo.bmp"
	splash::show 3000 $PLUGINSDIR\splash

	Pop $0 ; $0 has '1' if the user closed the splash screen early,
			; '0' if everything closed normally, and '-1' if some error occurred.
   ${If} ${AtLeastWinXP}
      ; At least Windows XP !!!
   ${else}    
      MessageBox MB_ICONSTOP "Necesita al menos Windows XP para instalar 'CIAA-IDE-Suite'"
      Quit
   ${EndIf}
   ;
   Push $1
 
   StrCpy $Firmware_Section_Last_Sel ${Sec_Firmware_Repo} ; Default Section...
   SectionGetFlags ${Sec_Firmware_Repo} $1
   IntOp $1 $1 | ${SF_SELECTED}
   SectionSetFlags ${Sec_Firmware_Repo} $1

   SectionGetFlags ${Sec_Firmware_Copy} $1
   IntOp $1 $1 & ${SECTION_OFF}
   SectionSetFlags ${Sec_Firmware_Copy} $1

   Pop $1
FunctionEnd

;--------------------------------
; 
;--------------------------------
Function .onSelChange 
   Push $1
	Push $2
   Push $3
 
	SectionGetFlags ${Sec_Firmware_Repo} $1
   IntOp $1 $1 & ${SF_SELECTED}
   SectionGetFlags ${Sec_Firmware_Copy} $2
   IntOp $2 $2 & ${SF_SELECTED}
   
   IntOp $3 $1 | $2
   ${If} $3 == "0" 
      StrCpy $Firmware_Section_Last_Sel ""
      Return
   ${EndIf}
   
   StrCmp $Firmware_Section_Last_Sel ${Sec_Firmware_Repo} Old_Was_FW_Repo
      ; Sec_Firmware_Repo was unselected...Is it selected now? => unselect Sec_Firmware_Copy
      ${If} $1 == "1"
         SectionGetFlags ${Sec_Firmware_Copy} $1
         IntOp $1 $1 & ${SECTION_OFF}
         SectionSetFlags ${Sec_Firmware_Copy} $1
         StrCpy $Firmware_Section_Last_Sel ${Sec_Firmware_Repo}
      ${EndIf}
      Goto ExitSelChange
   Old_Was_FW_Repo:
      ; Sec_Firmware_Copy was unselected...Is it selected now? => unselect Sec_Firmware_Repo
      ${If} $2 == "1"
         ;MessageBox MB_ICONINFORMATION "E:"
         SectionGetFlags ${Sec_Firmware_Repo} $2
         IntOp $2 $2 & ${SECTION_OFF}
         SectionSetFlags ${Sec_Firmware_Repo} $2
         StrCpy $Firmware_Section_Last_Sel ${Sec_Firmware_Copy}
      ${EndIf}
   
   ExitSelChange:
   Pop $3
   Pop $2   
   Pop $1
FunctionEnd