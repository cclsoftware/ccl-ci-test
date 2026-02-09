# CCL Development (Framework, Applications, SDK)

CMake and packaging infrastructure for CCL framework, applications, and SDK.

## Windows

To build an SDK package on Windows, run the following commands (assuming bash syntax):

```
cd cmake
cmake --preset win64 -DBUILD_sdk=ON
cd build/x64
cmake --build . --config Debug
cmake --build . --config Release
cpack -G NSIS64 -C 'Debug;Release' --config SdkPackageConfig.cmake
```

To build the Visual Studio solution for CCL Demo:

```
cd cmake
cmake --preset win64 -DBUILD_ccldemo=ON
```

## Linux

For Linux, use the Ninja Multi-Config generator:

```
cd cmake 
cmake --preset linux -DBUILD_sdk=ON
cd build/x64
cmake --build . --config Debug
cmake --build . --config Release
cpack -C 'Debug;Release' --config SdkPackageConfig.cmake
```
