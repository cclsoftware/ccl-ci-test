if (NOT CMAKE_SYSROOT AND DEFINED ENV{UBUNTU_SYSROOT})
	set (CMAKE_SYSROOT "$ENV{UBUNTU_SYSROOT}")
elseif (NOT CMAKE_SYSROOT)
	set (CMAKE_SYSROOT "/var/lib/schroot/chroots/ubuntu-arm64")
endif ()

include ("${CMAKE_CURRENT_LIST_DIR}/aarch64-linux-toolchain.cmake")
