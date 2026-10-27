[CmdletBinding()]
param(
    [string]$AutoItExe,
    [string]$AutoIt3Wrapper
)

$ErrorActionPreference = 'Stop'

function Resolve-ExistingPath {
    param(
        [string]$Path,
        [string]$Description
    )

    if (-not $Path) {
        throw "$Description was not supplied."
    }

    $resolved = Resolve-Path -LiteralPath $Path -ErrorAction Stop
    return $resolved.Path
}

function Find-AutoItExe {
    param([string]$ExplicitPath)

    if ($ExplicitPath) {
        return Resolve-ExistingPath -Path $ExplicitPath -Description 'AutoIt3.exe'
    }

    $command = Get-Command AutoIt3.exe -CommandType Application -ErrorAction SilentlyContinue
    if ($command) {
        return $command.Source
    }

    throw 'AutoIt3.exe was not found on PATH. Install AutoIt or pass -AutoItExe.'
}

function Find-AutoIt3Wrapper {
    param(
        [string]$ExplicitPath,
        [string]$AutoItPath
    )

    if ($ExplicitPath) {
        return Resolve-ExistingPath -Path $ExplicitPath -Description 'AutoIt3Wrapper.au3'
    }

    $autoItDirectory = Split-Path -Parent $AutoItPath
    $candidates = @(
        (Join-Path $autoItDirectory 'SciTE\AutoIt3Wrapper\AutoIt3Wrapper.au3'),
        (Join-Path ${env:ProgramFiles(x86)} 'AutoIt3\SciTE\AutoIt3Wrapper\AutoIt3Wrapper.au3'),
        (Join-Path $env:ProgramFiles 'AutoIt3\SciTE\AutoIt3Wrapper\AutoIt3Wrapper.au3')
    ) | Where-Object { $_ -and (Test-Path -LiteralPath $_ -PathType Leaf) }

    if ($candidates.Count -gt 0) {
        return (Resolve-Path -LiteralPath $candidates[0]).Path
    }

    throw 'AutoIt3Wrapper.au3 was not found. Install SciTE4AutoIt3 or pass -AutoIt3Wrapper.'
}

function Invoke-OptionalSigning {
    param([string]$OutputFile)

    $certificateBase64 = [string]$env:CPU_V_SIGNING_CERTIFICATE_BASE64
    $certificatePassword = [string]$env:CPU_V_SIGNING_CERTIFICATE_PASSWORD
    $hasCertificate = -not [string]::IsNullOrWhiteSpace($certificateBase64)
    $hasPassword = -not [string]::IsNullOrWhiteSpace($certificatePassword)

    if (-not $hasCertificate -and -not $hasPassword) {
        Write-Host 'No signing secrets were supplied. Leaving build unsigned.'
        return
    }

    if (-not $hasCertificate -or -not $hasPassword) {
        throw 'CPU_V_SIGNING_CERTIFICATE_BASE64 and CPU_V_SIGNING_CERTIFICATE_PASSWORD must be supplied together.'
    }

    $signToolCommand = Get-Command signtool.exe -CommandType Application -ErrorAction SilentlyContinue
    if (-not $signToolCommand) {
        throw 'Signing secrets were supplied but signtool.exe was not found on PATH.'
    }

    $timestampUrl = if ($env:CPU_V_SIGNING_TIMESTAMP_URL) { $env:CPU_V_SIGNING_TIMESTAMP_URL } else { 'http://timestamp.digicert.com' }
    $certificatePath = Join-Path ([System.IO.Path]::GetTempPath()) ("cpu-v-signing-$([guid]::NewGuid().ToString('N')).pfx")
    try {
        [System.IO.File]::WriteAllBytes($certificatePath, [Convert]::FromBase64String($certificateBase64))
        & $signToolCommand.Source sign /fd SHA256 /d 'LeoMoon CPU-V' /du 'https://leomoon.com' /f $certificatePath /p $certificatePassword /tr $timestampUrl /td SHA256 $OutputFile
        if ($LASTEXITCODE -ne 0) {
            throw "Signing failed with exit code $LASTEXITCODE."
        }
    }
    finally {
        if (Test-Path -LiteralPath $certificatePath) {
            Remove-Item -LiteralPath $certificatePath -Force
        }
    }
}

$repositoryRoot = Split-Path -Parent $PSScriptRoot
$sourceDirectory = Join-Path $repositoryRoot 'src'
$outputFile = Join-Path $repositoryRoot 'build\LeoMoon CPU-V.exe'

$autoItPath = Find-AutoItExe -ExplicitPath $AutoItExe
$wrapperPath = Find-AutoIt3Wrapper -ExplicitPath $AutoIt3Wrapper -AutoItPath $autoItPath

New-Item -ItemType Directory -Path (Split-Path -Parent $outputFile) -Force | Out-Null
$stageDirectory = Join-Path (Split-Path -Parent $outputFile) ("stage-" + [guid]::NewGuid().ToString('N'))
try {
    Copy-Item -LiteralPath $sourceDirectory -Destination $stageDirectory -Recurse
    $appInfo = Get-Content -LiteralPath (Join-Path $stageDirectory 'core\AppInfo.au3') -Raw
    if ($appInfo -notmatch '(?m)^Global Const \$APP_TITLE = ''([^'']+)''[ \t]*\r?$') { throw 'Invalid application title in AppInfo.au3.' }
    $title = $Matches[1]
    if ($appInfo -notmatch '(?m)^Global Const \$APP_VERSION = ''(\d+\.\d+\.\d+)''[ \t]*\r?$') { throw 'Invalid application version in AppInfo.au3.' }
    $version = $Matches[1] + '.0'
    $sourceFile = Join-Path $stageDirectory 'LeoMoon CPU-V.au3'
    $source = Get-Content -LiteralPath $sourceFile -Raw
    $source = $source -replace '(?m)^#pragma compile\(ProductName, .+\)[ \t]*\r?$', "#pragma compile(ProductName, $title)"
    $source = $source -replace '(?m)^#pragma compile\(FileDescription, .+\)[ \t]*\r?$', "#pragma compile(FileDescription, $title)"
    $source = $source -replace '(?m)^#pragma compile\((FileVersion|ProductVersion), .+\)[ \t]*\r?$', "#pragma compile(`$1, $version)"
    $source = $source -replace '(?m)^#pragma compile\(Out, .+\)[ \t]*\r?$', "#pragma compile(Out, $outputFile)"
    [IO.File]::WriteAllText($sourceFile, $source, [Text.UTF8Encoding]::new($false))
    $arguments = '"{0}" /in "{1}"' -f $wrapperPath, $sourceFile
    $process = Start-Process -FilePath $autoItPath -ArgumentList $arguments -WorkingDirectory $stageDirectory -WindowStyle Hidden -Wait -PassThru
    if ($process.ExitCode -ne 0) {
        throw "AutoIt compilation failed with exit code $($process.ExitCode)."
    }
}
finally {
    if (Test-Path -LiteralPath $stageDirectory) { Remove-Item -LiteralPath $stageDirectory -Recurse -Force }
}

if (-not (Test-Path -LiteralPath $outputFile -PathType Leaf)) {
    throw "AutoIt reported success but did not create $outputFile."
}

Invoke-OptionalSigning -OutputFile $outputFile

Write-Host "Built $outputFile"
