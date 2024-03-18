#!/bin/bash
set -euo pipefail

CONFIG=${1?}
PKG_VERSION=${2?}
VERSION="0.2.0"

if [ ! -d "sentencepiece-$VERSION" ]; then
  # Clone sentencepiece repo.
  git clone https://github.com/google/sentencepiece.git "sentencepiece-$VERSION"
  cd "sentencepiece-$VERSION"
  git checkout v$VERSION
  git submodule update --init --recursive
  cd ..
fi

cd sentencepiece-$VERSION

function build_for_arch() {
  ARCH=$1
  echo "Building for ${ARCH}"
  cmake . -B build_${ARCH}_${CONFIG} \
    -DCMAKE_OSX_DEPLOYMENT_TARGET=10.13 \
    -DSPM_ENABLE_SHARED=OFF \
    -DCMAKE_GENERATOR=Xcode \
    -DCMAKE_BUILD_TYPE=${CONFIG}

  cmake --build build_${ARCH}_${CONFIG} --config ${CONFIG} -- -arch ${ARCH} ONLY_ACTIVE_ARCH=YES
  mkdir -p release/${ARCH}/${CONFIG}
  cmake --install build_${ARCH}_${CONFIG} --config ${CONFIG} --prefix release/${ARCH}/${CONFIG}
}

build_for_arch x86_64
build_for_arch arm64

# Create universal binary.
mkdir -p release/universal/${CONFIG}/lib
lipo -create release/x86_64/${CONFIG}/lib/libsentencepiece.a release/arm64/${CONFIG}/lib/libsentencepiece.a -output release/universal/${CONFIG}/lib/libsentencepiece.a

# Copy headers.
cp -r release/x86_64/${CONFIG}/include release/universal/${CONFIG}/include

mkdir -p ../release
tar -C release/universal/${CONFIG} -cvf ../release/libsentencepiece-macos-${CONFIG}-${PKG_VERSION}.tar.gz .
