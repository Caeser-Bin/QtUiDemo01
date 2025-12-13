//
// Created by Caesar on 2025/11/30.
//

#ifndef QTUIDEMO_MAINWINDOW_H
#define QTUIDEMO_MAINWINDOW_H

#include <QMainWindow>


QT_BEGIN_NAMESPACE

namespace Ui
{
    class MainWindow;
}

QT_END_NAMESPACE

class MainWindow final : public QMainWindow
{
    Q_OBJECT

public:
    explicit MainWindow(QWidget* parent = nullptr);
    ~MainWindow() override;

private:
    void init();
    void connectSlots();

private slots:
    void outputBtnClicked();
    void outputBtn2Clicked();

private:
    Ui::MainWindow* ui;
};


#endif //QTUIDEMO_MAINWINDOW_H