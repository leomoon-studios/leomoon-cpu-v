[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][ValidatePattern('^\d+\.\d+\.\d+$')][string]$Version,
    [Parameter(Mandatory = $true)][string]$AutoItDirectory,
    [Parameter(Mandatory = $true)][string]$AutoIt3WrapperPath
)
$ErrorActionPreference = 'Stop'
foreach ($component in $Version.Split('.')) {
    $value = 0
    if (-not [int]::TryParse($component, [ref]$value) -or $value -gt 65535) { throw 'Each version component must be between 0 and 65535.' }
}
$root = Split-Path -Parent $PSScriptRoot
$autoit = Join-Path (Resolve-Path -LiteralPath $AutoItDirectory).Path 'AutoIt3.exe'
$wrapper = (Resolve-Path -LiteralPath $AutoIt3WrapperPath).Path
$output = Join-Path $root 'build\windows\output\LeoMoon CPU-V.exe'
if (-not (Test-Path -LiteralPath $autoit -PathType Leaf)) { throw "AutoIt3.exe not found: $autoit" }
if (Test-Path -LiteralPath $output -PathType Leaf) { Remove-Item -LiteralPath $output -Force }
& (Join-Path $PSScriptRoot 'build-local.ps1') -AutoItExe $autoit -AutoIt3Wrapper $wrapper -Version $Version -OutputFile $output
$versionInfo = [Diagnostics.FileVersionInfo]::GetVersionInfo($output)
if ($versionInfo.FileVersion -ne "$Version.0" -or $versionInfo.ProductVersion -ne "$Version.0") { throw 'Compiled file and product versions do not match the requested version.' }
$bytes = [IO.File]::ReadAllBytes($output)
if ($bytes.Length -lt 64 -or $bytes[0] -ne 0x4d -or $bytes[1] -ne 0x5a) { throw 'Output is not a PE executable.' }
$offset = [BitConverter]::ToInt32($bytes, 0x3c)
if ($offset -lt 0 -or $offset + 6 -gt $bytes.Length -or [BitConverter]::ToUInt32($bytes, $offset) -ne 0x4550 -or [BitConverter]::ToUInt16($bytes, $offset + 4) -ne 0x014c) { throw 'Output is not an x86 PE executable.' }
Add-Type -AssemblyName System.Drawing
$icon = [Drawing.Icon]::ExtractAssociatedIcon($output)
if (-not $icon) { throw 'The compiled application icon could not be loaded.' }
$icon.Dispose()
if (-not ('CpuVBuildResources' -as [type])) {
    Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;
public static class CpuVBuildResources {
    [DllImport("kernel32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
    public static extern IntPtr LoadLibraryEx(string path, IntPtr reserved, uint flags);
    [DllImport("kernel32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
    public static extern IntPtr FindResource(IntPtr module, string name, IntPtr type);
    [DllImport("kernel32.dll")]
    public static extern bool FreeLibrary(IntPtr module);
}
'@
}
$module = [CpuVBuildResources]::LoadLibraryEx($output, [IntPtr]::Zero, 2)
if ($module -eq [IntPtr]::Zero) { throw 'Could not inspect compiled PE resources.' }
try {
    if ([CpuVBuildResources]::FindResource($module, 'stripe', [IntPtr]10) -eq [IntPtr]::Zero) { throw 'Compiled stripe resource is missing.' }
} finally { [void][CpuVBuildResources]::FreeLibrary($module) }
Write-Host "Built x86 application $output with version $Version.0."
