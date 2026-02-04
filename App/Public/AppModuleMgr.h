//
// Created by Caesar on 2025/12/13.
//

#ifndef QTUIDEMO_APPMODULE_H
#define QTUIDEMO_APPMODULE_H
#include <algorithm>
#include <map>
#include <memory>
#include <ranges>
#include <vector>

// 模块接口定义
class Module {
public:
    virtual ~Module() = default;

public:
    virtual void initialize() = 0;
    virtual void start() = 0;
    virtual void shutdown() = 0;
    virtual std::string getName() const = 0;
};

// 使用宏定义自动注册
#define REGISTER_MODULE(module_class)                           \
static struct module_class##Registrar {                         \
    module_class##Registrar() {                                 \
        AppModuleMgr::instance().registerModule(                \
            std::make_unique<module_class> ()                   \
        );                                                      \
    }                                                           \
} module_class##_registrar;

class AppModuleMgr {
public:
    static AppModuleMgr &instance() {
        static AppModuleMgr instance;
        return instance;
    }

private:
    AppModuleMgr() = default;

public:
    void registerModule(std::unique_ptr<Module> module) {
        modulesMap[module->getName()] = std::move(module);
        modulesMap[module->getName()]->initialize();
    }

    void startModules() {
        for (const auto &val : modulesMap | std::views::values) {
            val->start();
        }
    }

private:
    std::map<std::string, std::unique_ptr<Module>> modulesMap;
};


#endif //QTUIDEMO_APPMODULE_H