New-Item -ItemType Directory -ErrorAction SilentlyContinue "build" | Out-Null
Push-Location "build"

$repoPath = "svtav1"
$buildPath = "svtav1-build"

if (Test-Path $repoPath) {
	Write-Host "Repository SVT-AV1 already exists. Pulling from upstream..."
	Push-Location $repoPath
	git pull
	Pop-Location
}
else {
	git clone --depth 1 https://gitlab.com/AOMediaCodec/SVT-AV1 $repoPath
}

New-Item -ItemType Directory -ErrorAction SilentlyContinue $buildPath | Out-Null

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

$installDir = "${env:ProgramFiles}\SVT-AV1"
Write-Host ""
cmake -G "Visual Studio 17 2022" -DCMAKE_INSTALL_PREFIX=$installDir -DCMAKE_C_FLAGS="$cflags" -DBUILD_TESTING=0 -DBUILD_SHARED_LIBS=0 -DCOMPILE_C_ONLY=0 -DBUILD_DEC=0 -DSVT_AV1_PGO=1 -S "$repoPath" -B "$buildPath"
Write-Host "Building..."
cmake --build $buildPath --config Release -j $cores
Write-Host ""
Write-Host -ForegroundColor Green "Build finished. Build output can be found in $repoPath\Bin\Release"
Write-Host -ForegroundColor Green "To install to $installDir, run 'cmake --install .\build\$buildPath --config Release'"
Write-Host -ForegroundColor Green "To get installation help, run 'cmake --install'"

Pop-Location
