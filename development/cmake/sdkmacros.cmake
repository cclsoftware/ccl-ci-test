include (ExternalProject)

macro (add_sdk_preset preset)

	option (BUILD_sdk_preset_${preset} "Build SDK preset ${preset}" ON)
	if (BUILD_sdk_preset_${preset})

		cmake_parse_arguments (preset_params "SIGN" "TOOLCHAIN;COMPONENT_SUFFIX;BUILD_SUFFIX" "CMAKE_ARGS" ${ARGN})

		if (NOT preset_params_COMPONENT_SUFFIX)
			set (preset_params_COMPONENT_SUFFIX ${preset})
		endif ()

		if (NOT preset_params_BUILD_SUFFIX)
			set (preset_params_BUILD_SUFFIX "${preset_params_COMPONENT_SUFFIX}")
		endif ()

		set (sdk_dest_dir "${CMAKE_BINARY_DIR}/sdk-${preset}/package")
		set (build_dir "${CMAKE_BINARY_DIR}/sdk-${preset}/build")
		set (cpack_config "${build_dir}/SdkPackageConfig.cmake")

		if (CMAKE_CONFIGURATION_TYPES)
			set (build_config "--config $<CONFIG>")
			set (install_config "-C $<CONFIG>")
		else ()
			set (build_config "")
			set (install_config "")
		endif ()

		set (cmake_args ${preset_params_CMAKE_ARGS})
		if (preset_params_TOOLCHAIN)
			list (APPEND cmake_args --toolchain "${preset_params_TOOLCHAIN}")
		endif ()

		if (TARGET sign_ccl_binaries AND preset_params_SIGN)
			set (sign_command ${CMAKE_COMMAND} --build "${build_dir}" --target sign_ccl_binaries ${build_config})
		else ()
			set (sign_command ${CMAKE_COMMAND} -E echo "Not signing ${preset} binaries")
		endif ()

		ExternalProject_Add (sdk-${preset}
			PREFIX "${CMAKE_BINARY_DIR}/sdk-${preset}"
			SOURCE_DIR "${CMAKE_CURRENT_LIST_DIR}"
			LIST_SEPARATOR "|"
			CONFIGURE_COMMAND ${CMAKE_COMMAND} -S "${CMAKE_CURRENT_LIST_DIR}" -B "${build_dir}" --preset ${preset} -DVENDOR_ENABLE_CODESIGNING=${VENDOR_ENABLE_CODESIGNING} -DBUILD_sdk=ON -DBUILD_documentation=OFF -DCPACK_SYSTEM_NAME=${preset} -DVENDOR_ENABLE_PARALLEL_BUILDS=ON -DCPACK_ARCHIVE_COMPONENT_INSTALL=ON ${cmake_args}
			BUILD_COMMAND ${CMAKE_COMMAND} -E echo "Building SDK configuration ${preset}" && ${CMAKE_COMMAND} --build "${build_dir}" ${build_config}
			INSTALL_COMMAND ${sign_command}
			COMMAND cpack -G ZIP -B ${sdk_dest_dir}/$<CONFIG> --config ${cpack_config} ${install_config}
			#WORKING_DIRECTORY "${CMAKE_CURRENT_LIST_DIR}"
			#LOG_CONFIGURE ON
			#LOG_INSTALL ON
			#LOG_BUILD ON
			#LOG_OUTPUT_ON_FAILURE ON
		)

		if ("${preset}" MATCHES "android.*")
			ExternalProject_Add_Step (sdk-${preset} stop-gradle
				COMMAND ${CCL_REPOSITORY_ROOT}/build/android/gradle/wrapper/gradlew.bat --stop
				DEPENDEES build
				DEPENDERS install
			)
		endif ()

		set (sdk_debug_dir "${sdk_dest_dir}/Debug/_CPack_Packages/${preset}/ZIP/${CPACK_PACKAGE_NAME}-${CCL_VERSION}-${preset}")
		set (sdk_release_dir "${sdk_dest_dir}/Release/_CPack_Packages/${preset}/ZIP/${CPACK_PACKAGE_NAME}-${CCL_VERSION}-${preset}")

		foreach (component public_headers prebuilt_libraries services)
			file (MAKE_DIRECTORY ${sdk_debug_dir}/${component}_${preset_params_BUILD_SUFFIX})
			file (MAKE_DIRECTORY ${sdk_release_dir}/${component}_${preset_params_BUILD_SUFFIX})
			install (DIRECTORY "${sdk_dest_dir}/$<CONFIG>/_CPack_Packages/${preset}/ZIP/${CPACK_PACKAGE_NAME}-${CCL_VERSION}-${preset}/${component}_${preset_params_BUILD_SUFFIX}/" DESTINATION "." COMPONENT ${component}_${preset_params_COMPONENT_SUFFIX})
		endforeach ()
	endif ()
endmacro ()

function (add_documentation)

	cmake_parse_arguments (documentation "" "PROJECT;FORMAT" "" ${ARGN})

	find_package (Python3 COMPONENTS Interpreter)
	if (NOT Python3_FOUND)
		message (NOTICE "Skipping documentation. Missing dependency: python3")
		return ()
	endif ()

	find_program (sphinx NAMES sphinx-build sphinx-build.exe)
	if (NOT sphinx)
		message (NOTICE "Skipping documentation. Missing dependency: sphinx-build")
		message (NOTICE "The following sphinx extensions are required:\n\tbreathe\n\tsphinx-rtd-theme")
		return ()
	endif ()

	find_program (doxygen NAMES doxygen doxygen.exe)
	if (NOT doxygen)
		message (NOTICE "Skipping documentation. Missing dependency: doxygen")
		return ()
	endif ()

	if (NOT documentation_PROJECT)
		set (documentation_PROJECT "dev.ccl.doc.cclpublicsdk")
	endif ()
	if (NOT documentation_FORMAT)
		set (documentation_FORMAT "html")
	endif ()

	if ("${documentation_FORMAT}" STREQUAL "html")
		set (output_suffix "html")
	endif ()

	set (documentation_revision_number "${CCL_VERSION_BUILD}")

	set (makedoc "${CCL_REPOSITORY_ROOT}/tools/doctools/makedoc/makedoc.py")
	set (output_path "${CCL_REPOSITORY_ROOT}/tools/doctools/makedoc/output/${documentation_PROJECT}/${output_suffix}")

	ExternalProject_Add (sdk-documentation
		PREFIX "${CMAKE_BINARY_DIR}/sdk-documentation"
		SOURCE_DIR "${CMAKE_CURRENT_LIST_DIR}"
		LIST_SEPARATOR "|"
		CONFIGURE_COMMAND ""
		BUILD_COMMAND ${Python3_EXECUTABLE} "${makedoc}" -no-rebuild -v "${documentation_PROJECT}" "${documentation_FORMAT}" "${documentation_revision_number}"
		INSTALL_COMMAND ""
		#LOG_CONFIGURE ON
		#LOG_INSTALL ON
		#LOG_BUILD ON
		#LOG_OUTPUT_ON_FAILURE ON
	)

	install_documentation ("${output_path}")

endfunction ()

function (install_documentation from)
	set (ccl_support_dest_path "${CCL_SUPPORT_DESTINATION}/")
	if ("${ccl_support_dest_path}" STREQUAL "./")
		set (ccl_support_dest_path "")
	endif ()

	install (DIRECTORY "${from}/" DESTINATION "${ccl_support_dest_path}documentation/" COMPONENT documentation)
endfunction ()
