# Set UTF-8 encoding for proper emoji display
$OutputEncoding = [System.Text.Encoding]::UTF8
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# Function to check if a command exists
function Test-Command {
    param([string]$Command)
    try {
        Get-Command $Command -ErrorAction Stop | Out-Null
        return $true
    }
    catch {
        return $false
    }
}

# Check for a C compiler
Write-Host "Checking for a C compiler..." -ForegroundColor Cyan

$compilerFound = $false
if (Test-Command "gcc") {
    Write-Host "Found GCC." -ForegroundColor Green
    $compilerFound = $true
}
elseif (Test-Command "clang") {
    Write-Host "Found Clang." -ForegroundColor Green
    $compilerFound = $true
}
elseif (Test-Command "zig") {
    Write-Host "Found Zig." -ForegroundColor Green
    $compilerFound = $true
}

if (-not $compilerFound) {
    Write-Host "Error: No C compiler found (gcc, clang, or zig is required)." -ForegroundColor Red
    
    # Check for package managers
    $hasChoco = Test-Command "choco"
    $hasScoop = Test-Command "scoop"
    
    if ($hasChoco) {
        Write-Host "Chocolatey is installed." -ForegroundColor Yellow
        Write-Host "Please install Zig using Chocolatey: choco install zig" -ForegroundColor Yellow
    }
    elseif ($hasScoop) {
        Write-Host "Scoop is installed." -ForegroundColor Yellow
        Write-Host "Please install GCC using Scoop: scoop install gcc" -ForegroundColor Yellow
    }
    else {
        Write-Host "Chocolatey is not installed." -ForegroundColor Yellow
        Write-Host "Scoop is not installed." -ForegroundColor Yellow
        Write-Host "Neither Chocolatey nor Scoop is installed." -ForegroundColor Red
        Write-Host "Visit: https://chocolatey.org/install or https://scoop.sh/" -ForegroundColor Yellow
    }
    
    Read-Host "Press Enter to exit"
    exit
}

# Check for Git
Write-Host "Checking for Git..." -ForegroundColor Cyan
if (-not (Test-Command "git")) {
    Write-Host "Error: Git is not installed or not in PATH." -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit
}
Write-Host "Git found." -ForegroundColor Green

# Check Neovim version
Write-Host "Checking Neovim version..." -ForegroundColor Cyan
try {
    $nvimOutput = & nvim --version 2>$null
    $versionLine = $nvimOutput | Where-Object { $_ -match "NVIM v" } | Select-Object -First 1
    
    if (-not $versionLine) {
        throw "Neovim version not found"
    }
    
    # Extract version number
    if ($versionLine -match "NVIM v(\d+\.\d+\.\d+)") {
        $nvimVersion = $matches[1]
        $versionParts = $nvimVersion -split '\.'
        $major = [int]$versionParts[0]
        $minor = [int]$versionParts[1]
        
        # Check if version is 0.11.0 or higher
        if ($major -gt 0 -or ($major -eq 0 -and $minor -ge 11)) {
            Write-Host "Neovim version $nvimVersion found." -ForegroundColor Green
        }
        else {
            Write-Host "Error: Neovim version 0.11.0 or higher is required. Found v$nvimVersion" -ForegroundColor Red
            Read-Host "Press Enter to exit"
            exit
        }
    }
    else {
        throw "Could not parse Neovim version"
    }
}
catch {
    Write-Host "Error: Neovim not found in PATH." -ForegroundColor Red
    Read-Host "Press Enter to exit"
    exit
}

# Set paths
$nvimDir = "$env:USERPROFILE\AppData\Local\nvim"
$backupDir = "$env:USERPROFILE\AppData\Local\nvim.bak"

# Backup existing config
Write-Host "Backing up Neovim config..." -ForegroundColor Cyan
if (Test-Path $backupDir) {
    Write-Host "Old backup found, deleting..." -ForegroundColor Yellow
    Remove-Item $backupDir -Recurse -Force
}

if (Test-Path $nvimDir) {
    Copy-Item $nvimDir $backupDir -Recurse -Force
}

# Clear existing config
Write-Host "Clearing current Neovim config..." -ForegroundColor Cyan
if (Test-Path $nvimDir) {
    Remove-Item $nvimDir -Recurse -Force
}

# Clone new config
Write-Host "Cloning ZaeNvim repo..." -ForegroundColor Cyan
git clone https://github.com/Zaetrix/ZaeNvim $nvimDir

# Remove unnecessary files
Write-Host "Removing README.md, LICENSE, and .git directory..." -ForegroundColor Cyan
$readmePath = Join-Path $nvimDir "README.md"
$licensePath = Join-Path $nvimDir "LICENSE"
$gitPath = Join-Path $nvimDir ".git"

if (Test-Path $readmePath) { Remove-Item $readmePath -Force }
if (Test-Path $licensePath) { Remove-Item $licensePath -Force }
if (Test-Path $gitPath) { Remove-Item $gitPath -Recurse -Force }

Write-Host "ZaeNvim installed successfully!" -ForegroundColor Green
Write-Host "Run Neovim to complete plugin installation." -ForegroundColor Yellow

Read-Host "Press Enter to exit"