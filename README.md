# LeoMoon CPU-V

LeoMoon CPU-V is a Windows utility that reports whether hardware virtualization is supported and enabled.

## Supported systems

CPU-V 3.0.0 supports Windows 8 and later. Earlier releases, including 2.0.5, supported Windows 7 and Vista. The application is compiled as a 32-bit executable and can run on 64-bit Windows.

## Virtualization results

CPU-V reports whether virtualization is enabled, disabled in firmware, unsupported, or unknown. An unknown result means Windows did not provide the information needed to determine the status. On systems with multiple processors, an unsupported result takes precedence, followed by unknown and disabled; all processors must report support and enabled firmware for the overall result to be enabled.

## Building and testing

Install the pinned AutoIt, SciTE4AutoIt3, and Inno Setup tools in an empty directory:

```powershell
.\scripts\install-build-tools.ps1 -ToolsDirectory "$PWD\build\tools"
.\scripts\check.ps1 -ToolchainDirectory "$PWD\build\tools\autoit-v3.3.18.0\install"
```

The checks run AutoIt syntax validation and noninteractive regression tests without opening the GUI or probing the host CPU. To build, pass the intended version as `-Version`, along with `-AutoItDirectory` and `-AutoIt3WrapperPath`, to `scripts/build-windows.ps1`. The build injects that version into the staged application and executable metadata; the source has no release version. The resulting x86 executable is written to `build\windows\output`.

GitHub Actions runs the same checks for pull requests and can be started manually using the **CI** workflow. It uses the pinned AutoIt toolchain on Windows Server 2022.

The **Build Windows packages** workflow runs when an exact `vX.Y.Z` tag is pushed, or manually with an `X.Y.Z` version. It runs checks before building, verifies the portable ZIP and installer, and uploads the packages, manifest, and checksums as a workflow artifact. As with HotKeyz, it does not publish a GitHub Release.

On an interactive Windows desktop, run the additional smoke test after building:

```powershell
AutoIt3.exe /ErrorStdOut .\tests\DesktopSmoke.au3 '.\build\windows\output\LeoMoon CPU-V.exe' normal '<build-version>'
```

The smoke test opens and closes CPU-V, checks its temporary resources, and saves a screenshot in `build\desktop-check.png` for visual inspection.

## Windows packages

`scripts/package-windows.ps1` creates a portable ZIP, a per-user Inno Setup installer, a release manifest, and `SHA256SUMS`. Pass the version, staged executable directory, an empty artifact directory, Inno Setup compiler path, release date, and commit. The script verifies the resulting artifacts. `scripts/verify-windows-package.ps1` can also run a silent install and uninstall test with `-RunInstallerSmokeTest`.

Builds are unsigned unless both optional signing credentials are supplied to the build environment. No signing credentials are required for an unsigned build.

## Third-party code

The vendored AutoIt resource helper and its attribution are described in [`src/resources/README.md`](src/resources/README.md).
