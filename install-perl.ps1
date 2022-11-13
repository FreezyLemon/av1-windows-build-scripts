New-Item -ItemType Directory -ErrorAction SilentlyContinue "deps" | Out-Null
Push-Location "deps"

$downloadUrl = "https://strawberryperl.com/download/5.32.1.1/strawberry-perl-5.32.1.1-64bit-portable.zip"
$outFile = "perl.zip"

Write-Host "Downloading perl (this might take a while)..."
Invoke-WebRequest $downloadUrl -OutFile $outFile -TimeoutSec 10
Write-Host "Extracting archive (be patient)..."
Expand-Archive -LiteralPath $outFile -DestinationPath 'perl'
Write-Host "Done"

$env:Path += ";$pwd\perl\perl\bin\"
perl --version

Pop-Location
