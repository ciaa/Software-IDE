/*
 * Copyright (C) 2013 David Gräff <david.graeff@web.de>
 * Copyright (C) 2002 Roman Zippel <zippel@linux-m68k.org>
 * Released under the terms of the GNU GPL v2.0.
 */

#ifndef QCONF_CONFIGINFOVIEW_H_
#define QCONF_CONFIGINFOVIEW_H_

#include <QTextBrowser>
#include <QAction>
#include <QString>

class InfoViewWidget : public QTextBrowser {
	Q_OBJECT
	typedef class QTextBrowser Parent;
public:
    InfoViewWidget(QWidget* parent);
	bool showDebug(void) const { return _showDebug; }

public Q_SLOTS:
	void setInfo(struct menu *menu);
private Q_SLOTS:
	void saveSettings(void);
	void setShowDebug(bool);

protected:
	void symbolInfo(void);
	void menuInfo(void);
	QString debug_info(struct symbol *sym);
	static QString print_filter(const QString &str);
	static void expr_print_help(void *data, struct symbol *sym, const char *str);

	struct symbol *sym;
	struct menu *_menu;
	bool _showDebug;
	
private:
	QAction* actionDebug;
};

#endif
