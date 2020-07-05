@echo off
@setlocal EnableExtensions EnableDelayedExpansion

:: This batch file will try to generate a minimalist project
:: It will create a src folder with a small cpp file^
:: It will create a test folder with some mock test files for catch2/catch
:: It will also ask if you want to enable testing
:: If a solution already exists (in the build folder) it will ask if you want to remove it and rebuild
:: NOTE: Run this in admin mode if it doesn't work

set rootDir=%~dp0%
set rootDir=%rootDir:\=/%
set srcDir=%rootDir%
set srcCodeDir=%rootDir%src
set testDir=%rootDir%tests
set builDir=%rootDir%build
set toolChainPath=C:/vcpkg/scripts/buildsystems/vcpkg.cmake
set vtt=x64-windows
set created_test_dir=0


if not exist "%srcCodeDir%" (
	REM You need to use ^ for special chars
	@mkdir "%srcCodeDir%"
	(
		echo #include ^<iostream^>
		echo:
		echo int main^(int argc, char** argv^) {
		echo:
		echo     std::cout ^<^< "Hello World!\n";
		echo:
		echo }
	) > "%srcCodeDir%/main.cpp"
)

if not exist "%testDir%" (
	REM You need to use ^ for special chars
	REM This is not being set correctly 
	set created_test_dir = 1
	
	@mkdir "%testDir%"
	(
		echo #define CATCH_CONFIG_MAIN
		echo #include ^<catch2/catch.hpp^>
	) > "%testDir%/main.cpp"
	
	(
		echo #include ^<catch2/catch.hpp^>
		echo:
		echo TEST_CASE^("Test1", "[Example]"^) {
		echo:
		echo }
	) > "%testDir%/ExampleTest.cpp"
)



if exist "%builDir%/*.sln" (
	CHOICE /M "Solution present. Delete it?"
	REM set /p delete_project="Solution present. Delete it?[yes/no default yes]: "
	REM if NOT DEFINED delete_project (
	if !errorlevel! == 1 (
		echo Removing directory
		rmdir /S "%builDir%"
	)
)

if not exist "%builDir%" mkdir "%builDir%"

:: Specifying the source and build dir does not work for whatever reason
:: cmake -S "%srcDir%" -B "%builDir%" -DCMAKE_TOOLCHAIN_FILE="%toolChainPath%" -DVCPKG_TARGET_TRIPLET="%vtt%"
if not exist "%rootDir%/CMakeLists.txt" (
	choice /M "There is no CMakeLists.txt file. Create one?"
	if !errorlevel! == 1 ( goto :pname ) else ( goto :exit )
	
	:pname
	set /p project_name="Enter Project name: "
	
	if NOT DEFINED project_name (
		echo The name of the project is required
		goto :pname
	)

	:pdesc
	set /p project_desc="Enter Project description: "
	if NOT DEFINED project_desc (
		echo A description is required
		goto :pdesc
	)
	
	
	CHOICE /C EL /D E /T 15 /M "Generate exe or lib?"
	REM ENSURE THERE ARE NO SPACES
	if !errorlevel! == 1 set project_type=exe
	if !errorlevel! == 2 set project_type=lib 
	if !errorlevel! == 0 goto :exit

	echo PROJECT TYPE
	echo !project_type!

	set enable_testing=0
	CHOICE /C YN /D Y /T 15 /M "Enable testing?"
	if !errorlevel! == 1 set enable_testing=1
	
	if !enable_testing! == 0 (
		REM this does not work because I am unable to get created_test_dir to be set with the value 1 when I create a test folder
		if !created_test_dir! == 1 (
			rmdir /s /q %testDir%
		)
	)

	set /p exe_name="Enter exe name(leave empty to use Project Name): "
	if NOT DEFINED exe_name set exe_name=!project_name!

	(
		echo cmake_minimum_required^(VERSION 3.15 FATAL_ERROR^)
		echo project^("!project_name!" DESCRIPTION "!project_desc!" VERSION 0.0.1 LANGUAGES CXX^)
		echo:
		if !enable_testing! == 1 (
			echo include^(CTest^)
			echo:
		)
		if !project_type! == exe (
			echo set^(EXENAME !exe_name!^)
		) else (
			echo set^(LIBNAME !exe_name!lib^)
		)
		echo:
		echo set^(CMAKE_CXX_STANDARD 20^)
		echo set^(CMAKE_CXX_STANDARD_REQUIRED ON^)
		echo set^(CMAKE_CXX_EXTENSIONS OFF^)
		echo:
		echo if ^(MSVC^)
		echo 	add_definitions^(-D_UNICODE -DUNICODE -DWIN32_LEAN_AND_MEAN -DNOMINMAX -DWINVER=0x0A00 -D_WIN32_WINNT=0x0A00^)
		echo 	add_definitions^(-D_CRT_SECURE_NO_DEPRECATE -D_CRT_SECURE_NO_WARNINGS -D_CRT_NONSTDC_NO_DEPRECATE^)
		echo 	add_definitions^(-D_ATL_SECURE_NO_DEPRECATE -D_SCL_SECURE_NO_WARNINGS^)
		echo endif^(^)
		echo:		
		echo file^(GLOB_RECURSE PROJ_SRC_FILES
		echo 	CONFIGURE_DEPENDS
		echo 	src/*.c* src/*.h*
		echo ^)
		echo:
		echo #To properly set the files in the treeview for MSVC
		echo foreach^(source IN LISTS PROJ_SRC_FILES^)
		echo 	get_filename_component^(source_path "${source}" PATH^)
		echo 	string^(REPLACE "${PROJECT_SOURCE_DIR}/" "" source_path_msvc "${source_path}"^)
		echo 	source_group^("${source_path_msvc}" FILES "${source}"^)
		echo endforeach^(^)
		echo:
		
		if !project_type! == exe (
			echo add_executable^(
			echo 	${EXENAME}
			echo 	${PROJ_SRC_FILES}
			echo ^)
		) ELSE (
			echo add_library^(
			echo 	${LIBNAME}
			echo 	${PROJ_SRC_FILES}
			echo ^)
		)
		echo:
		if !enable_testing! == 1 (
			echo enable_testing^(^)
			echo:
			echo file^(GLOB_RECURSE TEST_FILES 
			echo 	CONFIGURE_DEPENDS 
			echo 	${PROJECT_SOURCE_DIR}/tests/*.cpp
			echo ^)
			echo: 
			echo add_executable^(tests
			echo 	${TEST_FILES}
			echo ^)
			echo:
			echo target_include_directories^(tests
			echo 	PUBLIC
			echo 		tests/
			echo 		src/
			echo ^)
			echo:
			echo find_package^(Catch2 CONFIG REQUIRED^)
			echo target_link_libraries^(tests 
			echo 	PRIVATE 
			echo 		Catch2::Catch2
			echo 		${LIBNAME}
			echo ^)
		)
	) > "%rootDir%/CMakeLists.txt"	

)

:skip
if exist "%rootDir%/CMakeLists.txt" (
	echo Executing cmake command
	cd "%builDir%"
	REM %PROJECTS_INSTALL_DIR% is an environment variable set on my system
	cmake .. -DCMAKE_TOOLCHAIN_FILE="%toolChainPath%" -DVCPKG_TARGET_TRIPLET="%vtt%" -DCMAKE_PREFIX_PATH="%PROJECTS_INSTALL_DIR%"
	cd "%rootDir%"
	pause
)

:exit