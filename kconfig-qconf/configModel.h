/*
 * Copyright (C) 2013 David Gräff <david.graeff@web.de>
 * Released under the terms of the GNU GPL v2.0.
 */

#ifndef QCONF_CONFIGMODEL_H_
#define QCONF_CONFIGMODEL_H_

#include <QAbstractItemModel>
#include <QModelIndex>
#include <QVariant>
#include <QObject>

class ConfigItem;
struct menu;
class ConfigModel : public QAbstractItemModel
{
	Q_OBJECT

public:
    ConfigModel(QObject *parent = 0);
	~ConfigModel();
    QModelIndex indexOf(struct menu* menu, const QModelIndex &top = QModelIndex());

	QVariant data(const QModelIndex &index, int role) const;
	Qt::ItemFlags flags(const QModelIndex &index) const;
	QVariant headerData(int section, Qt::Orientation orientation,
						int role = Qt::DisplayRole) const;
	QModelIndex index(int row, int column,
					const QModelIndex &parent = QModelIndex()) const;
	QModelIndex parent(const QModelIndex &index) const;
	int rowCount(const QModelIndex &parent = QModelIndex()) const;
	int columnCount(const QModelIndex &parent = QModelIndex()) const;
    bool setData ( const QModelIndex & index, const QVariant & value, int role = Qt::EditRole );
    bool hasChildren ( const QModelIndex & parent = QModelIndex() ) const;

    enum ConfigModelRoles {
        MenuVisibleRole = Qt::UserRole,
        MenuHasPromptRole
    };
public Q_SLOTS:
    void setHideChildren(bool enabled);
private:
    /// if mHideChilderen == true, all children of an item are hidden, if
    /// the state of the item is unchecked/disabled
    bool mHideChildren;
	ConfigItem *rootItem;
    void updateAllItems(const QModelIndex &top);
};
 
#endif
