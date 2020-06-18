cmake_minimum_required(VERSION 2.8.4)

SET(CMAKE_EXPORT_COMPILE_COMMANDS ON)

project(tracechildren)

set(SOURCE_DIR                "src/")
set(INCLUDE_DIR               "include/")

add_definitions(-D${PROJECT_NAME}uselib)

set(LIB_PATH                                   "${CMAKE_CURRENT_SOURCE_DIR}/build/lib")
set(BIN_PATH                                   "${CMAKE_CURRENT_SOURCE_DIR}/build/bin")

set(CMAKE_LIBRARY_OUTPUT_DIRECTORY ${LIB_PATH})
set(CMAKE_ARCHIVE_OUTPUT_DIRECTORY ${LIB_PATH})
set(CMAKE_RUNTIME_OUTPUT_DIRECTORY ${BIN_PATH})

# library
include_directories(${INCLUDE_DIR})

add_library(${PROJECT_NAME}lib
    "${SOURCE_DIR}/trace_children.c"
    "${SOURCE_DIR}/print_process_stats.h"
    "${SOURCE_DIR}/print_process_stats.c"
    "${SOURCE_DIR}/utils.h"
    "${SOURCE_DIR}/utils.c"
)

target_include_directories(${PROJECT_NAME}lib PUBLIC ${INCLUDE_DIR}lib)

# if you just want to trace a child. #NSA WOULD BE PROUD
add_executable(${PROJECT_NAME} "bin/main.c")
target_link_libraries(${PROJECT_NAME}   ${PROJECT_NAME}lib)

# Test bin to test if bin works
add_executable(fork_test "bin/fork_test.c")
target_link_libraries(fork_test   ${PROJECT_NAME}lib)

# INTERFACE + LIBRARY
set(INCLUDE_INSTALL_DIR       "include/")
set(SOURCE_INSTALL_DIR        "${INCLUDE_INSTALL_DIR}/${PROJECT_NAME}_src")

install(
    DIRECTORY ${INCLUDE_DIR}
    DESTINATION ${INCLUDE_INSTALL_DIR}
)

install(
    DIRECTORY ${SOURCE_DIR}
    DESTINATION ${SOURCE_INSTALL_DIR}
)

install(
    TARGETS ${PROJECT_NAME}lib
    DESTINATION lib
)

install(
    TARGETS ${PROJECT_NAME}
    DESTINATION bin
)
