make_module(eventCore .)

## core/CMakeLists.txt
#cmake_minimum_required(VERSION 3.16)
#
#set(LIB_NAME event_core)
#
#project(${LIB_NAME})
#
#set(CMAKE_CXX_STANDARD 17)
#
## 查找 public 目录下的 .cpp 文件
#file(GLOB PUBLIC_SOURCES "public/*.cpp")
## 查找 private 目录下的 .cpp 文件
#file(GLOB PRIVATE_SOURCES "private/*.cpp")
#
## 合并所有源文件
#set(SOURCES ${PUBLIC_SOURCES} ${PRIVATE_SOURCES})
#
## 添加核心库（静态库）
#add_library(${LIB_NAME} STATIC ${SOURCES})
#
## 设置私有头文件路径（仅供本库内部使用）
#target_include_directories(${LIB_NAME} PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/private)
#
## 设置公共头文件路径（供外部使用）
#target_include_directories(${LIB_NAME} PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/public)
#
## 如果需要导出符号（如在 Windows 上用 DLL），可添加：
##set_target_properties(${LIB_NAME} PROPERTIES PREFIX "")
