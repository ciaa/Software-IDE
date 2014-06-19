/*
 * Copyright (C) 2013 David Gräff <david.graeff@web.de>
 * Copyright (C) 2002 Roman Zippel <zippel@linux-m68k.org>
 * Released under the terms of the GNU GPL v2.0.
 */

#ifndef QCONF_CONFIGSITEM_H_
#define QCONF_CONFIGSITEM_H_

#include <QPixmap>
#include <QString>
#include <QList>
#include <QVariant>
#include "./expr.h"
#include "./lkc.h"
#include "qconf.h"

class ConfigItem {
 public:
     ConfigItem();
     ConfigItem(struct menu *menuitem, ConfigItem* parent);
     ~ConfigItem();

     void appendChild(ConfigItem *child);

     ConfigItem *child(int row);
     int childCount() const;
     QVariant data( int column, int role) const;
     bool setData ( int column, const QVariant & value, int role);
     Qt::ItemFlags flags(int column) const;
     int row() const;
     ConfigItem *parent();
     struct menu *menu() const;

     // Basic data, visibility
     QString mOption;
     QString mName;
     bool mIsVisible;
     bool mIsPrompt;
     enum prop_type mPtype; //P_MENU or P_COMMENT
     struct menu *mMenuitem;

     // Value string
     QString mValue;//COL_VALUE
     bool mValueIsEditable;//COL_EDIT

     // yes/mod/no columns
     enum enable_type {en_no=0,en_mod,en_yes,en_unknown};
     bool mEnableRange[3]; //COL_NO_EN COL_MOD_EN COL_YES_EN
     enum enable_type mEnabled;//COL_YES,COL_NO,COL_MOD

     bool mIsChoice;//COL_BTNRAD

     /**
      * @brief Get advanced values out of the menu->sym struct
      * @return Return true if values have changed
      */
     bool setSymData();
 private:
     QList<ConfigItem*> childItems;

     ConfigItem *parentItem;
};

#endif
