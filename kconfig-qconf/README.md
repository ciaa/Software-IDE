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
