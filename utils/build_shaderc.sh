#!/bin/bash

##########################################################################
# This will                                                              #
#     1) pull source from github / gitlab[for pre-released components    #
#     2) build 2 stl flavours  ( c++_static / gnustl_static  )           #
#     3) copy headers from various modules                               #
# The result:                                                            #
#     $TARGET_ROOT                                                       #
#         include                                                        #
#         lib                                                            #
#            c++_static                                                  #
#            gnustl_static                                               #
# Usage:                                                                 #
#     modify the $TARGET_ROOT, $SRC_ROOT, $SCRIPT_ROOT                   #
#     then run this script                                               #
# Generated File Structure                                               #
#       shaderc                                                          #
#           toolChain-type (build only one toolchain at a run )          #
#               stl-type1 [total types are configurable]                 #
#                   arch1                                                #
#                   arch2                                                #
#                   arch3                                                #
#               stl-type2                                                #
#                   arch1                                                #
#                   arch2                                                #
#                   arch3                                                #
# Tested:                                                                #
#     Mac OS                                                             #
##########################################################################

set -e
##### script root directory, containing this file and combine.mri
SCRIPT_ROOT=${HOME}/backup/shaderc/scripts

## gcc-ar location
AR_TOOL=/Users/gfan/dev/ndk_current/toolchains/x86_64-4.9/prebuilt/darwin-x86_64/bin/x86_64-linux-android-gcc-ar

## shaderc source tree
SRC_ROOT=${HOME}/backup/shaderc/src
## should pull source code?
#PULL_SRC=YES

# Toolchain to use[4.8, 4.9, clang3.5, clang3.6]
toolChain=4.9
TOOLCHAIN=NDK_TOOLCHAIN_VERSION=$toolChain

## location to host combined libs
TARGET_ROOT=${HOME}/backup/shaderc/result/shaderc/${toolChain}
COMBINED_LIB_NAME=libshaderc.a

## STL_TYPE
STL_TYPES=(c++_static gnustl_static)

## arch types we are trying to build for given stl_type
declare ARCHS=(x86 x86_64 armeabi armeabi-v7a arm64-v8a)

#### pull source code into SRC_ROOT####################
if [ -n "${PULL_SRC}" ] && [ "${PULL_SRC}" == "YES" ]; then
  rm  -fr ${SRC_ROOT}
  git clone https://github.com/google/shaderc ${SRC_ROOT}
  pushd $SRC_ROOT/third_party
  git clone https://github.com/google/googletest.git

  #  after vulkan is released, get from github
  #    https://github.com/google/glslang.git
  #    https://github.com/KhronosGroup/SPIRV-Tools.git spirv-tools
  git clone git@gitlab.khronos.org:GLSL/glslang.git
  cd glslang
  git checkout -b vulkan-glsl origin/KHR_vulkan_glsl
  cd ..
  git clone git@gitlab.khronos.org:spirv/spirv-tools.git
  popd
fi

#####build and combine libs ###########################
if [ ! -f ${SCRIPT_ROOT}/combine.mri ]; then
  echo "${SCRIPT_ROOT}/combine.mri does not exist"
  exit
fi

for stl in "${STL_TYPES[@]}"; do
# set Application.mk into our stl type
  SUB_CMD=s/.*APP_STL.*/APP_STL=${stl}/g

  pushd ${SRC_ROOT}/android_test
  ndk-build clean
  grep -q 'NDK_TOOLCHAIN_VERSION' ./jni/Application.mk  && sed -i .org "s/.*NDK_TOOLCHAIN_VERSION.*/$TOOLCHAIN/g" ./jni/Application.mk || echo "${TOOLCHAIN}" >> ./jni/Application.mk

  sed -i .org ${SUB_CMD} ./jni/Application.mk
  ndk-build

  for arch in "${ARCHS[@]}"; do
    echo "######################
    echo "building ${arch} ..."
    echo "#####################
    
    cd obj/local/${arch}
    rm -f libshaderc_combined.a

    ${AR_TOOL} -M < ${SCRIPT_ROOT}/combine.mri
    mkdir  -p ${TARGET_ROOT}/lib/${stl}/${arch}
    cp -f libshaderc_combined.a ${TARGET_ROOT}/lib/${stl}/${arch}/${COMBINED_LIB_NAME}
    cd ../../..
  done

  popd
done

##### pull header files for lib ########################
##### copy and create shader/include folder #######
mkdir -p  ${TARGET_ROOT}
cp -r ${SRC_ROOT}/libshaderc/include ${TARGET_ROOT}

##### copy headers for SPIRV from client's [spirv-tools]
mkdir -p  ${TARGET_ROOT}/include/glslang/SPIRV
cp  ${SRC_ROOT}/third_party/spirv-tools/external/include/headers/*.h  ${TARGET_ROOT}/include/glslang/SPIRV/

mkdir  -p  ${TARGET_ROOT}/include/spirv-tools
cp -r ${SRC_ROOT}/third_party/spirv-tools/include/libspirv  ${TARGET_ROOT}/include/spirv-tools/
cp -r ${SRC_ROOT}/third_party/spirv-tools/include/util      ${TARGET_ROOT}/include/spirv-tools/

##### bypassing libshaderc_utils  libSPIRV-Tools

mkdir -p ${TARGET_ROOT}/include/glslang
cp  ${SRC_ROOT}/third_party/glslang/glslang/Public/ShaderLang.h  ${TARGET_ROOT}/include/glslang/

##### bypassing OGLCompiler OSDependent


##### unset variables #####
arch=
AR_TOOL=
STL_TYPES=
SRC_ROOT=
TARGET_ROOT=






