#!/bin/bash

set -uex

name=clang-tidy-plugin-support-$TRAVIS_TAG
mkdir -p $name/{bin,include,lib}
# bin
cp llvm-project/build/bin/clang-tidy $name/bin
cp llvm-project/clang-tools-extra/test/clang-tidy/check_clang_tidy.py $name/bin
ln -s /usr/bin/FileCheck-8 $name/bin/FileCheck
# include
mkdir -p $name/include/{clang-tidy,llvm,clang}
cp llvm-project/clang-tools-extra/clang-tidy/*.h $name/include/clang-tidy
ln -s llvm-project/llvm/include $name/include/llvm
ln -s llvm-project/clang/include $name/include/clang
# lib
cp llvm-project/build/lib/clangTidyMain.a $name/lib
# license
cp llvm-project/clang/LICENSE.TXT $name/clang-LICENSE.TXT
cp llvm-project/llvm/LICENSE.TXT $name/llvm-LICENSE.TXT
cp llvm-project/clang-tools-extra/LICENSE.TXT $name/clang-tools-extra-LICENSE.TXT
tar -cJvf $name.tar.xz $name
