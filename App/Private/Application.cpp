//
// Created by Caesar on 2025/12/2.
//

#include "Application.h"
#include "AppModuleMgr.h"
#include <iostream>

Application::Application(const int argc, char *argv[])
    : argc_(argc), argv_(argv) {
    initialize();
}

Application::~Application() {
    cleanup();
}

void Application::initialize() {
    // 初始化应用程序基础组件
    std::cout << "Initializing application..." << std::endl;
    // 可以在这里添加日志系统、配置系统等初始化
}

void Application::cleanup() {
    // 清理资源
    std::cout << "Cleaning up application resources..." << std::endl;
}

int Application::execute() {
    try {
        // 执行主程序逻辑
        std::cout << "Application started successfully!" << std::endl;

        // 这里可以调用模块管理器来启动各个模块
        AppModuleMgr::instance().startModules();

        // 主循环或者其他业务逻辑
        while (true) {
        }

        return 0; // 正常退出
    } catch (const std::exception &e) {
        std::cerr << "Application error: " << e.what() << std::endl;
        return -1; // 异常退出
    }
}
