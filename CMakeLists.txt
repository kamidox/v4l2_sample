cmake_minimum_required (VERSION 3.1)

project(v4l2)
set(EXECUTABLE_OUTPUT_PATH ${PROJECT_SOURCE_DIR}/build)

add_executable(capturer_mmap capturer_mmap.c)

add_executable(capturer_read capturer_read.c)

add_executable(viewer viewer.c)
target_link_libraries(viewer X11 Xext)

