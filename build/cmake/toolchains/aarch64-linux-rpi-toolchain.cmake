if (NOT CMAKE_SYSROOT AND DEFINED ENV{RASPBERRYPI_SYSROOT})
	set (CMAKE_SYSROOT "$ENV{RASPBERRYPI_SYSROOT}")
elseif (NOT CMAKE_SYSROOT)
	set (CMAKE_SYSROOT "/var/lib/schroot/chroots/rpizero-bookworm-arm64")
endif ()

include ("${CMAKE_CURRENT_LIST_DIR}/aarch64-linux-toolchain.cmake")
