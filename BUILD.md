# PowerTune Digital Dashboard - Build Instructions

## Overview

PowerTuneQMLGui is a Qt 6 / QML automotive dashboard application targeting the
Raspberry Pi 4 (ARMv7 32-bit). It is built locally on macOS for development and
cross-compiled for the Pi via a Yocto (Poky Scarthgap) build system running on
an Ubuntu 22.04 build server.

## Architecture

```
 Mac (dev)                Build Server                   Raspberry Pi 4
 macOS / Qt 6.x           Ubuntu 22.04 / Yocto           Poky / Qt 6.8.3
 CMake (native build)     meta-qt6 (cross-compile)       EGLFS / DRM / KMS
        |                        |                              |
        |--- git push ---------> |--- bitbake --------> SCP or WIC flash
        |                        |                              |
   IDE / test              powertune-src.tar.gz          /opt/PowerTune/
                           + full image build            PowerTuneQMLGui
```

## Architecture Changes (Settings Performance Overhaul)

### QSettings Caching (Phase 1)
- AppSettings now uses an in-memory `QHash<QString, QVariant>` cache with deferred disk writes via a 500ms single-shot QTimer
- All getValue() calls are O(1) hash lookups; all keys are preloaded at startup
- Single `m_settings` QSettings member replaces per-call construction

### Lazy Tab Loading (Phase 4)
- SettingsManager.qml uses Loader components for on-demand tab loading
- Only the active tab is instantiated; unloaded when switching away
- Eliminates 6 unnecessary Component.onCompleted cascades

### Signal Coalescing (Phase 3)
- SensorRegistry uses deferred emission via single-shot timer to batch sensorsChanged() signals
- SensorPicker.qml debounces refresh calls with a 50ms timer

### Removed Legacy Systems
- **UDP Receiver**: `Utils/UDPReceiver.cpp/.h` deleted - the legacy daemon UDP telemetry on port 45454 has been removed
- **Daemon Infrastructure**: All daemon binary support removed from connect.cpp (checkReg, checkOBDReg, LiveReqMsg, candump, etc.)
- **Daemon License System**: writeDaemonLicenseKey, writeHolleyProductID, getDaemonActivationKey removed from AppSettings
- **Daemon Properties**: daemonlicense, holleyproductid, supportedReg removed from ConnectionData
- **DaemonUDP Sensor Source**: Removed from SensorRegistry enum and all associated registration methods

### Removed Files
- `Utils/shcalc.cpp/.h` - replaced by SteinhartCalculator
- `Utils/SignalSmoother.cpp/.h` - never instantiated
- `Core/dashboard.cpp/.h` - empty facade, replaced by direct model access
- `Core/Models/SensorData.cpp/.h` - all properties were UDP-only
- `Core/Models/FlagsData.cpp/.h` - all properties were UDP-only
- `Core/Models/ElectricMotorData.cpp/.h` - all properties were UDP-only
- `Utils/textprogressbar.cpp/.h` - inlined into DownloadManager
- `Utils/ParseGithubData.cpp/.h` - inlined into DownloadManager
- `Utils/UDPReceiver.cpp/.h` - legacy UDP telemetry

### Domain Model Gutting (Phase 14)
- **EngineData**: 157 -> 5 properties (rpm, Power, Torque, Cylinders, Lambdamultiply)
- **VehicleData**: 81 -> 5 properties (Gear, GearCalculation, Odo, Trip, Weight)
- **DigitalInputs**: Removed DigitalInput1-7 (daemon-only), kept EXDigitalInput1-8 + frequency + DI1RPM config
- **AnalogInputs**: All 46 properties removed (empty shell for future CAN/ECU analog support)
- **GPSData**: All 10 properties removed (empty shell for future GPS hardware integration)
- **TimingData**: All 18 properties retained (actively used by Calculations)

### OverlayConfigManager -> OverlayPositionManager
- Renamed to reflect reduced responsibility (positions and lock state only)
- 7 unused methods removed (~200 lines of dead code)

### Shared Constants
- `Core/AppConstants.h` created with ORG_NAME/APP_NAME constants
- Replaces duplicated string literals across appsettings.cpp, OverlayPositionManager.cpp, SensorRegistry.cpp

### Calculations Speed Source Migration
- `Calculations.cpp` now uses `ExpanderBoardData::EXSpeed()` instead of the removed `VehicleData::speed()`
- Virtual dyno (Power/Torque from accelerometer) removed since `VehicleData::accely()` no longer exists

### Active/Inactive Sensor Architecture
- SensorRegistry is the single source of truth for sensor active state
- PropertyRouter respects SensorRegistry active state (returns 0 for inactive sensors)
- DiagnosticsProvider uses SensorRegistry for active/total sensor counts
- SensorPicker defaults to "active" filter mode
- CAN timeout of 10 seconds marks stale sensors as inactive

## 1. Local Development Build (macOS)

Preferred local preset flow:

```sh
cmake --preset macos-homebrew
cmake --build --preset macos-homebrew
```

This configures and builds the app into `build/macos-homebrew/`.

Prerequisites: Qt 6.x available on the machine and CMake 3.16+.

```sh
cd /path/to/PowerTuneDigitalOfficial_Prism
cmake -S . -B build/macos-homebrew -DCMAKE_BUILD_TYPE=Debug -DCMAKE_PREFIX_PATH=/opt/homebrew
cmake --build build/macos-homebrew --parallel
```

The preset build output is `build/macos-homebrew/PowerTuneQMLGui.app/Contents/MacOS/PowerTuneQMLGui`.

This build is for UI development, QML iteration, and testing only. It does not
produce an ARM Linux binary for the target device.

## 1.1 Local Development Build (Windows)

This path is intended for rapid UI iteration and visual verification when the
macOS development machine is unavailable.

Prerequisites:

- Qt 6 desktop kit (MSVC recommended), including `Core`, `Gui`, `Qml`, `Quick`,
  `QuickControls2`, `Network`, `SerialBus`, and `Multimedia`
- CMake 3.21+ (for preset support)
- Optional: Visual Studio 2022 Build Tools (if using an MSVC kit)

Set the Qt root once per PowerShell session:

```powershell
$env:POWERTUNE_QT_PREFIX = "C:\Qt\6.8.3\msvc2022_64"
```

Configure and build:

```powershell
cmake --preset windows-debug
cmake --build --preset windows-debug
```

If your terminal cannot see `cl.exe`, run the same flow through `VsDevCmd`:

```powershell
cmd /d /c "\"C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\Common7\Tools\VsDevCmd.bat\" -arch=x64 && cmake --preset windows-debug && cmake --build --preset windows-debug --parallel"
```

Run the executable:

```powershell
.\build\windows-debug\PowerTuneQMLGui.exe
```

Use `windows-release` for optimized builds:

```powershell
cmake --preset windows-release
cmake --build --preset windows-release
```

Deploy runtime DLLs/plugins after each build output refresh:

```powershell
"C:\Qt\6.8.3\msvc2022_64\bin\windeployqt.exe" --debug --qmldir "C:\Users\KaiWyborny\Projects\PowerTuneDigital_Prism" "C:\Users\KaiWyborny\Projects\PowerTuneDigital_Prism\build\windows-debug\PowerTuneQMLGui.exe"
```

If Windows shows `Qt6*.dll was not found`, the fix is to rerun `windeployqt`
for the current target executable.

Limitations on Windows local runs:

- Linux CAN bring-up (`ip link`) is Linux-only in `CanStartupManager`.
- Raspberry Pi backlight/sysfs and `ddcutil` paths are not expected to work on
  typical Windows hosts.
- Deployment scripts under `Scripts/*.sh` target macOS/Linux shells and remote
  Linux devices.
- Target runtime validation still requires the Raspberry Pi + Yocto deploy flow.

## 2. Cross-Compile Build (Yocto on Build Server)

### 2.1 Build Server Access

| Property | Value |
|----------|-------|
| Host | `192.168.15.205` |
| User | `kai_admin` |
| OS | Ubuntu 22.04.5 LTS (x86_64) |
| Yocto dir | `~/powertune-yocto/` |
| Build dir | `~/powertune-yocto/build-powertune/` |

```sh
ssh kai_admin@192.168.15.205
```

### 2.2 Yocto Layer Stack

| Layer | Branch | Purpose |
|-------|--------|---------|
| `poky` | `scarthgap` | Core Yocto reference distro |
| `meta-raspberrypi` | `scarthgap` | RPi 4 BSP (kernel, firmware, device trees) |
| `meta-openembedded` | `scarthgap` | OE supplementary recipes (networking, python, etc.) |
| `meta-qt6` | `6.8` | Qt 6.8.x framework recipes |
| `meta-powertune` | local | App, config, daemons, fonts, image |

### 2.3 meta-powertune Recipes

| Recipe | Purpose |
|--------|---------|
| `powertune-app` | Builds `PowerTuneQMLGui` from source tarball via `qt6-cmake` |
| `powertune-config` | Init scripts, network interfaces, environment variables |
| `powertune-daemons` | Pre-compiled ECU daemon binaries (Haltech, Link, Motec, etc.) |
| `powertune-fonts` | Custom fonts (Magneto, Nissan, SF Automaton, DejaVu, MS Core) |
| `powertune-image` | Composes the final flashable WIC image |
| `openssl-compat-1.1` | OpenSSL 1.1 shim for legacy daemon binaries |

### 2.4 Updating the Source Tarball

The `powertune-app` recipe builds from a source tarball located at:

```
~/powertune-yocto/meta-powertune/recipes-powertune/powertune-app/files/powertune-src.tar.gz
```

To update it with the latest code from the development machine:

```sh
# On the Mac: package the active working tree exactly as used in deployment
cd /path/to/PowerTuneDigitalOfficial_Prism
./Scripts/package-source-tarball.sh

# Upload the tarball to the build server recipe files directory
scp /tmp/powertune-src.tar.gz \
    kai_admin@192.168.15.205:~/powertune-yocto/meta-powertune/recipes-powertune/powertune-app/files/powertune-src.tar.gz
```

`Scripts/package-source-tarball.sh` stages `/tmp/powertune-src/` with `rsync` and excludes:
`.git`, `build`, `build-*`, `.cache`, `.cursor`, `docs-misc`, `node_modules`,
`.DS_Store`, `.memory`, `.kilocode`, `.vscode`, `compile_commands.json`, and
`target-backups`.

### 2.5 Building the App Only

To rebuild just the PowerTune app binary (fastest iteration):

```sh
# Run directly from the Mac
ssh kai_admin@192.168.15.205 '
    cd ~/powertune-yocto &&
    source poky/oe-init-build-env build-powertune 2>/dev/null &&
    bitbake -c cleansstate powertune-app &&
    bitbake powertune-app
'
```

The cross-compiled binary will be at:

```
~/powertune-yocto/build-powertune/tmp/work/cortexa7t2hf-neon-vfpv4-poky-linux-gnueabi/powertune-app/1.0/image/opt/PowerTune/PowerTuneQMLGui
```

### 2.6 Building the Full Image

To produce a complete flashable SD card image:

```sh
cd ~/powertune-yocto
source poky/oe-init-build-env build-powertune

bitbake powertune-image
```

Output images are at:

```
~/powertune-yocto/build-powertune/tmp/deploy/images/raspberrypi4/powertune-image-raspberrypi4.rootfs.wic      # ~1.2GB raw
~/powertune-yocto/build-powertune/tmp/deploy/images/raspberrypi4/powertune-image-raspberrypi4.rootfs.wic.bz2  # ~117MB compressed
```

### 2.7 Key Build Configuration

The build is configured in `build-powertune/conf/local.conf`:

- **MACHINE**: `raspberrypi4`
- **DISTRO**: `poky`
- **Init system**: SysVinit (not systemd)
- **GPU memory**: 256MB
- **Graphics**: VC4 KMS/DRM (no X11, no Wayland)
- **Qt EGLFS**: Enabled with GBM/KMS, libinput, xkbcommon
- **Image format**: WIC (SD card image)
- **CMake flags**: `-DCMAKE_BUILD_TYPE=Release -DFORCE_DDCUTIL=ON`

## 3. Deployment to Raspberry Pi

### 3.1 Target Device

| Property | Value |
|----------|-------|
| Host | `192.168.15.183` |
| User | `root` (passwordless SSH) |
| Board | Raspberry Pi 4 Model B (BCM2711, ARMv7 32-bit) |
| OS | Poky (Yocto) with SysVinit |
| Qt | 6.8.3 |
| Display | EGLFS / DRM / KMS on HDMI1 |
| CAN | MCP2515 via SPI (`can0` at 1Mbps) |
| App path | `/opt/PowerTune/PowerTuneQMLGui` |
| App log | `/var/log/powertune.log` |
| Settings | `/home/root/.config/PowerTune/PowerTune.conf` |

### 3.2 Mac-Driven Deployment Scripts

All normal target operations should be driven from the Mac, not by logging into
the target manually.

The target is resolved from `remotessh.login` by the helper scripts.

```sh
# Back up the current target deployment to target-backups/
./Scripts/backup-target-state.sh

# Tail the target app log from the Mac
./Scripts/tail-target-log.sh

# Check current can0 state, app log, and CAN traffic sample
./Scripts/check-target-can.sh

# Deploy the repo-managed init/runtime files and disable legacy startdaemon.sh
./Scripts/deploy-target-runtime.sh

# Deploy a prebuilt ARM binary only
./Scripts/deploy-prebuilt-binary.sh /absolute/path/to/PowerTuneQMLGui

# Full native-CAN deploy: runtime files + binary + post-check
./Scripts/deploy-native-can-target.sh /absolute/path/to/PowerTuneQMLGui
```

These scripts use SSH and SCP under the hood, but all actions are initiated from
the Mac terminal.

### 3.3 Exact Active Code -> Server -> Target Flow

This is the exact flow used during active development when deploying the current
working tree without flashing a new SD card image.

#### 3.3.1 Zip the active code on the Mac

```sh
cd /path/to/PowerTuneDigitalOfficial_Prism
./Scripts/package-source-tarball.sh
```

This creates:

```sh
/tmp/powertune-src.tar.gz
```

#### 3.3.2 Send the tarball to the build server

```sh
scp /tmp/powertune-src.tar.gz \
    kai_admin@192.168.15.205:~/powertune-yocto/meta-powertune/recipes-powertune/powertune-app/files/powertune-src.tar.gz
```

#### 3.3.3 Build the app on the build server

```sh
ssh kai_admin@192.168.15.205 '
    cd ~/powertune-yocto &&
    source poky/oe-init-build-env build-powertune 2>/dev/null &&
    bitbake -c cleansstate powertune-app &&
    bitbake powertune-app
'
```

#### 3.3.4 Download the fresh ARM binary from the build server

```sh
scp \
    kai_admin@192.168.15.205:~/powertune-yocto/build-powertune/tmp/work/cortexa7t2hf-neon-vfpv4-poky-linux-gnueabi/powertune-app/1.0/image/opt/PowerTune/PowerTuneQMLGui \
    /tmp/PowerTuneQMLGui
```

#### 3.3.5 Send the binary to the target

```sh
scp /tmp/PowerTuneQMLGui root@192.168.15.183:/tmp/PowerTuneQMLGui.new
```

#### 3.3.6 Safely deploy it on the target

Use maintenance mode so init respawn does not fight the deploy:

```sh
ssh -p 22 -o StrictHostKeyChecking=no root@192.168.15.183 "
    touch /tmp/powertune-maintenance
    killall -9 PowerTuneQMLGui 2>/dev/null || true
    killall -9 powertune-launcher 2>/dev/null || true
    sleep 2
    cp /tmp/PowerTuneQMLGui.new /opt/PowerTune/PowerTuneQMLGui
    chmod 0755 /opt/PowerTune/PowerTuneQMLGui
    rm -f /tmp/PowerTuneQMLGui.new
    sync
    rm -f /tmp/powertune-maintenance
"
```

Then verify the target respawned the app:

```sh
ssh -p 22 -o StrictHostKeyChecking=no root@192.168.15.183 \
    "ps | grep PowerTuneQMLGui | grep -v grep || true"
```

#### 3.3.7 Partial build and deploy

Use this path when only the app binary changed and you do not need a full image
rebuild.

Build only the app recipe on the build server:

```sh
cd /path/to/PowerTuneDigitalOfficial_Prism
./Scripts/package-source-tarball.sh

scp /tmp/powertune-src.tar.gz \
    kai_admin@192.168.15.205:~/powertune-yocto/meta-powertune/recipes-powertune/powertune-app/files/powertune-src.tar.gz

ssh kai_admin@192.168.15.205 '
    cd ~/powertune-yocto &&
    source poky/oe-init-build-env build-powertune 2>/dev/null &&
    bitbake -c cleansstate powertune-app &&
    bitbake powertune-app
'
```

Download the rebuilt ARM binary:

```sh
scp \
    kai_admin@192.168.15.205:~/powertune-yocto/build-powertune/tmp/work/cortexa7t2hf-neon-vfpv4-poky-linux-gnueabi/powertune-app/1.0/image/opt/PowerTune/PowerTuneQMLGui \
    /tmp/PowerTuneQMLGui
```

Device management commands for a safe partial deploy:

```sh
# Enter maintenance mode and stop the UI
ssh -p 22 -o StrictHostKeyChecking=no root@192.168.15.183 \
    "/etc/init.d/powertune stop"

# Or, if you need the low-level manual path:
ssh -p 22 -o StrictHostKeyChecking=no root@192.168.15.183 \
    "touch /tmp/powertune-maintenance && killall -9 PowerTuneQMLGui 2>/dev/null || true && killall -9 powertune-launcher 2>/dev/null || true"

# Upload the rebuilt binary
scp /tmp/PowerTuneQMLGui root@192.168.15.183:/tmp/PowerTuneQMLGui.new

# Install it atomically on the target
ssh -p 22 -o StrictHostKeyChecking=no root@192.168.15.183 "
    cp /tmp/PowerTuneQMLGui.new /opt/PowerTune/PowerTuneQMLGui &&
    chmod 0755 /opt/PowerTune/PowerTuneQMLGui &&
    rm -f /tmp/PowerTuneQMLGui.new &&
    sync
"

# Leave maintenance mode and let init respawn the app
ssh -p 22 -o StrictHostKeyChecking=no root@192.168.15.183 \
    "/etc/init.d/powertune start"

# Or the low-level manual equivalent:
ssh -p 22 -o StrictHostKeyChecking=no root@192.168.15.183 \
    "rm -f /tmp/powertune-maintenance"
```

Verify the partial deploy:

```sh
ssh -p 22 -o StrictHostKeyChecking=no root@192.168.15.183 \
    "/etc/init.d/powertune status"

ssh -p 22 -o StrictHostKeyChecking=no root@192.168.15.183 \
    "ps | grep PowerTuneQMLGui | grep -v grep || true"

ssh -p 22 -o StrictHostKeyChecking=no root@192.168.15.183 \
    "sed -n '1,120p' /var/log/powertune.log 2>/dev/null || true"
```

Use a full image rebuild only when changing Yocto recipes, launcher/runtime
files, boot configuration, init scripts, or other rootfs-level assets.

Notes:

- Do not use `telinit 1` for normal deployment. It can drop networking and kill
  the SSH session before recovery steps run.
- The safe iteration loop is: package source -> upload tarball -> build
  `powertune-app` -> download `PowerTuneQMLGui` -> deploy under maintenance mode.
- When the target login file is stale, use explicit SSH targets such as
  `root@192.168.15.183`.

### 3.4 Full Image Flash

To flash the complete WIC image to an SD card:

```sh
# On a machine with the SD card inserted (replace /dev/sdX with your device)
bunzip2 -k powertune-image-raspberrypi4.rootfs.wic.bz2
sudo dd if=powertune-image-raspberrypi4.rootfs.wic of=/dev/sdX bs=4M status=progress
sync
```

### 3.5 Boot Sequence and App Launch

The device is a dedicated appliance. There is no login prompt, no bootsplash
script, and no chain of shell-script wrappers.

**Boot chain:**

```
kernel -> init(8) -> rc scripts (networking, sshd) -> powertune-launcher (inittab respawn) -> PowerTuneQMLGui
```

- **`/opt/PowerTune/powertune-launcher`**: A compiled C binary that sets the
  required Qt/EGLFS environment variables, redirects stdout/stderr to the log
  file, and `exec()`'s PowerTuneQMLGui. No shell is involved.
- **inittab respawn**: init(8) automatically restarts the launcher (and
  therefore the app) if it exits or crashes.
- **Maintenance mode**: To stop the app for deployment, a flag file
  `/tmp/powertune-maintenance` gates the launcher. When the flag is present
  the launcher sleeps and exits, and init keeps retrying every few seconds.
  Removing the flag lets the app start on the next cycle.
- **CAN bus**: Brought up by the networking init script via
  `/etc/network/interfaces` (`auto can0`). The app's `CanStartupManager`
  verifies the interface state at runtime.
- **IPv6**: Disabled at three levels: kernel cmdline (`ipv6.disable=1`),
  sysctl (`/etc/sysctl.d/99-no-ipv6.conf`), and interfaces (IPv4-only).

Administrative control via SSH:

```sh
/etc/init.d/powertune stop      # Enter maintenance mode, kill app
/etc/init.d/powertune start     # Exit maintenance mode, init respawns app
/etc/init.d/powertune restart   # stop + start
/etc/init.d/powertune status    # Check if running

tail -f /var/log/powertune.log  # Watch app output
```

### 3.6 Environment Variables (set by powertune-launcher)

```sh
QT_QPA_PLATFORM=eglfs
QT_QPA_EGLFS_HIDECURSOR=1
QT_QPA_EGLFS_ALWAYS_SET_MODE=1
QT_QPA_EGLFS_KMS_ATOMIC=1
QT_QPA_EGLFS_KMS_CONFIG=/opt/PowerTune/kms-config.json
QML_DISK_CACHE=1
LC_ALL=en_US.utf8
```

### 3.7 KMS Configuration

`/opt/PowerTune/kms-config.json`:

```json
{
    "device": "/dev/dri/card0",
    "outputs": [
        {
            "name": "HDMI1",
            "mode": "preferred",
            "format": "xrgb8888"
        }
    ],
    "hwcursor": false,
    "separateScreens": false
}
```

## 4. Diagnostics and Logging

The app includes a built-in diagnostics page (Settings > Diagnostics) with:

- **System health**: CPU temp, load, RAM, disk usage, uptime
- **Connection status**: CAN bus state/rate, serial port, daemon info
- **Live sensor data**: real-time values from all registered sensors
- **System log**: all Qt messages (qDebug, qWarning, qCritical) captured in-app

### Log Level Filtering

A Qt message handler (`qInstallMessageHandler`) routes all framework and
application log output into the diagnostics log buffer (500 entries, circular).
The log panel has level filter buttons:

| Button | Level | Shows |
|--------|-------|-------|
| **All** | 0 | DEBUG + INFO + WARN + ERROR |
| **Info** | 1 | INFO + WARN + ERROR |
| **Warn** | 2 | WARN + ERROR only |
| **Error** | 3 | ERROR only |

Log entries are color-coded:
- Green: INFO messages
- Grey: DEBUG messages
- Orange: WARN messages
- Red: ERROR / FATAL messages

### Log Sources

Messages captured include:
- Qt QML warnings (deprecated syntax, anchors in layouts, type mismatches)
- PropertyRouter initialization
- CalibrationHelper status
- CAN connection/disconnection events
- Serial port events
- Application lifecycle (startup, shutdown, reboot, daemon restart)

The same messages also continue to write to `/var/log/powertune.log` on the Pi
via the previous stderr handler, so both in-app and file-based debugging work.

## 5. Git Repository

| Remote | URL |
|--------|-----|
| `origin` | `https://github.com/PrismAero/PowerTuneDigital_Prism.git` |
| `upstream` | `https://github.com/PowerTuneDigital/PowerTuneDigitalOfficial.git` |

Branch strategy is documented in the project rules. Active development happens
on `dev`, features on `feature/*`, releases via `release/*` into `main`.

## 5. Troubleshooting

### App does not start on the Pi

1. Check the log: `cat /var/log/powertune.log`
2. Verify the binary exists and is executable: `ls -la /opt/PowerTune/PowerTuneQMLGui`
3. Check Qt platform plugin: `QT_QPA_PLATFORM=eglfs /opt/PowerTune/PowerTuneQMLGui 2>&1`
4. Verify DRM device: `ls -la /dev/dri/card0`
5. Check GPU memory: `vcgencmd get_mem gpu` (should be 256M)

### Yocto build fails

1. Ensure you sourced the env: `source poky/oe-init-build-env build-powertune`
2. Clean and retry: `bitbake -c cleansstate powertune-app && bitbake powertune-app`
3. Check the build log: `~/powertune-build.log` or `~/powertune-rebuild.log`
4. Verify the source tarball extracts correctly: `tar tzf meta-powertune/recipes-powertune/powertune-app/files/powertune-src.tar.gz | head`

### CAN bus not working

1. Check interface: `ip link show can0`
2. Restart CAN: `ip link set can0 down && ip link set can0 type can bitrate 1000000 && ip link set can0 up`
3. Monitor traffic: `candump can0`
4. Check SPI overlay in `/boot/config.txt`: should have `dtoverlay=mcp2515-can0,oscillator=16000000,interrupt=25`
