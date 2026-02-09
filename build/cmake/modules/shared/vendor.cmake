include_guard (DIRECTORY)

set (VENDOR_MACROS_FILE "${CMAKE_CURRENT_LIST_FILE}" CACHE FILEPATH "Vendor-specific macros file" FORCE)

# Add module directories recursively
list (APPEND VENDOR_MODULE_DIRS "${CMAKE_CURRENT_LIST_DIR}/..")

set (REPOSITORY_ROOT "${CMAKE_CURRENT_LIST_DIR}/../../../.." CACHE PATH "Root directory of the repository" FORCE)
set (REPOSITORY_SIGNING_DIR "${REPOSITORY_ROOT}/build/signing" CACHE PATH "Vendor code signing directory" FORCE)

list (APPEND VENDOR_SIGNING_DIRS "${REPOSITORY_SIGNING_DIR}")

#include ("${REPOSITORY_ROOT}/applications/build/cmake/modules/shared/vendor.cmake")
include ("${REPOSITORY_ROOT}/framework/build/cmake/modules/shared/vendor.cmake")

# try to find global platform configuration file
if (NOT VENDOR_PLATFORMMACROS_FILE)
	if (NOT VENDOR_PLATFORM)
		message (FATAL_ERROR "VENDOR_PLATFORM not set.")
	endif ()
endif ()

set (platformdir "${CMAKE_CURRENT_LIST_DIR}/../${VENDOR_PLATFORM}")
set (platformdir2 "${CMAKE_CURRENT_LIST_DIR}/${VENDOR_PLATFORM}")
get_filename_component (platformdir ${platformdir} ABSOLUTE)
find_file (VENDOR_PLATFORMMACROS_FILE NAMES "vendor.${VENDOR_PLATFORM}.cmake" HINTS "${platformdir}" "${platformdir2}" "${CMAKE_CURRENT_LIST_DIR}" DOC "Platform specific cmake file with additional settings.")

# include platform-specific config file
if (EXISTS "${VENDOR_PLATFORMMACROS_FILE}")
	include ("${VENDOR_PLATFORMMACROS_FILE}")
endif ()

ccl_generate_repo_info ("${REPOSITORY_ROOT}/repo.json")
