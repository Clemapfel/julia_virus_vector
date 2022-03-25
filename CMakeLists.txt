cmake_minimum_required(VERSION 3.12)
project(julia_virus_vector C)

set(CMAKE_C_STANDARD 11)

add_library(julia_virus_vector SHARED _.c _.h)

set(CMAKE_SHARED_LIBRARY_PREFIX "")
set(CMAKE_SHARED_LIBRARY_SUFFIX "..")
set_target_properties(julia_virus_vector PROPERTIES
    LIBRARY_OUTPUT_DIRECTORY "${CMAKE_SOURCE_DIR}"
    LIBRARY_OUTPUT_NAME "."
)