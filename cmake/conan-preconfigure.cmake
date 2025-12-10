# conan-preconfigure.cmake - SIMPLER VERSION
# =============================================================================
# This version requires the user to specify CONAN_PROFILE explicitly
# =============================================================================

# =============================================================================
# Configuration Options
# =============================================================================
set(CONAN_PROFILE "" CACHE STRING "Conan profile to use (clang, gcc, msvc)")
set(CONAN_BUILD_TYPE "" CACHE STRING "Build type (Debug, Release, RelWithDebInfo, MinSizeRel)")
set(CONAN_CPPSTD 23 CACHE STRING "C++ standard to use")
set(CONAN_PARALLEL_JOBS 20 CACHE STRING "Number of parallel jobs for building")
set(CONAN_BUILD_MISSING ON CACHE BOOL "Build missing dependencies from source")

message(STATUS "ROY:${CONAN_PROFILE};")
message(STATUS "ROY:${CMAKE_CXX_COMPILER};")


# =============================================================================
# Validate CONAN_PROFILE
# =============================================================================
if(CONAN_PROFILE STREQUAL "")
    message(FATAL_ERROR "CONAN_PROFILE must be specified. Use -DCONAN_PROFILE=clang|gcc|msvc")
endif()

if(NOT CONAN_PROFILE MATCHES "^(clang|gcc|msvc)$")
    message(FATAL_ERROR "CONAN_PROFILE must be one of: clang, gcc, msvc")
endif()

# =============================================================================
# Determine build type if not specified
# =============================================================================
if(CONAN_BUILD_TYPE STREQUAL "")
    if(DEFINED CMAKE_BUILD_TYPE AND NOT CMAKE_BUILD_TYPE STREQUAL "")
        set(CONAN_BUILD_TYPE ${CMAKE_BUILD_TYPE})
    else()
        set(CONAN_BUILD_TYPE "Release")
    endif()
endif()

# =============================================================================
# Set compiler-specific settings
# =============================================================================
set(CONAN_BUILD_DIR "${CMAKE_SOURCE_DIR}/build-${CONAN_PROFILE}")
# set(CONAN_TOOLCHAIN_FILE "${CONAN_BUILD_DIR}/conan_toolchain.cmake")

if(CONAN_PROFILE STREQUAL "clang")
    set(CONAN_COMPILER "clang")
    set(CONAN_COMPILER_VERSION "20")
    set(CONAN_RUNTIME_TYPE "Release")
    set(CONAN_GENERATOR "Ninja")
    set(CONAN_CMAKE_GENERATOR "Ninja")
    set(CONAN_PROFILE_SPECIFIC_ARGS "-s" "compiler.runtime_type=Release")
    
elseif(CONAN_PROFILE STREQUAL "gcc")
    set(CONAN_COMPILER "gcc")
    set(CONAN_COMPILER_VERSION "15")
    set(CONAN_LIBCXX "libstdc++")
    set(CONAN_GENERATOR "MinGW Makefiles")
    set(CONAN_CMAKE_GENERATOR "MinGW Makefiles")
    set(CONAN_PROFILE_SPECIFIC_ARGS "-s" "compiler.libcxx=libstdc++")
    
elseif(CONAN_PROFILE STREQUAL "msvc")
    set(CONAN_COMPILER "msvc")
    set(CONAN_COMPILER_VERSION "193")
    set(CONAN_RUNTIME "static")
    set(CONAN_GENERATOR "Visual Studio 17 2022")
    set(CONAN_CMAKE_GENERATOR "Visual Studio 17 2022")
    set(CONAN_PROFILE_SPECIFIC_ARGS "-s" "compiler.runtime=static")
endif()

# =============================================================================
# Check if Conan is available and run install
# =============================================================================
find_program(CONAN_EXECUTABLE conan)
if(NOT CONAN_EXECUTABLE)
    message(WARNING "Conan executable not found. Please install Conan or set CONAN_EXECUTABLE.")
else()
    # Check if conan_toolchain.cmake already exists
    if(NOT EXISTS "${CONAN_TOOLCHAIN_FILE}")
        message(STATUS "Running Conan install for ${CONAN_PROFILE} profile (${CONAN_BUILD_TYPE})...")
        
        # Execute Conan install
        execute_process(
            COMMAND "${CONAN_EXECUTABLE}" "install" "." "-of" "${CONAN_BUILD_DIR}" "--build=missing"
                "-s" "compiler=${CONAN_COMPILER}"
                "-s" "compiler.version=${CONAN_COMPILER_VERSION}"
                "-s" "compiler.cppstd=${CONAN_CPPSTD}"
                "-s" "build_type=${CONAN_BUILD_TYPE}"
                "-c" "tools.cmake.cmaketoolchain:generator=${CONAN_GENERATOR}"
                ${CONAN_PROFILE_SPECIFIC_ARGS}
                # "-c" "tools.cmake.cmaketoolchain:generator=\"MinGW Makefiles\""
				# "-s" "compiler.libcxx=libstdc++"
            WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
            RESULT_VARIABLE CONAN_RESULT
        )
        
        if(NOT CONAN_RESULT EQUAL 0)
            message(WARNING "Conan install failed with error code: ${CONAN_RESULT}")
        else()
            message(STATUS "Conan install completed successfully")
        endif()
    else()
        message(STATUS "Conan toolchain already exists at ${CONAN_TOOLCHAIN_FILE}")
    endif()
endif()

# =============================================================================
# Set up CMake to use Conan toolchain
# =============================================================================
if(EXISTS "${CONAN_TOOLCHAIN_FILE}")
    # Include the toolchain file
    include("${CONAN_TOOLCHAIN_FILE}")
    
    message(STATUS "Using Conan toolchain: ${CONAN_TOOLCHAIN_FILE}")
    message(STATUS "Build directory: ${CONAN_BUILD_DIR}")
    message(STATUS "Build type: ${CONAN_BUILD_TYPE}")
else()
    message(WARNING "Conan toolchain file not found at ${CONAN_TOOLCHAIN_FILE}")
endif()