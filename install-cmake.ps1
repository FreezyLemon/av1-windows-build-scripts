New-Item -ItemType Directory -ErrorAction SilentlyContinue "deps" | Out-Null
Push-Location "deps"

$downloadUrl = "https://github.com/Kitware/CMake/releases/download/v3.24.0/cmake-3.24.0-windows-x86_64.zip"
$outFile = "cmake.zip"

Write-Host "Downloading cmake..."
Invoke-WebRequest $downloadUrl -OutFile $outFile -TimeoutSec 10
Write-Host "Extracting archive..."
Expand-Archive -LiteralPath $outFile -DestinationPath .
$cmakeDir = Get-ChildItem -Directory "cmake-*"
Rename-Item $cmakeDir "cmake"
Write-Host "Done"

$env:Path += ";$pwd\cmake\bin\"
cmake --version

Pop-Location
