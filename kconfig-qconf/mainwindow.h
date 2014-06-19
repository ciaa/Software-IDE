/*
 * Copyright (C) 2013 David Gräff <david.graeff@web.de>
 * Released under the terms of the GNU GPL v2.0.
 */

#ifndef QCONF_MAINWINDOW_H
#define QCONF_MAINWINDOW_H

#include <QMainWindow>
#include <QModelIndex>

namespace Ui {
class qconf_MainWindow;
}
class ConfigModel;
class SearchFilterModelProxy;

class qconf_MainWindow : public QMainWindow
{
    Q_OBJECT
    
public:
    explicit qconf_MainWindow(QWidget *parent = 0);
    ~qconf_MainWindow();
    
private Q_SLOTS:
    void on_actionExpand_triggered();
    void on_actionCollapse_triggered();
    void on_actionAbout_triggered();
    void on_actionIntroduction_triggered();
    void on_actionQuit_triggered();
    void on_actionSave_as_triggered();
    void on_actionSave_triggered();
    void on_actionLoad_triggered();
    void typeofOptions_triggered(QAction * action);
    void on_actionBack_triggered();
    void on_actionSingleView_triggered();
    void on_actionSplitView_triggered();
    void on_actionFullView_triggered();
    void on_actionShow_Name_triggered();
    void on_actionShow_Range_triggered();
    void on_actionShow_Data_Value_triggered();
    void on_treeNavigate_clicked(const QModelIndex &index);
    void on_treeAll_clicked(const QModelIndex &index);
    void on_treeAll_activated(const QModelIndex &index);
    void on_listSearch_clicked(const QModelIndex &index);

    void on_actionHide_disabled_subtrees_triggered();

private:
    Ui::qconf_MainWindow *ui;
    ConfigModel* mBaseModel;
    SearchFilterModelProxy* mModel;
    enum view_mode_enum {
        SINGLE_VIEW, SPLIT_VIEW, FULL_VIEW
    } view_mode;

    void closeEvent(QCloseEvent* e);
    /**
     * @brief Call this method after changes to the config.
     * This method sets the state of the save button etc.
     * @return Return true if config has been changed.
     */
    bool check_conf_changed();
    /**
     * Called by constructor and load..(). Display data depending on the view mode
     * and changes the layout.
     */
    void show_data(view_mode_enum view_mode);
    void updateCurrentPositionLabel();
};

#endif // QCONF_MAINWINDOW_H
