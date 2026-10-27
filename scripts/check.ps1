[CmdletBinding()]
param(
    [Parameter(Mandatory = $true)][string]$ToolchainDirectory
)
$ErrorActionPreference = 'Stop'
$root = Split-Path -Parent $PSScriptRoot
$toolchain = (Resolve-Path -LiteralPath $ToolchainDirectory).Path
$checker = Join-Path $toolchain 'Au3Check.exe'
$autoit = Join-Path $toolchain 'AutoIt3.exe'
foreach ($path in @($checker, $autoit, (Join-Path $toolchain 'Include'))) {
    if (-not (Test-Path -LiteralPath $path)) { throw "Required AutoIt tool not found: $path" }
}
$targets = @('src\LeoMoon CPU-V.au3', 'tests\TestRunner.au3', 'tests\VirtualizationResultTests.au3', 'tests\LocalizationTests.au3', 'tests\FixtureTests.au3', 'tests\DesktopSmoke.au3')
foreach ($target in $targets) {
    $path = Join-Path $root $target
    & $checker -q -d -I (Join-Path $toolchain 'Include') -I (Join-Path $root 'src') $path
    if ($LASTEXITCODE -ne 0) { throw "Au3Check failed for $target with exit code $LASTEXITCODE" }
}
$git = Get-Command git.exe -CommandType Application -ErrorAction SilentlyContinue | Select-Object -First 1
if ($git) { $gitPath = $git.Source } else { $gitPath = Join-Path $env:ProgramFiles 'Git\cmd\git.exe' }
if (-not (Test-Path -LiteralPath $gitPath -PathType Leaf)) { throw 'Git was not found.' }
$before = @(& $gitPath -C $root status --porcelain)
if ($LASTEXITCODE -ne 0) { throw 'Unable to inspect worktree before tests.' }
$start = [System.Diagnostics.ProcessStartInfo]::new()
$start.FileName = $autoit
$start.Arguments = '/ErrorStdOut "{0}"' -f (Join-Path $root 'tests\TestRunner.au3')
$start.WorkingDirectory = $root
$start.UseShellExecute = $false
$start.CreateNoWindow = $true
$start.RedirectStandardOutput = $true
$start.RedirectStandardError = $true
$process = [System.Diagnostics.Process]::Start($start)
$stdout = $process.StandardOutput.ReadToEnd()
$stderr = $process.StandardError.ReadToEnd()
$process.WaitForExit()
if ($stdout) { Write-Host $stdout.TrimEnd() }
if ($stderr) { Write-Host $stderr.TrimEnd() }
if ($process.ExitCode -ne 0) { throw "Regression tests failed with exit code $($process.ExitCode)" }
$after = @(& $gitPath -C $root status --porcelain)
if ($LASTEXITCODE -ne 0 -or ($before -join "`n") -ne ($after -join "`n")) { throw 'Regression tests changed the worktree or its status could not be read.' }
Write-Host 'Au3Check and noninteractive tests passed; worktree unchanged.'
