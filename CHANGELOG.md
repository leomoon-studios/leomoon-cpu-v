# Changelog

## 2.0.1 - 2026-10-29

- Improved high-DPI scaling for the Settings window.

## 3.0.0 - 2026-10-27

- Updated minimum supported Windows version to Windows 8 and removed the legacy detection driver used on Windows Vista and 7.
- Reworked hardware virtualization detection to report enabled, disabled, unsupported, or unknown status, including systems with multiple processors.
- Improved handling of missing Windows Management Instrumentation (WMI) data for virtualization, Data Execution Prevention (DEP), Second Level Address Translation (SLAT), and VM Monitor Mode Extensions.
- Read the CPU name through WMI instead of CPUID code that used executable memory.
- Improved localization and isolated temporary resources for each application instance, with cleanup on exit.
- Refreshed the application icon.
- Added automated regression and desktop smoke tests.
- Added versioned x86 builds, a portable ZIP, a Windows installer that does not require administrator privileges, and a GitHub Release workflow that verifies packages and publishes checksums.

## 2.0.5 - 2023-06-10

- Compiled with the latest compiler for better Windows 11 support.

## 2.0.4

- Rewrote parts of the application to remove the need to run as administrator.

## 2.0.3

- Minor improvements.
- Digitally signed the application.

## 2.0.2

- Improved virtualization technology (VT) detection.
- Bug fixes.

## 2.0.1

- Fixed a Windows 8 and 8.1 bug, thanks to Susanna Dzejachok for lending her computer.

## 2.0.0

- Added proper support for Windows 8, 8.1, and 10.
- Added Data Execution Prevention (DEP) detection.
- Added Second Level Address Translation (SLAT) detection.
- Added VM Monitor Mode Extensions detection.
- Minor UI changes.

## 1.22

- GUI changes.

## 1.00

- Initial release.
