# Install script for directory: C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/746526a878/_deps/opencv-src

# Set the install prefix
if(NOT DEFINED CMAKE_INSTALL_PREFIX)
  set(CMAKE_INSTALL_PREFIX "C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/746526a878/install")
endif()
string(REGEX REPLACE "/$" "" CMAKE_INSTALL_PREFIX "${CMAKE_INSTALL_PREFIX}")

# Set the install configuration name.
if(NOT DEFINED CMAKE_INSTALL_CONFIG_NAME)
  if(BUILD_TYPE)
    string(REGEX REPLACE "^[^A-Za-z0-9_]+" ""
           CMAKE_INSTALL_CONFIG_NAME "${BUILD_TYPE}")
  else()
    set(CMAKE_INSTALL_CONFIG_NAME "Release")
  endif()
  message(STATUS "Install configuration: \"${CMAKE_INSTALL_CONFIG_NAME}\"")
endif()

# Set the component getting installed.
if(NOT CMAKE_INSTALL_COMPONENT)
  if(COMPONENT)
    message(STATUS "Install component: \"${COMPONENT}\"")
    set(CMAKE_INSTALL_COMPONENT "${COMPONENT}")
  else()
    set(CMAKE_INSTALL_COMPONENT)
  endif()
endif()

# Install shared libraries without execute permission?
if(NOT DEFINED CMAKE_INSTALL_SO_NO_EXE)
  set(CMAKE_INSTALL_SO_NO_EXE "0")
endif()

# Is this installation the result of a crosscompile?
if(NOT DEFINED CMAKE_CROSSCOMPILING)
  set(CMAKE_CROSSCOMPILING "TRUE")
endif()

# Set default install directory permissions.
if(NOT DEFINED CMAKE_OBJDUMP)
  set(CMAKE_OBJDUMP "C:/Users/chitt/AppData/Local/Android/Sdk/ndk/26.3.11579264/toolchains/llvm/prebuilt/windows-x86_64/bin/llvm-objdump.exe")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xlicensesx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/sdk/etc/licenses" TYPE FILE RENAME "dlpack-LICENSE" FILES "C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/746526a878/_deps/opencv-src/3rdparty/dlpack/LICENSE")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xlicensesx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/sdk/etc/licenses" TYPE FILE RENAME "flatbuffers-LICENSE.txt" FILES "C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/746526a878/_deps/opencv-src/3rdparty/flatbuffers/LICENSE.txt")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xlicensesx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/sdk/etc/licenses" TYPE FILE RENAME "opencl-headers-LICENSE.txt" FILES "C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/746526a878/_deps/opencv-src/3rdparty/include/opencl/LICENSE.txt")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xdevx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/sdk/native/jni/include/opencv2" TYPE FILE FILES "C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/746526a878/cvconfig.h")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xdevx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/sdk/native/jni/include/opencv2" TYPE FILE FILES "C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/746526a878/opencv2/opencv_modules.hpp")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xdevx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/sdk/native/jni" TYPE FILE FILES "C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/746526a878/unix-install/OpenCV.mk")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xdevx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/sdk/native/jni" TYPE FILE FILES "C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/746526a878/unix-install/OpenCV-arm64-v8a.mk")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xdevx" OR NOT CMAKE_INSTALL_COMPONENT)
  if(EXISTS "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/sdk/native/jni/abi-arm64-v8a/OpenCVModules.cmake")
    file(DIFFERENT EXPORT_FILE_CHANGED FILES
         "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/sdk/native/jni/abi-arm64-v8a/OpenCVModules.cmake"
         "C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/746526a878/_deps/opencv-build/CMakeFiles/Export/sdk/native/jni/abi-arm64-v8a/OpenCVModules.cmake")
    if(EXPORT_FILE_CHANGED)
      file(GLOB OLD_CONFIG_FILES "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/sdk/native/jni/abi-arm64-v8a/OpenCVModules-*.cmake")
      if(OLD_CONFIG_FILES)
        message(STATUS "Old export file \"$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/sdk/native/jni/abi-arm64-v8a/OpenCVModules.cmake\" will be replaced.  Removing files [${OLD_CONFIG_FILES}].")
        file(REMOVE ${OLD_CONFIG_FILES})
      endif()
    endif()
  endif()
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/sdk/native/jni/abi-arm64-v8a" TYPE FILE FILES "C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/746526a878/_deps/opencv-build/CMakeFiles/Export/sdk/native/jni/abi-arm64-v8a/OpenCVModules.cmake")
  if("${CMAKE_INSTALL_CONFIG_NAME}" MATCHES "^([Rr][Ee][Ll][Ee][Aa][Ss][Ee])$")
    file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/sdk/native/jni/abi-arm64-v8a" TYPE FILE FILES "C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/746526a878/_deps/opencv-build/CMakeFiles/Export/sdk/native/jni/abi-arm64-v8a/OpenCVModules-release.cmake")
  endif()
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xdevx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/sdk/native/jni/abi-arm64-v8a" TYPE FILE FILES
    "C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/746526a878/unix-install/OpenCVConfig-version.cmake"
    "C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/746526a878/unix-install/abi-arm64-v8a/OpenCVConfig.cmake"
    )
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xdevx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/sdk/native/jni" TYPE FILE FILES
    "C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/746526a878/unix-install/OpenCVConfig-version.cmake"
    "C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/746526a878/unix-install/OpenCVConfig.cmake"
    )
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xlibsx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/." TYPE FILE PERMISSIONS OWNER_READ OWNER_WRITE GROUP_READ WORLD_READ FILES "C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/746526a878/_deps/opencv-src/LICENSE")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xlibsx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/." TYPE FILE PERMISSIONS OWNER_READ OWNER_WRITE GROUP_READ WORLD_READ FILES "C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/746526a878/_deps/opencv-src/platforms/android/README.android")
endif()

if("x${CMAKE_INSTALL_COMPONENT}x" STREQUAL "xdevx" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/sdk/etc" TYPE FILE FILES
    "C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/746526a878/_deps/opencv-src/platforms/scripts/valgrind.supp"
    "C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/746526a878/_deps/opencv-src/platforms/scripts/valgrind_3rdparty.supp"
    )
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for each subdirectory.
  include("C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/746526a878/_deps/opencv-build/3rdparty/cpufeatures/cmake_install.cmake")
  include("C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/746526a878/_deps/opencv-build/3rdparty/zlib/cmake_install.cmake")
  include("C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/746526a878/_deps/opencv-build/3rdparty/libjpeg-turbo/cmake_install.cmake")
  include("C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/746526a878/_deps/opencv-build/3rdparty/libtiff/cmake_install.cmake")
  include("C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/746526a878/_deps/opencv-build/3rdparty/libwebp/cmake_install.cmake")
  include("C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/746526a878/_deps/opencv-build/3rdparty/openjpeg/cmake_install.cmake")
  include("C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/746526a878/_deps/opencv-build/3rdparty/libpng/cmake_install.cmake")
  include("C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/746526a878/_deps/opencv-build/3rdparty/protobuf/cmake_install.cmake")
  include("C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/746526a878/_deps/opencv-build/3rdparty/quirc/cmake_install.cmake")
  include("C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/746526a878/_deps/opencv-build/hal/carotene/hal/cmake_install.cmake")
  include("C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/746526a878/_deps/opencv-build/include/cmake_install.cmake")
  include("C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/746526a878/_deps/opencv-build/modules/.firstpass/calib3d/cmake_install.cmake")
  include("C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/746526a878/_deps/opencv-build/modules/.firstpass/core/cmake_install.cmake")
  include("C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/746526a878/_deps/opencv-build/modules/.firstpass/dnn/cmake_install.cmake")
  include("C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/746526a878/_deps/opencv-build/modules/.firstpass/features2d/cmake_install.cmake")
  include("C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/746526a878/_deps/opencv-build/modules/.firstpass/flann/cmake_install.cmake")
  include("C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/746526a878/_deps/opencv-build/modules/.firstpass/gapi/cmake_install.cmake")
  include("C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/746526a878/_deps/opencv-build/modules/.firstpass/highgui/cmake_install.cmake")
  include("C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/746526a878/_deps/opencv-build/modules/.firstpass/imgcodecs/cmake_install.cmake")
  include("C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/746526a878/_deps/opencv-build/modules/.firstpass/imgproc/cmake_install.cmake")
  include("C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/746526a878/_deps/opencv-build/modules/.firstpass/java/cmake_install.cmake")
  include("C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/746526a878/_deps/opencv-build/modules/.firstpass/js/cmake_install.cmake")
  include("C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/746526a878/_deps/opencv-build/modules/.firstpass/ml/cmake_install.cmake")
  include("C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/746526a878/_deps/opencv-build/modules/.firstpass/objc/cmake_install.cmake")
  include("C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/746526a878/_deps/opencv-build/modules/.firstpass/objdetect/cmake_install.cmake")
  include("C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/746526a878/_deps/opencv-build/modules/.firstpass/photo/cmake_install.cmake")
  include("C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/746526a878/_deps/opencv-build/modules/.firstpass/python/cmake_install.cmake")
  include("C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/746526a878/_deps/opencv-build/modules/.firstpass/stitching/cmake_install.cmake")
  include("C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/746526a878/_deps/opencv-build/modules/.firstpass/ts/cmake_install.cmake")
  include("C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/746526a878/_deps/opencv-build/modules/.firstpass/video/cmake_install.cmake")
  include("C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/746526a878/_deps/opencv-build/modules/.firstpass/videoio/cmake_install.cmake")
  include("C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/746526a878/_deps/opencv-build/modules/.firstpass/world/cmake_install.cmake")
  include("C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/746526a878/_deps/opencv-build/modules/core/cmake_install.cmake")
  include("C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/746526a878/_deps/opencv-build/modules/imgproc/cmake_install.cmake")
  include("C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/746526a878/_deps/opencv-build/modules/imgcodecs/cmake_install.cmake")
  include("C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/746526a878/_deps/opencv-build/doc/cmake_install.cmake")
  include("C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/746526a878/_deps/opencv-build/data/cmake_install.cmake")

endif()

