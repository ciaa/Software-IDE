/*
 * Copyright (C) 2013 David Graeff <david.graeff@udo.edu>
 * Copyright (C) 2002 Roman Zippel <zippel@linux-m68k.org>
 * Released under the terms of the GNU GPL v2.0.
 */

#include "configItem.h"
#include "configModel.h"
#include <QStringList>
#include <QApplication>
#include <QDebug>

ConfigItem::ConfigItem() : parentItem(0)
{

    // Recursivly build tree of ConfigItem objects
    for (struct menu *child = rootmenu.list; child; child = child->next) {
       appendChild(new ConfigItem(child, this));
    }
}

ConfigItem::ConfigItem(struct menu *menuitem, ConfigItem *parent) : parentItem(parent)
{
    // Default values
    mEnableRange[0] = false; mEnableRange[1]=false; mEnableRange[2] = false; mIsChoice = false; mEnabled = en_unknown;
    mValueIsEditable = false;

    // Get basic values out of the menu struct
    struct symbol *sym = menuitem->sym;
    mOption = QString("%1 %2").arg(_(menu_get_prompt(menuitem))).arg(sym && !sym_has_value(sym) ? "(NEW)" : "");
    mIsPrompt = menu_has_prompt(menuitem);
    mIsVisible = menu_is_visible(menuitem);
    mPtype = menuitem->prompt ? menuitem->prompt->type : P_UNKNOWN;
    mMenuitem = menuitem;
    // Get advanced values out of the menu->sym struct
    if (sym) sym->flags |= SYMBOL_CHANGED;
    setSymData();

    // Recursivly build tree of ConfigItem objects
    for (struct menu *child = menuitem->list; child; child = child->next) {
        appendChild(new ConfigItem(child, this));
    }
}

ConfigItem::~ConfigItem()
{
    // On destruction remove all childs first
	qDeleteAll(childItems);
}

bool ConfigItem::setSymData()
{
    struct symbol *sym = mMenuitem->sym;
    if (!sym || !(sym->flags & SYMBOL_CHANGED))
        return false;

    bool changed = false;

    // visiblity
    mIsVisible = menu_is_visible(mMenuitem);

    // Get advanced values out of the menu->sym struct
    mName = mMenuitem->sym->name;
    sym_calc_value(sym);
    sym->flags &= ~SYMBOL_CHANGED;

    if (sym_is_choice(sym)) {
        // This ConfigItem has children who are mutually exclusive
        // Parse childs for getting final value for displaying the current choice
        struct menu *child;
        struct symbol *def_sym = sym_get_choice_value(sym);
        struct menu *def_menu = NULL;

        for (child = mMenuitem->list; child; child = child->next) {
            if (menu_is_visible(child)
                && child->sym == def_sym)
                def_menu = child;
        }

        if (def_menu) {
            mValue = QString(_(menu_get_prompt(def_menu)));
            return changed; // done
        }
    }

    // This ConfigItem is one of a few items who are mutually exclusive
    if (sym->flags & SYMBOL_CHOICEVAL)
        mIsChoice = true;

    // Parse S_BOOLEAN/S_TRISTATE values -> those indicate enabled/disabled/module states
    // Parse S_INT/S_HEX/S_STRING values -> those can freely be edited by the user
    tristate val;
    int stype = sym_get_type(sym);
    switch (stype) {
        case S_BOOLEAN:
            if (sym_is_choice(sym))
                break;
            /* fall through */
        case S_TRISTATE:
            val = sym_get_tristate_value(sym);
            switch (val) {
            case no:
                mEnabled = en_no;
                mValue = QApplication::tr("[No]");
                break;
            case mod:
                mEnabled = en_mod;
                mValue = QApplication::tr("[Module]");
                break;
            case yes:
                mEnabled = en_yes;
                mValue = QApplication::tr("[Yes]");
                break;
            }

            mEnableRange[en_no] = sym_tristate_within_range(sym, no); // No is allowed
            mEnableRange[en_mod] = sym_tristate_within_range(sym, mod); // Mod is allowed
            mEnableRange[en_yes] = sym_tristate_within_range(sym, yes); // Yes is allowed
            break;
        case S_INT:
        case S_HEX:
        case S_STRING:
            // Even if this is marked as a choice -> reset mIsChoice flag and set
            // mValueIsEditable flag instead
            mIsChoice = false;
            mValueIsEditable = true;
            const char *def = sym_get_string_value(sym);
            mValue = QString(def);
            break;
    }
    return changed;
}

struct menu* ConfigItem::menu() const
{
    return mMenuitem;
}

void ConfigItem::appendChild(ConfigItem *item)
{
	childItems.append(item);
}

ConfigItem *ConfigItem::child(int row)
{
	return childItems.value(row);
}

int ConfigItem::childCount() const
{
	return childItems.count();
}

QVariant ConfigItem::data(int column, int role) const
{
    // Visible role
    if (role == ConfigModel::MenuVisibleRole)
        return mIsVisible;

    // MenuHasPromptRole role
    else if (role == ConfigModel::MenuHasPromptRole)
        return mPtype;

    // String display role for option, name and value
    else if (role == Qt::DisplayRole) {
        switch(column) {
            case 0: return mOption;
            case 1: return mName;
            case 5: return mValue;
        }
    }
    // Edit role, only for value column
    else if (role == Qt::EditRole && column==5) {
        // Just return the current value string as edit value
        return mValue;
    }
    // Checkstate role: All checkboxes and radio buttons
    // propagate their current check state by this role
    else if (role == Qt::CheckStateRole) {
        // Check state of option column
        if (column==0) {
            switch (mEnabled)
            {
                case en_no:return Qt::Unchecked;
                case en_mod:return Qt::PartiallyChecked;
                case en_yes:return Qt::Checked;
                case en_unknown:return QVariant();
            }
        }
        else if (column==2 && mEnableRange[en_no])
            return mEnabled==en_no?Qt::Checked:Qt::Unchecked;
        else if (column==3 && mEnableRange[en_mod])
            return mEnabled==en_mod?Qt::Checked:Qt::Unchecked;
        else if (column==4 && mEnableRange[en_yes] && !mIsChoice) // if radio button, do not return check state
            return mEnabled==en_yes?Qt::Checked:Qt::Unchecked;
    }
    return QVariant();
}

bool ConfigItem::setData(int column, const QVariant &value, int role)
{
    struct symbol *sym = mMenuitem->sym;
    if (!sym)
        return false;

    if (role == Qt::CheckStateRole) {
        tristate newval;
        switch (column) {
        case 0:
            // This is a choice radio button
            // or a enabled/disabled/module state checkbox
            sym_toggle_tristate_value(sym);
            sym->flags |= SYMBOL_CHANGED;
            setSymData();
            return true;
            break;
        case 2:
            // enabled/disabled/module state radio buttons
            newval = no;
            break;
        case 3:
            // enabled/disabled/module state radio buttons
            newval = mod;
            break;
        case 4:
            // enabled/disabled/module state radio buttons
            newval = yes;
            break;
        default:
             return false;

        }

        switch (sym_get_type(sym)) {
            case S_BOOLEAN:
            case S_TRISTATE:
                if (!sym_tristate_within_range(sym, newval))
                    newval = yes;
                sym_set_tristate_value(sym, newval);
                sym->flags |= SYMBOL_CHANGED;
                setSymData();
                return true;
            default:
                return false;
        }
    }
    // The value field
    else if (role == Qt::EditRole && column==5 && mValueIsEditable) {
        struct symbol *sym = mMenuitem->sym;
        sym_set_string_value(sym, value.toString().toUtf8().constData());
        sym->flags |= SYMBOL_CHANGED;
        setSymData();
        return true;
    }

    // No handling for any other case
    return false;
}

Qt::ItemFlags ConfigItem::flags(int column) const
{
    Qt::ItemFlags f = Qt::ItemIsEnabled;
    switch(column) {
        case 0:
            f |= Qt::ItemIsSelectable;
            if(mEnableRange[en_yes]) {
                f |= Qt::ItemIsUserCheckable;
                if (!mIsChoice)
                    f |= Qt::ItemIsTristate;
            }
            break;
        case 1:
            f |= Qt::ItemIsSelectable;
            break;
        case 2:
            if (mEnableRange[en_no])
                f |= Qt::ItemIsEditable | Qt::ItemIsSelectable | Qt::ItemIsUserCheckable;
            break;
        case 3:
            if (mEnableRange[en_mod])
                f |= Qt::ItemIsEditable | Qt::ItemIsSelectable| Qt::ItemIsUserCheckable;
            break;
        case 4:
            if (mEnableRange[en_yes] && !mIsChoice)
                f |= Qt::ItemIsEditable | Qt::ItemIsSelectable| Qt::ItemIsUserCheckable;
            break;
        case 5:
            if(mValueIsEditable)
                f |= Qt::ItemIsEditable | Qt::ItemIsSelectable;
            break;
    }
    return f;
}

ConfigItem *ConfigItem::parent()
{
	return parentItem;
}

int ConfigItem::row() const
{
	if (parentItem)
		return parentItem->childItems.indexOf(const_cast<ConfigItem*>(this));

	return 0;
}
