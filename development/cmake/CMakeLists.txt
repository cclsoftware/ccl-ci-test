cmake_minimum_required (VERSION 3.23 FATAL_ERROR)

project ("CCL Development")
set (PROJECT_VENDOR ccl)

set (DEBUG_INTERNAL OFF) # disable internal debugging to keep debug/release class interfaces the same

include (vendor)
include (${CMAKE_CURRENT_LIST_DIR}/sdkmacros.cmake)

# Full SDK build

option (BUILD_sdk "Build CCL SDK" OFF)
if (BUILD_sdk)
	set (CCL_SYSTEM_INSTALL ON CACHE BOOL "" FORCE)
	set (CCL_DISABLE_CPACK ON CACHE INTERNAL "" FORCE) # disable packaging for components, create a single SDK package instead

	if (APPLE)
		string (REPLACE ";" "-" ARCH_NAME "${VENDOR_TARGET_ARCHITECTURE}") # for Apple universal binaries (mac-x86_64;arm64 is ONE configuration)
	else ()
		set (ARCH_NAME "${VENDOR_TARGET_ARCHITECTURE}")
	endif ()
	set (PROJECT_ARCHITECTURE_SUBDIRECTORY "${VENDOR_PLATFORM}-${ARCH_NAME}")
	if (WIN32)
		set (PROJECT_APPLICATION_RUNTIME_DIRECTORY "bin")
		set (PROJECT_APPSUPPORT_DESTINATION ".")
		set (PROJECT_DEBUG_SUFFIX "d")
	elseif (UNIX AND NOT APPLE)
		set (PROJECT_VERSION_SUBDIRECTORY "ccl/5.1.0") # TODO: parse version number?
	endif ()

	find_package (corelib REQUIRED COMPONENTS corelib coreextras-extensions coreextras-games coreextras-web)
	find_package (ccl REQUIRED COMPONENTS
		cclbase ccltext cclapp cclsystem cclsecurity cclnet cclgui
		cclextras-analytics cclextras-devices cclextras-extensions
		cclextras-firebase cclextras-gadgets cclextras-packages cclextras-portable
		cclextras-stores cclextras-tools cclextras-web cclextras-webfs
	)

	if (UNIX AND NOT APPLE)
		cmake_path (SET ccl_rpath NORMALIZE "${CMAKE_INSTALL_PREFIX}/${CCL_LIBRARY_DESTINATION}")
		set (CMAKE_INSTALL_RPATH "$ORIGIN;${ccl_rpath}")
	endif ()
endif ()

# Applications

option (BUILD_ccldemo "Build CCL Demo" OFF)
option (BUILD_localizer "Build CCL Localizer" OFF)
option (BUILD_skineditor "Build CCL Skin Editor" OFF)
option (BUILD_testapp "Build CCL Unit Test Application" OFF)

option (BUILD_applications "Build all applications" OFF)
if (BUILD_applications)
	SET (BUILD_ccldemo ON CACHE BOOL "Building all applications" FORCE)
	SET (BUILD_localizer ON CACHE BOOL "Building all applications" FORCE)
	SET (BUILD_skineditor ON CACHE BOOL "Building all applications" FORCE)
	SET (BUILD_testapp ON CACHE BOOL "Building all applications" FORCE)
endif ()

if (BUILD_ccldemo)
	add_subdirectory (${CCL_APPLICATIONS_ROOT}/ccldemo/cmake ccldemo)
endif ()
if (BUILD_localizer)
	add_subdirectory (${CCL_APPLICATIONS_ROOT}/localizer/cmake localizer)
endif ()
if (BUILD_skineditor)
	add_subdirectory (${CCL_APPLICATIONS_ROOT}/skineditor/cmake skineditor)
endif ()
if (BUILD_testapp)
	add_subdirectory (${CCL_APPLICATIONS_ROOT}/testapp/cmake testapp)
endif ()

# Public Tools

option (BUILD_public_tools "Build public CCL tools" OFF)
if (BUILD_public_tools)
	set (PROJECT_APPLICATION_RUNTIME_DIRECTORY "bin/${VENDOR_PLATFORM}/ccl")
	set (CCL_ENABLE_LIBUNISTRING OFF CACHE BOOL "" FORCE)
	set (CCL_INSTALL_TOOLS ON)

	add_subdirectory (${CCL_REPOSITORY_ROOT}/tools/ccl/crypt/cmake crypt)
	add_subdirectory (${CCL_REPOSITORY_ROOT}/tools/ccl/makebin/cmake makebin)
	add_subdirectory (${CCL_REPOSITORY_ROOT}/tools/ccl/makeguid/cmake makeguid)
	add_subdirectory (${CCL_REPOSITORY_ROOT}/tools/ccl/package/cmake package)

	install (FILES
		${CCL_IDENTITIES_DIR}/ccl/legal/CCL\ 3rd\ Party\ Licenses.txt
		${CCL_IDENTITIES_DIR}/ccl/eula/EULA.txt
		DESTINATION "."
	)

	set (CPACK_GENERATOR "ZIP")
	set (CPACK_PACKAGE_NAME "CCL CLI Tools")
	set (CPACK_PACKAGE_VERSION_MAJOR ${CCL_VERSION_MAJOR})
	set (CPACK_PACKAGE_VERSION_MINOR ${CCL_VERSION_MINOR})
	set (CPACK_PACKAGE_VERSION_PATCH ${CCL_VERSION_REVISION})
	set (CPACK_INCLUDE_TOPLEVEL_DIRECTORY OFF)
	set (CPACK_OUTPUT_CONFIG_FILE "${CMAKE_BINARY_DIR}/PublicToolsPackageConfig.cmake")
	include (CPack)
	add_custom_target (publictoolspackage COMMAND "${CMAKE_CPACK_COMMAND}" "-C" "$<CONFIGURATION>" "--config" "${CMAKE_BINARY_DIR}/PublicToolsPackageConfig.cmake")
endif ()

# Tools

option (BUILD_tools "Build CCL tools" OFF)
if (BUILD_sdk AND NOT ANDROID AND NOT IOS)
	set (BUILD_tools ON CACHE BOOL "" FORCE)
endif ()
if (BUILD_tools)
	add_subdirectory (${CCL_REPOSITORY_ROOT}/tools/ccl/cmake tools)
endif ()

# Core Tools

option (BUILD_core_tools "Build core tools" OFF)
if (BUILD_core_tools)
	add_subdirectory (${CCL_REPOSITORY_ROOT}/tools/core/cmake coretools)
endif ()

# Services

option (BUILD_services "Build CCL services" OFF)
if (BUILD_sdk)
	set (BUILD_services ON CACHE BOOL "" FORCE)
endif ()
if (BUILD_services)
	if (NOT IOS)
		find_package (cclspy)
		find_package (sqlite)
	endif ()
	find_package (bluetoothservice)
	find_package (dapservice)
	find_package (jsengine)
	find_package (modelimporter3d)
	find_package (usbservice)
endif ()

# Documentation

option (BUILD_documentation "Build Documentation" OFF)
if (BUILD_sdk AND NOT ANDROID)
	set (BUILD_documentation ON CACHE BOOL "" FORCE)
endif ()
if (BUILD_documentation)
	add_documentation ()
elseif (CCL_DOCUMENTATION_DIR)
	install_documentation ("${CCL_DOCUMENTATION_DIR}")
endif ()

# SDK package

if (BUILD_sdk)
	set (CPACK_PACKAGE_NAME "CCL SDK")
	set (CPACK_OUTPUT_CONFIG_FILE "${CMAKE_BINARY_DIR}/SdkPackageConfig.cmake") # rename output config file to prevent generation of a "package" target, which clashes with our packagetool
	set (CPACK_PACKAGE_VERSION_MAJOR ${CCL_VERSION_MAJOR})
	set (CPACK_PACKAGE_VERSION_MINOR ${CCL_VERSION_MINOR})
	set (CPACK_PACKAGE_VERSION_PATCH ${CCL_VERSION_REVISION})
	set (CPACK_PACKAGE_VENDOR "${CCL_COMPANY_NAME}")
	set (CPACK_PACKAGE_HOMEPAGE_URL "${CCL_WEBSITE}")
	set (CPACK_PACKAGE_COPYRIGHT "${CCL_COPYRIGHT}")
	set (CPACK_PACKAGE_DESCRIPTION "CCL is a cross-platform application framework written in modern C++ for Windows®, macOS®, iOS®, Android™, and Linux with a core library available for embedded development on RTOS platforms.")
	set (CPACK_RESOURCE_FILE_LICENSE "${CMAKE_CURRENT_LIST_DIR}/../packaging/resource/license.txt")

	ccl_include_platform_specifics (sdk)

	include (${CCL_REPOSITORY_ROOT}/ccl/cmake/ccl-install.cmake)

	install (FILES
		"${CPACK_RESOURCE_FILE_LICENSE}"
		DESTINATION "${CCL_LICENSE_DESTINATION}"
		COMPONENT public_headers
	)

	# Include Android SDK
	if (CCL_ANDROID_SDK_DIR)
		if (UNIX AND NOT APPLE)
			foreach (arch IN ITEMS armv7 arm64 i386 x86_64)
				execute_process (COMMAND sed -i -e "s|\$\{_IMPORT_PREFIX\}/include|\$\{_IMPORT_PREFIX\}/include/${PROJECT_VERSION_SUBDIRECTORY}|g" "${CMAKE_CURRENT_LIST_DIR}/${CCL_ANDROID_SDK_DIR}/cmake/android-${arch}/ccl-targets.cmake")
			endforeach ()
		endif ()

		cpack_add_component (public_headers_android DISPLAY_NAME "android_headers" DESCRIPTION "Public header files for Android" DEPENDS public_headers HIDDEN)
		cpack_add_component (prebuilt_libraries_android_java DISPLAY_NAME "android_java" DESCRIPTION "Prebuilt libraries targeting Android" GROUP prebuilt_libraries HIDDEN)
		cpack_add_component (services_android_java DISPLAY_NAME "android_java" DESCRIPTION "Prebuilt services targeting Android" GROUP prebuilt_libraries DEPENDS prebuilt_libraries_android_java HIDDEN)

		cpack_add_component (prebuilt_libraries_android_arm DISPLAY_NAME "android_arm" DESCRIPTION "Prebuilt libraries targeting Android arm" GROUP prebuilt_libraries DEPENDS public_headers_android prebuilt_libraries_android_java)
		cpack_add_component (services_android_arm DISPLAY_NAME "android_arm" DESCRIPTION "Prebuilt services targeting Android arm" GROUP services DEPENDS prebuilt_libraries_android_arm services_android_java)

		cpack_add_component (prebuilt_libraries_android_arm64 DISPLAY_NAME "android_arm64" DESCRIPTION "Prebuilt libraries targeting Android arm64" GROUP prebuilt_libraries DEPENDS public_headers_android prebuilt_libraries_android_java)
		cpack_add_component (services_android_arm64 DISPLAY_NAME "android_arm64" DESCRIPTION "Prebuilt services targeting Android arm64" GROUP services DEPENDS prebuilt_libraries_android_arm64 services_android_java)

		cpack_add_component (prebuilt_libraries_android_x86 DISPLAY_NAME "android_x86" DESCRIPTION "Prebuilt libraries targeting Android x86" GROUP prebuilt_libraries DEPENDS public_headers_android prebuilt_libraries_android_java)
		cpack_add_component (services_android_x86 DISPLAY_NAME "android_x86" DESCRIPTION "Prebuilt services targeting Android x86" GROUP services DEPENDS prebuilt_libraries_android_x86 services_android_java)

		cpack_add_component (prebuilt_libraries_android_x64 DISPLAY_NAME "android_x64" DESCRIPTION "Prebuilt libraries targeting Android x64" GROUP prebuilt_libraries DEPENDS public_headers_android prebuilt_libraries_android_java)
		cpack_add_component (services_android_x64 DISPLAY_NAME "android_x64" DESCRIPTION "Prebuilt services targeting Android x64" GROUP services DEPENDS prebuilt_libraries_android_x64 services_android_java)

		set (android_library_destination "${CCL_STATIC_LIBRARY_DESTINATION}/..")
		cmake_path (NORMAL_PATH android_library_destination)

		if(NOT "${CCL_SUPPORT_DESTINATION}" STREQUAL ".")
			set (android_build_support_destination "${CCL_SUPPORT_DESTINATION}/build")
		else ()
			set (android_build_support_destination "build")
		endif ()

		install (DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/${CCL_ANDROID_SDK_DIR}/include/core/platform/android DESTINATION "${corelib_PUBLIC_HEADERS_DESTINATION}/platform" COMPONENT public_headers_android)
		install (DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/${CCL_ANDROID_SDK_DIR}/include/core/platform/shared/jni DESTINATION "${corelib_PUBLIC_HEADERS_DESTINATION}/platform/shared" COMPONENT public_headers_android)
		install (DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/${CCL_ANDROID_SDK_DIR}/include/core/platform/shared/posix DESTINATION "${corelib_PUBLIC_HEADERS_DESTINATION}/platform/shared" COMPONENT public_headers_android)
		install (DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/${CCL_ANDROID_SDK_DIR}/include/ccl/platform/android DESTINATION "${CCL_PUBLIC_HEADERS_DESTINATION}/platform" COMPONENT public_headers_android)

		install (DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/${CCL_ANDROID_SDK_DIR}/cmake/android-armv7 DESTINATION "${CCL_CMAKE_EXPORT_DESTINATION}" COMPONENT prebuilt_libraries_android_arm)
		install (DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/${CCL_ANDROID_SDK_DIR}/lib/android-armv7 DESTINATION "${android_library_destination}" COMPONENT prebuilt_libraries_android_arm PATTERN Plugins EXCLUDE)

		install (DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/${CCL_ANDROID_SDK_DIR}/cmake/android-arm64 DESTINATION "${CCL_CMAKE_EXPORT_DESTINATION}" COMPONENT prebuilt_libraries_android_arm64)
		install (DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/${CCL_ANDROID_SDK_DIR}/lib/android-arm64 DESTINATION "${android_library_destination}" COMPONENT prebuilt_libraries_android_arm64 PATTERN Plugins EXCLUDE)

		install (DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/${CCL_ANDROID_SDK_DIR}/cmake/android-i386 DESTINATION "${CCL_CMAKE_EXPORT_DESTINATION}" COMPONENT prebuilt_libraries_android_x86)
		install (DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/${CCL_ANDROID_SDK_DIR}/lib/android-i386 DESTINATION "${android_library_destination}" COMPONENT prebuilt_libraries_android_x86 PATTERN Plugins EXCLUDE)

		install (DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/${CCL_ANDROID_SDK_DIR}/cmake/android-x86_64 DESTINATION "${CCL_CMAKE_EXPORT_DESTINATION}" COMPONENT prebuilt_libraries_android_x64)
		install (DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/${CCL_ANDROID_SDK_DIR}/lib/android-x86_64 DESTINATION "${android_library_destination}" COMPONENT prebuilt_libraries_android_x64 PATTERN Plugins EXCLUDE)

		install (DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/${CCL_ANDROID_SDK_DIR}/build/android DESTINATION "${android_build_support_destination}" COMPONENT prebuilt_libraries_android_java)
		install (DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/${CCL_ANDROID_SDK_DIR}/lib/android-java DESTINATION "${android_library_destination}" COMPONENT prebuilt_libraries_android_java PATTERN bluetoothservice.aar EXCLUDE)

		install (FILES
			${CMAKE_CURRENT_LIST_DIR}/${CCL_ANDROID_SDK_DIR}/cmake/cclapp.android.cmake
			${CMAKE_CURRENT_LIST_DIR}/${CCL_ANDROID_SDK_DIR}/cmake/cclbase.android.cmake
			${CMAKE_CURRENT_LIST_DIR}/${CCL_ANDROID_SDK_DIR}/cmake/cclextras-stores.android.cmake
			${CMAKE_CURRENT_LIST_DIR}/${CCL_ANDROID_SDK_DIR}/cmake/cclgui.android.cmake
			${CMAKE_CURRENT_LIST_DIR}/${CCL_ANDROID_SDK_DIR}/cmake/cclmacros.android.cmake
			${CMAKE_CURRENT_LIST_DIR}/${CCL_ANDROID_SDK_DIR}/cmake/cclnet.android.cmake
			${CMAKE_CURRENT_LIST_DIR}/${CCL_ANDROID_SDK_DIR}/cmake/ccltext.android.cmake
			${CMAKE_CURRENT_LIST_DIR}/${CCL_ANDROID_SDK_DIR}/cmake/cclsecurity.android.cmake
			${CMAKE_CURRENT_LIST_DIR}/${CCL_ANDROID_SDK_DIR}/cmake/cclsystem.android.cmake
			${CMAKE_CURRENT_LIST_DIR}/${CCL_ANDROID_SDK_DIR}/cmake/corelib.android.cmake
			${CMAKE_CURRENT_LIST_DIR}/${CCL_ANDROID_SDK_DIR}/cmake/coremacros.android.cmake
			DESTINATION "${CCL_CMAKE_EXPORT_DESTINATION}"
			COMPONENT prebuilt_libraries_android_java
		)

		set (android_library_prefix "${android_library_destination}/android")
		cmake_path (NORMAL_PATH android_library_prefix)
		install (DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/${CCL_ANDROID_SDK_DIR}/lib/android-armv7/Plugins DESTINATION "${android_library_prefix}-armv7" COMPONENT services_android_arm)
		install (DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/${CCL_ANDROID_SDK_DIR}/lib/android-arm64/Plugins DESTINATION "${android_library_prefix}-arm64" COMPONENT services_android_arm64)
		install (DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/${CCL_ANDROID_SDK_DIR}/lib/android-i386/Plugins DESTINATION "${android_library_prefix}-i386" COMPONENT services_android_x86)
		install (DIRECTORY ${CMAKE_CURRENT_LIST_DIR}/${CCL_ANDROID_SDK_DIR}/lib/android-x86_64/Plugins DESTINATION "${android_library_prefix}-x86_64" COMPONENT services_android_x64)

		install (FILES
			${CMAKE_CURRENT_LIST_DIR}/${CCL_ANDROID_SDK_DIR}/cmake/bluetoothservice.android.cmake
			${CMAKE_CURRENT_LIST_DIR}/${CCL_ANDROID_SDK_DIR}/cmake/dapservice.android.cmake
			${CMAKE_CURRENT_LIST_DIR}/${CCL_ANDROID_SDK_DIR}/cmake/jsengine.android.cmake
			${CMAKE_CURRENT_LIST_DIR}/${CCL_ANDROID_SDK_DIR}/cmake/modelimporter3d.android.cmake
			${CMAKE_CURRENT_LIST_DIR}/${CCL_ANDROID_SDK_DIR}/cmake/sqlite.android.cmake
			DESTINATION "${CCL_CMAKE_EXPORT_DESTINATION}"
			COMPONENT services_android_java
		)

		install (FILES ${CMAKE_CURRENT_LIST_DIR}/${CCL_ANDROID_SDK_DIR}/lib/android-java/bluetoothservice.aar DESTINATION "${android_library_prefix}-java" COMPONENT services_android_java)
	endif ()

	include (CPack)
	add_custom_target (sdkpackage COMMAND "${CMAKE_CPACK_COMMAND}" "-C" "$<CONFIGURATION>" "--config" "${CMAKE_BINARY_DIR}/SdkPackageConfig.cmake")
	set_target_properties (sdkpackage PROPERTIES USE_FOLDERS ON FOLDER "cmake")

	if (WIN32)
		ccl_sign_files (signed_sdkpackage "${PROJECT_VENDOR}" "${CPACK_PACKAGE_DIRECTORY}/*.exe")
	endif ()
endif ()
