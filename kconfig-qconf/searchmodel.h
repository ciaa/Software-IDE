#ifndef SEARCHMODEL_H
#define SEARCHMODEL_H

#include <QAbstractListModel>
#include <QList>

struct menu;
class SearchModel : public QAbstractListModel
{
    Q_OBJECT
public:
    SearchModel(QObject *parent = 0);
    QVariant data(const QModelIndex &index, int role) const;
    int rowCount(const QModelIndex &parent = QModelIndex()) const;
public Q_SLOTS:
    void setSearch(const QString& text);
private:
    struct item {
        QString text;
        struct menu* menu;
        bool visible;
        item(struct menu* menu);
    };

    QList<item*> mItems;
};

#endif // SEARCHMODEL_H
