[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$ArtifactDirectory,
    [Parameter(Mandatory = $true)][ValidatePattern('^\d+\.\d+\.\d+$')][string]$Version,
    [switch]$RunInstallerSmokeTest
)
$ErrorActionPreference = 'Stop'
$artifacts = (Resolve-Path -LiteralPath $ArtifactDirectory).Path
$portableName = "leomoon-cpu-v-$Version-windows-x86-portable.zip"
$installerName = "leomoon-cpu-v-$Version-windows-x86-setup.exe"
$expected = @($portableName, $installerName, 'release-manifest.json', 'SHA256SUMS') | Sort-Object
$actual = @(Get-ChildItem -LiteralPath $artifacts -Force | Select-Object -ExpandProperty Name | Sort-Object)
if (($expected -join "`n") -ne ($actual -join "`n")) { throw 'Artifact directory must contain exactly the expected four files.' }
$entries = @(Get-Content -LiteralPath (Join-Path $artifacts 'SHA256SUMS'))
if ($entries.Count -ne 3) { throw 'SHA256SUMS must contain three entries.' }
$expectedChecksums = @($portableName, $installerName, 'release-manifest.json') | Sort-Object
$names = @()
foreach ($line in $entries) {
    if ($line -notmatch '^([0-9a-f]{64}) \*(.+)$') { throw 'Invalid checksum entry.' }
    $hash = $Matches[1]; $name = $Matches[2]
    if ($name -notin $expectedChecksums) { throw "Unexpected checksum target: $name" }
    $names += $name
    if ((Get-FileHash -LiteralPath (Join-Path $artifacts $name) -Algorithm SHA256).Hash.ToLowerInvariant() -ne $hash) { throw "Checksum mismatch: $name" }
}
if ((($names | Sort-Object) -join "`n") -ne ($expectedChecksums -join "`n")) { throw 'Checksum file does not list each expected artifact exactly once.' }
$manifest = Get-Content -LiteralPath (Join-Path $artifacts 'release-manifest.json') -Raw | ConvertFrom-Json
if ($manifest.application -ne 'LeoMoon CPU-V' -or $manifest.version -ne $Version -or $manifest.fileVersion -ne "$Version.0" -or $manifest.platform -ne 'windows' -or $manifest.architecture -ne 'x86') { throw 'Invalid manifest metadata.' }
$manifestNames = (@($manifest.artifacts) | Sort-Object) -join "`n"
$expectedManifestNames = (@($portableName, $installerName) | Sort-Object) -join "`n"
if ($manifestNames -ne $expectedManifestNames) { throw 'Invalid manifest artifact list.' }
$installer = Join-Path $artifacts $installerName
$installerInfo = [Diagnostics.FileVersionInfo]::GetVersionInfo($installer)
if ([version]$installerInfo.FileVersion -ne [version]"$Version.0" -or [version]$installerInfo.ProductVersion -ne [version]"$Version.0") { throw 'Installer version does not match.' }

function Assert-Application([string]$Path) {
    $bytes = [IO.File]::ReadAllBytes($Path)
    if ($bytes.Length -lt 64 -or $bytes[0] -ne 0x4d -or $bytes[1] -ne 0x5a) { throw 'Application is not a PE executable.' }
    $offset = [BitConverter]::ToInt32($bytes, 60)
    if ($offset -lt 0 -or $offset + 6 -gt $bytes.Length -or [BitConverter]::ToUInt32($bytes, $offset) -ne 0x4550 -or [BitConverter]::ToUInt16($bytes, $offset + 4) -ne 0x014c) { throw 'Application is not an x86 PE.' }
    $info = [Diagnostics.FileVersionInfo]::GetVersionInfo($Path)
    if ($info.FileVersion -ne "$Version.0" -or $info.ProductVersion -ne "$Version.0") { throw 'Application version does not match.' }
}

function Invoke-Installer([string]$Path, [string[]]$Arguments) {
    $process = Start-Process -FilePath $Path -ArgumentList $Arguments -WindowStyle Hidden -PassThru
    if (-not $process.WaitForExit(120000)) { $process.Kill(); throw 'Installer process timed out.' }
    if ($process.ExitCode -ne 0) { throw "Installer process failed: $($process.ExitCode)" }
}

$temporaryRoot = Join-Path ([IO.Path]::GetTempPath()) ("cpu-v-package-test-" + [guid]::NewGuid().ToString('N'))
$installDir = Join-Path $temporaryRoot 'installed'
$uninstaller = Join-Path $installDir 'unins000.exe'
$installed = $false
$installAttempted = $false
try {
    New-Item -ItemType Directory -Path $temporaryRoot | Out-Null
    Add-Type -AssemblyName System.IO.Compression
    Add-Type -AssemblyName System.IO.Compression.FileSystem
    $zip = [IO.Compression.ZipFile]::OpenRead((Join-Path $artifacts $portableName))
    try {
        if ($zip.Entries.Count -ne 1 -or $zip.Entries[0].FullName -ne 'LeoMoon CPU-V.exe') { throw 'Portable ZIP must contain only LeoMoon CPU-V.exe.' }
        $extracted = Join-Path $temporaryRoot 'LeoMoon CPU-V.exe'
        [IO.Compression.ZipFileExtensions]::ExtractToFile($zip.Entries[0], $extracted)
    } finally { $zip.Dispose() }
    Assert-Application $extracted
    $signature = Get-AuthenticodeSignature -LiteralPath $extracted
    if ([bool]$manifest.signed -ne ($null -ne $signature.SignerCertificate)) { throw 'Manifest signing status does not match the portable application.' }
    if ($RunInstallerSmokeTest) {
        $uninstallKey = 'Software\Microsoft\Windows\CurrentVersion\Uninstall\{86F463A8-97B6-4083-85A7-B2C8F6E8F5AD}_is1'
        foreach ($hive in @('HKCU:', 'HKLM:')) {
            if (Test-Path -LiteralPath (Join-Path $hive $uninstallKey)) { throw 'An existing CPU-V installation was found; refusing to overwrite it.' }
        }
        if (Test-Path -LiteralPath 'HKLM:\Software\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\{86F463A8-97B6-4083-85A7-B2C8F6E8F5AD}_is1') { throw 'An existing CPU-V installation was found; refusing to overwrite it.' }
        if (Get-Process -Name 'LeoMoon CPU-V' -ErrorAction SilentlyContinue) { throw 'CPU-V is already running.' }
        $installAttempted = $true
        Invoke-Installer $installer @('/SP-', '/VERYSILENT', '/SUPPRESSMSGBOXES', '/NORESTART', '/NOICONS', "/DIR=`"$installDir`"")
        $installed = $true
        $installedExe = Join-Path $installDir 'LeoMoon CPU-V.exe'
        if (-not (Test-Path -LiteralPath $installedExe -PathType Leaf) -or -not (Test-Path -LiteralPath $uninstaller -PathType Leaf)) { throw 'Installation did not produce the application and uninstaller.' }
        $unexpected = @(Get-ChildItem -LiteralPath $installDir -File -Recurse | Where-Object { $_.Extension -eq '.sys' -or $_.Name -ieq 'havtool.exe' -or $_.Name -ieq 'detecthav.sys' })
        if ($unexpected.Count -ne 0) { throw 'Installation contains an obsolete virtualization helper or driver.' }
        Assert-Application $installedExe
        if (Get-Process -Name 'LeoMoon CPU-V' -ErrorAction SilentlyContinue) { throw 'Installer unexpectedly launched CPU-V.' }
        Invoke-Installer $uninstaller @('/VERYSILENT', '/SUPPRESSMSGBOXES', '/NORESTART')
        $installed = $false
        $installAttempted = $false
        if (Test-Path -LiteralPath $installedExe) { throw 'Uninstall did not remove the application.' }
        if (Test-Path -LiteralPath (Join-Path 'HKCU:' $uninstallKey)) { throw 'Uninstall left its registry entry.' }
    }
} finally {
    if ($installAttempted -and (Test-Path -LiteralPath $uninstaller -PathType Leaf)) {
        try { Invoke-Installer $uninstaller @('/VERYSILENT', '/SUPPRESSMSGBOXES', '/NORESTART'); $installed = $false } catch { $installed = $true; Write-Warning "Cleanup uninstall failed; files remain at ${installDir}: $($_.Exception.Message)" }
    }
    if (-not $installed -and (Test-Path -LiteralPath $temporaryRoot)) { Remove-Item -LiteralPath $temporaryRoot -Recurse -Force -ErrorAction SilentlyContinue }
}
Write-Host "Verified Windows artifacts for version $Version."
