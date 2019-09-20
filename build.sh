#!/bin/bash

set -uex

root=$PWD
date +%s > build-start-time
time_limit=2650

ccache -s

function build_time {
  echo $(($(date +%s) - $(cat $root/build-start-time)))
}

export CC=clang-8
export CXX=clang++-8

llvm_dir=/usr/lib/llvm-8/lib/cmake/llvm

test -f "$llvm_dir/LLVMConfig.cmake"

function git_clone {
  git clone --depth 1 --branch release/8.x "$@"
}

git_clone https://github.com/llvm/llvm-project.git

patch -p1 < plugin-support.patch

mkdir build
cd build
cmake \
  -DCMAKE_CXX_COMPILER_LAUNCHER=ccache \
  -DLLVM_ENABLE_PROJECTS='clang;clang-tools-extra' \
  -DCMAKE_BUILD_TYPE=MinSizeRel \
  -DCMAKE_EXE_LINKER_FLAGS="-fuse-ld=lld" \
  -DLLVM_INCLUDE_TESTS=OFF \
  -DLLVM_TARGETS_TO_BUILD="" \
  -DCLANG_ENABLE_ARCMT=OFF \
#  -DCLANG_ENABLE_STATIC_ANALYZER=OFF \
  ../llvm
#cat CMakeCache.txt
# Loop over targets so we can abort when aproaching the 50 minute Travis time
# limit
while read targets
do
  time=$(build_time)
  if [ "$time" -gt "$time_limit" ]
  then
    echo "Stopping build; running out of time"
    break
  fi
  make -j3 $targets
done < $root/targets
ccache -s

cd $root
