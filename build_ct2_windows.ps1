Param($Configuration)

$Version = "3.20.0"

# Clone CTranslate2 repo.
git clone https://github.com/OpenNMT/CTranslate2.git "CTranslate2-$Version"
Set-Location "CTranslate2-$Version"
git checkout "v$Version"
git submodule update --init --recursive

# download OpenBLAS
Invoke-WebRequest -Uri https://github.com/xianyi/OpenBLAS/releases/download/v0.3.24/OpenBLAS-0.3.24-x64.zip `
  -OutFile OpenBLAS-0.3.24-x64.zip
Expand-Archive OpenBLAS-0.3.24-x64.zip -DestinationPath OpenBLAS-0.3.24-x64 -Force
Remove-Item OpenBLAS-0.3.24-x64.zip

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
  -DOPENBLAS_INCLUDE_DIR="OpenBLAS-0.3.24-x64\include" `
  -DOPENBLAS_LIBRARY="OpenBLAS-0.3.24-x64\lib\libopenblas.dll.a" `
  -DCMAKE_BUILD_TYPE=$Configuration


cmake --build build_$Configuration --config $Configuration

New-Item -ItemType Directory -Force -Path "..\release\"

cmake --install build_$Configuration --config $Configuration --prefix "..\release\$Configuration"
# copy openblas .dll to release folder, first create the folder
New-Item -ItemType Directory -Force -Path "..\release\$Configuration\bin"
Copy-Item "OpenBLAS-0.3.24-x64\bin\libopenblas.dll" "..\release\$Configuration\bin\libopenblas.dll"
Compress-Archive "..\release\$Configuration\*" "..\release\libctranslate2-windows-$Version-$Configuration.zip" -Verbose
