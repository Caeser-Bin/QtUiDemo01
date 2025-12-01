#获取当前cmake脚本所在目录
set(SCRIPT_ROOT ${CMAKE_CURRENT_LIST_DIR})

#获取当前目录下所有cmake脚本
file(GLOB OTHER_SCRIPTS "${SCRIPT_ROOT}/*.cmake")

#获取所有其他的cmake脚本
list(FILTER OTHER_SCRIPTS EXCLUDE REGEX ".loadScripts.*")

#包含所有其他cmake脚本
foreach (SCRIPTS ${OTHER_SCRIPTS})
    if (NOT ${SCRIPTS} MATCHES "buildWasm.cmake")
        include(${SCRIPTS})
    endif ()
endforeach ()