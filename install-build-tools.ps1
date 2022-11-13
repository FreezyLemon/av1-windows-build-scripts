New-Item -ItemType Directory -ErrorAction SilentlyContinue "deps" | Out-Null
Push-Location "deps"

$vswhere = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\vswhere.exe"
$vswhereExists = Test-Path $vswhere
if (!$vswhereExists) {
	$vswhere = "${env:ProgramFiles}\Microsoft Visual Studio\Installer\vswhere.exe"
	$vswhereExists = Test-Path $vswhere
}

# TODO: Handle build tools via vswhere
#& $vswhere -sort `
	#-version '[16.0' `
	#-requires 'Microsoft.VisualStudio.Workload.NativeDesktop' `
	#-products 'Microsoft.VisualStudio.Product.Community, Microsoft.VisualStudio.Product.Professional, Microsoft.VisualStudio.Product.Enterprise, Microsoft.VisualStudio.Product.BuildTools' `
	# -property 

if ($vswhereExists) {
	$versions = @(& $vswhere -version '[16.0' -sort -requires 'Microsoft.VisualStudio.Workload.NativeDesktop' -property catalog_productDisplayVersion)
	# -products 'Microsoft.VisualStudio.Product.Community' 'Microsoft.VisualStudio.Product.Professional' 'Microsoft.VisualStudio.Product.Enterprise' 'Microsoft.VisualStudio.Product.BuildTools'
} else {
	$versions = @()
}

if ($versions.Length -gt 0) {
	Write-Host "Found $($versions.Length) compatible Visual Studio installations"
	
	# Since we used -sort, versions[0] is the highest available versions
	$v = $versions[0]
	$setup = & $vswhere -version $v -property properties_setupEngineFilePath
	$installPath = & $vswhere -version $v -property installationPath
	
	# Run the installer to install any missing packages
	Write-Host "Installing missing packages..."
	Write-Host -NoNewLine "If the required packages are already installed, "
	Write-Host -ForegroundColor Green "just close the installation window."
	Start-Process $setup "modify --focusedUi --installWhileDownloading --installPath `"$installPath`" --config `"$PSScriptRoot\vs.vsconfig`"" -NoNewWindow -Wait
	
	try {
		Write-Host -NoNewLine "Looking for CMake on PATH... "
		Get-Command -ErrorAction Stop 'cmake' | Out-Null
		Write-Host -ForegroundColor Green "found"
	} catch {
		Write-Host -ForegroundColor Red "not found"
		Write-Host "Adding CMake from VS to PATH..."
		$cmakePath = & $vswhere -version $v -find '**\bin\cmake.exe'
		if ([string]::IsNullOrEmpty($cmakePath)) {
			Write-Error "Cannot find CMake. Was the installation successful?"
			exit 1
		} else {
			$cmakePath = $cmakePath.Remove($cmakePath.LastIndexOf('\'))
			$env:Path += ";$cmakePath"

			Write-Host "Done"
			Write-Host ""
			cmake --version
		}
	}
} else {
	# No VS installed, install build tools
	Write-Host "No compatible Visual Studio installation found"
	Write-Host -NoNewLine "Looking for 2022 Build tools... "
	$toolsPath = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2022\BuildTools"

	if (!(Test-Path $toolsPath)) {
		# Also check for 2019 build tools
		Write-Host -ForegroundColor Red "not found"
		Write-Host -NoNewLine "Looking for 2019 Build Tools... "
		$toolsPath = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\2019\BuildTools"
	}

	if (Test-Path $toolsPath) {
		# We have build tools installed
		Write-Host -ForegroundColor Green "found"
		$setup = "${env:ProgramFiles(x86)}\Microsoft Visual Studio\Installer\setup.exe"
		if (Test-Path $setup) {
			Write-Host "Waiting for installer to install missing packages"
			Write-Host -NoNewLine "If the required packages are already installed, "
			Write-Host -ForegroundColor Green "just close the installation window."
			Start-Process $setup "modify --focusedUi --installWhileDownloading --installPath `"$toolsPath`" --config `"$PSScriptRoot\tools.vsconfig`"" -NoNewWindow -Wait
		} else {
			Write-Error "The VS installer could not be found."
		}
	} else {
		# Install build tools from scratch
		Write-Host -ForegroundColor Red "not found"
		Write-Host "Installing 2022 Build Tools..."
		$downloadUrl = "https://aka.ms/vs/17/release/vs_BuildTools.exe"
		$outFile = ".\buildtools.exe"
		Write-Host "Downloading installer..."
		Invoke-WebRequest $downloadUrl -OutFile $outFile -TimeoutSec 10
		Write-Host -NoNewLine "Downloading and installing Build Tools (this might take a while)..."
		Start-Process $outFile '-q --norestart --installWhileDownloading --config `"$PSScriptRoot\tools.vsconfig`"' -NoNewWindow -Wait
		Write-Host -ForegroundColor Green "Done"
	}
}

Pop-Location
