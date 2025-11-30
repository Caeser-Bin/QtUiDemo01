# Module/CMakeLists.txt
cmake_minimum_required(VERSION 3.16)
set(CMAKE_CXX_STANDARD 23)
set(LIB_NAME event_module)
project(${LIB_NAME})

# 查找 public 目录下的 .cpp 文件
file(GLOB PUBLIC_SOURCES "public/*.cpp")
# 查找 private 目录下的 .cpp 文件
file(GLOB PRIVATE_SOURCES "private/*.cpp")

# 合并所有源文件
set(SOURCES ${PUBLIC_SOURCES} ${PRIVATE_SOURCES})

add_executable(${LIB_NAME} STATIC ${SOURCES})

# 链接 core 和 impl
target_link_libraries(${LIB_NAME} PRIVATE event_core event_impl)
