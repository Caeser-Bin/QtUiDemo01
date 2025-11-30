# impl/CMakeLists.txt
cmake_minimum_required(VERSION 3.16)

set(LIB_NAME event_impl)

project(${LIB_NAME})

# 查找 public 目录下的 .cpp 文件
file(GLOB PUBLIC_SOURCES "public/*.cpp")
# 查找 private 目录下的 .cpp 文件
file(GLOB PRIVATE_SOURCES "private/*.cpp")
# 合并所有源文件
set(SOURCES ${PUBLIC_SOURCES} ${PRIVATE_SOURCES})
# 添加核心库（静态库）
add_library(${LIB_NAME} STATIC ${SOURCES})

# 引用 core 库
target_link_libraries(${LIB_NAME} PRIVATE event_core)
