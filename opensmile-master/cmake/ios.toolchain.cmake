# This file is part of the ios-cmake project. It was retrieved from
# https://github.com/gerstrong/ios-cmake.git which is a fork of
# https://github.com/cristeab/ios-cmake.git, which again is a fork of
# https://code.google.com/p/ios-cmake/. Which in turn is based off of
# the Platform/Darwin.cmake and Platform/UnixPaths.cmake files which
# are included with CMake 2.8.4
#
# The ios-cmake project is licensed under the new BSD license.
#
# Copyright (c) 2014, Bogdan Cristea and LTE Engineering Software,
# Kitware, Inc., Insight Software Consortium.  All rights reserved.
# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions
# are met:
# 1. Redistributions of source code must retain the above copyright
# notice, this list of conditions and the following disclaimer.
#
# 2. Redistributions in binary form must reproduce the above copyright
# notice, this list of conditions and the following disclaimer in the
# documentation and/or other materials provided with the distribution.
#
# 3. Neither the name of the copyright holder nor the names of its
# contributors may be used to endorse or promote products derived from
# this software without specific prior written permission.
#
# THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
# "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
# LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
# FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE
# COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT,
# INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING,
# BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
# LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
# CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
# LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN
# ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
# POSSIBILITY OF SUCH DAMAGE.
#
# This file is based off of the Platform/Darwin.cmake and
# Platform/UnixPaths.cmake files which are included with CMake 2.8.4
# It has been altered for iOS development.
#
# Updated by Alex Stewart (alexs.mac@gmail.com)
#
# *****************************************************************************
#      Now maintained by Alexander Widerberg (widerbergaren [at] gmail.com)
#                      under the BSD-3-Clause license
#                   https://github.com/leetal/ios-cmake
# *****************************************************************************
#
#                           INFORMATION / HELP
#
# The following options control the behaviour of this toolchain:
#
# PLATFORM: (default "OS64")
#    OS = Build for iPhoneOS.
#    OS64 = Build for arm64 iphoneOS.
#    OS64COMBINED = Build for arm64 x86_64 iphoneOS. Combined into FAT STATIC lib (supported on 3.14+ of CMakewith "-G Xcode" argument ONLY)
#    SIMULATOR = Build for x86 i386 iphoneOS Simulator.
#    SIMULATOR64 = Build for x86_64 iphoneOS Simulator.
#    SIMULATORARM64 = Build for arm64 iphoneOS Simulator.
#    TVOS = Build for arm64 tvOS.
#    TVOSCOMBINED = Build for arm64 x86_64 tvOS. Combined into FAT STATIC lib (supported on 3.14+ of CMake with "-G Xcode" argument ONLY)
#    SIMULATOR_TVOS = Build for x86_64 tvOS Simulator.
#    WATCHOS = Build for armv7k arm64_32 for watchOS.
#    WATCHOSCOMBINED = Build for armv7k arm64_32 x86_64 watchOS. Combined into FAT STATIC lib (supported on 3.14+ of CMake with "-G Xcode" argument ONLY)
#    SIMULATOR_WATCHOS = Build for x86_64 for watchOS Simulator.
#    MAC = Build for x86_64 macOS.
#    MAC_ARM64 = Build for Apple Silicon macOS.
#    MAC_CATALYST = Build for x86_64 macOS with Catalyst support (iOS toolchain on macOS).
#                   Note: The build argument "MACOSX_DEPLOYMENT_TARGET" can be used to control min-version of macOS
#    MAC_CATALYST_ARM64 = Build for Apple Silicon macOS with Catalyst support (iOS toolchain on macOS).
#                         Note: The build argument "MACOSX_DEPLOYMENT_TARGET" can be used to control min-version of macOS
#
# CMAKE_OSX_SYSROOT: Path to the SDK to use.  By default this is
#    automatically determined from PLATFORM and xcodebuild, but
#    can also be manually specified (although this should not be required).
#
# CMAKE_DEVELOPER_ROOT: Path to the Developer directory for the platform
#    being compiled for.  By default this is automatically determined from
#    CMAKE_OSX_SYSROOT, but can also be manually specified (although this should
#    not be required).
#
# DEPLOYMENT_TARGET: Minimum SDK version to target. Default 2.0 on watchOS and 9.0 on tvOS+iOS
#
# ENABLE_BITCODE: (1|0) Enables or disables bitcode support. Default 1 (true)
#
# ENABLE_ARC: (1|0) Enables or disables ARC support. Default 1 (true, ARC enabled by default)
#
# ENABLE_VISIBILITY: (1|0) Enables or disables symbol visibility support. Default 0 (false, visibility hidden by default)
#
# ENABLE_STRICT_TRY_COMPILE: (1|0) Enables or disables strict try_compile() on all Check* directives (will run linker
#    to actually check if linking is possible). Default 0 (false, will set CMAKE_TRY_COMPILE_TARGET_TYPE to STATIC_LIBRARY)
#
# ARCHS: (armv7 armv7s armv7k arm64 arm64_32 i386 x86_64) If specified, will override the default architectures for the given PLATFORM
#    OS = armv7 armv7s arm64 (if applicable)
#    OS64 = arm64 (if applicable)
#    SIMULATOR = i386
#    SIMULATOR64 = x86_64
#    SIMULATORARM64 = arm64
#    TVOS = arm64
#    SIMULATOR_TVOS = x86_64 (i386 has since long been deprecated)
#    WATCHOS = armv7k arm64_32 (if applicable)
#    SIMULATOR_WATCHOS = x86_64 (i386 has since long been deprecated)
#    MAC = x86_64
#    MAC_ARM64 = arm64
#    MAC_CATALYST = x86_64
#    MAC_CATALYST_ARM64 = arm64
#
# This toolchain defines the following variables for use externally:
#
# XCODE_VERSION: Version number (not including Build version) of Xcode detected.
# SDK_VERSION: Version of SDK being used.
# CMAKE_OSX_ARCHITECTURES: Architectures being compiled for (generated from PLATFORM).
# APPLE_TARGET_TRIPLE: Used by autoconf build systems. NOTE: If "ARCHS" are overridden, this will *NOT* be set!
#
# This toolchain defines the following macros for use externally:
#
# set_xcode_property (TARGET XCODE_PROPERTY XCODE_VALUE XCODE_VARIANT)
#   A convenience macro for setting xcode specific properties on targets.
#   Available variants are: All, Release, RelWithDebInfo, Debug, MinSizeRel
#   example: set_xcode_property (myioslib IPHONEOS_DEPLOYMENT_TARGET "3.1" "all").
#
# find_host_package (PROGRAM ARGS)
#   A macro used to find executable programs on the host system, not within the
#   environment. Thanks to the android-cmake project for providing the
#   command.
#

cmake_minimum_required(VERSION 3.8.0)

# CMake invokes the toolchain file twice during the first build, but only once during subsequent rebuilds.
if(IOS_TOOLCHAIN_HAS_RUN)
  return()
endif(IOS_TOOLCHAIN_HAS_RUN)
set(IOS_TOOLCHAIN_HAS_RUN true)

###############################################################################
#                                  OPTIONS                                    #
###############################################################################

option(DROP_32_BIT "Drops the 32-bit targets universally." YES)

###############################################################################
#                                END OPTIONS                                  #
###############################################################################

# Fix for PThread library not in path
set(CMAKE_THREAD_LIBS_INIT "-lpthread")
set(CMAKE_HAVE_THREADS_LIBRARY 1)
set(CMAKE_USE_WIN32_THREADS_INIT 0)
set(CMAKE_USE_PTHREADS_INIT 1)

# List of supported platform values
list(APPEND _supported_platforms
    "OS" "OS64" "OS64COMBINED" "SIMULATOR" "SIMULATOR64" "SIMULATORARM64"
    "TVOS" "TVOSCOMBINED" "SIMULATOR_TVOS"
    "WATCHOS" "WATCHOSCOMBINED" "SIMULATOR_WATCHOS"
    "MAC" "MAC_ARM64"
    "MAC_CATALYST" "MAC_CATALYST_ARM64")

# Cache what generator is used
set(USED_CMAKE_GENERATOR "${CMAKE_GENERATOR}" CACHE STRING "Expose CMAKE_GENERATOR" ${FORCE_CACHE})

# Check if using a CMake version capable of building combined FAT builds (simulator and target slices combined in one static lib)
if(${CMAKE_VERSION} VERSION_GREATER_EQUAL "3.14")
  set(MODERN_CMAKE YES)
endif()

# Get the Xcode version being used.
if(NOT DEFINED XCODE_VERSION)
  execute_process(COMMAND xcodebuild -version
    OUTPUT_VARIABLE XCODE_VERSION
    ERROR_QUIET
    OUTPUT_STRIP_TRAILING_WHITESPACE)
  string(REGEX MATCH "Xcode [0-9\\.]+" XCODE_VERSION "${XCODE_VERSION}")
  string(REGEX REPLACE "Xcode ([0-9\\.]+)" "\\1" XCODE_VERSION "${XCODE_VERSION}")
  set(XCODE_VERSION "${XCODE_VERSION}" CACHE STRING "" ${FORCE_CACHE})
endif()

# Assuming that xcode 12.0 is installed you most probably have ios sdk 14.2 or later installed (tested on Big Sur)
# if you don't set a deployment target it will be set the way you only get 64-bit builds
if(NOT DEFINED DEPLOYMENT_TARGET AND XCODE_VERSION VERSION_GREATER 12.0)
  # Temporarily fix the arm64 issues in CMake install-combined by excluding arm64 for simulator builds (needed for Apple Silicon...)
  set(CMAKE_XCODE_ATTRIBUTE_EXCLUDED_ARCHS[sdk=iphonesimulator*] "arm64")
endif()

# Unset the FORCE on cache variables if in try_compile()
set(FORCE_CACHE FORCE)
get_property(_CMAKE_IN_TRY_COMPILE GLOBAL PROPERTY IN_TRY_COMPILE)
if(_CMAKE_IN_TRY_COMPILE)
  unset(FORCE_CACHE)
endif()

if(NOT DEFINED PLATFORM)
  message(FATAL_ERROR "PLATFORM argument not set. Bailing configure since I don't know what target you want to build for!")
endif ()

# Safeguard that the platform value is set and is one of the supported values
list(FIND _supported_platforms ${PLATFORM} contains_PLATFORM)
if("${contains_PLATFORM}" EQUAL "-1")
  string(REPLACE ";"  "\n * " _supported_platforms_formatted "${_supported_platforms}")
  message(FATAL_ERROR " Invalid PLATFORM specified! Current value: ${PLATFORM}.\n"
      " Supported PLATFORM values: \n * ${_supported_platforms_formatted}")
endif()

# Check if Apple Silicon is supported
if(PLATFORM MATCHES "^(MAC_ARM64)$|^(MAC_CATALYST_ARM64)$" AND ${CMAKE_VERSION} VERSION_LESS "3.19.5")
  message(FATAL_ERROR "Apple Silicon builds requires a minimum of CMake 3.19.5")
endif()

# Specify minimum version of deployment target.
if(NOT DEFINED DEPLOYMENT_TARGET)
  if (PLATFORM STREQUAL "WATCHOS" OR PLATFORM STREQUAL "SIMULATOR_WATCHOS")
    # Unless specified, SDK version 4.0 is used by default as minimum target version (watchOS).
    set(DEPLOYMENT_TARGET "4.0" CACHE STRING "Minimum SDK version to build for.")
  elseif(PLATFORM MATCHES "MAC")
    # Unless specified, SDK version 10.13 (High sierra) is used by default as minimum target version (macos).
    set(DEPLOYMENT_TARGET "10.13" CACHE STRING "Minimum SDK version to build for.")
  elseif(PLATFORM STREQUAL "MAC_ARM64")
    # Unless specified, SDK version 11.0 (Big Sur) is used by default as minimum target version (macos on arm).
    set(DEPLOYMENT_TARGET "11.0" CACHE STRING "Minimum SDK version to build for.")
  elseif(PLATFORM MATCHES "(MAC_CATALYST|MAC_CATALYST_ARM64)")
    # Unless specified, SDK version 13.0 is used by default as minimum target version (mac catalyst minimum requirement).
    set(DEPLOYMENT_TARGET "13.0" CACHE STRING "Minimum SDK version to build for.")
  else()
    # Unless specified, SDK version 11.0 is used by default as minimum target version (iOS, tvOS).
    set(DEPLOYMENT_TARGET "11.0" CACHE STRING "Minimum SDK version to build for.")
  endif()
  message(STATUS "[DEFAULTS] Using the default min-version since DEPLOYMENT_TARGET not provided!")
elseif(DEFINED DEPLOYMENT_TARGET AND PLATFORM STREQUAL "MAC_CATALYST" AND ${DEPLOYMENT_TARGET} VERSION_LESS "13.0")
  message(FATAL_ERROR "Mac Catalyst builds requires a minimum deployment target of 13.0!")
endif()

# Handle the case where we are targeting iOS and a version above 10.3.4 (32-bit support dropped officially)
if(PLATFORM STREQUAL "OS" AND DEPLOYMENT_TARGET VERSION_GREATER_EQUAL 10.3.4)
  set(PLATFORM "OS64")
  message(STATUS "Targeting minimum SDK version ${DEPLOYMENT_TARGET}. Dropping 32-bit support.")
elseif(PLATFORM STREQUAL "SIMULATOR" AND DEPLOYMENT_TARGET VERSION_GREATER_EQUAL 10.3.4)
  set(PLATFORM "SIMULATOR64")
  message(STATUS "Targeting minimum SDK version ${DEPLOYMENT_TARGET}. Dropping 32-bit support.")
endif()

set(PLATFORM_INT "${PLATFORM}" CACHE STRING "Type of platform for which the build targets.")

# Determine the platform name and architectures for use in xcodebuild commands
# from the specified PLATFORM_INT name.
if(PLATFORM_INT STREQUAL "OS")
  set(SDK_NAME iphoneos)
  if(NOT ARCHS)
    set(ARCHS armv7 armv7s arm64)
    set(APPLE_TARGET_TRIPLE_INT arm-apple-ios)
  endif()
elseif(PLATFORM_INT STREQUAL "OS64")
  set(SDK_NAME iphoneos)
  if(NOT ARCHS)
    if (XCODE_VERSION VERSION_GREATER 10.0)
      set(ARCHS arm64) # Add arm64e when Apple have fixed the integration issues with it, libarclite_iphoneos.a is currently missung bitcode markers for example
    else()
      set(ARCHS arm64)
    endif()
    set(APPLE_TARGET_TRIPLE_INT aarch64-apple-ios)
  endif()
elseif(PLATFORM_INT STREQUAL "OS64COMBINED")
  set(SDK_NAME iphoneos)
  if(MODERN_CMAKE)
    if(NOT ARCHS)
      if (XCODE_VERSION VERSION_GREATER 10.0)
        set(ARCHS arm64 x86_64) # Add arm64e when Apple have fixed the integration issues with it, libarclite_iphoneos.a is currently missung bitcode markers for example
      else()
        set(ARCHS arm64 x86_64)
      endif()
      set(APPLE_TARGET_TRIPLE_INT aarch64-x86_64-apple-ios)
    endif()
  else()
    message(FATAL_ERROR "Please make sure that you are running CMake 3.14+ to make the OS64COMBINED setting work")
  endif()
elseif(PLATFORM_INT STREQUAL "SIMULATOR")
  set(SDK_NAME iphonesimulator)
  if(NOT ARCHS)
    set(ARCHS i386)
    set(APPLE_TARGET_TRIPLE_INT i386-apple-ios)
  endif()
  message(DEPRECATION "SIMULATOR IS DEPRECATED. Consider using SIMULATOR64 instead.")
elseif(PLATFORM_INT STREQUAL "SIMULATOR64")
  set(SDK_NAME iphonesimulator)
  if(NOT ARCHS)
    set(ARCHS x86_64)
    set(APPLE_TARGET_TRIPLE_INT x86_64-apple-ios)
  endif()
elseif(PLATFORM_INT STREQUAL "SIMULATORARM64")
  set(SDK_NAME iphonesimulator)
  if(NOT ARCHS)
    set(ARCHS arm64)
    set(APPLE_TARGET_TRIPLE_INT aarch64-apple-ios)
  endif()
elseif(PLATFORM_INT STREQUAL "TVOS")
  set(SDK_NAME appletvos)
  if(NOT ARCHS)
    set(ARCHS arm64)
    set(APPLE_TARGET_TRIPLE_INT aarch64-apple-tvos)
  endif()
elseif (PLATFORM_INT STREQUAL "TVOSCOMBINED")
  set(SDK_NAME appletvos)
  if(MODERN_CMAKE)
    if(NOT ARCHS)
      set(ARCHS arm64 x86_64)
      set(APPLE_TARGET_TRIPLE_INT aarch64-x86_64-apple-tvos)
    endif()
  else()
    message(FATAL_ERROR "Please make sure that you are running CMake 3.14+ to make the TVOSCOMBINED setting work")
  endif()
elseif(PLATFORM_INT STREQUAL "SIMULATOR_TVOS")
  set(SDK_NAME appletvsimulator)
  if(NOT ARCHS)
    set(ARCHS x86_64)
    set(APPLE_TARGET_TRIPLE_INT x86_64-apple-tvos)
  endif()
elseif(PLATFORM_INT STREQUAL "WATCHOS")
  set(SDK_NAME watchos)
  if(NOT ARCHS)
    if (XCODE_VERSION VERSION_GREATER 10.0)
      set(ARCHS armv7k arm64_32)
      set(APPLE_TARGET_TRIPLE_INT aarch64_32-apple-watchos)
    else()
      set(ARCHS armv7k)
      set(APPLE_TARGET_TRIPLE_INT arm-apple-watchos)
    endif()
  endif()
elseif(PLATFORM_INT STREQUAL "WATCHOSCOMBINED")
  set(SDK_NAME watchos)
  if(MODERN_CMAKE)
    if(NOT ARCHS)
      if (XCODE_VERSION VERSION_GREATER 10.0)
        set(ARCHS armv7k arm64_32 i386)
        set(APPLE_TARGET_TRIPLE_INT aarch64_32-i386-apple-watchos)
      else()
        set(ARCHS armv7k i386)
        set(APPLE_TARGET_TRIPLE_INT arm-i386-apple-watchos)
      endif()
    endif()
  else()
    message(FATAL_ERROR "Please make sure that you are running CMake 3.14+ to make the WATCHOSCOMBINED setting work")
  endif()
elseif(PLATFORM_INT STREQUAL "SIMULATOR_WATCHOS")
  set(SDK_NAME watchsimulator)
  if(NOT ARCHS)
    set(ARCHS i386)
    set(APPLE_TARGET_TRIPLE_INT i386-apple-watchos)
  endif()
elseif(PLATFORM_INT MATCHES "^(MAC)$|^(MAC_CATALYST)$")
  set(SDK_NAME macosx)
  if(NOT ARCHS)
    set(ARCHS x86_64)
  endif()
  if(PLATFORM_INT STREQUAL "MAC")
    set(APPLE_TARGET_TRIPLE_INT x86_64-apple-macosx)
  elseif(PLATFORM_INT STREQUAL "MAC_CATALYST")
    set(APPLE_TARGET_TRIPLE_INT x86_64-apple-ios${DEPLOYMENT_TARGET}-macabi)
  endif()
elseif(PLATFORM_INT MATCHES "^(MAC_ARM64)$|^(MAC_CATALYST_ARM64)$")
  set(SDK_NAME macosx)
  if(NOT ARCHS)
    set(ARCHS arm64)
  endif()
  if(PLATFORM_INT STREQUAL "MAC_ARM64")
    set(APPLE_TARGET_TRIPLE_INT arm64-apple-macosx)
  elseif(PLATFORM_INT STREQUAL "MAC_CATALYST_ARM64")
    set(APPLE_TARGET_TRIPLE_INT arm64-apple-ios${DEPLOYMENT_TARGET}-macabi)
  endif()
else()
  message(FATAL_ERROR "Invalid PLATFORM: ${PLATFORM_INT}")
endif()

if(MODERN_CMAKE AND PLATFORM_INT MATCHES ".*COMBINED" AND NOT CMAKE_GENERATOR MATCHES "Xcode")
  message(FATAL_ERROR "The COMBINED options only work with Xcode generator, -G Xcode")
endif()

if(CMAKE_GENERATOR MATCHES "Xcode" AND PLATFORM_INT MATCHES "MAC_CATALYST_.*")
  set(CMAKE_XCODE_ATTRIBUTE_CLANG_CXX_LIBRARY "libc++")
  set(CMAKE_XCODE_ATTRIBUTE_SUPPORTED_PLATFORMS "macosx")
  set(CMAKE_XCODE_EFFECTIVE_PLATFORMS "-maccatalyst")
  if(NOT DEFINED MACOSX_DEPLOYMENT_TARGET)
    set(CMAKE_XCODE_ATTRIBUTE_MACOSX_DEPLOYMENT_TARGET "10.15")
  else()
    set(CMAKE_XCODE_ATTRIBUTE_MACOSX_DEPLOYMENT_TARGET "${MACOSX_DEPLOYMENT_TARGET}")
  endif()
endif()

# If user did not specify the SDK root to use, then query xcodebuild for it.
if(NOT DEFINED CMAKE_OSX_SYSROOT_INT)
  execute_process(COMMAND xcodebuild -version -sdk ${SDK_NAME} Path
      OUTPUT_VARIABLE CMAKE_OSX_SYSROOT_INT
      ERROR_QUIET
      OUTPUT_STRIP_TRAILING_WHITESPACE)
endif()

if (NOT DEFINED CMAKE_OSX_SYSROOT_INT AND NOT DEFINED CMAKE_OSX_SYSROOT)
  message(SEND_ERROR "Please make sure that Xcode is installed and that the toolchain"
  "is pointing to the correct path. Please run:"
  "sudo xcode-select -s /Applications/Xcode.app/Contents/Developer"
  "and see if that fixes the problem for you.")
  message(FATAL_ERROR "Invalid CMAKE_OSX_SYSROOT: ${CMAKE_OSX_SYSROOT} "
  "does not exist.")
elseif(DEFINED CMAKE_OSX_SYSROOT_INT)
  set(CMAKE_OSX_SYSROOT_INT "${CMAKE_OSX_SYSROOT_INT}" CACHE INTERNAL "" ${FORCE_CACHE})
  set(CMAKE_OSX_SYSROOT "${CMAKE_OSX_SYSROOT_INT}" CACHE INTERNAL "" ${FORCE_CACHE})
endif()

# Set Xcode property for SDKROOT as well if Xcode generator is used
#if(CMAKE_GENERATOR MATCHES "Xcode")
#  set(CMAKE_OSX_SYSROOT "${SDK_NAME}" CACHE INTERNAL "")
#endif()

# Use bitcode or not
if(NOT DEFINED ENABLE_BITCODE AND NOT ARCHS MATCHES "((^|;|, )(i386|x86_64))+")
  # Unless specified, enable bitcode support by default
  message(STATUS "[DEFAULTS] Enabling bitcode support by default. ENABLE_BITCODE not provided!")
  set(ENABLE_BITCODE TRUE)
elseif(NOT DEFINED ENABLE_BITCODE)
  message(STATUS "[DEFAULTS] Disabling bitcode support by default on simulators. ENABLE_BITCODE not provided for override!")
  set(ENABLE_BITCODE FALSE)
endif()
set(ENABLE_BITCODE_INT ${ENABLE_BITCODE} CACHE BOOL
    "Whether or not to enable bitcode" ${FORCE_CACHE})
# Use ARC or not
if(NOT DEFINED ENABLE_ARC)
  # Unless specified, enable ARC support by default
  set(ENABLE_ARC TRUE)
  message(STATUS "[DEFAULTS] Enabling ARC support by default. ENABLE_ARC not provided!")
endif()
set(ENABLE_ARC_INT ${ENABLE_ARC} CACHE BOOL "Whether or not to enable ARC" ${FORCE_CACHE})
# Use hidden visibility or not
if(NOT DEFINED ENABLE_VISIBILITY)
  # Unless specified, disable symbols visibility by default
  set(ENABLE_VISIBILITY FALSE)
  message(STATUS "[DEFAULTS] Hiding symbols visibility by default. ENABLE_VISIBILITY not provided!")
endif()
set(ENABLE_VISIBILITY_INT ${ENABLE_VISIBILITY} CACHE BOOL
    "Whether or not to hide symbols (-fvisibility=hidden)" ${FORCE_CACHE})
# Set strict compiler checks or not
if(NOT DEFINED ENABLE_STRICT_TRY_COMPILE)
  # Unless specified, disable strict try_compile()
  set(ENABLE_STRICT_TRY_COMPILE FALSE)
  message(STATUS "[DEFAULTS] Using NON-strict compiler checks by default. ENABLE_STRICT_TRY_COMPILE not provided!")
endif()
set(ENABLE_STRICT_TRY_COMPILE_INT ${ENABLE_STRICT_TRY_COMPILE} CACHE BOOL
    "Whether or not to use strict compiler checks" ${FORCE_CACHE})

# Get the SDK version information.
if(NOT DEFINED SDK_VERSION)
  execute_process(COMMAND xcodebuild -sdk ${CMAKE_OSX_SYSROOT_INT} -version SDKVersion
    OUTPUT_VARIABLE SDK_VERSION
    ERROR_QUIET
    OUTPUT_STRIP_TRAILING_WHITESPACE)
endif()

# Find the Developer root for the specific iOS platform being compiled for
# from CMAKE_OSX_SYSROOT.  Should be ../../ from SDK specified in
# CMAKE_OSX_SYSROOT. There does not appear to be a direct way to obtain
# this information from xcrun or xcodebuild.
if (NOT DEFINED CMAKE_DEVELOPER_ROOT AND NOT CMAKE_GENERATOR MATCHES "Xcode")
  get_filename_component(PLATFORM_SDK_DIR ${CMAKE_OSX_SYSROOT_INT} PATH)
  get_filename_component(CMAKE_DEVELOPER_ROOT ${PLATFORM_SDK_DIR} PATH)
  if (NOT DEFINED CMAKE_DEVELOPER_ROOT)
    message(FATAL_ERROR "Invalid CMAKE_DEVELOPER_ROOT: "
      "${CMAKE_DEVELOPER_ROOT} does not exist.")
  endif()
endif()

# Find the C & C++ compilers for the specified SDK.
if(NOT DEFINED CMAKE_C_COMPILER)
  execute_process(COMMAND xcrun -sdk ${CMAKE_OSX_SYSROOT_INT} -find clang
    OUTPUT_VARIABLE CMAKE_C_COMPILER
    ERROR_QUIET
    OUTPUT_STRIP_TRAILING_WHITESPACE)
endif()
if(NOT DEFINED CMAKE_CXX_COMPILER)
  execute_process(COMMAND xcrun -sdk ${CMAKE_OSX_SYSROOT_INT} -find clang++
    OUTPUT_VARIABLE CMAKE_CXX_COMPILER
    ERROR_QUIET
    OUTPUT_STRIP_TRAILING_WHITESPACE)
endif()
# Find (Apple's) libtool.
if(NOT DEFINED BUILD_LIBTOOL)
  execute_process(COMMAND xcrun -sdk ${CMAKE_OSX_SYSROOT_INT} -find libtool
    OUTPUT_VARIABLE BUILD_LIBTOOL
    ERROR_QUIET
    OUTPUT_STRIP_TRAILING_WHITESPACE)
endif()
# Find the toolchain's provided install_name_tool if none is found on the host
if(NOT DEFINED CMAKE_INSTALL_NAME_TOOL)
  execute_process(COMMAND xcrun -sdk ${CMAKE_OSX_SYSROOT_INT} -find install_name_tool
          OUTPUT_VARIABLE CMAKE_INSTALL_NAME_TOOL_INT
          ERROR_QUIET
          OUTPUT_STRIP_TRAILING_WHITESPACE)
  set(CMAKE_INSTALL_NAME_TOOL ${CMAKE_INSTALL_NAME_TOOL_INT} CACHE STRING "" ${FORCE_CACHE})
endif()

# Configure libtool to be used instead of ar + ranlib to build static libraries.
# This is required on Xcode 7+, but should also work on previous versions of
# Xcode.
get_property(languages GLOBAL PROPERTY ENABLED_LANGUAGES)
foreach(lang ${languages})
  set(CMAKE_${lang}_CREATE_STATIC_LIBRARY
          "${BUILD_LIBTOOL} -static -o <TARGET> <LINK_FLAGS> <OBJECTS> ")
endforeach()

# CMake 3.14+ support building for iOS, watchOS and tvOS out of the box.
if(MODERN_CMAKE)
  if(SDK_NAME MATCHES "iphone")
    set(CMAKE_SYSTEM_NAME iOS CACHE INTERNAL "" ${FORCE_CACHE})
  elseif(SDK_NAME MATCHES "macosx")
    set(CMAKE_SYSTEM_NAME Darwin CACHE INTERNAL "" ${FORCE_CACHE})
  elseif(SDK_NAME MATCHES "appletv")
    set(CMAKE_SYSTEM_NAME tvOS CACHE INTERNAL "" ${FORCE_CACHE})
  elseif(SDK_NAME MATCHES "watch")
    set(CMAKE_SYSTEM_NAME watchOS CACHE INTERNAL "" ${FORCE_CACHE})
  endif()
  # Provide flags for a combined FAT library build on newer CMake versions
  if(PLATFORM_INT MATCHES ".*COMBINED")
    set(CMAKE_XCODE_ATTRIBUTE_ONLY_ACTIVE_ARCH "NO")
    set(CMAKE_IOS_INSTALL_COMBINED YES CACHE INTERNAL "" ${FORCE_CACHE})
    message(STATUS "Will combine built (static) artifacts into FAT lib...")
  endif()
elseif(NOT DEFINED CMAKE_SYSTEM_NAME AND ${CMAKE_VERSION} VERSION_GREATER_EQUAL "3.10")
  # Legacy code path prior to CMake 3.14 or fallback if no CMAKE_SYSTEM_NAME specified
  set(CMAKE_SYSTEM_NAME iOS CACHE INTERNAL "" ${FORCE_CACHE})
elseif(NOT DEFINED CMAKE_SYSTEM_NAME)
  # Legacy code path prior to CMake 3.14 or fallback if no CMAKE_SYSTEM_NAME specified
  set(CMAKE_SYSTEM_NAME Darwin CACHE INTERNAL "" ${FORCE_CACHE})
endif()
# Standard settings.
set(CMAKE_SYSTEM_VERSION ${SDK_VERSION} CACHE INTERNAL "")
set(UNIX TRUE CACHE BOOL "")
set(APPLE TRUE CACHE BOOL "")
set(IOS TRUE CACHE BOOL "")
set(CMAKE_AR ar CACHE FILEPATH "" ${FORCE_CACHE})
set(CMAKE_RANLIB ranlib CACHE FILEPATH "" ${FORCE_CACHE})
set(CMAKE_STRIP strip CACHE FILEPATH "" ${FORCE_CACHE})
# Set the architectures for which to build.
set(CMAKE_OSX_ARCHITECTURES ${ARCHS} CACHE STRING "Build architecture")
# Change the type of target generated for try_compile() so it'll work when cross-compiling, weak compiler checks
if(NOT ENABLE_STRICT_TRY_COMPILE_INT)
  set(CMAKE_TRY_COMPILE_TARGET_TYPE STATIC_LIBRARY)
endif()
# All iOS/Darwin specific settings - some may be redundant.
set(CMAKE_MACOSX_BUNDLE YES)
set(CMAKE_XCODE_ATTRIBUTE_CODE_SIGNING_REQUIRED "NO")
set(CMAKE_SHARED_LIBRARY_PREFIX "lib")
set(CMAKE_SHARED_LIBRARY_SUFFIX ".dylib")
set(CMAKE_SHARED_MODULE_PREFIX "lib")
set(CMAKE_SHARED_MODULE_SUFFIX ".so")
set(CMAKE_C_COMPILER_ABI ELF)
set(CMAKE_CXX_COMPILER_ABI ELF)
set(CMAKE_C_HAS_ISYSROOT 1)
set(CMAKE_CXX_HAS_ISYSROOT 1)
set(CMAKE_MODULE_EXISTS 1)
set(CMAKE_DL_LIBS "")
set(CMAKE_C_OSX_COMPATIBILITY_VERSION_FLAG "-compatibility_version ")
set(CMAKE_C_OSX_CURRENT_VERSION_FLAG "-current_version ")
set(CMAKE_CXX_OSX_COMPATIBILITY_VERSION_FLAG "${CMAKE_C_OSX_COMPATIBILITY_VERSION_FLAG}")
set(CMAKE_CXX_OSX_CURRENT_VERSION_FLAG "${CMAKE_C_OSX_CURRENT_VERSION_FLAG}")

if(ARCHS MATCHES "((^|;|, )(arm64|arm64e|x86_64))+")
  set(CMAKE_C_SIZEOF_DATA_PTR 8)
  set(CMAKE_CXX_SIZEOF_DATA_PTR 8)
  if(ARCHS MATCHES "((^|;|, )(arm64|arm64e))+")
    set(CMAKE_SYSTEM_PROCESSOR "aarch64")
  else()
    set(CMAKE_SYSTEM_PROCESSOR "x86_64")
  endif()
else()
  set(CMAKE_C_SIZEOF_DATA_PTR 4)
  set(CMAKE_CXX_SIZEOF_DATA_PTR 4)
  set(CMAKE_SYSTEM_PROCESSOR "arm")
endif()

# Note that only Xcode 7+ supports the newer more specific:
# -m${SDK_NAME}-version-min flags, older versions of Xcode use:
# -m(ios/ios-simulator)-version-min instead.
if(${CMAKE_VERSION} VERSION_LESS "3.11")
  if(PLATFORM_INT STREQUAL "OS" OR PLATFORM_INT STREQUAL "OS64")
    if(XCODE_VERSION VERSION_LESS 7.0)
      set(SDK_NAME_VERSION_FLAGS
        "-mios-version-min=${DEPLOYMENT_TARGET}")
    else()
      # Xcode 7.0+ uses flags we can build directly from SDK_NAME.
      set(SDK_NAME_VERSION_FLAGS
        "-m${SDK_NAME}-version-min=${DEPLOYMENT_TARGET}")
    endif()
  elseif(PLATFORM_INT STREQUAL "TVOS")
    set(SDK_NAME_VERSION_FLAGS
      "-mtvos-version-min=${DEPLOYMENT_TARGET}")
  elseif(PLATFORM_INT STREQUAL "SIMULATOR_TVOS")
    set(SDK_NAME_VERSION_FLAGS
      "-mtvos-simulator-version-min=${DEPLOYMENT_TARGET}")
  elseif(PLATFORM_INT STREQUAL "WATCHOS")
    set(SDK_NAME_VERSION_FLAGS
      "-mwatchos-version-min=${DEPLOYMENT_TARGET}")
  elseif(PLATFORM_INT STREQUAL "SIMULATOR_WATCHOS")
    set(SDK_NAME_VERSION_FLAGS
      "-mwatchos-simulator-version-min=${DEPLOYMENT_TARGET}")
  elseif(PLATFORM_INT STREQUAL "MAC")
    set(SDK_NAME_VERSION_FLAGS
        "-mmacosx-version-min=${DEPLOYMENT_TARGET}")
  else()
    # SIMULATOR or SIMULATOR64 both use -mios-simulator-version-min.
    set(SDK_NAME_VERSION_FLAGS
      "-mios-simulator-version-min=${DEPLOYMENT_TARGET}")
  endif()
elseif(NOT PLATFORM_INT STREQUAL "MAC_CATALYST")
  # Newer versions of CMake sets the version min flags correctly, skip this for Mac Catalyst targets
  set(CMAKE_OSX_DEPLOYMENT_TARGET ${DEPLOYMENT_TARGET} CACHE STRING
      "Set CMake deployment target" ${FORCE_CACHE})
endif()

if(DEFINED APPLE_TARGET_TRIPLE_INT)
  set(APPLE_TARGET_TRIPLE ${APPLE_TARGET_TRIPLE_INT} CACHE STRING
          "Autoconf target triple compatible variable" ${FORCE_CACHE})
endif()

if(PLATFORM_INT STREQUAL "MAC_CATALYST")
  set(C_TARGET_FLAGS "-target ${APPLE_TARGET_TRIPLE_INT} -isystem ${CMAKE_OSX_SYSROOT_INT}/System/iOSSupport/usr/include")
endif()

if(ENABLE_BITCODE_INT)
  set(BITCODE "-fembed-bitcode")
  set(CMAKE_XCODE_ATTRIBUTE_BITCODE_GENERATION_MODE "bitcode")
  set(CMAKE_XCODE_ATTRIBUTE_ENABLE_BITCODE "YES")
else()
  set(BITCODE "")
  set(CMAKE_XCODE_ATTRIBUTE_ENABLE_BITCODE "NO")
endif()

if(ENABLE_ARC_INT)
  set(FOBJC_ARC "-fobjc-arc")
  set(CMAKE_XCODE_ATTRIBUTE_CLANG_ENABLE_OBJC_ARC "YES")
else()
  set(FOBJC_ARC "-fno-objc-arc")
  set(CMAKE_XCODE_ATTRIBUTE_CLANG_ENABLE_OBJC_ARC "NO")
endif()

if(NOT ENABLE_VISIBILITY_INT)
  set(VISIBILITY "-fvisibility=hidden")
  set(CMAKE_XCODE_ATTRIBUTE_GCC_SYMBOLS_PRIVATE_EXTERN "YES")
else()
  set(VISIBILITY "")
  set(CMAKE_XCODE_ATTRIBUTE_GCC_SYMBOLS_PRIVATE_EXTERN "NO")
endif()

#Check if Xcode generator is used, since that will handle these flags automagically
if(CMAKE_GENERATOR MATCHES "Xcode")
  message(STATUS "Not setting any manual command-line buildflags, since Xcode is selected as generator.")
else()
  # Hidden visibility is required for C++ on iOS.
  set(CMAKE_C_FLAGS "${C_TARGET_FLAGS} ${SDK_NAME_VERSION_FLAGS} ${BITCODE} -fobjc-abi-version=2 ${FOBJC_ARC} ${CMAKE_C_FLAGS}")
  set(CMAKE_CXX_FLAGS "${C_TARGET_FLAGS} ${SDK_NAME_VERSION_FLAGS} ${BITCODE} ${VISIBILITY} -fvisibility-inlines-hidden -fobjc-abi-version=2 ${FOBJC_ARC} ${CMAKE_CXX_FLAGS}")
  set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS} -O0 -g ${CMAKE_CXX_FLAGS_DEBUG}")
  set(CMAKE_CXX_FLAGS_MINSIZEREL "${CMAKE_CXX_FLAGS} -DNDEBUG -Os -ffast-math ${CMAKE_CXX_FLAGS_MINSIZEREL}")
  set(CMAKE_CXX_FLAGS_RELWITHDEBINFO "${CMAKE_CXX_FLAGS} -DNDEBUG -O2 -g -ffast-math ${CMAKE_CXX_FLAGS_RELWITHDEBINFO}")
  set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS} -DNDEBUG -O3 -ffast-math ${CMAKE_CXX_FLAGS_RELEASE}")
  set(CMAKE_C_LINK_FLAGS "${C_TARGET_FLAGS} ${SDK_NAME_VERSION_FLAGS} -Wl,-search_paths_first ${CMAKE_C_LINK_FLAGS}")
  set(CMAKE_CXX_LINK_FLAGS "${C_TARGET_FLAGS} ${SDK_NAME_VERSION_FLAGS}  -Wl,-search_paths_first ${CMAKE_CXX_LINK_FLAGS}")
  set(CMAKE_ASM_FLAGS "${CMAKE_C_FLAGS} -x assembler-with-cpp -arch ${CMAKE_OSX_ARCHITECTURES}")

  # In order to ensure that the updated compiler flags are used in try_compile()
  # tests, we have to forcibly set them in the CMake cache, not merely set them
  # in the local scope.
  set(VARS_TO_FORCE_IN_CACHE
    CMAKE_C_FLAGS
    CMAKE_CXX_FLAGS
    CMAKE_CXX_FLAGS_DEBUG
    CMAKE_CXX_FLAGS_RELWITHDEBINFO
    CMAKE_CXX_FLAGS_MINSIZEREL
    CMAKE_CXX_FLAGS_RELEASE
    CMAKE_C_LINK_FLAGS
    CMAKE_CXX_LINK_FLAGS
    CMAKE_ASM_FLAGS)
  foreach(VAR_TO_FORCE ${VARS_TO_FORCE_IN_CACHE})
    set(${VAR_TO_FORCE} "${${VAR_TO_FORCE}}" CACHE STRING "" ${FORCE_CACHE})
  endforeach()
endif()

## Print status messages to inform of the current state
message(STATUS "Configuring ${SDK_NAME} build for platform: ${PLATFORM_INT}, architecture(s): ${ARCHS}")
message(STATUS "Using SDK: ${CMAKE_OSX_SYSROOT_INT}")
message(STATUS "Using C compiler: ${CMAKE_C_COMPILER}")
message(STATUS "Using CXX compiler: ${CMAKE_CXX_COMPILER}")
message(STATUS "Using libtool: ${BUILD_LIBTOOL}")
message(STATUS "Using install name tool: ${CMAKE_INSTALL_NAME_TOOL}")
if(DEFINED APPLE_TARGET_TRIPLE)
  message(STATUS "Autoconf target triple: ${APPLE_TARGET_TRIPLE}")
endif()
message(STATUS "Using minimum deployment version: ${DEPLOYMENT_TARGET}"
    " (SDK version: ${SDK_VERSION})")
if(MODERN_CMAKE)
  message(STATUS "Merging integrated CMake 3.14+ iOS,tvOS,watchOS,macOS toolchain(s) with this toolchain!")
endif()
if(CMAKE_GENERATOR MATCHES "Xcode")
  message(STATUS "Using Xcode version: ${XCODE_VERSION}")
endif()
message(STATUS "CMake version: ${CMAKE_VERSION}")
if(DEFINED SDK_NAME_VERSION_FLAGS)
  message(STATUS "Using version flags: ${SDK_NAME_VERSION_FLAGS}")
endif()
message(STATUS "Using a data_ptr size of: ${CMAKE_CXX_SIZEOF_DATA_PTR}")
if(ENABLE_BITCODE_INT)
  message(STATUS "Bitcode: Enabled")
else()
  message(STATUS "Bitcode: Disabled")
endif()

if(ENABLE_ARC_INT)
  message(STATUS "ARC: Enabled")
else()
  message(STATUS "ARC: Disabled")
endif()

if(NOT ENABLE_VISIBILITY_INT)
  message(STATUS "Hiding symbols (-fvisibility=hidden).")
endif()

# Set global properties
set_property(GLOBAL PROPERTY PLATFORM "${PLATFORM}")
set_property(GLOBAL PROPERTY APPLE_TARGET_TRIPLE "${APPLE_TARGET_TRIPLE_INT}")
set_property(GLOBAL PROPERTY SDK_VERSION "${SDK_VERSION}")
set_property(GLOBAL PROPERTY XCODE_VERSION "${XCODE_VERSION}")

# Export configurable variables for the try_compile() command.
set(CMAKE_TRY_COMPILE_PLATFORM_VARIABLES
    PLATFORM
    XCODE_VERSION
    SDK_VERSION
    DEPLOYMENT_TARGET
    CMAKE_DEVELOPER_ROOT
    CMAKE_OSX_SYSROOT_INT
    ENABLE_BITCODE
    ENABLE_ARC
    CMAKE_C_COMPILER
    CMAKE_CXX_COMPILER
    BUILD_LIBTOOL
    CMAKE_INSTALL_NAME_TOOL
    )

set(CMAKE_PLATFORM_HAS_INSTALLNAME 1)
set(CMAKE_SHARED_LINKER_FLAGS "-rpath @executable_path/Frameworks -rpath @loader_path/Frameworks")
set(CMAKE_SHARED_LIBRARY_CREATE_C_FLAGS "-dynamiclib -Wl,-headerpad_max_install_names")
set(CMAKE_SHARED_MODULE_CREATE_C_FLAGS "-bundle -Wl,-headerpad_max_install_names")
set(CMAKE_SHARED_MODULE_LOADER_C_FLAG "-Wl,-bundle_loader,")
set(CMAKE_SHARED_MODULE_LOADER_CXX_FLAG "-Wl,-bundle_loader,")
set(CMAKE_FIND_LIBRARY_SUFFIXES ".tbd" ".dylib" ".so" ".a")
set(CMAKE_SHARED_LIBRARY_SONAME_C_FLAG "-install_name")

# Set the find root to the iOS developer roots and to user defined paths.
set(CMAKE_FIND_ROOT_PATH ${CMAKE_OSX_SYSROOT_INT} ${CMAKE_PREFIX_PATH} CACHE STRING
    "Root path that will be prepended to all search paths")
# Default to searching for frameworks first.
set(CMAKE_FIND_FRAMEWORK FIRST)
# Set up the default search directories for frameworks.
if(PLATFORM_INT MATCHES "MAC_CATALYST.*")
  set(CMAKE_FRAMEWORK_PATH
      ${CMAKE_DEVELOPER_ROOT}/Library/PrivateFrameworks
      ${CMAKE_OSX_SYSROOT_INT}/System/Library/Frameworks
      ${CMAKE_OSX_SYSROOT_INT}/System/iOSSupport/System/Library/Frameworks
      ${CMAKE_FRAMEWORK_PATH} CACHE STRING "Frameworks search paths" ${FORCE_CACHE})
else()
  set(CMAKE_FRAMEWORK_PATH
      ${CMAKE_DEVELOPER_ROOT}/Library/PrivateFrameworks
      ${CMAKE_OSX_SYSROOT_INT}/System/Library/Frameworks
      ${CMAKE_FRAMEWORK_PATH} CACHE STRING "Frameworks search paths" ${FORCE_CACHE})
endif()

# By default, search both the specified iOS SDK and the remainder of the host filesystem.
if(NOT CMAKE_FIND_ROOT_PATH_MODE_PROGRAM)
  set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM BOTH CACHE STRING "" ${FORCE_CACHE})
endif()
if(NOT CMAKE_FIND_ROOT_PATH_MODE_LIBRARY)
  set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY BOTH CACHE STRING "" ${FORCE_CACHE})
endif()
if(NOT CMAKE_FIND_ROOT_PATH_MODE_INCLUDE)
  set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE BOTH CACHE STRING "" ${FORCE_CACHE})
endif()
if(NOT CMAKE_FIND_ROOT_PATH_MODE_PACKAGE)
  set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE BOTH CACHE STRING "" ${FORCE_CACHE})
endif()

#
# Some helper-macros below to simplify and beautify the CMakeFile
#

# This little macro lets you set any Xcode specific property.
macro(set_xcode_property TARGET XCODE_PROPERTY XCODE_VALUE XCODE_RELVERSION)
  set(XCODE_RELVERSION_I "${XCODE_RELVERSION}")
  if(XCODE_RELVERSION_I STREQUAL "All")
    set_property(TARGET ${TARGET} PROPERTY XCODE_ATTRIBUTE_${XCODE_PROPERTY} "${XCODE_VALUE}")
  else()
    set_property(TARGET ${TARGET} PROPERTY XCODE_ATTRIBUTE_${XCODE_PROPERTY}[variant=${XCODE_RELVERSION_I}] "${XCODE_VALUE}")
  endif()
endmacro(set_xcode_property)

# This macro lets you find executable programs on the host system.
macro(find_host_package)
  set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
  set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY NEVER)
  set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE NEVER)
  set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE NEVER)
  set(IOS FALSE)
  find_package(${ARGN})
  set(IOS TRUE)
  set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM BOTH)
  set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY BOTH)
  set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE BOTH)
  set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE BOTH)
endmacro(find_host_package)
