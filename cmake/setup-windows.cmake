# Minimal Windows setup check for Conan projects
message(STATUS "Checking development environment...")

# Check CMake version
# if(CMAKE_VERSION VERSION_LESS 3.28)
    # message(WARNING "CMake ${CMAKE_VERSION} found, but 3.28+ is required")
execute_process(
    COMMAND powershell -ExecutionPolicy Bypass -File "${CMAKE_SOURCE_DIR}/scripts/setup-windows.ps1"
    WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}"
    RESULT_VARIABLE setup_result
)
    # if(NOT setup_result EQUAL 0)
    #     message(FATAL_ERROR "Setup script failed with code: ${setup_result}")
    # endif()
# endif()

# # Check for Conan toolchain
# if(EXISTS "${CMAKE_BINARY_DIR}/generators/conan_toolchain.cmake")
#     include("${CMAKE_BINARY_DIR}/generators/conan_toolchain.cmake")
#     message(STATUS "Using Conan toolchain")
# elseif(EXISTS "${CMAKE_SOURCE_DIR}/conanfile.txt")
#     message(WARNING "Conan dependencies not installed")
#     message(STATUS "Run: scripts/setup.ps1")
# endif()

# message(STATUS "Environment check complete")