[CmdletBinding()]
param(
    [string]$AutoItExe,
    [string]$AutoIt3Wrapper
)

$ErrorActionPreference = 'Stop'
$repositoryRoot = Split-Path -Parent $PSScriptRoot
$buildScript = Join-Path $PSScriptRoot 'build-local.ps1'
$outputFile = Join-Path $repositoryRoot 'build\LeoMoon CPU-V.exe'

& $buildScript -AutoItExe $AutoItExe -AutoIt3Wrapper $AutoIt3Wrapper

if (-not (Test-Path -LiteralPath $outputFile -PathType Leaf)) {
    throw "Expected build output was not created: $outputFile"
}

$bytes = [System.IO.File]::ReadAllBytes($outputFile)
if ($bytes.Length -lt 64 -or $bytes[0] -ne 0x4D -or $bytes[1] -ne 0x5A) {
    throw 'Build output is not a valid PE executable.'
}

$peOffset = [BitConverter]::ToInt32($bytes, 0x3C)
if ($peOffset -lt 0 -or $peOffset + 6 -ge $bytes.Length -or [Text.Encoding]::ASCII.GetString($bytes, $peOffset, 4) -ne 'PE' + [char]0 + [char]0) {
    throw 'Build output does not contain a valid PE signature.'
}

$machine = [BitConverter]::ToUInt16($bytes, $peOffset + 4)
if ($machine -ne 0x014C) {
    throw ('Expected an x86 PE (0x014c); found 0x{0:x4}.' -f $machine)
}

foreach ($resource in @('src/resources/CPU-V.dll', 'src/resources/CPU-V.ini', 'src/resources/stripe.jpg', 'src/resources/icon.ico')) {
    $path = Join-Path $repositoryRoot $resource
    if (-not (Test-Path -LiteralPath $path -PathType Leaf)) {
        throw "Baseline resource is missing: $resource"
    }
}

Write-Host 'Baseline build is an x86 PE and all source resources are present.'
Write-Host 'Launch build\LeoMoon CPU-V.exe to complete the interactive GUI resource-loading check.'
