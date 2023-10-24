Param($Configuration, $Version)

# Clone CTranslate2 repo.
git clone https://github.com/OpenNMT/CTranslate2.git "CTranslate2-$VERSION"
cd "CTranslate2-$VERSION"
git checkout v$VERSION
git submodule update --init --recursive

# download OpenBLAS
Invoke-WebRequest -Uri https://github.com/xianyi/OpenBLAS/releases/download/v0.3.24/OpenBLAS-0.3.24-x64.zip `
  -OutFile OpenBLAS-0.3.24-x64.zip
Expand-Archive OpenBLAS-0.3.24-x64.zip -DestinationPath OpenBLAS-0.3.24-x64 -Force

cmake . -B build_$Configuration `
  -DBUILD_SHARED_LIBS=OFF `
  -DOPENMP_RUNTIME=COMP `
  -DWITH_CUDA=OFF `
  -DWITH_MKL=OFF `
  -DWITH_TESTS=OFF `
  -DWITH_EXAMPLES=OFF `
  -DWITH_TFLITE=OFF `
  -DWITH_TRT=OFF `
  -DWITH_PYTHON=OFF `
  -DWITH_SERVER=OFF `
  -DWITH_COVERAGE=OFF `
  -DWITH_PROFILING=OFF `
  -DBUILD_CLI=OFF `
  -DWITH_OPENBLAS=ON `
  -DOPENBLAS_INCLUDE_DIR=OpenBLAS-0.3.24-x64\include `
  -DOPENBLAS_LIBRARY=OpenBLAS-0.3.24-x64\lib\libopenblas.dll.a `
  -DCMAKE_BUILD_TYPE=$Configuration


cmake --build build_$Configuration --config $Configuration
cmake --install build_$Configuration --config $Configuration --prefix release/$Configuration
# copy openblas .dll to release folder
cp OpenBLAS-0.3.24-x64\bin\libopenblas.dll release\$Configuration\bin\libopenblas.dll
Compress-Archive release\$Configuration\* release\libcurl-windows-$Version-$Configuration.zip -Verbose
