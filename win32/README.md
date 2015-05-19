Scripts que descargan y preparan los componentes del instalador
===============================================================

Prerequisitos
-------------
 Windows XP o superior

Ejecute prepare.bat en una consola de windows abierta como administrador (Run as administrator...) y espere a que termine.
Esto creará las carpetas
 * local-repo Repo local donde se encuentran los paquetes requeridos para instalar cygwin
 * cygwin Directorio de instalación de cygwin (debe habilitar la linea "rem cyg-install.bat" en el archivo prepare.bat)
 * eclipse-cdt conteniendo el JRE
 * arm-none-eabi-gcc desde launchpad
 * Firmware desde el repositorio de CIAA-Firmware
 * FTDI_Driver
 * usbdriver
 * NSIS
 * IDE4PLC por ahora desde un ZIP externo
 * openocd desde el repositorio de freddy chopins
 * Testcase de compilacion de linea de comandos

Luego crear el instalador:
 * Copiar Config_Inst_MUI_CIAA_IDE_Suite_v1'1'0.config como Config_Inst_MUI_CIAA_IDE_Suite_v1'1'0.nsh y definerque secciones y archivos quiere incluir
 * Ejecutar make-installer.bat en una consola y esperar un rato a que termine...el archivo Setup_CIAA_IDE_Suite_v1_1_0.exe se creará en esta carpeta.


TODO
----
 - IDE4PLC descargable desde el repo (no está subido aún)
 - Realizar un *.ini con los parámetros de eclipse correspondientes
 - workspace por defecto, perspectiva a usar -cdt-, etc.)
 - Realizar *.ini de instalación del driver
 - Expandir testcases de las herramientas luego de instalar
