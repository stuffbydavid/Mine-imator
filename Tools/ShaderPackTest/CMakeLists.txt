cmake_minimum_required(VERSION 3.16)

# Standalone test harness for the shaderpack engine in CppProject/ShaderPack.
# Loads shaderpacks, compiles all programs and renders a test scene offscreen.
project(ShaderPackTest LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC OFF)

find_package(Qt5 5.15 CONFIG REQUIRED COMPONENTS Gui)
find_package(OpenGL REQUIRED)

set(LIBZIP_INCLUDE_DIR "" CACHE PATH "Directory containing zip.h and zipconf.h")
set(LIBZIP_LIBRARY "" CACHE FILEPATH "Static or shared libzip library")
find_package(ZLIB REQUIRED)

get_filename_component(ENGINE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../../CppProject/ShaderPack" ABSOLUTE)
file(GLOB ENGINE_SOURCES CONFIGURE_DEPENDS "${ENGINE_DIR}/*.cpp" "${ENGINE_DIR}/*.hpp")

add_executable(ShaderPackTest main.cpp ${ENGINE_SOURCES})
target_include_directories(ShaderPackTest PRIVATE "${ENGINE_DIR}" "${LIBZIP_INCLUDE_DIR}")
target_link_libraries(ShaderPackTest PRIVATE Qt5::Gui OpenGL::GL "${LIBZIP_LIBRARY}" ZLIB::ZLIB)
