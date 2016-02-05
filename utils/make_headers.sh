#!/bin/bash
#############################################################################
#  This file is part of the build_shaderc.sh now, no need to use it         #
#############################################################################



##### set up the target directory to host "include" dir
TARGET_ROOT=${HOME}/backup/shaderc/result/shaderc

##### the directory that hosting the shaderc code from web
#####     .git is here 
SRC_ROOT=${HOME}/backup/shaderc/src

##### copy and create shader/include folder #######
mkdir -p  ${TARGET_ROOT}
cp -r ${SRC_ROOT}/libshaderc/include ${TARGET_ROOT}

##### copy headers for SPIRV from client's [spirv-tools]
mkdir -p  ${TARGET_ROOT}/include/glslang/SPIRV
cp  ${SRC_ROOT}/third_party/spirv-tools/external/include/headers/*.h  ${TARGET_ROOT}/include/glslang/SPIRV/

mkdir  -p  ${TARGET_ROOT}/include/spirv-tools
cp -r ${SRC_ROOT}/third_party/spirv-tools/include/libspirv  ${TARGET_ROOT}/include/spirv-tools/
cp -r ${SRC_ROOT}/third_party/spirv-tools/include/util      ${TARGET_ROOT}/include/spirv-tools/

# bypassing libshaderc_utils module
# bypassing libSPIRV-Tools

mkdir -p ${TARGET_ROOT}/include/glslang
cp  ${SRC_ROOT}/third_party/glslang/glslang/Public/ShaderLang.h  ${TARGET_ROOT}/include/glslang/

# bypassing OGLCompiler 
# bypassing OSDependent

