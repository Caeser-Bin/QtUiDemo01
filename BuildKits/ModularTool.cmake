### public

function(add_project_source dir)
    add_subdirectory(${dir})
    set_property(GLOBAL PROPERTY PXX_SOURCE_NAME "${dir}")
    #    module_depend_check()
endfunction()


#创建模块，并编译源代码的函数
function(make_module MODULE_NAME PATH)
    add_compile_definitions(MODULE_NAME_DEF="${MODULE_NAME}")

    #找出兴趣文件和目录
    find_folder_under(${PATH} "Public" PUBLIC_FOLDERS)
    find_folder_under(${PATH} "Private" PRIVATE_FOLDERS)

    # error and tip
    if (NOT DEFINED PUBLIC_FOLDERS)
        message(SEND_ERROR "cannot find 'Public' folder under module '${MODULE_NAME}'")
        return()
    endif ()

    if (NOT DEFINED PRIVATE_FOLDERS)
        message(STATUS "treat module '${MODULE_NAME}' as a template module (none source files)!")
        create_interface_module(${MODULE_NAME} ${PUBLIC_FOLDERS})
        return()
    else ()
        find_all_sources(${PRIVATE_FOLDERS} SOURCES)
    endif ()

    if (NOT DEFINED SOURCES)
        message(SEND_ERROR "module '${MODULE_NAME}' doesn't contain any source file")
        return()
    endif ()

    #判断构建类型
    if (NOT BUILD_STATIC)
        set(BUILD_TYPE SHARED)
    else ()
        set(BUILD_TYPE STATIC)
    endif ()

    #编译库
    make_library(${MODULE_NAME} ${BUILD_TYPE} "${SOURCES}")

    config_targets(${MODULE_NAME} "${PUBLIC_FOLDERS}" "${PRIVATE_FOLDERS}")
endfunction()

function(link_public_target MODULE_NAME DEP_MODULE_NAME)
    is_header_only_module(${MODULE_NAME} IS_HEADER_ONLY)
    if (IS_HEADER_ONLY)
        target_link_libraries(${MODULE_NAME} INTERFACE ${DEP_MODULE_NAME})
    else ()
        target_link_libraries(${MODULE_NAME} PUBLIC ${DEP_MODULE_NAME})
    endif ()
endfunction()

function(export_all_symbols MODULE_NAME)
    set_target_properties(${MODULE_NAME} PROPERTIES WINDOWS_EXPORT_ALL_SYMBOLS ON)
endfunction()

function(link_private_target MODULE_NAME DEP_MODULE_NAME)
    target_link_libraries(${MODULE_NAME} PRIVATE ${DEP_MODULE_NAME})
endfunction()

### private

#找到目录下所有源文件
function(find_all_sources UNDER_PATH SOURCE_FILES)
    file(GLOB_RECURSE MATCHED_FILES ${UNDER_PATH}/*.c ${UNDER_PATH}/*.cpp)
    set(${SOURCE_FILES} ${MATCHED_FILES} PARENT_SCOPE)
endfunction()

function(find_sources_under FOLDERS SOURCE_FILES)
    set(SOURCE_LIST)
    foreach (FOLDER ${FOLDERS})
        findAllSources(${FOLDER} SOURCE_UNDER_FOLDER)
        LIST(APPEND SOURCE_LIST ${SOURCE_UNDER_FOLDER})
    endforeach ()
    set(${SOURCE_FILES} ${SOURCE_LIST} PARENT_SCOPE)
endfunction()

#找到目录下所有目标文件夹的文件夹位置
function(find_folder_under UNDER_PATH TARGET_FOLDER INCLUDES_DIR)
    file(GLOB_RECURSE ALL_DIR LIST_DIRECTORIES true ${UNDER_PATH})

    foreach (DIR ${ALL_DIR})
        # 检查当前文件是否为一个文件夹，并且名字符合
        if (IS_DIRECTORY ${DIR} AND ${DIR} MATCHES "/${TARGET_FOLDER}$")
            # 将找到的Public文件夹路径添加到列表中
            list(APPEND MATCHED_DIR ${DIR})
        endif ()
    endforeach ()

    set(${INCLUDES_DIR} ${MATCHED_DIR} PARENT_SCOPE)
endfunction()

#
function(make_library MODULE_NAME BUILD_TYPE SOURCES)
    add_library(${MODULE_NAME} ${BUILD_TYPE} ${SOURCES})
endfunction()

#将帕斯卡式命名转换成下划线式命名
function(create_module_define MODULE_NAME DEFINE_NAME)
    string(REGEX REPLACE "([^A-Z])([A-Z])" "\\1_\\2" UNDERSCORES_NAME "${MODULE_NAME}")
    string(TOUPPER "${UNDERSCORES_NAME}" UPPER_UNDERSCORES_NAME)
    set(${DEFINE_NAME} ${UPPER_UNDERSCORES_NAME} PARENT_SCOPE)
endfunction()

#创建构建时宏命名
function(create_building_define MODULE_NAME DEFINE_NAME)
    create_module_define(${MODULE_NAME} MODULE_DEFINE)
    set(${DEFINE_NAME} "-DBUILDING_${MODULE_DEFINE}" PARENT_SCOPE)
endfunction()

#创建接口库（只含有头文件）
function(create_interface_module MODULE_NAME INCLUDE_DIR)
    add_library(${MODULE_NAME} INTERFACE)
    target_include_directories(${MODULE_NAME} INTERFACE ${INCLUDE_DIR})
endfunction()

# 在目录层级下创建模块，并编译源代码的函数
function(make_module_under_level MODULE_NAME PATH)
    make_module(${MODULE_NAME} ${PATH})
    if (NOT DEFINED LEVEL_NAME)
        message(SEND_ERROR "LEVEL_NAME is not defined")
        return()
    endif ()
    get_directory_property(MODULE_TARGET DIRECTORY "${PATH}" BUILDSYSTEM_TARGETS)
    set_property(GLOBAL APPEND PROPERTY ${LEVEL_NAME} "${MODULE_TARGET}")
endfunction()

# 在目录层级下注册模块，用于第三方库和伪模块的注册
function(register_module_under_level MODULE_NAME)
    if (NOT DEFINED LEVEL_NAME)
        message(SEND_ERROR "LEVEL_NAME is not defined")
        return()
    endif ()
    set_property(GLOBAL APPEND PROPERTY ${LEVEL_NAME} "${MODULE_NAME}")
endfunction()

# 添加目录层级并指定该目录的类型
function(add_level DIRS LEVEL_TYPE)
    set(LEVEL_NAME ${DIRS})
    add_subdirectory(${DIRS})
    set_property(GLOBAL APPEND PROPERTY ${LEVEL_TYPE} "${DIRS}")
ENDFUNCTION()


# 额外目录检测器（用于检测是否包含额外的目录）
function(level_extra_check)
    # 获取当前目录下的所有子目录名称
    get_property(SOURCE_NAME GLOBAL PROPERTY PXX_SOURCE_NAME)
    get_directory_property(subdirs DIRECTORY "${CMAKE_PROJECT_DIR}/${SOURCE_NAME}" SUBDIRECTORIES)
    # 遍历所有子目录名称
    foreach (subdir ${subdirs})
        get_filename_component(dirName ${subdir} NAME)
        list(APPEND CUR_ALL_LEVELS ${dirName})
    endforeach ()

    get_property(PUBLIC_LEVEL GLOBAL PROPERTY PUBLIC_LEVEL)
    get_property(PRIVATE_LEVEL GLOBAL PROPERTY PRIVATE_LEVEL)
    list(APPEND STAND_ALL_LEVEL ${PUBLIC_LEVEL} ${PRIVATE_LEVEL})

    foreach (level ${CUR_ALL_LEVELS})
        list(FIND STAND_ALL_LEVEL ${level} FIND_RESULT)
        if (FIND_RESULT EQUAL -1)
            message(SEND_ERROR "Extra Level Import: ${level}")
            return()
        endif ()
    ENDFOREACH ()
endfunction()

# 目录跨层级依赖检测器
function(module_depend_check)

    level_extra_check()

    get_property(PUBLIC_LEVEL GLOBAL PROPERTY PUBLIC_LEVEL)
    get_property(PRIVATE_LEVEL GLOBAL PROPERTY PRIVATE_LEVEL)

    list(LENGTH PRIVATE_LEVEL PRIVATE_LENGTH)
    math(EXPR PRIVATE_MAX_INDEX "${PRIVATE_LENGTH}-1")
    foreach (i RANGE 0 ${PRIVATE_LEVEL})
        set(AVA_LEVELS ${PUBLIC_LEVEL})
        math(EXPR NEXT_INDEX "${i}+1")
        if (NEXT_INDEX LESS ${PRIVATE_MAX_INDEX})
            list(GET PRIVATE_LEVEL ${NEXT_INDEX} NEXT_LEVEL)
            list(APPEND AVA_LEVELS ${NEXT_LEVEL})
        endif ()

        check_dependencies(${LEVEL} ${AVA_LEVELS})
    endforeach ()
endfunction()

# 检测目录层级依赖是否合法
function(check_dependencies LEVEL)
    get_all_targets_under_level(${LEVEL} ALL_AVA_TARGETS)

    foreach (AVA_LEVEL ${ARGN})
        get_all_targets_under_level(${AVA_LEVEL} TARGETS)
        list(APPEND ALL_AVA_TARGETS ${TARGETS})
    endforeach ()

    get_all_depends_under_level(${LEVEL} DEPENDS_TARGETS)

    foreach (TARGET ${DEPENDS_TARGETS})
        list(FIND ALL_AVA_TARGETS ${TARGET} FIND_RESULT)
        if (FIND_RESULT EQUAL -1)
            message(SEND_ERROR "${LEVEL} Depnds Invalid Level")
            return()
        endif ()
    endforeach ()

endfunction()

# 获取目录层级下的所有目标
function(get_all_targets_under_level LEVEL_NAME TARGETS_LIST)
    get_property(LIST GLOBAL PROPERTY ${LEVEL_NAME})
    set(${TARGETS_LIST} ${LIST} PARENT_SCOPE)
endfunction()

# 获取目录层级下的所有依赖
function(get_all_depends_under_level LEVEL_NAME DEPENDS)
    get_property(TARGETS GLOBAL PROPERTY ${LEVEL_NAME})
    foreach (TARGET ${TARGETS})
        get_target_property(DEPENDSVAR ${TARGET} LINK_LIBRARIES)
        if (NOT DEPENDSVAR STREQUAL "DEPENDSVAR-NOTFOUND")
            list(APPEND ALL_DEPENDS ${DEPENDSVAR})
        endif ()
    endforeach ()

    set(${DEPENDS} ${ALL_DEPENDS} PARENT_SCOPE)
endfunction()

function(config_targets MODULE_NAME PUBLIC_INCLUDES PRIVATE_INCLUDES)
    if (IS_WIN AND (IS_MSVC OR IS_MSVC_LIKE))
        target_compile_definitions(${MODULE_NAME} PUBLIC BUILDING_DLL)
    endif ()


    #创建构建时宏
    create_building_define(${MODULE_NAME} BUILDIND_DEF)

    #添加构建时宏(用于控制DLL导出符号)
    target_compile_definitions(${MODULE_NAME} PRIVATE ${BUILDIND_DEF})

    #添加公共头文件(所有依赖的该模块的编译目标都会同步引入这些头文件)
    target_include_directories(${MODULE_NAME} PUBLIC ${PUBLIC_INCLUDES})


    #添加私有头文件(这些头文件只在本模块内可用)
    target_include_directories(${MODULE_NAME} PRIVATE ${PRIVATE_INCLUDES})
endfunction()

function(is_header_only_module MODULE_NAME IS_HEADER_ONLY)
    get_target_property(TARGET_TYPE ${MODULE_NAME} TYPE)
    if (TARGET_TYPE STREQUAL "INTERFACE_LIBRARY")
        set(IS_HEADER_ONLY TRUE PARENT_SCOPE)
    else ()
        set(IS_HEADER_ONLY FALSE PARENT_SCOPE)
    endif ()
endfunction()