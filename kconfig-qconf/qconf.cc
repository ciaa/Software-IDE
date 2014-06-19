/*
 * Copyright (C) 2013 David Graeff <david.graeff@udo.edu>
 * Based on Copyright (C) 2002 Roman Zippel <zippel@linux-m68k.org>
 * Released under the terms of the GNU GPL v2.0.
 */

#include "qconf.h"
#include "mainwindow.h"
#include <qglobal.h>
#include <QApplication>
#include <QDebug>
#include "./expr.h"
#include "./lkc.h"

void fixup_rootmenu(struct menu *menu)
{
	struct menu *child;
	static int menu_cnt = 0;

	menu->flags |= MENU_ROOT;
	for (child = menu->list; child; child = child->next) {
		if (child->prompt && child->prompt->type == P_MENU) {
			menu_cnt++;
			fixup_rootmenu(child);
			menu_cnt--;
		} else if (!menu_cnt)
			fixup_rootmenu(child);
	}
}

extern "C" int conf_main(int ac, char **av);

static const char *progname;

static void usage(void)
{
    qDebug() << QApplication::tr("%s <config>\n").arg(progname);
	exit(0);
}

int main(int ac, char** av)
{
	const char *name;

	bindtextdomain(PACKAGE, LOCALEDIR);
	textdomain(PACKAGE);

	progname = av[0];
    QApplication configApp(ac, av);
	// Important for QSetting to store settings in .config/kernel.org/qconf
	configApp.setApplicationName("qconf");
	configApp.setOrganizationDomain("kernel.org");
	
	if (ac > 1 && av[1][0] == '-') {
		switch (av[1][1]) {
		case 'h':
		case '?':
			usage();
		}
	}
	
	if (ac > 2 && av[1][0] == '-') {
		name = av[2];
    } else if(ac>1) {
		name = av[1];
	} else {
		printf("No config file!\n");
        name = "Kconfig";
	}

	conf_parse(name);
	fixup_rootmenu(&rootmenu);
	conf_read(NULL);
	//zconfdump(stdout);

    qconf_MainWindow v;
    configApp.setQuitOnLastWindowClosed(true);
    v.show();
    configApp.exec();
    do {
        char *v[] = {
            "conf", "--silentoldconfig", (char*) name
        };
        conf_main(3, v);
    } while(0);
	return 0;
}
