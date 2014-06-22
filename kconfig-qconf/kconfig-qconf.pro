#-------------------------------------------------
#
# Project created by QtCreator 2014-06-18T22:06:24
#
#-------------------------------------------------

QT       += core gui

greaterThan(QT_MAJOR_VERSION, 4): QT += widgets

TARGET = kconfig-qtconf
TEMPLATE = app

SOURCES +=\
        qconf.cc \
        expr.c \
        images.c \
        configItem.cc \
        configModel.cc \
        configmodeldelegate.cc \
        infoViewWidget.cc \
        searchfiltermodelproxy.cc \
        searchmodel.cc \
        zconf.hash.c \
        zconf.lex.c \
        zconf.tab.c \
        util.c \
        confdata.c \
        symbol.c \
        menu.c \
        mainwindow.cc \
    conf.c

HEADERS  += mainwindow.h \
    qconf.h \
    lkc.h \
    lkc_proto.h \
    expr.h \
    list.h \
    configItem.h \
    configModel.h \
    configmodeldelegate.h \
    infoViewWidget.h \
    searchfiltermodelproxy.h \
    searchmodel.h

FORMS    += mainwindow.ui

OTHER_FILES += \
    Kconfig.test
