//
// Created by Caesar on 2025/12/2.
//

#ifndef QTUIDEMO_EVENT_H
#define QTUIDEMO_EVENT_H
#include <string>
#include <utility>

class Event {
public:
    explicit Event(std::string name) : m_name(std::move(name)) {
    }

    [[nodiscard]] const std::string &name() const {
        return m_name;
    }

private:
    std::string m_name;
};

#endif //QTUIDEMO_EVENT_H