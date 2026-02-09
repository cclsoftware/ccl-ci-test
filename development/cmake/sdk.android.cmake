include_guard (DIRECTORY)

if (${BUILD_sdk})
	# Add dummy cclsdk app as a target containing all CCL dependencies
	ccl_add_app (cclsdk GUI
		VENDOR ccl
	)

	target_sources (cclsdk PRIVATE ${cclsdk_sources})

	set_target_properties(cclsdk PROPERTIES LINKER_LANGUAGE CXX)

	ccl_add_dependencies (cclsdk ccl)

	if (${BUILD_services})
		ccl_add_dependencies (cclsdk
			coreextras-extensions coreextras-games coreextras-web
			cclextras-analytics cclextras-devices cclextras-extensions cclextras-firebase cclextras-gadgets cclextras-packages cclextras-portable cclextras-stores cclextras-tools cclextras-web cclextras-webfs
			bluetoothservice dapservice jsengine modelimporter3d sqlite
		)
	endif ()

	ccl_add_deployment_project (cclsdk "dev.ccl.sdk"
		CMAKE_ARGS "-DBUILD_sdk=${BUILD_sdk}" "-DBUILD_services=${BUILD_services}"
	)
endif ()
