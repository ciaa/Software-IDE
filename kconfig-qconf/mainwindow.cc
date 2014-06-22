/*
 * Copyright (C) 2013 David Graeff <david.graeff@udo.edu>
 * Released under the terms of the GNU GPL v2.0.
 */

#include "mainwindow.h"
#include "ui_mainwindow.h"
#include "searchfiltermodelproxy.h"
#include "configModel.h"
#include "configItem.h"
#include "configmodeldelegate.h"
#include "searchmodel.h"
#include <QMessageBox>
#include <QSettings>
#include <QCloseEvent>
#include <QFileDialog>
#include <QLineEdit>
#include <QDebug>
#define IMAGES_TOOLBAR
#include "./images.c"
#include "./expr.h"
#include "./lkc.h"

bool qconf_MainWindow::check_conf_changed()
{
    bool changed = conf_get_changed();
    ui->actionSave->setEnabled(changed);
    return changed;
}

void qconf_MainWindow::show_data(view_mode_enum view_mode)
{
    this->view_mode = view_mode;
    ui->treeAll->setRootIndex(QModelIndex());
    ui->labelPosition->clear();
    switch(view_mode) {
        case FULL_VIEW: {
            ui->splitter_2->setChildrenCollapsible(true);
            ui->splitter_2->setSizes(QList<int>() << 0 << width());
            ui->splitter_2->setChildrenCollapsible(false);
            ui->actionFullView->setChecked(true);
            ui->btnBack->setVisible(false);
            ui->treeAll->setItemsExpandable(true);
            break;
        }
        case SPLIT_VIEW:{
            ui->splitter_2->setChildrenCollapsible(false);
            ui->splitter_2->setSizes(QList<int>() << width()*0.3 << width()*0.7);
            ui->actionSplitView->setChecked(true);
            ui->btnBack->setVisible(false);
            ui->treeAll->setItemsExpandable(true);
            break;
        };
        case SINGLE_VIEW:{
            ui->treeAll->collapseAll();
            ui->splitter_2->setChildrenCollapsible(true);
            ui->splitter_2->setSizes(QList<int>() << 0 << width());
            ui->splitter_2->setChildrenCollapsible(false);
            ui->actionSingleView->setChecked(true);
            ui->btnBack->setVisible(true);
            ui->actionBack->setEnabled(false);
            ui->treeAll->setItemsExpandable(false);
            break;
        };
    }
}

qconf_MainWindow::qconf_MainWindow(QWidget *parent) :
    QMainWindow(parent),
    ui(new Ui::qconf_MainWindow)
{
    ui->setupUi(this);
    { // Restore window geometry
        QSettings settings;
        restoreGeometry(settings.value("geometry").toByteArray());
        restoreState(settings.value("windowState").toByteArray());
        setWindowTitle(rootmenu.prompt->text);
    }
    { // Action groups for menu items in the option menu
        QActionGroup* g = new QActionGroup(this);
        g->addAction(ui->actionShow_all_Options);
        g->addAction(ui->actionShow_normal_Options);
        g->addAction(ui->actionShow_prompt_Options);
        connect( g, SIGNAL(triggered(QAction*)), this, SLOT(typeofOptions_triggered(QAction*)) );
    }
    { // Action groups for menu items in the option menu
        QActionGroup* g = new QActionGroup(this);
        g->setExclusive(false);
        g->addAction(ui->actionShow_Data_Value);
        g->addAction(ui->actionShow_Name);
        g->addAction(ui->actionShow_Range);
        connect( g, SIGNAL(triggered(QAction*)), this, SLOT(typeofOptions_triggered(QAction*)) );
    }
    { // icons for actions
        ui->actionSingleView->setIcon(QPixmap(xpm_single_view));
        ui->actionSplitView->setIcon(QPixmap(xpm_split_view));
        ui->actionFullView->setIcon(QPixmap(xpm_tree_view));
    }
    { // Menubar
        QToolBar *bar = ui->mainToolBar;
        bar->addActions(QList<QAction*>() << ui->actionLoad << ui->actionSave);
        bar->addSeparator();
        bar->addActions(QList<QAction*>() << ui->actionSingleView << ui->actionSplitView << ui->actionFullView);
        QActionGroup* g = new QActionGroup(this);
        g->addAction(ui->actionSingleView);
        g->addAction(ui->actionSplitView);
        g->addAction(ui->actionFullView);
    }
    { // add actions to tree views
        ui->treeAll->setContextMenuPolicy(Qt::ActionsContextMenu);
        QAction* sep = new QAction(this);
        sep->setSeparator(true);
        ui->treeAll->addActions(QList<QAction*>() << ui->actionExpand << ui->actionCollapse << sep <<
                                ui->actionShow_Data_Value << ui->actionShow_Name << ui->actionShow_Range);
        ui->treeNavigate->setContextMenuPolicy(Qt::ActionsContextMenu);
        ui->treeNavigate->addActions(QList<QAction*>() << ui->actionExpand << ui->actionCollapse);
        ui->btnBack->setDefaultAction(ui->actionBack);
    }
    { // tree model and proxy model (the proxy filters entries according to the entered search pattern)
        mBaseModel = new ConfigModel;
        mModel = new SearchFilterModelProxy;
        mModel->setSourceModel(mBaseModel);
        ui->treeAll->setModel(mModel);
        ui->treeNavigate->setModel(mModel);
        ui->treeAll->setItemDelegate(new ConfigModelDelegate(mModel, this));
        ui->treeNavigate->setItemDelegate(new ConfigModelDelegate(mModel, this));
        // hide columns in the left tree view
        ui->treeNavigate->hideColumn(5);
        ui->treeNavigate->hideColumn(4);
        ui->treeNavigate->hideColumn(3);
        ui->treeNavigate->hideColumn(2);
        ui->treeNavigate->hideColumn(1);
        QHeaderView* header = ui->treeAll->header();
#if QT_VERSION >= 0x050000
        header->setSectionResizeMode(0, QHeaderView::ResizeToContents);
        header->setSectionResizeMode(1, QHeaderView::Interactive);
        header->setSectionResizeMode(2, QHeaderView::Fixed);
        header->setSectionResizeMode(3, QHeaderView::Fixed);
        header->setSectionResizeMode(4, QHeaderView::Fixed);
        header->setSectionResizeMode(5, QHeaderView::Stretch);
#else
        header->setResizeMode(0, QHeaderView::ResizeToContents);
        header->setResizeMode(1, QHeaderView::Interactive);
        header->setResizeMode(2, QHeaderView::Fixed);
        header->setResizeMode(3, QHeaderView::Fixed);
        header->setResizeMode(4, QHeaderView::Fixed);
        header->setResizeMode(5, QHeaderView::Stretch);
#endif
        header->resizeSection(2, 30);
        header->resizeSection(3, 30);
        header->resizeSection(4, 30);
        ui->treeAll->setFirstColumnSpanned(0, QModelIndex(), true);
    }
    { // Search
        SearchModel* sm = new SearchModel(this);
        connect(ui->lineSearch, SIGNAL(textChanged(QString)), sm, SLOT(setSearch(QString)));
        ui->listSearch->setModel(sm);
    }
    { // init
        check_conf_changed();
        QSettings settings;
        show_data((view_mode_enum)settings.value("view_mode", SPLIT_VIEW).toInt());
        ui->actionShow_normal_Options->activate(QAction::Trigger);
    }
}

qconf_MainWindow::~qconf_MainWindow()
{
    delete ui;
    delete mModel;
    delete mBaseModel;
}

void qconf_MainWindow::closeEvent(QCloseEvent* e)
{
    { // save window geometry settings
        QSettings settings;
        settings.setValue("geometry", saveGeometry());
        settings.setValue("windowState", saveState());
        settings.setValue("view_mode", view_mode);
    }

    if (!conf_get_changed()) {
        e->accept();
        return;
    }
    QMessageBox mb("qconf", _("Save configuration?"), QMessageBox::Warning,
            QMessageBox::Yes | QMessageBox::Default, QMessageBox::No, QMessageBox::Cancel | QMessageBox::Escape);
    mb.setButtonText(QMessageBox::Yes, _("&Save Changes"));
    mb.setButtonText(QMessageBox::No, _("&Discard Changes"));
    mb.setButtonText(QMessageBox::Cancel, _("Cancel Exit"));
    switch (mb.exec()) {
    case QMessageBox::Yes:
        if (!conf_write(NULL))
            e->accept();
        else
            e->ignore();
        break;
    case QMessageBox::No:
        e->accept();
        break;
    case QMessageBox::Cancel:
        e->ignore();
        break;
    }
}

void qconf_MainWindow::typeofOptions_triggered(QAction *action)
{
    // Model indexes get invalid if we change the filter
    // -> Reset right view before applying another filter
    ui->treeAll->setRootIndex(QModelIndex());

    if (action == ui->actionShow_all_Options)
        mModel->setFilterType(SearchFilterModelProxy::OPT_ALL);
    else if (action == ui->actionShow_normal_Options)
        mModel->setFilterType(SearchFilterModelProxy::OPT_NORMAL);
    else if (action == ui->actionShow_prompt_Options)
        mModel->setFilterType(SearchFilterModelProxy::OPT_PROMPT);
}


void qconf_MainWindow::on_actionExpand_triggered()
{
    if (ui->treeAll->rect().contains(ui->treeAll->mapFromGlobal(QCursor::pos()))) {
        ui->treeAll->expandAll();
    } else if (ui->treeNavigate->rect().contains(ui->treeNavigate->mapFromGlobal(QCursor::pos()))) {
        ui->treeNavigate->expandAll();
    }
}

void qconf_MainWindow::on_actionCollapse_triggered()
{
    if (ui->treeAll->rect().contains(ui->treeAll->mapFromGlobal(QCursor::pos()))) {
        ui->treeAll->collapseAll();
    } else if (ui->treeNavigate->rect().contains(ui->treeNavigate->mapFromGlobal(QCursor::pos()))) {
        ui->treeNavigate->collapseAll();
    }
}

void qconf_MainWindow::on_actionAbout_triggered()
{
    const QString str = tr(
          "qconf is Copyright (C) 2002 Roman Zippel <zippel@linux-m68k.org>, 2013 David Gräff <david.graeff@web.de>.\n\n"
          "qconf bug reports and feature request can also be entered at http://bugzilla.kernel.org/\n\n"
          "CIAA Firmware bug reports and feature request can also be entered at http://github.com/ciaa/IDE/issues\n\n"
          "CIAA Project Page: http://www.proyecto-ciaa.com.ar\n");

    QMessageBox::information(this, "CIAA Firmware Configuration", str);
}

void qconf_MainWindow::on_actionIntroduction_triggered()
{
    const QString str = tr(
         "This is the CIAA Firmware configuration tool.\n\n"
         "This tool will allow you to configure the CIAA Firmware in an easy way.\n"
         "Please check the help of each parameter and use defaults values if you are not sure.\n\n"
         "Official WebPage: http://www.proyecto-ciaa.com.ar\n\n"
         "Issues shall be reported to : https://github.com/ciaa/IDE/issues\n\n"
         "This configuration tool is based on the Linux Kernel Configuration\n");

    QMessageBox::information(this, "CIAA Firmware Configuration", str);
}

void qconf_MainWindow::on_actionQuit_triggered()
{
    close();
}

void qconf_MainWindow::on_actionSave_as_triggered()
{
    QString s = QFileDialog::getSaveFileName(this, conf_get_configname(), conf_get_configname());
    if (s.isNull())
        return;
    if (conf_write(s.toUtf8().constData())) {
        QMessageBox::information(this, "qconf", _("Unable to save configuration!"));
    }
}

void qconf_MainWindow::on_actionSave_triggered()
{
    if (conf_write(NULL)) {
        QMessageBox::information(this, "qconf", _("Unable to save configuration!"));
    }
}

void qconf_MainWindow::on_actionLoad_triggered()
{
    QString s = QFileDialog::getOpenFileName(this, conf_get_configname(), conf_get_configname());
    if (s.isNull())
        return;
    if (conf_read(QFile::encodeName(s)))
        QMessageBox::information(this, "qconf", _("Unable to load configuration!"));
    else
    {}//TODO
}

void qconf_MainWindow::on_actionBack_triggered()
{
    // if (view_mode==SINGLE_VIEW)
    QModelIndex current = ui->treeAll->rootIndex();
    QModelIndex parent = current.parent();
    ui->treeAll->setRootIndex(parent);
    ui->actionBack->setEnabled(parent.isValid());
    ui->treeAll->scrollTo(current);
    updateCurrentPositionLabel();
}

void qconf_MainWindow::on_actionSingleView_triggered()
{
    show_data(SINGLE_VIEW);
}

void qconf_MainWindow::on_actionSplitView_triggered()
{
    show_data(SPLIT_VIEW);
}

void qconf_MainWindow::on_actionFullView_triggered()
{
    show_data(FULL_VIEW);
}

void qconf_MainWindow::on_actionShow_Name_triggered()
{
    ui->treeAll->setColumnHidden(1, !ui->actionShow_Name->isChecked());
}

void qconf_MainWindow::on_actionShow_Range_triggered()
{
    ui->treeAll->setColumnHidden(2, !ui->actionShow_Range->isChecked());
    ui->treeAll->setColumnHidden(3, !ui->actionShow_Range->isChecked());
    ui->treeAll->setColumnHidden(4, !ui->actionShow_Range->isChecked());
}

void qconf_MainWindow::on_actionShow_Data_Value_triggered()
{
    ui->treeAll->setColumnHidden(5, !ui->actionShow_Data_Value->isChecked());
}

void qconf_MainWindow::on_treeNavigate_clicked(const QModelIndex &index)
{
    if (view_mode==SPLIT_VIEW && ui->treeAll->model()->hasChildren(index)) {
        ui->treeAll->setRootIndex(index);
    }
    ConfigItem* item = static_cast<ConfigItem*>(mModel->mapToSource(index).internalPointer());
    ui->textBrowser->setInfo(item->menu());
}

void qconf_MainWindow::on_treeAll_clicked(const QModelIndex &index)
{
    ConfigItem* item = static_cast<ConfigItem*>(mModel->mapToSource(index).internalPointer());
    ui->textBrowser->setInfo(item->menu());
}

void qconf_MainWindow::on_treeAll_activated(const QModelIndex &index)
{
    if (view_mode==SINGLE_VIEW && ui->treeAll->model()->hasChildren(index)) {

        ui->treeAll->setRootIndex(index);
        ui->actionBack->setEnabled(true);
        updateCurrentPositionLabel();
    }
}

void qconf_MainWindow::on_listSearch_clicked(const QModelIndex &index)
{
    struct menu *menu = (struct menu *)ui->listSearch->model()->data(index, Qt::UserRole).value<void*>();
    QModelIndex orig_index = mBaseModel->indexOf(menu);
    QModelIndex translated_index = mModel->mapFromSource(orig_index);
    ui->treeAll->scrollTo(translated_index);
}

void qconf_MainWindow::updateCurrentPositionLabel()
{
    QString t;
    ConfigItem* item = static_cast<ConfigItem*>(mModel->mapToSource(ui->treeAll->rootIndex()).internalPointer());
    while(item) {
        t.prepend(item->mOption);
        item = item->parent();
        if (item)
            t.prepend(tr(" > "));
    }
    ui->labelPosition->setText(t);
}

void qconf_MainWindow::on_actionHide_disabled_subtrees_triggered()
{
    mBaseModel->setHideChildren(ui->actionHide_disabled_subtrees->isChecked());
}
