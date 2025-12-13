//
// Created by Caesar on 2025/11/30.
//

// You may need to build the project (run Qt uic code generator) to get "ui_MainWindow.h" resolved

#include "mainwindow.h"

#include <iostream>

#include "ui_MainWindow.h"

MainWindow::MainWindow(QWidget* parent) :
    QMainWindow(parent), ui(new Ui::MainWindow)
{
    ui->setupUi(this);
    init();
    connectSlots();
}

MainWindow::~MainWindow()
{
    delete ui;
}

void MainWindow::init()
{

}

void MainWindow::connectSlots()
{
    connect( ui->outputBtn, &QPushButton::clicked, this, &MainWindow::outputBtnClicked);
    connect( ui->outputBtn2, &QPushButton::clicked, this, &MainWindow::outputBtn2Clicked);
}

void MainWindow::outputBtnClicked()
{
    std::cout<< "八个雅鹿!"<<std::endl;
}

void MainWindow::outputBtn2Clicked()
{
    std::cout<< "Hello World2!"<<std::endl;
}
