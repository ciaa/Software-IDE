Kconfig Qt frontend
===================

Frontend for Kconfig files.

Kconfig language reference: [www.kernel.org/doc/Documentation/kbuild/kconfig-language.txt](https://www.kernel.org/doc/Documentation/kbuild/kconfig-language.txt)

Requires
--------
* gcc/make: On debian/ubuntu build-essential
* Qt4/Qt5: QtCore and QtGui modules. QtCreator preferred.

Build
-----
Run on terminal:
```
      qmake
```
This command generate Makefile, next run make:
```
      make
```
Finally, the kconfig-qconf executable will be found in the directory

Install
-------

Copy kconfig-qconf executable into a directory of the search path (/usr/local/bin by example)

Usage
-----
Show a simple demo of utilization in example/ directory

Only two build commands are implemented
```
     make menconfig
```
For GUI configuration, and
```
     make mrproper
```
To clean configuration

At the end of make menuconfig rule, the directory include/ was created containing several important files:

 * include/config/auto.conf: The variable declaration for include in main Makefile
 * include/config/auto.conf.cmd: The Makefile rules for rebuild include/* configuration
 * include/generated/autoconf.h: Plain C include containing all defined symbols as #define macros