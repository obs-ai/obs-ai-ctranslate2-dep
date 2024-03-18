Param($Configuration)

$Version = "4.1.1"

# Clone CTranslate2 repo.
git clone https://github.com/OpenNMT/CTranslate2.git "CTranslate2-$Version"
Set-Location "CTranslate2-$Version"
git checkout "v$Version"
git submodule update --init --recursive

# download OpenBLAS
$OpenBLASVersion = "0.3.26"
Invoke-WebRequest -Uri https://github.com/xianyi/OpenBLAS/releases/download/v$OpenBLASVersion/OpenBLAS-$OpenBLASVersion-x64.zip `
  -OutFile OpenBLAS-$OpenBLASVersion-x64.zip
Expand-Archive OpenBLAS-$OpenBLASVersion-x64.zip -DestinationPath OpenBLAS-$OpenBLASVersion-x64 -Force
Remove-Item OpenBLAS-$OpenBLASVersion-x64.zip

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
  -DOPENBLAS_INCLUDE_DIR="OpenBLAS-$OpenBLASVersion-x64\include" `
  -DOPENBLAS_LIBRARY="OpenBLAS-$OpenBLASVersion-x64\lib\libopenblas.dll.a" `
  -DCMAKE_BUILD_TYPE=$Configuration


cmake --build build_$Configuration --config $Configuration

New-Item -ItemType Directory -Force -Path "..\dist\"

cmake --install build_$Configuration --config $Configuration --prefix "..\dist\$Configuration"
# copy openblas .dll to dist folder, first create the folder
New-Item -ItemType Directory -Force -Path "..\dist\$Configuration\bin"
Copy-Item "OpenBLAS-$OpenBLASVersion-x64\bin\libopenblas.dll" "..\dist\$Configuration\bin\libopenblas.dll"
Compress-Archive "..\dist\$Configuration\*" "..\dist\libctranslate2-windows-$Version-$Configuration.zip" -Verbose
