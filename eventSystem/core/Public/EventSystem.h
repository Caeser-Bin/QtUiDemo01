//
// Created by Caesar on 2025/12/13.
//

#ifndef QTUIDEMO_EVENTSYSTEM_H
#define QTUIDEMO_EVENTSYSTEM_H
#include <functional>
#include <map>
#include <string>

#include "Event.h"
#include "EventContent.h"
#include "Macros.h"


class EventSystem {
public:
    explicit EventSystem() = default;
    ~EventSystem() = default;

private:
    using Handler = std::function<void(const SP<Event> &)>;

public:
    void registerEventHandler(
        const std::string &eventName,
        const Handler &handler);

    void dispatchEvent(const SP<Event> &event);

    void unregisterEventHandler(const std::string &eventName);

    void clearEventHandlers();

private:
    std::map<std::string, Handler> m_eventHandlers;
};


#endif //QTUIDEMO_EVENTSYSTEM_H