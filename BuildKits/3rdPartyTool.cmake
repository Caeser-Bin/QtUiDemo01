#初始化外部第三方库的目录变量
function(init_3rd_party_directory PATH_UNDER_ROOT)
    #初步的目录定位
    set(_PROJECT_ROOT ${CMAKE_PROJECT_DIR})
    set(_3RD_PARTY_BIN "${_PROJECT_ROOT}/${PATH_UNDER_ROOT}/bin")
    set(_3RD_PARTY_LIB "${_PROJECT_ROOT}/${PATH_UNDER_ROOT}/lib")
    set(_3RD_PARTY_INCLUDES "${_PROJECT_ROOT}/${PATH_UNDER_ROOT}/includes")

    #警告输出和进一步的定位
    if (EXISTS ${_3RD_PARTY_INCLUDES})
        set(3RD_PARTY_INCLUDES ${_3RD_PARTY_INCLUDES} CACHE STRING "external third party includes directory" FORCE)
    else ()
        message(STATUS "didn't find 'includes' folder under external 3rd-party path [${PATH_UNDER_ROOT}]")
    endif ()

    if (EXISTS ${_3RD_PARTY_BIN})
        find_subdirectory_by_env(${_3RD_PARTY_BIN} REAL_BIN_DIR)
        set(3RD_PARTY_BIN ${REAL_BIN_DIR} CACHE STRING "external third party library directory" FORCE)
    else ()
        message(STATUS "didn't find 'bin' folder under external 3rd-party path [${PATH_UNDER_ROOT}]")
    endif ()

    if (EXISTS ${_3RD_PARTY_LIB})
        find_subdirectory_by_env(${_3RD_PARTY_LIB} REAL_LIB_DIR)
        set(3RD_PARTY_LIB ${REAL_LIB_DIR} CACHE STRING "external third party binary directory" FORCE)
    else ()
        message(STATUS "didn't find 'lib' folder under external 3rd-party path [${PATH_UNDER_ROOT}]")
    endif ()
endfunction()

#根据环境找到合适的依赖子目录
function(find_subdirectory_by_env PATH SUBDIR)
    if (IS_WIN)
        set(${SUBDIR} "${PATH}/win" PARENT_SCOPE)
    elseif (IS_LINUX)
        set(${SUBDIR} "${PATH}/linux" PARENT_SCOPE)
    elseif (IS_APPLE_OS)
        if (IS_ARM_64)
            set(${SUBDIR} "${PATH}/mac-arm" PARENT_SCOPE)
        elseif (IS_X86_64)
            set(${SUBDIR} "${PATH}/mac-x86" PARENT_SCOPE)
        else ()
            message(FATAL_ERROR "unsupported architecture on mac")
        endif ()
    elseif (IS_WASM)
        set(${SUBDIR} "${PATH}/wasm" PARENT_SCOPE)
    endif ()
endfunction()

function(make_imported_target TARGET_NAME)
    if (BUILD_STATIC)
        make_static_imported_target(${TARGET_NAME})
    else ()
        make_shared_imported_target(${TARGET_NAME})
    endif ()
endfunction()

function(make_shared_imported_target TARGET_NAME)
    add_library(${TARGET_NAME} SHARED IMPORTED GLOBAL)
    register_module_under_level(${TARGET_NAME})
endfunction()

function(make_static_imported_target TARGET_NAME)
    add_library(${TARGET_NAME} STATIC IMPORTED GLOBAL)
    register_module_under_level(${TARGET_NAME})
endfunction()

function(make_interface_imported_target TARGET_NAME)
    add_library(${TARGET_NAME} INTERFACE)
    register_module_under_level(${TARGET_NAME})
endfunction()

function(bind_include_for_imported_target TARGET_NAME INCLUDE_DIR)
    target_include_directories(${TARGET_NAME} INTERFACE ${3RD_PARTY_INCLUDES}/${INCLUDE_DIR})
endfunction()

function(bind_library_for_imported_target TARGET_NAME LIBRARY_NAME)
    is_shared_target(${TARGET_NAME} IS_SHARED)
    get_library_dir(${IS_SHARED} LIBRARY_DIR)
    set_target_properties(${TARGET_NAME} PROPERTIES IMPORTED_LOCATION ${LIBRARY_DIR}/${LIBRARY_NAME})
endfunction()

function(bind_imported_library_for_target TARGET_NAME LIBRARY_NAME)
    set_target_properties(${TARGET_NAME} PROPERTIES IMPORTED_IMPLIB ${3RD_PARTY_LIB}/${LIBRARY_NAME})
endfunction()

function(add_dependencies_for_imported_target TARGET_NAME DEPENDENCE_NAME)
    if (BUILD_STATIC)
        add_library(${DEPENDENCE_NAME} STATIC IMPORTED)
    else ()
        add_library(${DEPENDENCE_NAME} SHARED IMPORTED)
    endif ()
    get_library_dir(TRUE LIBRARY_DIR)
    set_target_properties(${DEPENDENCE_NAME} PROPERTIES IMPORTED_LOCATION ${LIBRARY_DIR}/${DEPENDENCE_NAME})

    target_link_libraries(${TARGET_NAME} INTERFACE ${DEPENDENCE_NAME})
endfunction()

#windows环境下，将DLL文件和编译目标进行绑定
function(copy_dll_files_for MODULE_NAME)
    #非Windows环境不调用，dll文件常理下只在Windows环境下使用
    if (NOT IS_WIN)
        return()
    endif ()

    #获取从第二个参数起其后的参数
    set(file_names ${ARGV})
    list(REMOVE_AT file_names 0)

    isImportedTarget(${MODULE_NAME} IS_IMPORTED)

    #查找对于dll文件，并添加自定义命令
    #在目标编译结束后，移动到输出目录
    foreach (file_name ${file_names})
        set(DLL_PATH "${3RD_PARTY_BIN}/${file_name}")
        if (EXISTS ${DLL_PATH})
            if (IS_IMPORTED)
                set_target_properties(${MODULE_NAME} PROPERTIES IMPORTED_LOCATION ${DLL_PATH})
            else ()
                add_custom_command(
                        TARGET ${MODULE_NAME} POST_BUILD
                        COMMAND ${CMAKE_COMMAND} -E copy_if_different ${DLL_PATH} ${BIN_OUTPUT_DIR}/${file_name})
            endif ()
        else ()
            message(WARNING "${file_name} not founded")
        endif ()
    endforeach ()

endfunction()

function(copy_so_files_for MODULE_NAME)
    if (NOT IS_LINUX)
        return()
    endif ()

    #获取从第一个参数起其后的参数
    set(file_names ${ARGV})
    list(REMOVE_AT file_names 0)

    isImportedTarget(${MODULE_NAME} IS_IMPORTED)

    #在目标编译结束后，移动到输出目录
    foreach (file_name ${file_names})
        set(SO_PATH "${3RD_PARTY_LIB}/${file_name}")
        if (EXISTS ${SO_PATH})
            if (IS_IMPORTED)
                set_target_properties(${MODULE_NAME} PROPERTIES IMPORTED_LOCATION ${SO_PATH})
            else ()
                add_custom_command(
                        TARGET ${MODULE_NAME} POST_BUILD
                        COMMAND ${CMAKE_COMMAND} -E copy_if_different ${SO_PATH} ${BIN_OUTPUT_DIR}/${file_name})
            endif ()
        else ()
            message(WARNING "${file_name} not founded")
        endif ()
    endforeach ()

endfunction()

function(import_dll_library_for MODULE_NAME LIB_NAME)
    #非Windows环境不调用，dll文件常理下只在Windows环境下使用
    if (NOT IS_WIN)
        return()
    endif ()

    #获取从第二个参数起其后的参数
    set(file_names ${ARGV})
    list(REMOVE_AT file_names 0 1)

    set(LIB_PATH "${3RD_PARTY_LIB}/${LIB_NAME}")
    if (EXISTS ${LIB_PATH})
        set_property(TARGET ${MODULE_NAME} PROPERTY IMPORTED_IMPLIB ${LIB_PATH})
    else ()
        message(WARNING "${file_name} not founded")
    endif ()

    #查找对于dll文件，并添加自定义命令
    #在目标编译结束后，移动到输出目录
    foreach (file_name ${file_names})
        set(DLL_PATH "${3RD_PARTY_BIN}/${file_name}")
        if (EXISTS ${DLL_PATH})
            set_property(TARGET ${MODULE_NAME} PROPERTY IMPORTED_LOCATION ${DLL_PATH})
        else ()
            message(WARNING "${file_name} not founded")
        endif ()
    endforeach ()

endfunction()

function(import_so_library_for MODULE_NAME)
    if (NOT IS_LINUX)
        return()
    endif ()

    #获取从第一个参数起其后的参数
    set(file_names ${ARGV})
    list(REMOVE_AT file_names 0)

    foreach (file_name ${file_names})
        set(SO_PATH "${3RD_PARTY_BIN}/${file_name}")
        if (EXISTS ${SO_PATH})
            set_property(TARGET ${MODULE_NAME} PROPERTY IMPORTED_LOCATION ${SO_PATH})
        else ()
            message(WARNING "${file_name} not founded")
        endif ()
    endforeach ()

endfunction()

function(is_imported_target MODULE_NAME IS_IMPORTED)
    get_target_property(VAL ${MODULE_NAME} IMPORTED)
    if (${VAL} STREQUAL "TRUE")
        set(${IS_IMPORTED} TRUE PARENT_SCOPE)
    else ()
        set(${IS_IMPORTED} FALSE PARENT_SCOPE)
    endif ()
endfunction()

function(is_shared_target MODULE_NAME IS_SHARED)
    get_target_property(VAL ${MODULE_NAME} TYPE)
    if (${VAL} STREQUAL "SHARED_LIBRARY")
        set(${IS_SHARED} TRUE PARENT_SCOPE)
    else ()
        set(${IS_SHARED} FALSE PARENT_SCOPE)
    endif ()
endfunction()

function(get_library_dir IS_SHARED LIBRARY_DIR)
    if (${IS_SHARED})
        set(${LIBRARY_DIR} ${3RD_PARTY_BIN} PARENT_SCOPE)
    else ()
        set(${LIBRARY_DIR} ${3RD_PARTY_LIB} PARENT_SCOPE)
    endif ()
endfunction()
