//
// Created by Caesar on 2025/12/13.
//

#include "EventSystem.h"

void EventSystem::registerEventHandler(
    const std::string &eventName,
    const Handler &handler) {
    m_eventHandlers[eventName] = handler;
}

void EventSystem::dispatchEvent(const SP<Event> &event) {
    if (const auto handler = m_eventHandlers.find(event->name()); handler !=
        m_eventHandlers.end()) {
        handler->second(event);
    }
}

void EventSystem::unregisterEventHandler(const std::string &eventName) {
    m_eventHandlers.erase(eventName);
}

void EventSystem::clearEventHandlers() {
    m_eventHandlers.clear();
}