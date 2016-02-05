#!/bin/bash
#######################################################################
# This file is part of the build_shaderc.sh now, no need to execute   #
#######################################################################


#Pull source into current directory
SOURCE_DIR=$HOME/backup/shaderc/src

rm  -fr ${SOURCE_DIR}
git clone https://github.com/google/shaderc $SOURCE_DIR
pushd $SOURCE_DIR/third_party
git clone https://github.com/google/googletest.git
git clone git@gitlab.khronos.org:GLSL/glslang.git
git clone git@gitlab.khronos.org:spirv/spirv-tools.git

####### Not using the ones from Google page##########
#git clone https://github.com/google/glslang.git
#git clone https://github.com/KhronosGroup/SPIRV-Tools.git spirv-tools
popd




