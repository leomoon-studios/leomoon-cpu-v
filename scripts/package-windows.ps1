[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][ValidatePattern('^\d+\.\d+\.\d+$')][string]$Version,
    [Parameter(Mandatory = $true)][string]$StageDirectory,
    [Parameter(Mandatory = $true)][string]$DistDirectory,
    [Parameter(Mandatory = $true)][string]$IsccPath,
    [Parameter(Mandatory = $true)][ValidatePattern('^\d{4}-\d{2}-\d{2}T')][string]$ReleaseDate,
    [Parameter(Mandatory = $true)][ValidatePattern('^[0-9a-fA-F]{7,64}$')][string]$Commit
)
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$stage = (Resolve-Path -LiteralPath $StageDirectory).Path
$iscc = (Resolve-Path -LiteralPath $IsccPath).Path
$application = Join-Path $stage 'LeoMoon CPU-V.exe'
if (-not (Test-Path -LiteralPath $application -PathType Leaf)) { throw 'StageDirectory must contain LeoMoon CPU-V.exe.' }
$metadata = [Diagnostics.FileVersionInfo]::GetVersionInfo($application)
if ($metadata.FileVersion -ne "$Version.0" -or $metadata.ProductVersion -ne "$Version.0") { throw 'Staged application version does not match the requested package version.' }
$dist = [IO.Path]::GetFullPath($DistDirectory)
if ($dist -eq [IO.Path]::GetPathRoot($dist) -or $dist -eq [IO.Path]::GetFullPath($root)) { throw 'Refusing to use a filesystem root or the repository as the artifact directory.' }
if ((Test-Path -LiteralPath $dist) -and @(Get-ChildItem -LiteralPath $dist -Force).Count -ne 0) { throw 'Artifact directory must be empty.' }
New-Item -ItemType Directory -Path $dist -Force | Out-Null
$portableName = "leomoon-cpu-v-$Version-windows-x86-portable.zip"
$installerName = "leomoon-cpu-v-$Version-windows-x86-setup.exe"
$portable = Join-Path $dist $portableName
$installer = Join-Path $dist $installerName
$manifestPath = Join-Path $dist 'release-manifest.json'
$checksums = Join-Path $dist 'SHA256SUMS'
Add-Type -AssemblyName System.IO.Compression
Add-Type -AssemblyName System.IO.Compression.FileSystem
$zip = [IO.Compression.ZipFile]::Open($portable, [IO.Compression.ZipArchiveMode]::Create)
try { [void][IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip, $application, 'LeoMoon CPU-V.exe', [IO.Compression.CompressionLevel]::Optimal) } finally { $zip.Dispose() }
$script = Join-Path $root 'packaging\windows\cpu-v.iss'
& $iscc '/Qp' "/DAppVersion=$Version" "/DAppFileVersion=$Version.0" "/DStageDir=$stage" "/DOutputDir=$dist" $script
if ($LASTEXITCODE -ne 0 -or -not (Test-Path -LiteralPath $installer -PathType Leaf)) { throw 'Inno Setup failed to create the installer.' }
$signature = Get-AuthenticodeSignature -LiteralPath $application
$manifest = [ordered]@{
    application = 'LeoMoon CPU-V'; version = $Version; fileVersion = "$Version.0"; releaseDate = $ReleaseDate
    commit = $Commit.ToLowerInvariant(); platform = 'windows'; architecture = 'x86'; signed = ($null -ne $signature.SignerCertificate)
    artifacts = @($portableName, $installerName)
}
[IO.File]::WriteAllText($manifestPath, (($manifest | ConvertTo-Json -Depth 3) + "`n"), [Text.UTF8Encoding]::new($false))
$lines = @($portable, $installer, $manifestPath) | Sort-Object { Split-Path -Leaf $_ } | ForEach-Object { '{0} *{1}' -f (Get-FileHash -LiteralPath $_ -Algorithm SHA256).Hash.ToLowerInvariant(), (Split-Path -Leaf $_) }
[IO.File]::WriteAllLines($checksums, [string[]]$lines, [Text.Encoding]::ASCII)
& (Join-Path $PSScriptRoot 'verify-windows-package.ps1') -ArtifactDirectory $dist -Version $Version
Write-Host "Windows artifacts are ready in $dist"
