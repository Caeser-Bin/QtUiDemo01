
# 查询当前文件夹下所有源文件
file(GLOB_RECURSE SRC_FILES *.cpp *.c)

add_executable(a ${SRC_FILES})