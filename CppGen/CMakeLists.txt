cmake_minimum_required(VERSION 3.16)

# Target OS X 10.15 for maximum support
if(CMAKE_HOST_APPLE)
    if(NOT DEFINED CMAKE_OSX_ARCHITECTURES OR CMAKE_OSX_ARCHITECTURES STREQUAL "")
        execute_process(COMMAND uname -m
            OUTPUT_VARIABLE CMAKE_OSX_ARCHITECTURES
            OUTPUT_STRIP_TRAILING_WHITESPACE)
    endif()
    if(CMAKE_OSX_ARCHITECTURES STREQUAL "arm64")
        set(CMAKE_OSX_DEPLOYMENT_TARGET "11.0")
    else()
        set(CMAKE_OSX_DEPLOYMENT_TARGET "10.15")
    endif()
endif()

project(CppGen LANGUAGES CXX)

file(GLOB CPPGEN_SOURCES CONFIGURE_DEPENDS "Sources/*.cpp")
add_executable(${PROJECT_NAME} ${CPPGEN_SOURCES})
target_compile_features(${PROJECT_NAME} PRIVATE cxx_std_17)

# Keep the console executable directly in the selected build directory for
# both single- and multi-configuration generators.
set_target_properties(CppGen PROPERTIES
    RUNTIME_OUTPUT_DIRECTORY "${CMAKE_BINARY_DIR}"
    RUNTIME_OUTPUT_DIRECTORY_RELEASE "${CMAKE_BINARY_DIR}"
)

# Release builds use the compiler's normal optimization level plus link-time
# optimization when the selected toolchain supports it.
include(CheckIPOSupported)
check_ipo_supported(RESULT CPPGEN_IPO_SUPPORTED OUTPUT CPPGEN_IPO_ERROR)
if(CPPGEN_IPO_SUPPORTED)
    set_property(TARGET ${PROJECT_NAME} PROPERTY INTERPROCEDURAL_OPTIMIZATION_RELEASE TRUE)
endif()

if(MSVC)
    target_compile_options(${PROJECT_NAME} PRIVATE /W4 /permissive-)
else()
    target_compile_options(${PROJECT_NAME} PRIVATE -Wall -Wextra -Wpedantic)
endif()
