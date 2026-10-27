# LeoMoon CPU-V

LeoMoon CPU-V is a small x86 Windows utility that reports whether hardware virtualization is supported and enabled.

## Support

The maintained baseline is version `v2.0.5`. The application entry point is [`src/LeoMoon CPU-V.au3`](src/LeoMoon%20CPU-V.au3). CPU-V supports Windows 8 and later; it rejects older Windows versions before extracting resources or checking hardware.

## Local build

Build on Windows with AutoIt installed and available as `AutoIt3.exe`:

```powershell
.\scripts\build-local.ps1
```

If AutoIt or AutoIt3Wrapper is installed elsewhere, pass explicit paths:

```powershell
.\scripts\build-local.ps1 -AutoItExe 'C:\Tools\AutoIt3\AutoIt3.exe' -AutoIt3Wrapper 'C:\Tools\AutoIt3\SciTE\AutoIt3Wrapper\AutoIt3Wrapper.au3'
```

The result is `build\LeoMoon CPU-V.exe`. Builds are unsigned unless the release workflow injects both optional GitHub secrets into `CPU_V_SIGNING_CERTIFICATE_BASE64` and `CPU_V_SIGNING_CERTIFICATE_PASSWORD`. When both values are present, the build signs the executable with `signtool.exe`; when neither is present, it continues unsigned. A partial signing configuration fails rather than silently producing an unexpected artifact. `CPU_V_SIGNING_TIMESTAMP_URL` may optionally override the default timestamp service.

No certificate, password file, signing path, or signing credential is stored in this repository. The later GitHub release workflow will map optional repository secrets to those environment variables and will not require them for a successful release.

## Baseline verification

On a clean Windows checkout, compile the program and run:

```powershell
.\scripts\verify-baseline.ps1
```

Then launch `build\LeoMoon CPU-V.exe` and confirm the window opens, the stripe banner renders, localized text loads, and the status icons appear. This interactive check is required because resource loading occurs inside the GUI.

Run the hardware-independent virtualization checks with AutoIt installed:

```powershell
AutoIt3.exe /ErrorStdOut .\tests\TestRunner.au3
```

The runner uses fixtures in `tests/fixtures/` and does not launch the GUI, query the host CPU, or extract a driver. It returns a nonzero exit code if a suite fails. On an interactive Windows desktop, run `AutoIt3.exe /ErrorStdOut .\tests\DesktopSmoke.au3` after building. The desktop check launches CPU-V, verifies its window and temporary resources, saves `build\desktop-check.png` for visual inspection, and closes it.

Virtualization is **enabled** when the processor reports support and firmware enables it, **disabled** when support is reported but firmware disables it, and **unsupported** when the processor reports no monitor-mode extensions. CPU-V shows an unknown result when required WMI values are missing or a query fails. For multiple processor records, unsupported takes precedence, followed by unknown, then disabled; enabled requires every processor to report support and enabled firmware. For individual features, a negative result takes precedence over unknown data. CPU-V displays a question mark when a result cannot be determined.

The application title and version are defined in `src/core/AppInfo.au3`. The local build stages the source and uses those values for the executable's title and version metadata as well as the runtime display.

## Bundled resource inventory

The hashes below are for the `v2.0.5` baseline before package changes. `CPU-V.ini` is UTF-16 LE and is intentionally treated as binary by Git.

| Resource | Purpose | Provenance and license status | SHA-256 |
| --- | --- | --- | --- |
| `src/resources/CPU-V.dll` | Icon resource DLL used by the GUI | Shared legacy LeoMoon asset with HotKeyz, tracked in CPU-V since `v2.0.3`; no separate license declaration in the repository | `62cce2c15b1b06e3f7cc89c6707b437b010163d93ece7d40c349103d097987fb` |
| `src/resources/CPU-V.ini` | Localized GUI strings | Shared legacy LeoMoon asset with HotKeyz, tracked in CPU-V since `v2.0.3`; no separate license declaration in the repository | `ba2267e8aa29108d63fd826e1fd3481bf905b4f1ec6f5de87ecce49378f8dc5b` |
| `src/resources/stripe.jpg` | Top banner image | Shared legacy LeoMoon asset with HotKeyz, tracked in CPU-V since `v2.0.3`; no separate license declaration in the repository | `f80e0cf83f4a3aa6b8f27fd3c226281771304cbd2e60256c8921af0dc029dd8d` |
| `src/resources/icon.ico` | Application executable and shortcut icon | Shared legacy LeoMoon asset with HotKeyz, tracked in CPU-V since `v2.0.3`; no separate license declaration in the repository | `82c2567264f20861d9657a05fa0ae3b368073bccaeb5acbc7daa58ceecca813b` |
| `src/resources/ResourcesEx.au3` | Resource extraction and GUI resource helper UDF | Shared legacy AutoIt ResourcesEx UDF with HotKeyz, credited in its header to Zedna and guinness with community contributors; no license text is included in the vendored source | `d4bba8dd81ec34f9166f3374c577b464ba077b29a4c56e78eabe8edcb496bc6f` |
| `src/resources/ResourcesEx_PE.au3` | Constants companion for ResourcesEx | Shared ResourcesEx companion with HotKeyz, credited by `ResourcesEx.au3` to PreExpand; no license text is included in the vendored source | `537c09c0b909d472ee1fb7206b1fed6af6e8c17b5cf80369b347cd8e1c81915c` |

Future redistribution must retain the ResourceEx attribution and resolve its upstream license before altering or repackaging that code.
