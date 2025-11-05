# =============================================================================
# Project Configuration
# =============================================================================
cmake_minimum_required(VERSION 3.20)

project(cmake_project_template 
    LANGUAGES CXX
    VERSION 1.0.0
)

# =============================================================================
# Platform Configuration
# =============================================================================
if(WIN32)
    include(cmake/setup-windows.cmake)
endif()

# =============================================================================
# Compiler Configuration
# =============================================================================
set(CMAKE_CXX_STANDARD 23)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

# =============================================================================
# Dependencies
# =============================================================================
# find_package(fmt REQUIRED)

# =============================================================================
# Main Executable
# =============================================================================
add_executable(${PROJECT_NAME} 
    src/main.cpp
)

# target_link_libraries(${PROJECT_NAME} PRIVATE fmt::fmt)