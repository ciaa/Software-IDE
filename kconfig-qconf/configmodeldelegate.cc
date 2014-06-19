#include "configmodeldelegate.h"
#include "configItem.h"
#include "searchfiltermodelproxy.h"
#include <QDebug>
#include <QApplication>

ConfigModelDelegate::ConfigModelDelegate(SearchFilterModelProxy *model, QObject *p) : QStyledItemDelegate(p), mModel(model)
{
}

bool ConfigModelDelegate::needRadiobutton(const QModelIndex &index, bool& checked) const
{
    /**
     * Get config item out of the model index. Because we use a proxy model, we have to use mapToSource.
     */
    ConfigItem* item = static_cast<ConfigItem*>(mModel->mapToSource(index).internalPointer());
    bool radioButtonSelected = false;
    bool radioButtonEnabled = false;
    /// Determine if a radio button should be drawn and its state
    switch(index.column()) {
        case 0:
            radioButtonEnabled = item->mIsChoice;
            radioButtonSelected = item->mIsChoice && item->mEnabled == ConfigItem::en_yes;
            break;
        case 2:
            radioButtonEnabled = item->mEnableRange[ConfigItem::en_no];
            radioButtonSelected = item->mEnabled == ConfigItem::en_no;
            break;
        case 3:
            radioButtonEnabled = item->mEnableRange[ConfigItem::en_mod];
            radioButtonSelected = item->mEnabled == ConfigItem::en_mod;
            break;
        case 4:
            radioButtonEnabled = item->mEnableRange[ConfigItem::en_yes] && !item->mIsChoice;
            radioButtonSelected = item->mEnabled == ConfigItem::en_yes;
            break;
    }
    checked = radioButtonSelected;
    return radioButtonEnabled;
}

void ConfigModelDelegate::paint(QPainter *painter, const QStyleOptionViewItem &option, const QModelIndex &index) const
{
    bool radioButtonSelected;
    if (needRadiobutton(index, radioButtonSelected)) {
        QStyle *style = QApplication::style();

        /// draw background appearance (highlighting)
        QStyleOptionViewItem myOption = option;
        int left = myOption.rect.left();
        QStyleOptionViewItemV4 opt = option;
        initStyleOption(&opt,index);
        style->drawPrimitive(QStyle::PE_PanelItemViewItem, &opt, painter);

        /// determine size and spacing of radio buttons in current style
        int radioButtonWidth = style->pixelMetric(QStyle::PM_ExclusiveIndicatorWidth, &option);
        int spacing = style->pixelMetric(QStyle::PM_RadioButtonLabelSpacing, &option);

        /// draw radio button
        myOption.rect.setLeft(left + spacing / 2);
        myOption.rect.setWidth(radioButtonWidth);
        myOption.state |= radioButtonSelected ? QStyle::State_On : QStyle::State_Off;
        style->drawPrimitive(QStyle::PE_IndicatorRadioButton, &myOption, painter);

        /// draw text if any
        QString name = index.data( Qt::DisplayRole ).toString();
        if (name.size())
        {
            QFontMetrics fm(option.font);
            QRect nameRect( option.rect.topLeft(), fm.size( 0, name ) );
            nameRect.setHeight( option.rect.height() );
            /// move x position
            nameRect.moveLeft( left + spacing * 3 / 2 + radioButtonWidth );
            style->drawItemText( painter, nameRect, Qt::AlignLeft | Qt::AlignVCenter, option.palette,
                                     true, name );
        }
    } else
        QStyledItemDelegate::paint(painter, option, index);
}

QSize ConfigModelDelegate::sizeHint(const QStyleOptionViewItem &option, const QModelIndex &index) const
{
    QSize s = QStyledItemDelegate::sizeHint(option, index);
    /// determine size of radio buttons in current style
    int radioButtonHeight = QApplication::style()->pixelMetric(QStyle::PM_ExclusiveIndicatorHeight, &option);
    /// ensure that line is tall enough to draw radio buttons and checkboxes
    s.setHeight(qMax(s.height(), radioButtonHeight));
    bool radioButtonSelected;
    if (needRadiobutton(index, radioButtonSelected)) {
        int radioButtonWidth = QApplication::style()->pixelMetric(QStyle::PM_ExclusiveIndicatorWidth, &option);
        int spacing = QApplication::style()->pixelMetric(QStyle::PM_RadioButtonLabelSpacing, &option);
        s.setWidth(s.width() + spacing * 3 / 2 + radioButtonWidth);
    }
    return s;
}
