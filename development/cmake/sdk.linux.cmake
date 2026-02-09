if ("${VENDOR_TARGET_ARCHITECTURE}" STREQUAL "x86_64")
	add_sdk_preset (linux-arm64 COMPONENT_SUFFIX linux_arm64 TOOLCHAIN "${REPOSITORY_ROOT}/build/cmake/toolchains/aarch64-linux-ubuntu-toolchain.cmake")

	# find the default template shipped with cmake
	find_file (base_template REQUIRED NAMES "Modules/Internal/CPack/CPack.STGZ_Header.sh.in" PATH_SUFFIXES "share/cmake-${CMAKE_MAJOR_VERSION}.${CMAKE_MINOR_VERSION}")

	set (stgz_template "${CMAKE_BINARY_DIR}/stgz/ccl-sdk/CPack.STGZ_Header.sh.in")
	list (APPEND CMAKE_MODULE_PATH "${CMAKE_BINARY_DIR}/stgz/ccl-sdk")

	# copy the base template and replace defaults
	file (READ "${base_template}" template_contents)
	string (REPLACE "cpack_include_subdir=\"\"" "cpack_include_subdir=FALSE" template_contents "${template_contents}")
	string (REPLACE "toplevel=\"`pwd`\"" "toplevel=/" template_contents "${template_contents}")
	string (REPLACE "interactive=FALSE" "interactive=TRUE" template_contents "${template_contents}")

	file (WRITE "${stgz_template}" "${template_contents}")
endif ()
