# Install script for directory: C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/2c9b84f4ac/_deps/opencv-src

# Set the install prefix
if(NOT DEFINED CMAKE_INSTALL_PREFIX)
  set(CMAKE_INSTALL_PREFIX "C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/2c9b84f4ac/install")
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

# Is this installation the result of a crosscompile?
if(NOT DEFINED CMAKE_CROSSCOMPILING)
  set(CMAKE_CROSSCOMPILING "TRUE")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "licenses" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/etc/licenses" TYPE FILE RENAME "dlpack-LICENSE" FILES "C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/2c9b84f4ac/_deps/opencv-src/3rdparty/dlpack/LICENSE")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "licenses" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/etc/licenses" TYPE FILE RENAME "flatbuffers-LICENSE.txt" FILES "C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/2c9b84f4ac/_deps/opencv-src/3rdparty/flatbuffers/LICENSE.txt")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "licenses" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/etc/licenses" TYPE FILE RENAME "opencl-headers-LICENSE.txt" FILES "C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/2c9b84f4ac/_deps/opencv-src/3rdparty/include/opencl/LICENSE.txt")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "dev" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/opencv2" TYPE FILE FILES "C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/2c9b84f4ac/cvconfig.h")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "dev" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/opencv2" TYPE FILE FILES "C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/2c9b84f4ac/opencv2/opencv_modules.hpp")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "dev" OR NOT CMAKE_INSTALL_COMPONENT)
  if(EXISTS "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/x64/vc17/staticlib/OpenCVModules.cmake")
    file(DIFFERENT _cmake_export_file_changed FILES
         "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/x64/vc17/staticlib/OpenCVModules.cmake"
         "C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/2c9b84f4ac/_deps/opencv-build/CMakeFiles/Export/3a6169c0a7a93ceefd7e7be6be08fcaf/OpenCVModules.cmake")
    if(_cmake_export_file_changed)
      file(GLOB _cmake_old_config_files "$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/x64/vc17/staticlib/OpenCVModules-*.cmake")
      if(_cmake_old_config_files)
        string(REPLACE ";" ", " _cmake_old_config_files_text "${_cmake_old_config_files}")
        message(STATUS "Old export file \"$ENV{DESTDIR}${CMAKE_INSTALL_PREFIX}/x64/vc17/staticlib/OpenCVModules.cmake\" will be replaced.  Removing files [${_cmake_old_config_files_text}].")
        unset(_cmake_old_config_files_text)
        file(REMOVE ${_cmake_old_config_files})
      endif()
      unset(_cmake_old_config_files)
    endif()
    unset(_cmake_export_file_changed)
  endif()
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/x64/vc17/staticlib" TYPE FILE FILES "C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/2c9b84f4ac/_deps/opencv-build/CMakeFiles/Export/3a6169c0a7a93ceefd7e7be6be08fcaf/OpenCVModules.cmake")
  if(CMAKE_INSTALL_CONFIG_NAME MATCHES "^([Dd][Ee][Bb][Uu][Gg])$")
    file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/x64/vc17/staticlib" TYPE FILE FILES "C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/2c9b84f4ac/_deps/opencv-build/CMakeFiles/Export/3a6169c0a7a93ceefd7e7be6be08fcaf/OpenCVModules-debug.cmake")
  endif()
  if(CMAKE_INSTALL_CONFIG_NAME MATCHES "^([Mm][Ii][Nn][Ss][Ii][Zz][Ee][Rr][Ee][Ll])$")
    file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/x64/vc17/staticlib" TYPE FILE FILES "C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/2c9b84f4ac/_deps/opencv-build/CMakeFiles/Export/3a6169c0a7a93ceefd7e7be6be08fcaf/OpenCVModules-minsizerel.cmake")
  endif()
  if(CMAKE_INSTALL_CONFIG_NAME MATCHES "^([Rr][Ee][Ll][Ww][Ii][Tt][Hh][Dd][Ee][Bb][Ii][Nn][Ff][Oo])$")
    file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/x64/vc17/staticlib" TYPE FILE FILES "C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/2c9b84f4ac/_deps/opencv-build/CMakeFiles/Export/3a6169c0a7a93ceefd7e7be6be08fcaf/OpenCVModules-relwithdebinfo.cmake")
  endif()
  if(CMAKE_INSTALL_CONFIG_NAME MATCHES "^([Rr][Ee][Ll][Ee][Aa][Ss][Ee])$")
    file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/x64/vc17/staticlib" TYPE FILE FILES "C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/2c9b84f4ac/_deps/opencv-build/CMakeFiles/Export/3a6169c0a7a93ceefd7e7be6be08fcaf/OpenCVModules-release.cmake")
  endif()
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "dev" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/x64/vc17/staticlib" TYPE FILE FILES
    "C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/2c9b84f4ac/win-install/OpenCVConfig-version.cmake"
    "C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/2c9b84f4ac/win-install/x64/vc17/staticlib/OpenCVConfig.cmake"
    )
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "dev" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/." TYPE FILE FILES
    "C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/2c9b84f4ac/win-install/OpenCVConfig-version.cmake"
    "C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/2c9b84f4ac/win-install/OpenCVConfig.cmake"
    )
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "libs" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/." TYPE FILE PERMISSIONS OWNER_READ OWNER_WRITE GROUP_READ WORLD_READ FILES "C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/2c9b84f4ac/_deps/opencv-src/LICENSE")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "scripts" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/." TYPE FILE PERMISSIONS OWNER_READ OWNER_WRITE OWNER_EXECUTE GROUP_READ GROUP_EXECUTE WORLD_READ WORLD_EXECUTE FILES "C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/2c9b84f4ac/CMakeFiles/install/setup_vars_opencv4.cmd")
endif()

if(NOT CMAKE_INSTALL_LOCAL_ONLY)
  # Include the install script for each subdirectory.
  include("C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/2c9b84f4ac/_deps/opencv-build/3rdparty/zlib/cmake_install.cmake")
  include("C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/2c9b84f4ac/_deps/opencv-build/3rdparty/libjpeg-turbo/cmake_install.cmake")
  include("C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/2c9b84f4ac/_deps/opencv-build/3rdparty/libtiff/cmake_install.cmake")
  include("C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/2c9b84f4ac/_deps/opencv-build/3rdparty/libwebp/cmake_install.cmake")
  include("C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/2c9b84f4ac/_deps/opencv-build/3rdparty/openjpeg/cmake_install.cmake")
  include("C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/2c9b84f4ac/_deps/opencv-build/3rdparty/libpng/cmake_install.cmake")
  include("C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/2c9b84f4ac/_deps/opencv-build/3rdparty/protobuf/cmake_install.cmake")
  include("C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/2c9b84f4ac/_deps/opencv-build/3rdparty/quirc/cmake_install.cmake")
  include("C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/2c9b84f4ac/_deps/opencv-build/include/cmake_install.cmake")
  include("C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/2c9b84f4ac/_deps/opencv-build/modules/.firstpass/calib3d/cmake_install.cmake")
  include("C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/2c9b84f4ac/_deps/opencv-build/modules/.firstpass/core/cmake_install.cmake")
  include("C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/2c9b84f4ac/_deps/opencv-build/modules/.firstpass/dnn/cmake_install.cmake")
  include("C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/2c9b84f4ac/_deps/opencv-build/modules/.firstpass/features2d/cmake_install.cmake")
  include("C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/2c9b84f4ac/_deps/opencv-build/modules/.firstpass/flann/cmake_install.cmake")
  include("C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/2c9b84f4ac/_deps/opencv-build/modules/.firstpass/gapi/cmake_install.cmake")
  include("C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/2c9b84f4ac/_deps/opencv-build/modules/.firstpass/highgui/cmake_install.cmake")
  include("C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/2c9b84f4ac/_deps/opencv-build/modules/.firstpass/imgcodecs/cmake_install.cmake")
  include("C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/2c9b84f4ac/_deps/opencv-build/modules/.firstpass/imgproc/cmake_install.cmake")
  include("C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/2c9b84f4ac/_deps/opencv-build/modules/.firstpass/java/cmake_install.cmake")
  include("C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/2c9b84f4ac/_deps/opencv-build/modules/.firstpass/js/cmake_install.cmake")
  include("C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/2c9b84f4ac/_deps/opencv-build/modules/.firstpass/ml/cmake_install.cmake")
  include("C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/2c9b84f4ac/_deps/opencv-build/modules/.firstpass/objc/cmake_install.cmake")
  include("C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/2c9b84f4ac/_deps/opencv-build/modules/.firstpass/objdetect/cmake_install.cmake")
  include("C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/2c9b84f4ac/_deps/opencv-build/modules/.firstpass/photo/cmake_install.cmake")
  include("C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/2c9b84f4ac/_deps/opencv-build/modules/.firstpass/python/cmake_install.cmake")
  include("C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/2c9b84f4ac/_deps/opencv-build/modules/.firstpass/stitching/cmake_install.cmake")
  include("C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/2c9b84f4ac/_deps/opencv-build/modules/.firstpass/ts/cmake_install.cmake")
  include("C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/2c9b84f4ac/_deps/opencv-build/modules/.firstpass/video/cmake_install.cmake")
  include("C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/2c9b84f4ac/_deps/opencv-build/modules/.firstpass/videoio/cmake_install.cmake")
  include("C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/2c9b84f4ac/_deps/opencv-build/modules/.firstpass/world/cmake_install.cmake")
  include("C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/2c9b84f4ac/_deps/opencv-build/modules/core/cmake_install.cmake")
  include("C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/2c9b84f4ac/_deps/opencv-build/modules/imgproc/cmake_install.cmake")
  include("C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/2c9b84f4ac/_deps/opencv-build/modules/imgcodecs/cmake_install.cmake")
  include("C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/2c9b84f4ac/_deps/opencv-build/doc/cmake_install.cmake")
  include("C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/2c9b84f4ac/_deps/opencv-build/data/cmake_install.cmake")

endif()

string(REPLACE ";" "\n" CMAKE_INSTALL_MANIFEST_CONTENT
       "${CMAKE_INSTALL_MANIFEST_FILES}")
if(CMAKE_INSTALL_LOCAL_ONLY)
  file(WRITE "C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/2c9b84f4ac/_deps/opencv-build/install_local_manifest.txt"
     "${CMAKE_INSTALL_MANIFEST_CONTENT}")
endif()
