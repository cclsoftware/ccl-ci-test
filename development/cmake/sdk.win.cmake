install (FILES 
	${CCL_REPOSITORY_ROOT}/build/win/nsis/ccl.nsh
	${CCL_REPOSITORY_ROOT}/build/win/nsis/functions.nsh
	${CCL_REPOSITORY_ROOT}/build/win/nsis/localize.nsh
	${CCL_REPOSITORY_ROOT}/build/win/nsis/muicustomize.nsh
	${CCL_REPOSITORY_ROOT}/build/win/nsis/shared.nsh
	DESTINATION ${CCL_PUBLIC_HEADERS_DESTINATION}/packaging/win/nsis
)

cmake_path (SET nsis_path NORMALIZE "${CMAKE_CURRENT_LIST_DIR}/../packaging/win/nsis")
cmake_path (SET resource_path NORMALIZE "${nsis_path}/resource")

set (CPACK_NSIS_COMPONENT_INSTALL ON)
set (CPACK_PACKAGE_INSTALL_DIRECTORY "${CCL_NAME}\\\\CCL ${CCL_VERSION}")
set (CPACK_NSIS_DISPLAY_NAME "${CCL_NAME} SDK ${CCL_VERSION}")
set (CPACK_NSIS_PACKAGE_NAME "${CCL_NAME} SDK")
set (CPACK_NSIS_BRANDING_TEXT " ")
set (CPACK_NSIS_MANIFEST_DPI_AWARE "1")
set (CPACK_NSIS_MUI_WELCOMEFINISHPAGE_BITMAP "${resource_path}/wizard@2x.bmp")
set (CPACK_NSIS_MUI_UNWELCOMEFINISHPAGE_BITMAP "${resource_path}/wizard@2x.bmp")
set (CPACK_NSIS_MUI_HEADERIMAGE "${resource_path}/header@2x.bmp")
set (CPACK_NSIS_MUI_ICON "${resource_path}/installer-icon.ico")
set (CPACK_NSIS_MUI_UNIICON "${resource_path}/installer-icon.ico")

set (CPACK_NSIS_EXTRA_INSTALL_COMMANDS "
	WriteRegStr HKLM \\\"Software\\\\Kitware\\\\CMake\\\\Packages\\\\CCL\\\" \\\"${CCL_VERSION}\\\" \\\"\$INSTDIR\\\\${CCL_CMAKE_EXPORT_DESTINATION}\\\"
	WriteRegStr HKLM \\\"Software\\\\Kitware\\\\CMake\\\\Packages\\\\corelib\\\" \\\"${CCL_VERSION}\\\" \\\"\$INSTDIR\\\\${CCL_CMAKE_EXPORT_DESTINATION}\\\"
	WriteRegStr HKLM \\\"Software\\\\Kitware\\\\CMake\\\\Packages\\\\extensions\\\" \\\"${CCL_VERSION}\\\" \\\"\$INSTDIR\\\\${CCL_CMAKE_EXPORT_DESTINATION}\\\"
	WriteRegStr HKLM \\\"Software\\\\Microsoft\\\\Windows\\\\CurrentVersion\\\\Uninstall\\\\${CPACK_PACKAGE_INSTALL_DIRECTORY}\\\" \\\"InstallLocation\\\" \\\"\$INSTDIR\\\"
	WriteRegStr HKLM \\\"Software\\\\Microsoft\\\\Windows\\\\CurrentVersion\\\\Uninstall\\\\${CPACK_PACKAGE_INSTALL_DIRECTORY}\\\" \\\"UninstallString\\\" \\\"\$INSTDIR\\\\Uninstall.exe\\\"
")

set (CPACK_NSIS_EXTRA_UNINSTALL_COMMANDS "
	DeleteRegValue HKLM \\\"Software\\\\Kitware\\\\CMake\\\\Packages\\\\CCL\\\" \\\"${CCL_VERSION}\\\"
	DeleteRegValue HKLM \\\"Software\\\\Kitware\\\\CMake\\\\Packages\\\\corelib\\\" \\\"${CCL_VERSION}\\\"
	DeleteRegValue HKLM \\\"Software\\\\Kitware\\\\CMake\\\\Packages\\\\extensions\\\" \\\"${CCL_VERSION}\\\"
")

string (REGEX REPLACE "/" "\\\\\\\\" CPACK_RESOURCE_FILE_LICENSE "${CPACK_RESOURCE_FILE_LICENSE}")
string (REGEX REPLACE "/" "\\\\\\\\" CPACK_NSIS_MUI_WELCOMEFINISHPAGE_BITMAP "${CPACK_NSIS_MUI_WELCOMEFINISHPAGE_BITMAP}")
string (REGEX REPLACE "/" "\\\\\\\\" CPACK_NSIS_MUI_UNWELCOMEFINISHPAGE_BITMAP "${CPACK_NSIS_MUI_UNWELCOMEFINISHPAGE_BITMAP}")
string (REGEX REPLACE "/" "\\\\\\\\" CPACK_NSIS_MUI_ICON "${CPACK_NSIS_MUI_ICON}")
string (REGEX REPLACE "/" "\\\\\\\\" CPACK_NSIS_MUI_UNIICON "${CPACK_NSIS_MUI_UNIICON}")
string (REGEX REPLACE "/" "\\\\\\\\" CPACK_NSIS_MUI_HEADERIMAGE "${CPACK_NSIS_MUI_HEADERIMAGE}")

# find the default template shipped with cmake
find_file (base_template REQUIRED NAMES "Modules/Internal/CPack/NSIS.template.in" PATH_SUFFIXES "share/cmake-${CMAKE_MAJOR_VERSION}.${CMAKE_MINOR_VERSION}")

# copy the base template and prepend with custom commands and definitions
set (nsis_template "${CMAKE_BINARY_DIR}/nsis/ccl-sdk/NSIS.template.in")
list (APPEND CMAKE_MODULE_PATH "${CMAKE_BINARY_DIR}/nsis/ccl-sdk")
file (READ "${nsis_path}/sdk-installer.nsis.in" template_contents)
file (READ "${base_template}" base_template_contents OFFSET 3) # skip byte order mark

# don't generate start menu entries
string (REPLACE "!insertmacro MUI_PAGE_STARTMENU" ";!insertmacro MUI_PAGE_STARTMENU" base_template_contents "${base_template_contents}")
string (REGEX REPLACE "\\!insertmacro MUI_STARTMENU_WRITE_BEGIN(.*)MUI_STARTMENU_WRITE_END" "; no start menu entries" base_template_contents "${base_template_contents}")

file (CONFIGURE OUTPUT "${nsis_template}" CONTENT "${template_contents}" NEWLINE_STYLE CRLF)
file (APPEND "${nsis_template}" "${base_template_contents}")

if ("${VENDOR_TARGET_ARCHITECTURE}" STREQUAL "x86_64")
	add_sdk_preset (win-arm64 COMPONENT_SUFFIX win_arm64 SIGN)
endif ()
