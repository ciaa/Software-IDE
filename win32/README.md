Scripts que descargan y preparan los componentes del instalador
===============================================================

Prerequisitos
-------------
 Windows 7

Ejecute prepare.bat en una consola de windows abierta como administrador (Run as administrator...) y espere a que termine.
Esto creará las carpetas
 * local-repo Repo local donde se encuentran los paquetes requeridos para instalar cygwin
 * cygwin Directorio de instalación de cygwin (debe habilitar la linea "rem cyg-install.bat" en el archivo prepare.bat)
 * eclipse-cdt conteniendo el JRE
 * arm-none-eabi-gcc desde launchpad
 * openOCD 0.8 desde el repositorio de freddy chopins
 * Testcase de compilacion de linea de comandos

TODO
----
 - Realizar un *.ini con los parámetros de eclipse correspondientes
 - workspace por defecto, perspectiva a usar -cdt-, etc.)
 - Realizar *.ini de instalación del driver
 - Expandir testcases de las herramientas luego de instalar
