//
// Created by Caesar on 2025/12/13.
//

#ifndef QTUIDEMO_EVENT_CONTENT_H
#define QTUIDEMO_EVENT_CONTENT_H
#include <cstdint>
#include <string>
#include <vector>

template <typename T = std::string>
struct EventContent {
public:

private:
    std::vector<uint8_t> m_data;
    T arg;
};


#endif //QTUIDEMO_EVENT_CONTENT_H