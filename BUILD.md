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
# On the Mac: stage a clean source tree and create the tarball
cd /path/to/PowerTuneDigitalOfficial_Prism

rm -rf /tmp/powertune-src && mkdir /tmp/powertune-src
rsync -a \
    --exclude='.git' --exclude='build' --exclude='build-*' \
    --exclude='.cache' --exclude='docs-misc' --exclude='plans' \
    --exclude='agent-transcripts' --exclude='.cursor' --exclude='node_modules' \
    --exclude='.DS_Store' --exclude='.memory' --exclude='.kilocode' \
    --exclude='.vscode' --exclude='.clangd' --exclude='.clang-tidy' \
    --exclude='.clang-format' --exclude='.qmllint.ini' --exclude='.github' \
    ./ /tmp/powertune-src/

cd /tmp && tar czf /tmp/powertune-src.tar.gz powertune-src

# Transfer to build server
scp /tmp/powertune-src.tar.gz \
    kai_admin@192.168.15.205:~/powertune-yocto/meta-powertune/recipes-powertune/powertune-app/files/
```

### 2.5 Building the App Only

To rebuild just the PowerTune app binary (fastest iteration):

```sh
ssh kai_admin@192.168.15.205

cd ~/powertune-yocto
source poky/oe-init-build-env build-powertune

# Clean previous build state for the app recipe
bitbake -c cleansstate powertune-app

# Rebuild only the app
bitbake powertune-app
```

The cross-compiled binary will be at:

```
~/powertune-yocto/build-powertune/tmp/work/cortexa7t2hf-neon-vfpv4-poky-linux-gnueabi/powertune-app/1.0-r0/image/opt/PowerTune/PowerTuneQMLGui
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
| Host | `192.168.15.129` |
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

### 3.3 Full Image Flash

To flash the complete WIC image to an SD card:

```sh
# On a machine with the SD card inserted (replace /dev/sdX with your device)
bunzip2 -k powertune-image-raspberrypi4.rootfs.wic.bz2
sudo dd if=powertune-image-raspberrypi4.rootfs.wic of=/dev/sdX bs=4M status=progress
sync
```

### 3.4 Init System and Runtime

The app starts automatically at boot via SysVinit:

- **Init script**: `/etc/init.d/powertune` (installed at priority 99)
- Legacy deployed images may still contain `/home/pi/startdaemon.sh` and the
  `Generic` daemon.
- The target native-CAN runtime direction is for the app to own `can0` startup
  and EX communication directly.
- `Scripts/deploy-target-runtime.sh` installs the repo-managed init script and
  disables the legacy `startdaemon.sh` bootstrap on the target.
- **Recovery**: If `PowerTuneQMLGui` fails to launch, `/home/pi/Recovery/Recovery` is started

Manual control, if needed:

```sh
ssh root@192.168.15.129

/etc/init.d/powertune stop      # Stop the app and daemons
/etc/init.d/powertune start     # Start the app and daemons
/etc/init.d/powertune restart   # Restart everything

tail -f /var/log/powertune.log  # Watch app output
```

### 3.5 Environment Variables (set by init script)

```sh
QT_QPA_PLATFORM=eglfs
QT_QPA_EGLFS_HIDECURSOR=1
QT_QPA_EGLFS_ALWAYS_SET_MODE=1
QT_QPA_EGLFS_KMS_ATOMIC=1
QT_QPA_EGLFS_KMS_CONFIG=/opt/PowerTune/kms-config.json
QML_DISK_CACHE=1
LC_ALL=en_US.utf8
```

### 3.6 KMS Configuration

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
