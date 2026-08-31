cmake_minimum_required(VERSION 3.18)

# Toolchain-affecting settings established before project()
set(PROJECT_CONFIGURATION_TYPES "Debug;DebugBenchmarks;RelWithDebInfo;RunBenchmarks;Release")
get_property(IS_MULTI_CONFIG GLOBAL PROPERTY GENERATOR_IS_MULTI_CONFIG)
if(IS_MULTI_CONFIG)
	set(CMAKE_CONFIGURATION_TYPES "${PROJECT_CONFIGURATION_TYPES}" CACHE STRING "Supported build configurations" FORCE)
else()
	if(NOT DEFINED CMAKE_BUILD_TYPE OR CMAKE_BUILD_TYPE STREQUAL "")
		set(CMAKE_BUILD_TYPE Debug CACHE STRING "Build type" FORCE)
	endif()
	set_property(CACHE CMAKE_BUILD_TYPE PROPERTY STRINGS "${PROJECT_CONFIGURATION_TYPES}")
endif()

if(CMAKE_HOST_WIN32)
	cmake_policy(SET CMP0091 NEW)
elseif(CMAKE_HOST_APPLE)
	if(NOT DEFINED CMAKE_OSX_ARCHITECTURES OR CMAKE_OSX_ARCHITECTURES STREQUAL "")
		execute_process(COMMAND uname -m
			OUTPUT_VARIABLE CMAKE_OSX_ARCHITECTURES
			OUTPUT_STRIP_TRAILING_WHITESPACE)
	endif()
	if(NOT CMAKE_OSX_ARCHITECTURES MATCHES "^(x86_64|arm64)$")
		message(FATAL_ERROR
			"CMAKE_OSX_ARCHITECTURES must contain one architecture: x86_64 or arm64")
	endif()
	set(CMAKE_OSX_ARCHITECTURES "${CMAKE_OSX_ARCHITECTURES}"
		CACHE STRING "macOS target architecture" FORCE)
	if(NOT DEFINED CMAKE_OSX_DEPLOYMENT_TARGET OR CMAKE_OSX_DEPLOYMENT_TARGET STREQUAL "")
		if(CMAKE_OSX_ARCHITECTURES STREQUAL "arm64")
			set(CMAKE_OSX_DEPLOYMENT_TARGET "11.0")
		else()
			set(CMAKE_OSX_DEPLOYMENT_TARGET "10.15")
		endif()
	endif()
	if(CMAKE_OSX_ARCHITECTURES STREQUAL "arm64"
		AND CMAKE_OSX_DEPLOYMENT_TARGET VERSION_LESS "11.0")
		message(FATAL_ERROR "arm64 requires CMAKE_OSX_DEPLOYMENT_TARGET 11.0 or newer")
	endif()
	set(CMAKE_OSX_DEPLOYMENT_TARGET "${CMAKE_OSX_DEPLOYMENT_TARGET}"
		CACHE STRING "Minimum supported macOS version" FORCE)
else()
	set(CMAKE_C_COMPILER "/usr/bin/clang" CACHE FILEPATH "Linux C compiler" FORCE)
	set(CMAKE_CXX_COMPILER "/usr/bin/clang++" CACHE FILEPATH "Linux C++ compiler" FORCE)
endif()

project(Mine-imator LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)
set(CLANG21_WARNING_SUPPRESSIONS)
set_property(GLOBAL PROPERTY USE_FOLDERS ON)
get_filename_component(REPO_DIR
	"${CMAKE_CURRENT_SOURCE_DIR}/.."
	ABSOLUTE
)

# Third-party source and Qt installation roots
if(NOT DEFINED DEV_DIR)
	if(DEFINED ENV{DEV_DIR})
		set(DEV_DIR "$ENV{DEV_DIR}" CACHE PATH "Third-party development directory")
	else()
		message(FATAL_ERROR "DEV_DIR is not set. Define the environment variable or pass -DDEV_DIR=<path>.")
	endif()
endif()
file(TO_CMAKE_PATH "${DEV_DIR}" DEV_DIR)
message(STATUS "DEV_DIR = ${DEV_DIR}")

set(QT_BASE_DIR "${DEV_DIR}/Qt/5.15.19")
set(QT_INSTALL_DIR "${QT_BASE_DIR}/install")
set(QT_SOURCE_DIR "${QT_BASE_DIR}/qt5")
set(LIBZIP_SOURCE_DIR "${DEV_DIR}/Libzip/libzip-1.11.4")
set(FFMPEG_SOURCE_DIR "${DEV_DIR}/FFmpeg/ffmpeg-5.1.10")
set(OPENAL_SOURCE_DIR "${DEV_DIR}/OpenAL/openal-soft-1.24.3")

set(ASSET_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}/Asset")
set(GM_SHADERS_DIR "${REPO_DIR}/GmProject/shaders")
set(CPPGEN_DIR "${REPO_DIR}/CppGen")
set(INSTALL_DIR "${REPO_DIR}/install")

if(WIN32 AND CMAKE_GENERATOR_PLATFORM STREQUAL "Win32")
	set(WINDOWS_ARCH "Win32")
	set(EXTERNAL_PLATFORM_DIR "${CMAKE_CURRENT_SOURCE_DIR}/External/Win32")
	set(QT_INSTALL_DIR "${QT_BASE_DIR}-Win32/install")
	set(QT_SOURCE_DIR "${QT_BASE_DIR}-Win32/qt5")
	set(CPPGEN_EXE "${CPPGEN_DIR}/Win32/CppGen.exe")
	set(INSTALL_DIR "${REPO_DIR}/install-Win32")
elseif(WIN32)
	set(WINDOWS_ARCH "x64")
	set(EXTERNAL_PLATFORM_DIR "${CMAKE_CURRENT_SOURCE_DIR}/External/Win64")
	set(CPPGEN_EXE "${CPPGEN_DIR}/Win64/CppGen.exe")
elseif(APPLE)
	set(EXTERNAL_PLATFORM_DIR "${CMAKE_CURRENT_SOURCE_DIR}/External/Mac")
	set(CPPGEN_EXE "${CPPGEN_DIR}/Mac/CppGen")
	execute_process(COMMAND brew --prefix libomp
		RESULT_VARIABLE LIBOMP_RESULT
		OUTPUT_VARIABLE LIBOMP_PREFIX OUTPUT_STRIP_TRAILING_WHITESPACE)
	if(NOT LIBOMP_RESULT EQUAL 0 OR NOT EXISTS "${LIBOMP_PREFIX}/include/omp.h")
		message(FATAL_ERROR "Homebrew libomp was not found")
	endif()
	if(CMAKE_OSX_ARCHITECTURES STREQUAL "x86_64")
		set(OPENMP_RUNTIME_LIBRARY "${EXTERNAL_PLATFORM_DIR}/libomp.dylib")
		set(OPENMP_LINKED_LIBRARY "/usr/local/opt/libomp/lib/libomp.dylib")
	else()
		set(OPENMP_RUNTIME_LIBRARY "${LIBOMP_PREFIX}/lib/libomp.dylib")
		set(OPENMP_LINKED_LIBRARY "${OPENMP_RUNTIME_LIBRARY}")
	endif()
	if(NOT EXISTS "${OPENMP_RUNTIME_LIBRARY}")
		message(FATAL_ERROR "OpenMP runtime was not found at ${OPENMP_RUNTIME_LIBRARY}")
	endif()
	set(OpenMP_libomp_LIBRARY "${OPENMP_RUNTIME_LIBRARY}" CACHE FILEPATH "" FORCE)
	set(OpenMP_CXX_INCLUDE_DIR "${LIBOMP_PREFIX}/include" CACHE PATH "" FORCE)
else()
	set(EXTERNAL_PLATFORM_DIR "${CMAKE_CURRENT_SOURCE_DIR}/External/Linux")
	set(CPPGEN_EXE "${CPPGEN_DIR}/Linux/CppGen")
	if(CMAKE_CXX_COMPILER_VERSION VERSION_GREATER_EQUAL 21)
		list(APPEND CLANG21_WARNING_SUPPRESSIONS -Wno-nontrivial-memcall)
	endif()
endif()

message(STATUS "CppGen location = ${CPPGEN_EXE}")
message(STATUS "External libraries = ${EXTERNAL_PLATFORM_DIR}")
message(STATUS "Qt installation = ${QT_INSTALL_DIR}")

# RelWithDebInfo configuration
if(MSVC)
	set(RELWITHDEBINFO_CXX_FLAGS "${CMAKE_CXX_FLAGS_RELEASE} /Zi")
	set(RELWITHDEBINFO_LINKER_FLAGS
		"${CMAKE_EXE_LINKER_FLAGS_RELEASE} /DEBUG:FULL /OPT:REF /OPT:ICF")
else()
	set(RELWITHDEBINFO_CXX_FLAGS "${CMAKE_CXX_FLAGS_RELEASE} -g")
	set(RELWITHDEBINFO_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS_RELEASE}")
endif()
set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "${RELWITHDEBINFO_CXX_FLAGS}"
	CACHE STRING "C++ flags for RelWithDebInfo" FORCE)
set(CMAKE_EXE_LINKER_FLAGS_RELWITHDEBINFO "${RELWITHDEBINFO_LINKER_FLAGS}"
	CACHE STRING "Executable linker flags for RelWithDebInfo" FORCE)

# Benchmark configurations
set(CMAKE_CXX_FLAGS_DEBUGBENCHMARKS "${CMAKE_CXX_FLAGS_DEBUG}"
	CACHE STRING "C++ flags for DebugBenchmarks" FORCE)
set(CMAKE_EXE_LINKER_FLAGS_DEBUGBENCHMARKS "${CMAKE_EXE_LINKER_FLAGS_DEBUG}"
	CACHE STRING "Executable linker flags for DebugBenchmarks" FORCE)
set(CMAKE_CXX_FLAGS_RUNBENCHMARKS "${CMAKE_CXX_FLAGS_RELWITHDEBINFO}"
	CACHE STRING "C++ flags for RunBenchmarks" FORCE)
set(CMAKE_EXE_LINKER_FLAGS_RUNBENCHMARKS "${CMAKE_EXE_LINKER_FLAGS_RELWITHDEBINFO}"
	CACHE STRING "Executable linker flags for RunBenchmarks" FORCE)
set(CMAKE_MAP_IMPORTED_CONFIG_DEBUGBENCHMARKS Release) # Map to Qt release build
set(CMAKE_MAP_IMPORTED_CONFIG_RUNBENCHMARKS Release)

if(WIN32)
	set(CMAKE_RC_FLAGS_DEBUGBENCHMARKS "${CMAKE_RC_FLAGS_DEBUG}"
		CACHE STRING "Resource compiler flags for DebugBenchmarks" FORCE)
endif()

# Find Qt package
find_package(Qt5 5.15.19 EXACT CONFIG REQUIRED COMPONENTS Widgets Gui Network
	PATHS "${QT_INSTALL_DIR}"
	NO_DEFAULT_PATH)
set_property(GLOBAL PROPERTY AUTOGEN_SOURCE_GROUP "QtGenerated")
set_property(GLOBAL PROPERTY AUTOGEN_TARGETS_FOLDER "CMakePredefinedTargets")
set_property(TARGET Qt5::rcc PROPERTY MAP_IMPORTED_CONFIG_DEBUGBENCHMARKS "Release;") # Map to Qt release build
set_property(TARGET Qt5::rcc PROPERTY MAP_IMPORTED_CONFIG_RUNBENCHMARKS "Release;")
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC OFF)
set(CMAKE_AUTOUIC OFF)

# Find OpenMP
find_package(OpenMP REQUIRED COMPONENTS CXX)

# Refresh Assets.cmake manifest using CppGen
set(CPPGEN_ASSET_MANIFEST "${CMAKE_CURRENT_SOURCE_DIR}/Generated/Assets.cmake")
execute_process(
	COMMAND "${CPPGEN_EXE}" "${REPO_DIR}" "${CPPGEN_DIR}/gml.json" "--assets-manifest"
	WORKING_DIRECTORY "${CPPGEN_DIR}"
	RESULT_VARIABLE CPPGEN_ASSET_MANIFEST_RESULT
	OUTPUT_VARIABLE CPPGEN_ASSET_MANIFEST_OUTPUT
	ERROR_VARIABLE CPPGEN_ASSET_MANIFEST_ERROR
)
if(NOT CPPGEN_ASSET_MANIFEST_RESULT EQUAL 0)
	message(FATAL_ERROR
		"CppGen did not create ${CPPGEN_ASSET_MANIFEST} (exit ${CPPGEN_ASSET_MANIFEST_RESULT}).\n"
		"${CPPGEN_ASSET_MANIFEST_OUTPUT}${CPPGEN_ASSET_MANIFEST_ERROR}")
endif()
set_property(DIRECTORY APPEND PROPERTY CMAKE_CONFIGURE_DEPENDS "${CPPGEN_ASSET_MANIFEST}")
include("${CPPGEN_ASSET_MANIFEST}")

# Reconstruct GameMaker folder hierarchy
function(add_gm_manifest_entries CATEGORY ENTRIES_VARIABLE FILES_VARIABLE RESOURCE_ENTRIES_VARIABLE ALIASES_VARIABLE)
	set(GM_FILES)
	if(RESOURCE_ENTRIES_VARIABLE)
		set(GM_RESOURCE_ENTRIES)
	endif()
	if(ALIASES_VARIABLE)
		set(GM_ALIASES)
	endif()

	foreach(GM_ENTRY IN LISTS ${ENTRIES_VARIABLE})
		string(REPLACE "|" ";" GM_ENTRY_PARTS "${GM_ENTRY}")
		list(GET GM_ENTRY_PARTS 0 GM_ENTRY_PATH)
		set(GM_ENTRY_FILE "${REPO_DIR}/${GM_ENTRY_PATH}")
		list(APPEND GM_FILES "${GM_ENTRY_FILE}")

		if(RESOURCE_ENTRIES_VARIABLE)
			list(GET GM_ENTRY_PARTS 1 GM_ENTRY_ALIAS)
			list(GET GM_ENTRY_PARTS 2 GM_ENTRY_GROUP)
			list(APPEND GM_RESOURCE_ENTRIES "${GM_ENTRY_FILE}|${GM_ENTRY_ALIAS}")
			if(ALIASES_VARIABLE)
				list(APPEND GM_ALIASES "${GM_ENTRY_ALIAS}")
			endif()
			if(CATEGORY STREQUAL "Sprites")
				get_filename_component(GM_ENTRY_DIRECTORY "${GM_ENTRY_FILE}" DIRECTORY)
				get_filename_component(GM_ENTRY_NAME "${GM_ENTRY_DIRECTORY}" NAME)
				if(GM_ENTRY_GROUP STREQUAL "")
					set(GM_ENTRY_GROUP "${GM_ENTRY_NAME}")
				else()
					set(GM_ENTRY_GROUP "${GM_ENTRY_GROUP}/${GM_ENTRY_NAME}")
				endif()
			endif()
		else()
			list(GET GM_ENTRY_PARTS 1 GM_ENTRY_GROUP)
		endif()

		set(GM_SOURCE_GROUP "GmProject/${CATEGORY}")
		if(NOT GM_ENTRY_GROUP STREQUAL "")
			string(APPEND GM_SOURCE_GROUP "/${GM_ENTRY_GROUP}")
		endif()
		source_group("${GM_SOURCE_GROUP}" FILES "${GM_ENTRY_FILE}")
	endforeach()

	set(${FILES_VARIABLE} "${GM_FILES}" PARENT_SCOPE)
	if(RESOURCE_ENTRIES_VARIABLE)
		set(${RESOURCE_ENTRIES_VARIABLE} "${GM_RESOURCE_ENTRIES}" PARENT_SCOPE)
	endif()
	if(ALIASES_VARIABLE)
		set(${ALIASES_VARIABLE} "${GM_ALIASES}" PARENT_SCOPE)
	endif()
endfunction()

add_gm_manifest_entries("Sprites" CPPGEN_SPRITE_RESOURCE_ENTRIES
	GM_SPRITE_FILES GM_SPRITE_RESOURCE_ENTRIES "")
add_gm_manifest_entries("Shaders" CPPGEN_SHADER_RESOURCE_ENTRIES
	GM_SHADER_FILES GM_SHADER_RESOURCE_ENTRIES GM_SHADER_ALIASES)
add_gm_manifest_entries("Scripts" CPPGEN_SCRIPT_ENTRIES
	GM_SCRIPT_FILES "" "")

# Combine shaders from CppProject/Asset/Shaders and GmProject/shaders
file(GLOB_RECURSE ASSET_SHADER_SOURCE_FILES CONFIGURE_DEPENDS LIST_DIRECTORIES FALSE
	"${ASSET_SOURCE_DIR}/Shaders/*.vsh"
	"${ASSET_SOURCE_DIR}/Shaders/*.fsh"
)
list(SORT ASSET_SHADER_SOURCE_FILES)
set(SHADER_FILES)
foreach(ASSET_SHADER_SOURCE_FILE IN LISTS ASSET_SHADER_SOURCE_FILES)
	get_filename_component(ASSET_SHADER_NAME "${ASSET_SHADER_SOURCE_FILE}" NAME)
	list(FIND GM_SHADER_ALIASES "Shaders/${ASSET_SHADER_NAME}" GAME_MAKER_SHADER_INDEX)
	if(GAME_MAKER_SHADER_INDEX EQUAL -1)
		list(APPEND SHADER_FILES "${ASSET_SHADER_SOURCE_FILE}")
	endif()
endforeach()

# Exclude compiled D3D bytecode from source tree
file(GLOB_RECURSE D3D_SHADER_FILES CONFIGURE_DEPENDS LIST_DIRECTORIES FALSE
	"${ASSET_SOURCE_DIR}/Shaders/*.d3d"
)
list(SORT D3D_SHADER_FILES)

# Assemble embedded
set(ASSET_RESOURCE_ENTRIES ${GM_SPRITE_RESOURCE_ENTRIES})
foreach(SHADER_FILE IN LISTS SHADER_FILES)
	get_filename_component(SHADER_NAME "${SHADER_FILE}" NAME)
	list(APPEND ASSET_RESOURCE_ENTRIES
		"${SHADER_FILE}|Shaders/${SHADER_NAME}")
endforeach()
list(APPEND ASSET_RESOURCE_ENTRIES ${GM_SHADER_RESOURCE_ENTRIES})
foreach(D3D_SHADER_FILE IN LISTS D3D_SHADER_FILES)
	file(RELATIVE_PATH D3D_SHADER_ALIAS "${ASSET_SOURCE_DIR}" "${D3D_SHADER_FILE}")
	file(TO_CMAKE_PATH "${D3D_SHADER_ALIAS}" D3D_SHADER_ALIAS)
	list(APPEND ASSET_RESOURCE_ENTRIES
		"${D3D_SHADER_FILE}|${D3D_SHADER_ALIAS}")
endforeach()

# Show GameMaker assets in the main project
set(IDE_ONLY_FILES ${GM_SPRITE_FILES} ${GM_SHADER_FILES} ${GM_SCRIPT_FILES} ${SHADER_FILES})
set_source_files_properties(${IDE_ONLY_FILES} PROPERTIES HEADER_FILE_ONLY TRUE)
source_group("CppProject/Asset/Shaders" FILES ${SHADER_FILES})

# Generate index file
set(QT_INDEX_FILE "${CMAKE_CURRENT_BINARY_DIR}/index.qrc")
set(INDEX_XML "<!-- Auto-generated by CMake; do not edit. -->\n<RCC>\n\t<qresource prefix=\"/\">")

foreach(ASSET_RESOURCE_ENTRY IN LISTS ASSET_RESOURCE_ENTRIES)
	string(REPLACE "|" ";" ASSET_RESOURCE_PARTS "${ASSET_RESOURCE_ENTRY}")
	list(GET ASSET_RESOURCE_PARTS 0 ASSET_FILE)
	list(GET ASSET_RESOURCE_PARTS 1 ASSET_ALIAS)
	file(TO_CMAKE_PATH "${ASSET_FILE}" ASSET_FILE_CMAKE)
	string(APPEND INDEX_XML "\n\t\t<file alias=\"${ASSET_ALIAS}\">${ASSET_FILE_CMAKE}</file>")
endforeach()
string(APPEND INDEX_XML "\n\t</qresource>\n</RCC>\n")
file(WRITE "${QT_INDEX_FILE}" "${INDEX_XML}")

qt5_add_resources(RESOURCE_SOURCES "${QT_INDEX_FILE}")

# CONFIGURE_DEPENDS retains automatic source discovery while making additions
# visible to CMake without a manual reconfigure.
file(GLOB_RECURSE PROJECT_SOURCES CONFIGURE_DEPENDS LIST_DIRECTORIES FALSE
	"${CMAKE_CURRENT_SOURCE_DIR}/*.cpp"
	"${CMAKE_CURRENT_SOURCE_DIR}/*.hpp"
)
source_group(TREE "${CMAKE_CURRENT_SOURCE_DIR}" PREFIX "CppProject" FILES ${PROJECT_SOURCES})
source_group("QtGenerated" REGULAR_EXPRESSION "[/\\\\]Qt5[^/\\\\]*_Import\\.cpp$")
source_group("QtGenerated" FILES ${RESOURCE_SOURCES})

if(WIN32)
	set(APP_ICON_RESOURCE "${CMAKE_CURRENT_SOURCE_DIR}/Asset/Icons/appicon.rc")
	source_group("CppProject/Asset/Icons" FILES "${APP_ICON_RESOURCE}")
endif()

add_executable(${PROJECT_NAME}
	${PROJECT_SOURCES}
	${IDE_ONLY_FILES}
	${RESOURCE_SOURCES}
	${APP_ICON_RESOURCE}
)

if(MSVC)
	target_compile_options(${PROJECT_NAME} PRIVATE "/FI${CMAKE_CURRENT_SOURCE_DIR}/Common.hpp")
else()
	target_compile_options(${PROJECT_NAME} PRIVATE -include "${CMAKE_CURRENT_SOURCE_DIR}/Common.hpp")
endif()
target_include_directories(${PROJECT_NAME} PRIVATE
	"${CMAKE_CURRENT_SOURCE_DIR}"
	"${QT_INSTALL_DIR}/include/QtZlib"
	"${CMAKE_CURRENT_SOURCE_DIR}/External/Sources"
	"${LIBZIP_SOURCE_DIR}/lib"
	"${OPENAL_SOURCE_DIR}/include"
	"${QT_SOURCE_DIR}/qtbase/src/3rdparty/freetype/include"
)

if(APPLE)
	# Fix FFmpeg include issue with VERSION
	target_compile_options(${PROJECT_NAME} PRIVATE
		"SHELL:-idirafter \"${FFMPEG_SOURCE_DIR}\""
	)
else()
	target_include_directories(${PROJECT_NAME} PRIVATE
		"${FFMPEG_SOURCE_DIR}"
	)
endif()

target_compile_definitions(${PROJECT_NAME} PRIVATE
	"BUILD_FOLDER=QString(\"${CMAKE_BINARY_DIR}\"\)"
	"PROJECT_NAME=\"${PROJECT_NAME}\""
	"ASSETS_DIR=\"${ASSET_SOURCE_DIR}\""
	"GM_SHADERS_DIR=\"${GM_SHADERS_DIR}\""
	"DEBUG_MODE=$<IF:$<OR:$<CONFIG:Debug>,$<CONFIG:DebugBenchmarks>>,1,0>"
	"RELEASE_MODE=$<IF:$<CONFIG:Release>,1,0>"
	"OPTIMIZED=$<IF:$<OR:$<CONFIG:RelWithDebInfo>,$<CONFIG:RunBenchmarks>,$<CONFIG:Release>>,1,0>"
)
target_link_libraries(${PROJECT_NAME} PRIVATE
	OpenMP::OpenMP_CXX
)

if(WIN32)
	message(STATUS "Windows platform (${WINDOWS_ARCH})")
	set_property(DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}" PROPERTY VS_STARTUP_PROJECT ${PROJECT_NAME})

	# Qt and the bundled static libraries are built against the static MSVC CRT
	set_property(TARGET ${PROJECT_NAME} PROPERTY MSVC_RUNTIME_LIBRARY "MultiThreaded")
	target_compile_options(${PROJECT_NAME} PRIVATE /MP /bigobj)
	target_compile_definitions(${PROJECT_NAME} PRIVATE OS_WINDOWS)

	target_link_libraries(${PROJECT_NAME} PRIVATE
		"${EXTERNAL_PLATFORM_DIR}/zip.lib"
		"${EXTERNAL_PLATFORM_DIR}/OpenAL32.lib"
		"${EXTERNAL_PLATFORM_DIR}/libavformat.a"
		"${EXTERNAL_PLATFORM_DIR}/libavcodec.a"
		"${EXTERNAL_PLATFORM_DIR}/libswresample.a"
		"${EXTERNAL_PLATFORM_DIR}/libswscale.a"
		"${EXTERNAL_PLATFORM_DIR}/libavutil.a"
		"${EXTERNAL_PLATFORM_DIR}/libx264.lib"
		Mf
		Mfplat
		mfuuid
		strmiids
		Avrt
		d3d11
		"$<$<OR:$<CONFIG:Debug>,$<CONFIG:DebugBenchmarks>>:d3dcompiler>"
	)
	target_link_options(${PROJECT_NAME} PRIVATE
		"$<$<OR:$<CONFIG:Debug>,$<CONFIG:DebugBenchmarks>,$<CONFIG:RelWithDebInfo>,$<CONFIG:RunBenchmarks>>:/IGNORE:4099>"
	)
	
	# Toggle console
	set_property(TARGET ${PROJECT_NAME} PROPERTY WIN32_EXECUTABLE "$<CONFIG:Release>")

	# Set working directories
	set_property(TARGET ${PROJECT_NAME} PROPERTY RUNTIME_OUTPUT_DIRECTORY_RELEASE "${CMAKE_BINARY_DIR}")
	set_property(TARGET ${PROJECT_NAME} PROPERTY VS_DEBUGGER_WORKING_DIRECTORY "${CMAKE_BINARY_DIR}")

	# Apply benchmark arguments
	set(BENCHMARK_ARGS "--benchmark_project \"${REPO_DIR}/rendering/benchmark_project/benchmark_project.miproject\"")
	set_property(TARGET ${PROJECT_NAME} PROPERTY VS_DEBUGGER_COMMAND_ARGUMENTS
		"$<$<OR:$<CONFIG:DebugBenchmarks>,$<CONFIG:RunBenchmarks>>:${BENCHMARK_ARGS}>")
else()
	target_compile_options(${PROJECT_NAME} PRIVATE
		-Wall
		-Wno-overloaded-virtual
		-Wno-parentheses
		-Wno-reorder-ctor
		-Wno-sometimes-uninitialized
		-Wno-switch
		-Wno-unknown-pragmas
		${CLANG21_WARNING_SUPPRESSIONS}
	)
	target_compile_definitions(${PROJECT_NAME} PRIVATE OS_UNIX)

	# Static-library order matters to GNU-family linkers: dependants precede the
	# archives that satisfy them
	target_link_libraries(${PROJECT_NAME} PRIVATE
		"${EXTERNAL_PLATFORM_DIR}/libzip.a"
		"${EXTERNAL_PLATFORM_DIR}/libopenal.a"
		"${EXTERNAL_PLATFORM_DIR}/libavformat.a"
		"${EXTERNAL_PLATFORM_DIR}/libavcodec.a"
		"${EXTERNAL_PLATFORM_DIR}/libswresample.a"
		"${EXTERNAL_PLATFORM_DIR}/libswscale.a"
		"${EXTERNAL_PLATFORM_DIR}/libavutil.a"
		"${EXTERNAL_PLATFORM_DIR}/libx264.a"
	)

	if(APPLE)
		message(STATUS "macOS platform")
		target_compile_definitions(${PROJECT_NAME} PRIVATE OS_MAC GL_SILENCE_DEPRECATION)
		set_target_properties(${PROJECT_NAME} PROPERTIES
			CXX_VISIBILITY_PRESET hidden
			VISIBILITY_INLINES_HIDDEN YES
			BUILD_RPATH "@loader_path/Data/Libraries"
			INSTALL_RPATH "@loader_path/Data/Libraries"
			XCODE_GENERATE_SCHEME TRUE
		)

		find_library(ICONV_LIBRARY iconv REQUIRED)
		find_library(AUDIO_TOOLBOX_FRAMEWORK AudioToolbox REQUIRED)
		find_library(CORE_AUDIO_FRAMEWORK CoreAudio REQUIRED)
		target_link_libraries(${PROJECT_NAME} PRIVATE
			${ICONV_LIBRARY}
			${AUDIO_TOOLBOX_FRAMEWORK}
			${CORE_AUDIO_FRAMEWORK}
		)

		message(STATUS "OpenMP runtime = ${OPENMP_RUNTIME_LIBRARY}")
	else()
		message(STATUS "Linux platform")
		set_target_properties(${PROJECT_NAME} PROPERTIES
			BUILD_RPATH "$ORIGIN/Data/Libraries"
			INSTALL_RPATH "$ORIGIN/Data/Libraries"
		)
	endif()
endif()

target_link_libraries(${PROJECT_NAME} PRIVATE
	Qt5::Widgets
	Qt5::Gui
	Qt5::Network
)

# Copy datafiles from GmProjects into build folder for developer configurations
set(DATAFILES_SOURCE_DIR "${REPO_DIR}/GmProject/datafiles")
if(WIN32)
	set(DATAFILES_OUTPUT_DIR "${CMAKE_BINARY_DIR}")
else()
	set(DATAFILES_OUTPUT_DIR "$<TARGET_FILE_DIR:${PROJECT_NAME}>")
endif()

add_custom_command(
	TARGET ${PROJECT_NAME} POST_BUILD
	COMMAND "${CMAKE_COMMAND}" -E
		"$<IF:$<CONFIG:Release>,echo,copy_directory>"
		"$<$<NOT:$<CONFIG:Release>>:${DATAFILES_SOURCE_DIR}>"
		"$<$<NOT:$<CONFIG:Release>>:${DATAFILES_OUTPUT_DIR}>"
	COMMAND "${CMAKE_COMMAND}" -E remove_directory
		"${DATAFILES_OUTPUT_DIR}/Data/Minecraft/Patched"
	VERBATIM
)

# Installation layout
if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
	set(CMAKE_INSTALL_PREFIX "${INSTALL_DIR}/Mine-imator"
		CACHE PATH "Mine-imator installation directory" FORCE)
endif()
install(TARGETS ${PROJECT_NAME}
	RUNTIME DESTINATION "."
	BUNDLE DESTINATION "."
)
install(DIRECTORY
	"${DATAFILES_SOURCE_DIR}/Data"
	"${DATAFILES_SOURCE_DIR}/Particles"
	"${DATAFILES_SOURCE_DIR}/Schematics"
	DESTINATION "."
	PATTERN "Libraries" EXCLUDE
	PATTERN "Patched" EXCLUDE
)
install(DIRECTORY DESTINATION "Skins")

if(WIN32)
	install(FILES "${EXTERNAL_PLATFORM_DIR}/vcomp140.dll" DESTINATION ".")
	install(DIRECTORY DESTINATION "Projects")
elseif(APPLE)
	install(FILES "${OPENMP_RUNTIME_LIBRARY}" DESTINATION "Data/Libraries" RENAME "libomp.dylib")
	set(OPENMP_INSTALLED_EXECUTABLE "\${CMAKE_INSTALL_PREFIX}/Mine-imator")
	install(CODE
		"execute_process(
			COMMAND \"${CMAKE_INSTALL_NAME_TOOL}\"
				-change
				\"${OPENMP_LINKED_LIBRARY}\"
				\"@executable_path/Data/Libraries/libomp.dylib\"
				\"${OPENMP_INSTALLED_EXECUTABLE}\"
				RESULT_VARIABLE OPENMP_PATCH_RESULT
		)
		if(NOT OPENMP_PATCH_RESULT EQUAL 0)
			message(FATAL_ERROR \"Could not patch the installed OpenMP library path\")
		endif()"
	)
else()
	install(DIRECTORY "${EXTERNAL_PLATFORM_DIR}/" DESTINATION "Data/Libraries"
		FILES_MATCHING PATTERN "*.so*"
	)
endif()

# Create CppGen shortcut in IDE
if(CMAKE_GENERATOR STREQUAL "Xcode")
	add_custom_target(CppGen)

	set_target_properties(CppGen PROPERTIES
		XCODE_GENERATE_SCHEME TRUE
		XCODE_SCHEME_EXECUTABLE "${CPPGEN_EXE}"
		XCODE_SCHEME_ARGUMENTS
			"${REPO_DIR};${CPPGEN_DIR}/gml.json"
		XCODE_SCHEME_WORKING_DIRECTORY "${CPPGEN_DIR}"
	)
else()
	add_custom_target(CppGen
		COMMAND "${CPPGEN_EXE}" "${REPO_DIR}" "${CPPGEN_DIR}/gml.json"
		WORKING_DIRECTORY "${CPPGEN_DIR}"
		COMMENT "Running CppGen"
		VERBATIM
		USES_TERMINAL
	)
endif()
