set (triple "aarch64-linux-gnu")

set (CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
set (CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
set (CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)

set (CMAKE_FIND_ROOT_PATH "${CMAKE_SYSROOT};/")
set (CMAKE_LIBRARY_PATH "${CMAKE_SYSROOT}/usr/lib/${triple};${CMAKE_SYSROOT}/usr/lib")
set (CMAKE_PROGRAM_PATH "${CMAKE_SYSROOT}/usr/bin")
set (CMAKE_PREFIX_PATH "${CMAKE_SYSROOT}/usr/lib/${triple}/cmake;${CMAKE_SYSROOT}/usr/lib/cmake;/")

set (PKG_CONFIG_EXECUTABLE "/usr/bin/pkg-config")
set (ENV{PKG_CONFIG_DIR} "")
set (ENV{PKG_CONFIG_LIBDIR} "${CMAKE_SYSROOT}/usr/lib/${triple}/pkgconfig:${CMAKE_SYSROOT}/usr/lib/pkgconfig:${CMAKE_SYSROOT}/usr/share/pkgconfig")
set (ENV{PKG_CONFIG_SYSROOT_DIR} ${CMAKE_SYSROOT})

set (VENDOR_DYNAMIC_LINKER_PATH "${CMAKE_SYSROOT}/lib/ld-linux-aarch64.so.1")
