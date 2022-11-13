New-Item -ItemType Directory -ErrorAction SilentlyContinue "deps" | Out-Null
Push-Location "deps"

$downloadUrl = "https://github.com/git-for-windows/git/releases/download/v2.37.1.windows.1/PortableGit-2.37.1-64-bit.7z.exe"
$outFile = "portable-git.exe"

Write-Host "Downloading git..."
Invoke-WebRequest $downloadUrl -OutFile $outFile -TimeoutSec 10
Write-Host "Extracting..."
Start-Process -Wait $outFile -ArgumentList "-y", "-ogit"
Write-Host "Done"

$env:Path += ";${pwd}\git\bin\"
git --version

Pop-Location
