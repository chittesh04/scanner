# -----------------------------------------------
# File that provides "make uninstall" target
#  We use the file 'install_manifest.txt'
#
# Details: https://gitlab.kitware.com/cmake/community/-/wikis/FAQ#can-i-do-make-uninstall-with-cmake
# -----------------------------------------------

if(NOT EXISTS "C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/746526a878/install_manifest.txt")
  message(FATAL_ERROR "Cannot find install manifest: \"C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/746526a878/install_manifest.txt\"")
endif()

file(READ "C:/Users/chitt/Desktop/project/SmartScan/.dart_tool/hooks_runner/shared/dartcv4/build/746526a878/install_manifest.txt" files)
string(REGEX REPLACE "\n" ";" files "${files}")
foreach(file ${files})
  message(STATUS "Uninstalling $ENV{DESTDIR}${file}")
  if(IS_SYMLINK "$ENV{DESTDIR}${file}" OR EXISTS "$ENV{DESTDIR}${file}")
    exec_program(
        "C:/Users/chitt/AppData/Local/Android/Sdk/cmake/3.22.1/bin/cmake.exe" ARGS "-E remove \"$ENV{DESTDIR}${file}\""
        OUTPUT_VARIABLE rm_out
        RETURN_VALUE rm_retval
    )
    if(NOT "${rm_retval}" STREQUAL 0)
      message(FATAL_ERROR "Problem when removing $ENV{DESTDIR}${file}")
    endif()
  else(IS_SYMLINK "$ENV{DESTDIR}${file}" OR EXISTS "$ENV{DESTDIR}${file}")
    message(STATUS "File $ENV{DESTDIR}${file} does not exist.")
  endif()
endforeach()
