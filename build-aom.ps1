New-Item -ItemType Directory -ErrorAction SilentlyContinue "build" | Out-Null
Push-Location "build"

$aomPath = "aom"
if (Test-Path $aomPath) {
	Write-Host "Repository aom already exists. Pulling from upstream..."
	Push-Location $aomPath
	git pull
	Pop-Location
}
else {
	git clone --depth 1 https://aomedia.googlesource.com/aom $aomPath
}

New-Item -ItemType Directory -ErrorAction SilentlyContinue "aom-build" | Out-Null

Write-Host -NoNewLine "Detecting available CPU cores... "
$cores = (Get-CimInstance -ClassName Win32_Processor).NumberOfLogicalProcessors
Write-Host -ForegroundColor Green $cores

# AVX-512 detection is too annoying to figure out, and I'm not sure there's a benefit to it
# Feel free to manually set /arch:AVX512 though, if your CPU supports it
Write-Host -NoNewLine "Checking CPU features... "
if ([System.Runtime.Intrinsics.X86.Avx2]::IsSupported) {
	Write-Host -ForegroundColor Green "AVX2"
	$cflags = "/arch:AVX2"
} elseif ([System.Runtime.Intrinsics.X86.Avx]::IsSupported) {
	Write-Host -ForegroundColor Green "AVX"
	$cflags = "/arch:AVX"
} else {
	Write-Host -ForegroundColor Green "SSE2"
}

Write-Host ""
cmake -G "Visual Studio 17 2022" -DCMAKE_INSTALL_PREFIX="${env:ProgramFiles}/AOM" -DCMAKE_C_FLAGS="$cflags" -DCONFIG_AV1_DECODER=0 -DENABLE_DOCS=0 -DENABLE_TESTS=0 -S "$aomPath" -B "aom-build"
Write-Host "Building..."
cmake --build "aom-build" --config Release -j $cores
Write-Host ""
Write-Host -ForegroundColor Green "Build finished. Build output can be found in aom-build\Release"
Write-Host -ForegroundColor Green "To install to C:\Program Files\AOM, run 'cmake --install .\build\aom-build --config Release'"
Write-Host -ForegroundColor Green "To get installation help, run 'cmake --install'"

Pop-Location
