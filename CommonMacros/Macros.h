//
// Created by Caesar on 2025/12/13.
//

#ifndef QTUIDEMO_MACROS_H
#define QTUIDEMO_MACROS_H
#include <memory>

template <typename T>
using SP = std::shared_ptr<T>;

template <typename T>
using WP = std::weak_ptr<T>;

template <typename T>
using UP = std::unique_ptr<T>;

template <typename T, typename... Args>
SP<T> makeSP(Args... args) {
    return std::make_shared<T>(std::forward<Args>(args)...);
}

template <typename T, typename... Args>
UP<T> makeUP(Args... args) {
    return std::make_unique<T>(std::forward<Args>(args)...);
}

#endif //QTUIDEMO_MACROS_H
