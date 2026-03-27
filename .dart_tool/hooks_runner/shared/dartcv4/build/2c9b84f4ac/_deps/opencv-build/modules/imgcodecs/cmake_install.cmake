# Install script for directory: C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/2c9b84f4ac/_deps/opencv-src/modules/imgcodecs

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

if(CMAKE_INSTALL_COMPONENT STREQUAL "dev" OR NOT CMAKE_INSTALL_COMPONENT)
  if(CMAKE_INSTALL_CONFIG_NAME MATCHES "^([Dd][Ee][Bb][Uu][Gg])$")
    file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/x64/vc17/staticlib" TYPE STATIC_LIBRARY OPTIONAL FILES "C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/2c9b84f4ac/_deps/opencv-build/lib/Debug/opencv_imgcodecs4130d.lib")
  elseif(CMAKE_INSTALL_CONFIG_NAME MATCHES "^([Rr][Ee][Ll][Ee][Aa][Ss][Ee])$")
    file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/x64/vc17/staticlib" TYPE STATIC_LIBRARY OPTIONAL FILES "C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/2c9b84f4ac/_deps/opencv-build/lib/Release/opencv_imgcodecs4130.lib")
  elseif(CMAKE_INSTALL_CONFIG_NAME MATCHES "^([Mm][Ii][Nn][Ss][Ii][Zz][Ee][Rr][Ee][Ll])$")
    file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/x64/vc17/staticlib" TYPE STATIC_LIBRARY OPTIONAL FILES "C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/2c9b84f4ac/_deps/opencv-build/lib/MinSizeRel/opencv_imgcodecs4130.lib")
  elseif(CMAKE_INSTALL_CONFIG_NAME MATCHES "^([Rr][Ee][Ll][Ww][Ii][Tt][Hh][Dd][Ee][Bb][Ii][Nn][Ff][Oo])$")
    file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/x64/vc17/staticlib" TYPE STATIC_LIBRARY OPTIONAL FILES "C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/2c9b84f4ac/_deps/opencv-build/lib/RelWithDebInfo/opencv_imgcodecs4130.lib")
  endif()
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "dev" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/opencv2" TYPE FILE OPTIONAL FILES "C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/2c9b84f4ac/_deps/opencv-src/modules/imgcodecs/include/opencv2/imgcodecs.hpp")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "dev" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/opencv2/imgcodecs" TYPE FILE OPTIONAL FILES "C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/2c9b84f4ac/_deps/opencv-src/modules/imgcodecs/include/opencv2/imgcodecs/imgcodecs.hpp")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "dev" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/opencv2/imgcodecs" TYPE FILE OPTIONAL FILES "C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/2c9b84f4ac/_deps/opencv-src/modules/imgcodecs/include/opencv2/imgcodecs/imgcodecs_c.h")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "dev" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/opencv2/imgcodecs" TYPE FILE OPTIONAL FILES "C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/2c9b84f4ac/_deps/opencv-src/modules/imgcodecs/include/opencv2/imgcodecs/ios.h")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "dev" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/opencv2/imgcodecs/legacy" TYPE FILE OPTIONAL FILES "C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/2c9b84f4ac/_deps/opencv-src/modules/imgcodecs/include/opencv2/imgcodecs/legacy/constants_c.h")
endif()

if(CMAKE_INSTALL_COMPONENT STREQUAL "dev" OR NOT CMAKE_INSTALL_COMPONENT)
  file(INSTALL DESTINATION "${CMAKE_INSTALL_PREFIX}/include/opencv2/imgcodecs" TYPE FILE OPTIONAL FILES "C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/2c9b84f4ac/_deps/opencv-src/modules/imgcodecs/include/opencv2/imgcodecs/macosx.h")
endif()

string(REPLACE ";" "\n" CMAKE_INSTALL_MANIFEST_CONTENT
       "${CMAKE_INSTALL_MANIFEST_FILES}")
if(CMAKE_INSTALL_LOCAL_ONLY)
  file(WRITE "C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/2c9b84f4ac/_deps/opencv-build/modules/imgcodecs/install_local_manifest.txt"
     "${CMAKE_INSTALL_MANIFEST_CONTENT}")
endif()
