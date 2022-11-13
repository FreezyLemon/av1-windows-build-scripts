New-Item -ItemType Directory -ErrorAction SilentlyContinue "deps" | Out-Null
Push-Location "deps"

New-Item -ItemType Directory -ErrorAction SilentlyContinue "yasm" | Out-Null
Push-Location "yasm"

$downloadUrl = "http://www.tortall.net/projects/yasm/releases/yasm-1.3.0-win64.exe"
$outFile = "yasm.exe"

Write-Host "Downloading yasm..."
Invoke-WebRequest $downloadUrl -OutFile $outFile -TimeoutSec 10
Write-Host "Done"

$env:Path += ";$pwd"
yasm --version

Pop-Location
Pop-Location
