//
// Created by Caesar on 2025/12/2.
//

#include "Module.h"

// 注册事件模块到App中

#include "AppModuleMgr.h"
#include "EventSystem.h"

class EventSystemModule final : public Module {
public:
    explicit EventSystemModule() {
        m_eventSystem = std::make_shared<EventSystem>();
    }

    ~EventSystemModule() override;

    void initialize() override {
    }

    void start() override {
    }

    void shutdown() override {
    }

    std::string getName() const override {
        return "EventSystemModule";
    }

public:
    SP<EventSystem> m_eventSystem;
};

// 在模块实现文件中使用
REGISTER_MODULE(EventSystemModule)

namespace Modules {
SP<EventSystem> eventSystem() {
    return EventSystemModule::instance().m_eventSystem;
}
}