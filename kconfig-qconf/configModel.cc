/*
 * Copyright (C) 2013 David Graeff <david.graeff@udo.edu>
 * Copyright (C) 2002 Roman Zippel <zippel@linux-m68k.org>
 * Released under the terms of the GNU GPL v2.0.
 */

#include "configModel.h"
#include "configItem.h"
#include <QtGui>
#include "./expr.h"
#include "./lkc.h"

ConfigModel::ConfigModel(QObject *parent)
    : QAbstractItemModel(parent), mHideChildren(true)
{
    rootItem = new ConfigItem();
}

ConfigModel::~ConfigModel()
{
	delete rootItem;
}

QModelIndex ConfigModel::indexOf(struct menu* menu, const QModelIndex& top)
{
    if( top.isValid() ) {
        ConfigItem *item = static_cast<ConfigItem*>(top.internalPointer());
        if (item->mMenuitem == menu)
            return top;
    }

    for( int r = 0; r < rowCount( top );r ++ ) {
        QModelIndex foundindex = indexOf( menu, index( r, 0, top ));
        if (foundindex.isValid())
            return foundindex;
    }
    return QModelIndex();
}

int ConfigModel::columnCount(const QModelIndex &) const
{
        return 6;
}

QVariant ConfigModel::data(const QModelIndex &index, int role) const
{
	if (!index.isValid())
		return QVariant();

	ConfigItem *item = static_cast<ConfigItem*>(index.internalPointer());

    return item->data(index.column(), role);
}

bool ConfigModel::setData ( const QModelIndex & index, const QVariant & value, int role)
{
    if (!index.isValid())
        return false;

    ConfigItem *item = static_cast<ConfigItem*>(index.internalPointer());
    bool r = item->setData(index.column(), value, role);
    if (r) { // internal kconfig update successfull, notify the model consumers
        emit dataChanged( index, ConfigModel::index(index.row(),columnCount()-1,index.parent()) );
        // update all ConfigItems
        updateAllItems(QModelIndex());
        emit layoutAboutToBeChanged();
        emit layoutChanged();
    }
    return r;
}

bool ConfigModel::hasChildren(const QModelIndex &parent) const
{
    if (mHideChildren && parent.isValid()) {
        ConfigItem *item = static_cast<ConfigItem*>(parent.internalPointer());
        return item->mEnabled!=ConfigItem::en_no && item->childCount();
    } else {
        return rowCount(parent);
    }
}

void ConfigModel::setHideChildren(bool enabled)
{
    mHideChildren = enabled;
    emit layoutAboutToBeChanged();
    emit layoutChanged();
}

void ConfigModel::updateAllItems(const QModelIndex& top)
{
    if( top.isValid() ) {
        ConfigItem *item = static_cast<ConfigItem*>(top.internalPointer());
        // if data changes in this ConfigItem notify the model consumers
        item->setSymData();
        // Actually we do not have to do this here -> layoutChanged will be called after
        // this method and the views update their visible area
        // emit dataChanged( top, ConfigModel::index(top.row(),columnCount()-1,top.parent()) );
    }

    for( int r = 0, m = rowCount( top ); r < m; r++ ) {
        updateAllItems( index( r, 0, top ));
    }
}

Qt::ItemFlags ConfigModel::flags(const QModelIndex &index) const
{
	if (!index.isValid())
		return 0;

    ConfigItem *item = static_cast<ConfigItem*>(index.internalPointer());
    return item->flags(index.column());
}

QVariant ConfigModel::headerData(int section, Qt::Orientation orientation,
							int role) const
{
    if (orientation == Qt::Horizontal && role == Qt::DisplayRole) {
        switch (section) {
        case 0: return tr("Option");
        case 1: return tr("Name");
        case 2: return tr("N");
        case 3: return tr("M");
        case 4: return tr("Y");
        case 5: return tr("Value");
        }
    }
    else if (orientation == Qt::Horizontal && role == Qt::ToolTipRole) {
        switch (section) {
        case 0: return tr("Option");
        case 1: return tr("Internal Name");
        case 2: return tr("Disable");
        case 3: return tr("Enable as module");
        case 4: return tr("Enable");
        case 5: return tr("Value");
        }
    }
	return QVariant();
}

QModelIndex ConfigModel::index(int row, int column, const QModelIndex &parent)
			const
{
	if (!hasIndex(row, column, parent))
		return QModelIndex();

	ConfigItem *parentItem;

	if (!parent.isValid())
		parentItem = rootItem;
	else
		parentItem = static_cast<ConfigItem*>(parent.internalPointer());

	ConfigItem *childItem = parentItem->child(row);
	if (childItem)
		return createIndex(row, column, childItem);
	else
		return QModelIndex();
}

QModelIndex ConfigModel::parent(const QModelIndex &index) const
{
	if (!index.isValid())
		return QModelIndex();

	ConfigItem *childItem = static_cast<ConfigItem*>(index.internalPointer());
	ConfigItem *parentItem = childItem->parent();

	if (parentItem == rootItem)
		return QModelIndex();

	return createIndex(parentItem->row(), 0, parentItem);
}

int ConfigModel::rowCount(const QModelIndex &parent) const
{
	ConfigItem *parentItem;
	if (parent.column() > 0)
		return 0;

	if (!parent.isValid())
		parentItem = rootItem;
	else
		parentItem = static_cast<ConfigItem*>(parent.internalPointer());

	return parentItem->childCount();
}
