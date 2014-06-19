/*
 * Copyright (C) 2013 David Gräff <david.graeff@web.de>
 * Released under the terms of the GNU GPL v2.0.
 */

#ifndef SEARCHFILTERMODELPROXY_H
#define SEARCHFILTERMODELPROXY_H

#include <QSortFilterProxyModel>

class SearchFilterModelProxy : public QSortFilterProxyModel
{
    Q_OBJECT
public:
    explicit SearchFilterModelProxy(QObject *parent = 0);
    /**
     * @brief Define types for filtering
     */
    enum opt_enum {
        OPT_NORMAL, OPT_ALL, OPT_PROMPT
    };
    /**
     * @brief Set type for filtering
     */
    void setFilterType(opt_enum option);
private:
    opt_enum mFilterOption;
    bool filterAcceptsRow(int sourceRow, const QModelIndex &sourceParent) const;
signals:
    
public slots:
    
};

#endif // SEARCHFILTERMODELPROXY_H
