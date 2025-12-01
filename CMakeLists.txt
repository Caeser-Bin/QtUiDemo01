cmake_minimum_required(VERSION 4.0)
project(QtUiDemo)

set(CMAKE_CXX_STANDARD 23)

# 设置所有库文件的输出目录
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/bin)

include(BuildKits/loadScripts.cmake)

add_subdirectory(ui)

add_subdirectory(eventSystem)

add_executable(QtUiDemo main.cpp)

target_link_libraries(QtUiDemo UI_LIBRARY)
