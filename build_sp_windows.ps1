Param($Configuration)

$Version = "0.2.0"

# Clone CTranslate2 repo.
git clone https://github.com/google/sentencepiece.git "sentencepiece-$Version"
Set-Location "sentencepiece-$Version"
git checkout "v$Version"
git submodule update --init --recursive

cmake . -B build_$Configuration `
    -DSPM_ENABLE_SHARED=OFF `
    -DBUILD_SHARED_LIBS=OFF `
    -DCMAKE_BUILD_TYPE=$Configuration

cmake --build build_$Configuration --config $Configuration

New-Item -ItemType Directory -Force -Path "..\dist\"

cmake --install build_$Configuration --config $Configuration --prefix "..\dist\$Configuration"

Compress-Archive "..\dist\$Configuration\*" "..\dist\sentencepiece-windows-$Version-$Configuration.zip" -Verbose
