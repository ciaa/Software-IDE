/*
 * Copyright (C) 2013 David Gräff <david.graeff@web.de>
 * Released under the terms of the GNU GPL v2.0.
 */

#ifndef CONFIGMODELDELEGATE_H
#define CONFIGMODELDELEGATE_H

#include <QStyledItemDelegate>
class SearchFilterModelProxy;

/**
 * @brief This delegate is responsible for drawing radio buttons in tree views.
 * Qt nativly supports using checkboxes in views. Because we also need radio
 * buttons, we have to use this delegate and draw them ourselfs.
 */
class ConfigModelDelegate : public QStyledItemDelegate
{
public:
    ConfigModelDelegate(SearchFilterModelProxy* model, QObject *p);
    void paint(QPainter *painter, const QStyleOptionViewItem &option, const QModelIndex &index) const;
    virtual QSize sizeHint(const QStyleOptionViewItem &option, const QModelIndex &index) const;
private:
    SearchFilterModelProxy* mModel;
    bool needRadiobutton(const QModelIndex &index, bool& checked) const;
};

#endif // CONFIGMODELDELEGATE_H
