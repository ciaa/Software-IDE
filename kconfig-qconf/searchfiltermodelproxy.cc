/*
 * Copyright (C) 2013 David Graeff <david.graeff@udo.edu>
 * Released under the terms of the GNU GPL v2.0.
 */
#include "searchfiltermodelproxy.h"
#include "configModel.h"

SearchFilterModelProxy::SearchFilterModelProxy(QObject *parent) :
    QSortFilterProxyModel(parent)
{
    this->mFilterOption = OPT_NORMAL;
    setDynamicSortFilter(true);
    setFilterCaseSensitivity(Qt::CaseInsensitive);
}

void SearchFilterModelProxy::setFilterType(opt_enum option)
{
    this->mFilterOption = option;
    beginResetModel();
    endResetModel();
}

bool SearchFilterModelProxy::filterAcceptsRow(int sourceRow,
        const QModelIndex &sourceParent) const
{
    bool ok = true;
    if (mFilterOption == OPT_NORMAL) {
        QModelIndex index0 = sourceModel()->index(sourceRow, 0, sourceParent);
        ok = sourceModel()->data(index0, ConfigModel::MenuVisibleRole).toBool();
    } else if (mFilterOption == OPT_PROMPT) {
        QModelIndex index0 = sourceModel()->index(sourceRow, 0, sourceParent);
        ok = sourceModel()->data(index0, ConfigModel::MenuHasPromptRole).toBool();
    }

    return ok && QSortFilterProxyModel::filterAcceptsRow(sourceRow, sourceParent);
}
