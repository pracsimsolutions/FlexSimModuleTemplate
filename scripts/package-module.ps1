# package-module.ps1
# Zips the module's DLL, its .t file, and anything listed in package-list.txt.
# Output: dist\<ModuleName>.zip, with a top-level <ModuleName>\ folder inside,
# so the recipient can unzip it straight into their FlexSim modules folder.
#
# Usage:  scripts\package-module.bat
#    or:  powershell -File scripts\package-module.ps1

[CmdletBinding()]
param(
    [string] $ListFile = '',
    [string] $OutDir   = ''
)

$ErrorActionPreference = 'Stop'
trap { Write-Host ''; Write-Host "Could not package: $($_.Exception.Message)" -ForegroundColor Red; exit 1 }
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem

$moduleRoot = (Resolve-Path (Split-Path -Parent $PSScriptRoot)).Path
if (-not $OutDir)   { $OutDir   = Join-Path $moduleRoot 'dist' }
if (-not $ListFile) { $ListFile = Join-Path $PSScriptRoot 'package-list.txt' }

# Module name = the .fsx file name
$fsx = Get-ChildItem -Path $moduleRoot -Filter '*.fsx' -File | Select-Object -First 1
if (-not $fsx) { throw "No .fsx file found in $moduleRoot, so the module name is unknown." }
$name = $fsx.BaseName

# The DLL and .t are always included, and must exist
$required = @("$name.dll", "$name.t")
$missingRequired = $required | Where-Object { -not (Test-Path -LiteralPath (Join-Path $moduleRoot $_) -PathType Leaf) }
if ($missingRequired) {
    $msg = "Missing: $($missingRequired -join ', ')`n"
    if ($missingRequired -contains "$name.dll") { $msg += "  - $name.dll is made by building the module (scripts\build-module.bat).`n" }
    if ($missingRequired -contains "$name.t")   { $msg += "  - $name.t is made in FlexSim with File > Save Defaults.`n" }
    throw $msg
}

# Collect files: key = path relative to the module folder
$files = [ordered]@{}
function Add-File([string] $fullPath) {
    $rel = $fullPath.Substring($moduleRoot.Length).TrimStart('\', '/')
    $files[$rel.ToLowerInvariant()] = $rel
}

foreach ($r in $required) { Add-File (Join-Path $moduleRoot $r) }

$problems = @()
if (Test-Path -LiteralPath $ListFile) {
    $lineNo = 0
    foreach ($raw in Get-Content -LiteralPath $ListFile) {
        $lineNo++
        $line = $raw.Trim()
        if ($line -eq '' -or $line.StartsWith('#')) { continue }

        if ([IO.Path]::IsPathRooted($line) -or $line -match '(^|[\\/])\.\.([\\/]|$)') {
            $problems += "package-list.txt line ${lineNo}: '$line' must be a path inside the module folder."
            continue
        }

        $found = @(Get-ChildItem -Path (Join-Path $moduleRoot $line) -ErrorAction SilentlyContinue)
        if ($found.Count -eq 0) {
            $problems += "package-list.txt line ${lineNo}: '$line' was not found."
            continue
        }
        foreach ($m in $found) {
            if ($m.PSIsContainer) {
                # a folder: everything inside it, including nested folders
                Get-ChildItem -LiteralPath $m.FullName -Recurse -File | ForEach-Object { Add-File $_.FullName }
            } else {
                Add-File $m.FullName
            }
        }
    }
} else {
    Write-Host "No package-list.txt found, packaging the DLL and .t only."
}

if ($problems) { throw ($problems -join "`n") }

# Build the zip. Entry names use forward slashes and start with <ModuleName>/
New-Item -ItemType Directory -Force -Path $OutDir | Out-Null
$zipPath = Join-Path $OutDir "$name.zip"
if (Test-Path -LiteralPath $zipPath) { Remove-Item -LiteralPath $zipPath -Force }

$zip = [IO.Compression.ZipFile]::Open($zipPath, [IO.Compression.ZipArchiveMode]::Create)
try {
    foreach ($rel in $files.Values) {
        $entryName = "$name/" + ($rel -replace '\\', '/')
        [void][IO.Compression.ZipFileExtensions]::CreateEntryFromFile(
            $zip, (Join-Path $moduleRoot $rel), $entryName, [IO.Compression.CompressionLevel]::Optimal)
        Write-Host "  + $entryName"
    }
} finally {
    $zip.Dispose()
}

Write-Host ""
Write-Host "Packaged $($files.Count) file(s) into $zipPath"
