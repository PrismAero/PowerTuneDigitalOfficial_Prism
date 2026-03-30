# PowerTune Prism

`PowerTuneDigitalOfficial_Prism` is the current Qt 6 / QML dashboard application
for the PowerTune platform. The repository name, executable target, runtime app
name, and QML namespaces are not fully identical, so this README uses the
following terminology:

| Term | Meaning |
| --- | --- |
| `PowerTuneDigitalOfficial_Prism` | This repository / workspace |
| `PowerTuneQMLGui` | CMake executable target and packaged app bundle |
| `PowerTune` | Runtime application name and `QSettings` organization/app name |
| `PrismPT.Dashboard` / `Prism.Keyboard` | Active QML module namespaces used by the UI |

## Current Stack

- Qt 6 + CMake
- C++17 backend in `Core/`, `Hardware/`, and `Utils/`
- QML UI in `PowerTune/` and `Prism/`
- Raspberry Pi 4 target runtime with EGLFS
- macOS local development via `CMakePresets.json` or direct CMake

## Repository Structure

```text
.
|-- CMakeLists.txt
|-- main.cpp
|-- Core/
|-- Hardware/
|-- Utils/
|-- PowerTune/
|   |-- Core/
|   |-- Dashboard/
|   |-- Gauges/
|   `-- Settings/
|-- Prism/
|   `-- Keyboard/
|-- Resources/
|-- Scripts/
|-- docs-misc/
`-- operating_platform/
```

## QML Modules

The active QML modules declared in `CMakeLists.txt` are:

- `PowerTune.Utils`
- `PowerTune.Core`
- `PowerTune.UI`
- `PowerTune.Settings`
- `PowerTune.Gauges.Shared`
- `PowerTune.Gauges.RaceDash`
- `PrismPT.Dashboard`
- `Prism.Keyboard`

## App Entry Flow

- `main.cpp` sets the runtime app identity to `PowerTune`
- `main.cpp` loads `PowerTune/Core/Main.qml`
- `Core/connect.cpp` creates the backend objects and exposes them to QML
- `PowerTune/Core/SettingsManager.qml` owns the settings tab stack
- `PowerTune/Dashboard/RaceDash.qml` and `PowerTune/Dashboard/UserDashboard.qml`
  provide the dashboard pages

## Local Build

### Preferred preset flow

```sh
cmake --preset macos-homebrew
cmake --build --preset macos-homebrew
```

Build output:

```text
build/macos-homebrew/PowerTuneQMLGui.app
```

### Windows local development (UI iteration + testing)

Install Qt 6 with a desktop kit (MSVC recommended), CMake 3.21+, Ninja, and
Visual Studio Build Tools with the C++ workload.
Then set an environment variable to your Qt kit root (contains `lib/cmake/Qt6`):

```powershell
$env:POWERTUNE_QT_PREFIX = "C:\Qt\6.8.3\msvc2022_64"
```

Configure + build using presets:

```powershell
cmake --preset windows-debug
cmake --build --preset windows-debug
```

If `cl.exe` is not on your normal PATH, run from the VS 2022 developer shell:

```powershell
cmd /d /c "\"C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\Common7\Tools\VsDevCmd.bat\" -arch=x64 && cmake --preset windows-debug && cmake --build --preset windows-debug --parallel"
```

Deploy Qt runtime files after building (required for direct `.exe` launch):

```powershell
"C:\Qt\6.8.3\msvc2022_64\bin\windeployqt.exe" --debug --qmldir "C:\Users\KaiWyborny\Projects\PowerTuneDigital_Prism" "C:\Users\KaiWyborny\Projects\PowerTuneDigital_Prism\build\windows-debug\PowerTuneQMLGui.exe"
```

Run:

```powershell
.\build\windows-debug\PowerTuneQMLGui.exe
```

Notes:
- Linux-only hardware flows (CAN interface setup, Pi backlight sysfs, target deploy scripts) are no-op or unavailable on Windows.
- Dashboard files for non-Linux local builds are stored under Qt `AppDataLocation/UserDashboards`.
- `.vscode/tasks.json` and `.vscode/launch.json` now include Windows-aware build/run entries.
- Run `Scripts/windows-dev-bootstrap.ps1` to audit local tools and print safe install commands.
- If Windows reports missing `Qt6*.dll`, re-run `windeployqt` for the current build folder.

### Manual CMake flow

```sh
cmake -S . -B build/macos-homebrew -DCMAKE_BUILD_TYPE=Debug -DCMAKE_PREFIX_PATH=/opt/homebrew
cmake --build build/macos-homebrew --parallel
```

Run the built app with:

```sh
open build/macos-homebrew/PowerTuneQMLGui.app
```

or

```sh
./build/macos-homebrew/PowerTuneQMLGui.app/Contents/MacOS/PowerTuneQMLGui
```

## Target Runtime

- Primary target device: Raspberry Pi 4
- Graphics path: EGLFS / DRM / KMS
- CAN interface: `can0` via MCP2515
- Runtime settings path: `/home/root/.config/PowerTune/PowerTune.conf`

## Reference Docs

- `docs-misc/PROJECT_REFERENCE.md`: current architecture and codebase reference
- `BUILD.md`: build, Yocto, and deployment workflow

## Historical Notes

Older instructions in previous revisions may still mention:

- Qt 5
- qmake
- `PowerTuneQMLGui.pro`
- older deployment/update scripts

Those references are historical only and should not be treated as the supported
development path for this repository.
