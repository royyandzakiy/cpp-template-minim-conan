# Simple Windows Dev Setup for Conan Projects
param([switch]$Force)

$ErrorActionPreference = "Stop"

Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Minimal Dev Setup for Conan Projects  " -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan

# Test if a tool is in PATH
function Test-Tool {
	param([string]$Tool)
	try {
		$null = Get-Command $Tool -ErrorAction Stop
		return $true
	}
 catch {
		return $false
	}
}

# Download and install helper
function Install-Tool {
	param(
		[string]$Name,
		[string]$Url,
		[string]$InstallerArgs = "",
		[string]$TestCommand = $Name
	)
    
	Write-Host "`nInstalling $Name..." -ForegroundColor Yellow
    
	$tempFile = Join-Path $env:TEMP "$Name-installer.exe"
    
	# Download
	Write-Host "  Downloading..." -ForegroundColor Gray
	try {
		Invoke-WebRequest -Uri $Url -OutFile $tempFile -UserAgent "PowerShell"
	}
 catch {
		Write-Host "  Download failed: $_" -ForegroundColor Red
		return $false
	}
    
	# Install
	Write-Host "  Installing..." -ForegroundColor Gray
	try {
		if ($InstallerArgs) {
			Start-Process $tempFile -ArgumentList $InstallerArgs -Wait -NoNewWindow
		}
		else {
			Start-Process $tempFile -Wait -NoNewWindow
		}
        
		# Cleanup
		Remove-Item $tempFile -Force -ErrorAction SilentlyContinue
        
		# Verify installation
		Start-Sleep -Seconds 2
		$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
        
		if (Test-Tool $TestCommand) {
			Write-Host "  ✓ $Name installed successfully" -ForegroundColor Green
			return $true
		}
		else {
			Write-Host "  ✗ $Name installed but not in PATH" -ForegroundColor Red
			return $false
		}
	}
 catch {
		Write-Host "  Installation failed: $_" -ForegroundColor Red
		return $false
	}
}

# ============================================================================
# Check existing tools
# ============================================================================
Write-Host "`nChecking existing tools..." -ForegroundColor Yellow

$tools = @{
	"Git"    = if (Test-Tool "git") { 
		$version = git --version 2>&1
		$match = $version | Select-String -Pattern "\d+\.\d+\.\d+"
		if ($match) { $match.Matches.Value } else { "unknown" }
	}
 else { $null }
    
	"CMake"  = if (Test-Tool "cmake") { 
		$version = cmake --version 2>&1
		$match = $version | Select-String -Pattern "\d+\.\d+\.\d+"
		if ($match) { $match.Matches.Value } else { "unknown" }
	}
 else { $null }
    
	"Python" = if (Test-Tool "python") { 
		$version = python --version 2>&1
		$version -replace 'Python ', ''
	}
 else { $null }
    
	"Conan"  = if (Test-Tool "conan") { 
		conan --version 2>&1 | Select-Object -First 1
	}
 else { $null }
    
	"Ninja"  = if (Test-Tool "ninja") { 
		ninja --version 2>&1
	}
 else { $null }
}

foreach ($tool in $tools.Keys) {
	if ($tools[$tool]) {
		Write-Host "  ✓ $tool $($tools[$tool])" -ForegroundColor Green
	}
 else {
		Write-Host "  ✗ $tool (not found)" -ForegroundColor Red
	}
}

# ============================================================================
# Install missing tools
# ============================================================================
if (-not $Force) {
	$response = Read-Host "`nInstall missing tools? (Y/N)"
	if ($response -notmatch "^[Yy]$") {
		Write-Host "Setup cancelled." -ForegroundColor Yellow
		exit 0
	}
}

# Install Git if missing
if (-not $tools.Git) {
	Install-Tool -Name "Git" `
		-Url "https://github.com/git-for-windows/git/releases/latest/download/Git-64-bit.exe" `
		-InstallerArgs "/VERYSILENT /NORESTART /NOCANCEL /SP-" `
		-TestCommand "git"
}

# Install CMake if missing or version < 3.28
$cmakeVersionOk = $false
if ($tools.CMake) {
	$version = [Version]$tools.CMake
	$required = [Version]"3.28.0"
	if ($version -ge $required) {
		$cmakeVersionOk = $true
		Write-Host "`n✓ CMake version $version meets requirement (3.28+)" -ForegroundColor Green
	}
 else {
		Write-Host "`n✗ CMake version $version is too old (need 3.28+)" -ForegroundColor Red
	}
}

if (-not $tools.CMake -or (-not $cmakeVersionOk -and $Force)) {
	Install-Tool -Name "CMake" `
		-Url "https://github.com/Kitware/CMake/releases/download/v3.28.0/cmake-3.28.0-windows-x86_64.msi" `
		-InstallerArgs "/quiet /norestart" `
		-TestCommand "cmake"
}

# Install Python if missing (needed for Conan)
if (-not $tools.Python) {
	Write-Host "`nInstalling Python (required for Conan)..." -ForegroundColor Yellow
    
	$pythonUrl = "https://www.python.org/ftp/python/3.11.9/python-3.11.9-amd64.exe"
	$tempFile = Join-Path $env:TEMP "python-installer.exe"
    
	try {
		Invoke-WebRequest -Uri $pythonUrl -OutFile $tempFile
		Start-Process $tempFile -ArgumentList "/quiet InstallAllUsers=1 PrependPath=1" -Wait -NoNewWindow
		Remove-Item $tempFile -Force
        
		# Refresh PATH
		$env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
		Start-Sleep -Seconds 3
        
		if (Test-Tool "python") {
			Write-Host "  ✓ Python installed" -ForegroundColor Green
		}
	}
 catch {
		Write-Host "  ✗ Python installation failed: $_" -ForegroundColor Red
	}
}

# Install Conan if missing
if ($tools.Python -and (-not $tools.Conan)) {
	Write-Host "`nInstalling Conan via pip..." -ForegroundColor Yellow
    
	try {
		python -m pip install --upgrade pip
		python -m pip install conan
        
		if (Test-Tool "conan") {
			Write-Host "  ✓ Conan installed" -ForegroundColor Green
		}
	}
 catch {
		Write-Host "  ✗ Conan installation failed: $_" -ForegroundColor Red
	}
}

# Install Ninja if missing
if (-not $tools.Ninja) {
	Write-Host "`nInstalling Ninja..." -ForegroundColor Yellow
    
	$ninjaUrl = "https://github.com/ninja-build/ninja/releases/download/v1.12.1/ninja-win.zip"
	$tempFile = Join-Path $env:TEMP "ninja.zip"
	$installDir = Join-Path $env:LOCALAPPDATA "Programs\Ninja"
    
	try {
		Invoke-WebRequest -Uri $ninjaUrl -OutFile $tempFile
        
		# Create directory and extract
		New-Item -ItemType Directory -Path $installDir -Force | Out-Null
		Expand-Archive -Path $tempFile -DestinationPath $installDir -Force
		Remove-Item $tempFile -Force
        
		# Add to PATH
		$env:Path += ";$installDir"
        
		if (Test-Tool "ninja") {
			Write-Host "  ✓ Ninja installed to $installDir" -ForegroundColor Green
		}
	}
 catch {
		Write-Host "  ✗ Ninja installation failed: $_" -ForegroundColor Red
	}
}

# ============================================================================
# Final verification
# ============================================================================
Write-Host "`n" + ("=" * 40) -ForegroundColor Cyan
Write-Host "SETUP COMPLETE" -ForegroundColor Cyan
Write-Host "=" * 40 -ForegroundColor Cyan

Write-Host "`nTools status:" -ForegroundColor Gray
$allGood = $true

foreach ($tool in @("git", "cmake", "python", "conan", "ninja")) {
	if (Test-Tool $tool) {
		Write-Host "  ✓ $tool" -ForegroundColor Green
	}
 else {
		Write-Host "  ✗ $tool" -ForegroundColor Red
		$allGood = $false
	}
}

if ($allGood) {
	Write-Host "`nAll tools installed successfully!" -ForegroundColor Green
}
else {
	Write-Host "`nSome tools failed to install." -ForegroundColor Yellow
	Write-Host "Run this script again or install manually." -ForegroundColor Gray
}

Write-Host "`n" + ("=" * 40) -ForegroundColor Cyan