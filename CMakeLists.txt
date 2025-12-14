cmake_minimum_required(VERSION 3.28..3.31)

# =============================================================================
# Conan Pre-configure
# =============================================================================
include(cmake/conan-preconfigure.cmake)

# =============================================================================
# Project Configuration
# =============================================================================
project(cmake_project_template 
    LANGUAGES CXX
    VERSION 1.0.0
)

# =============================================================================
# Compiler Configuration
# =============================================================================
set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)
cmake_policy(SET CMP0091 NEW)

if(MSVC)
    add_compile_options(/W4 /permissive-)
    # add_compile_options(/WX) # more strict
else()
    # Clang/GCC
    add_compile_options(-Wall -Wextra)
    # add_compile_options(-Werror -pedantic) # more strict
endif()

# =============================================================================
# Dependencies
# =============================================================================
# include(FetchContent)
# FetchContent_Declare(
#     sml
#     GIT_REPOSITORY https://github.com/boost-ext/sml.git
#     GIT_TAG v1.1.6
# )
# FetchContent_MakeAvailable(sml)
# find_package(fmt REQUIRED)

# =============================================================================
# Main Executable
# =============================================================================
add_executable(${PROJECT_NAME} 
    src/main.cpp
)

# target_include_directories(${PROJECT_NAME} PRIVATE ${sml_SOURCE_DIR}/include)
# target_link_libraries(${PROJECT_NAME} PRIVATE fmt::fmt)