# update-module-version.ps1
# Sets the module's version in its .fsx from one number.
#
# Usage:  powershell -File scripts\update-module-version.ps1 -Version 27.0.1
#   or:   scripts\update-module-version.bat 27.0.1
#   or:   scripts\build-module.bat 27.0.1   (runs this first, then builds)
#
# 27.0.1 becomes three nodes at the end of the .fsx:
#   release          27.0
#   revision         .1
#   flexsim release  27.0
# If a node is missing it is added. If it exists, its value is updated.
#
# This only edits the .fsx. FlexSim loads the .t file, so afterwards open
# FlexSim and use File > Save Defaults to regenerate the .t.

[CmdletBinding()]
param(
    [Parameter(Mandatory)] [string] $Version
)

$ErrorActionPreference = 'Stop'
trap { Write-Host ''; Write-Host "Could not set version: $($_.Exception.Message)" -ForegroundColor Red; exit 1 }

if ($Version -notmatch '^(\d+)\.(\d+)\.(\d+)$') {
    throw "Version '$Version' must be X.Y.Z, for example 27.0.1."
}
$release  = "$($Matches[1]).$($Matches[2])"
$revision = ".$($Matches[3])"

$moduleRoot = Split-Path -Parent $PSScriptRoot
$fsx = Get-ChildItem -Path $moduleRoot -Filter '*.fsx' -File | Select-Object -First 1
if (-not $fsx) { throw "No .fsx file found in $moduleRoot." }

$text = [IO.File]::ReadAllText($fsx.FullName)
$eol  = if ($text.Contains("`r`n")) { "`r`n" } else { "`n" }

$wanted = [ordered]@{
    'release'         = $release
    'revision'        = $revision
    'flexsim release' = $release
}

$updated = $text
$toAdd = @()
foreach ($nodeName in $wanted.Keys) {
    $value   = $wanted[$nodeName]
    $pattern = "(<name>$([regex]::Escape($nodeName))</name><data>)([^<]*)(</data>)"
    $count   = [regex]::Matches($updated, $pattern).Count
    if ($count -gt 1) {
        throw "Found $count '$nodeName' nodes in $($fsx.Name). Expected at most one."
    } elseif ($count -eq 1) {
        $updated = [regex]::Replace($updated, $pattern, { param($m) $m.Groups[1].Value + $value + $m.Groups[3].Value })
    } else {
        $toAdd += " <node f=`"42`" dt=`"2`"><name>$nodeName</name><data>$value</data></node>"
    }
}

if ($toAdd.Count -gt 0) {
    # New nodes go last inside the module's root node, like other FlexSim modules.
    $closing = '</node></flexsim-tree>'
    $at = $updated.LastIndexOf($closing)
    if ($at -lt 0 -or $updated.Substring($at).TrimEnd() -ne $closing) {
        throw "Could not find the end of $($fsx.Name) ('$closing'), so nothing was changed."
    }
    $updated = $updated.Substring(0, $at) + (($toAdd -join $eol) + $eol) + $updated.Substring($at)
}

if ($updated -eq $text) {
    Write-Host "$($fsx.Name) already has version $Version. No change."
} else {
    [IO.File]::WriteAllText($fsx.FullName, $updated, (New-Object Text.UTF8Encoding($false)))
    Write-Host "$($fsx.Name): release=$release revision=$revision 'flexsim release'=$release"
    if ($toAdd.Count -gt 0) { Write-Host "Added $($toAdd.Count) missing node(s)." }
}
Write-Host "Next: open FlexSim and use File > Save Defaults to regenerate the .t file."
