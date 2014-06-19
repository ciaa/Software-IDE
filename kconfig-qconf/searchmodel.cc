#include "searchmodel.h"
#include <QPalette>
#include "./expr.h"
#include "./lkc.h"


SearchModel::item::item(struct menu* menu) {
    this->menu = menu;
    visible = menu_is_visible(menu);
    this->text = QString::fromUtf8(menu_get_prompt(menu));
}

SearchModel::SearchModel(QObject *parent) : QAbstractListModel(parent)
{
}

QVariant SearchModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid())
        return QVariant();

    if (role==Qt::DisplayRole)
        return mItems[index.row()]->text;
    else if (role==Qt::UserRole)
        return qVariantFromValue((void*)mItems[index.row()]->menu);
    else if (role==Qt::ForegroundRole && !mItems[index.row()]->visible)
        return  QPalette().mid();

    return QVariant();
}

int SearchModel::rowCount(const QModelIndex &) const
{
    return mItems.size();
}

void SearchModel::setSearch(const QString& text)
{
    struct symbol **p;
    struct property *prop;
    struct symbol **result = 0;

    free(result);
    mItems.clear();

    result = sym_re_search(text.toLatin1());
    if (!result) {
        beginResetModel();
        endResetModel();
        return;
    }
    for (p = result; *p; p++) {
        for_all_prompts((*p), prop)
                mItems.append(new item(prop->menu));
//            lastItem = new ConfigItem(list->list, lastItem, prop->menu, menu_is_visible(prop->menu));
    }
    beginResetModel();
    endResetModel();
}
