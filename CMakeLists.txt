cmake_minimum_required(VERSION 3.15 FATAL_ERROR)
project("htmlparser_consumer" DESCRIPTION "consumer for htmlparser lib" VERSION 0.0.1 LANGUAGES CXX)

set(EXENAME htmlparser_consumer)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_CXX_EXTENSIONS OFF)

if (MSVC)
	add_definitions(-D_UNICODE -DUNICODE -DWIN32_LEAN_AND_MEAN -DNOMINMAX -DWINVER=0x0A00 -D_WIN32_WINNT=0x0A00)
	add_definitions(-D_CRT_SECURE_NO_DEPRECATE -D_CRT_SECURE_NO_WARNINGS -D_CRT_NONSTDC_NO_DEPRECATE)
	add_definitions(-D_ATL_SECURE_NO_DEPRECATE -D_SCL_SECURE_NO_WARNINGS)
endif()
		
file(GLOB_RECURSE PROJ_SRC_FILES
	CONFIGURE_DEPENDS
	src/*.c* src/*.h*
)

#To properly set the files in the treeview for MSVC
foreach(source IN LISTS PROJ_SRC_FILES)
	get_filename_component(source_path "${source}" PATH)
	string(REPLACE "${PROJECT_SOURCE_DIR}/" "" source_path_msvc "${source_path}")
	source_group("${source_path_msvc}" FILES "${source}")
endforeach()

add_executable(
	${EXENAME}
	${PROJ_SRC_FILES}
)

find_package(HtmlParser REQUIRED CONFIG)

target_link_libraries(
	${EXENAME} 
	PUBLIC 
	HtmlParser::HtmlParser
)

#add_library(HtmlParser SHARED IMPORTED)
#set_property(TARGET HtmlParser PROPERTY IMPORTED_LOCATION_RELEASE ${PROJECT_SOURCE_DIR}/libs/htmlparser.lib)
#set_property(TARGET HtmlParser PROPERTY IMPORTED_LOCATION_DEBUG   ${PROJECT_SOURCE_DIR}/libs/htmlparser_d.lib)

#target_link_libraries(${EXENAME} 
#	debug 
#		${PROJECT_SOURCE_DIR}/libs/htmlparser_d.lib 
#	optimized 
#		${PROJECT_SOURCE_DIR}/libs/htmlparser.lib
#)

#include_directories(${PROJECT_SOURCE_DIR}/libs/)