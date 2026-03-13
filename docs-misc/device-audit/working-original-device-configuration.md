# PowerTune Device Configuration Audit

This document is a point-in-time snapshot of a specific deployed device image.
It is useful for device forensics and platform comparison, but it is not the
authoritative reference for the current application structure, build system, or
runtime naming used by this repository. For current app architecture, use
`docs-misc/PROJECT_REFERENCE.md` and `BUILD.md`.

**Date**: 2026-03-04
**Device IP**: 192.168.15.129
**Access**: ssh root@192.168.15.129 (passwordless)

---

## 1. Hardware

| Component     | Detail                                          |
|---------------|-------------------------------------------------|
| Board         | Raspberry Pi 4 Model B (BCM2711)                |
| Architecture  | ARMv7 (armv7l, 32-bit)                          |
| CPU           | 4x ARMv7 Processor rev 3 (v7l)                  |
| RAM           | 3.3 GiB (4GB physical, GPU reserved)            |
| Storage       | 29.7 GB microSD (mmcblk0)                       |
| Revision      | c03115                                          |
| Serial        | 10000000a94770f9                                |
| CAN           | MCP2515 via SPI (oscillator 16MHz, IRQ pin 25)  |
| Display       | EGLFS (no X11), vc4-kms-v3d GPU driver          |
| Bluetooth     | Disabled (dtoverlay=disable-bt)                  |

## 2. Operating System

| Property          | Value                                         |
|-------------------|-----------------------------------------------|
| Distro            | Poky (Yocto Project Reference Distro) 4.0.17  |
| Kernel            | 6.1.61-v7l (SMP, Nov 9 2023)                  |
| Hostname          | raspberrypi4                                  |
| Init System       | SysVinit (NOT systemd)                        |
| Default Runlevel  | 5                                             |
| Swap              | None                                          |
| Package Manager   | opkg (no packages visible via list-installed)  |

## 3. Storage Layout

### Partitions

| Partition     | Size   | Used  | Avail | Use% | Mount  | Filesystem |
|---------------|--------|-------|-------|------|--------|------------|
| mmcblk0p1     | 50.9M  | 30M   | 22M   | 58%  | /boot  | vfat       |
| mmcblk0p2     | 14.6G  | 1.4G  | 13G   | 11%  | /      | ext4       |

### Space Breakdown

| Directory | Size  |
|-----------|-------|
| /bin      | 3.4M  |
| /boot     | 30M   |
| /etc      | 17M   |
| /home     | 507M  |
| /lib      | 31M   |
| /opt      | 16M   |
| /sbin     | 3.7M  |
| /usr      | 800M  |
| /var      | 1.1M  |
| **Total** |~1.4G  |

### fstab

```
/dev/root            /                    auto       defaults              1  1
proc                 /proc                proc       defaults              0  0
devpts               /dev/pts             devpts     mode=0620,ptmxmode=0666,gid=5  0  0
tmpfs                /run                 tmpfs      mode=0755,nodev,nosuid,strictatime 0  0
tmpfs                /var/volatile        tmpfs      defaults              0  0
/dev/mmcblk0p1       /boot                vfat       defaults              0  0
```

## 4. Network Configuration

### Interfaces

| Interface | Type     | State | IP Address         | MAC               |
|-----------|----------|-------|--------------------|-------------------|
| lo        | Loopback | UP    | 127.0.0.1/8        | -                 |
| eth0      | Ethernet | UP    | 192.168.15.129/24  | 88:a2:9e:29:a4:38 |
| can0      | CAN      | UP    | -                  | -                 |
| wlan0     | WiFi     | DOWN  | -                  | 88:a2:9e:29:a4:3a |

### Routing

```
default via 192.168.15.1 dev eth0 metric 10
192.168.15.0/24 dev eth0 proto kernel scope link src 192.168.15.129
```

### DNS

- Nameserver: 192.168.15.1

### DHCP

- Using `udhcpc` for both eth0 and wlan0
- eth0: DHCP (currently 192.168.15.129)
- wlan0: DHCP, hostname "PowerTuneDigital"

### /etc/network/interfaces

```
auto lo
iface lo inet loopback

auto wlan0
    iface wlan0 inet dhcp
    hostname PowerTuneDigital
    wireless_mode managed
    wireless_essid any
    wpa-driver wext
    wpa-conf /etc/wpa_supplicant.conf

auto eth0
    iface eth0 inet dhcp

auto can0
    iface can0 inet manual
    pre-up /sbin/ip link set can0 type can bitrate 1000000
    up /sbin/ifconfig can0 up
    down /sbin/ifconfig can0 down
```

### CAN Bus Configuration

```
can0: bitrate 1000000, sample-point 0.750
  tq 125, prop-seg 2, phase-seg1 3, phase-seg2 2, sjw 1, brp 1
  mcp251x: tseg1 3..16, tseg2 2..8, sjw 1..4, brp 1..64
  clock 8000000
  State: ERROR-PASSIVE
```

## 5. Boot Configuration

### /boot/config.txt (active settings only)

```
disable_overscan=1
gpu_mem=1024
boot_delay=0
disable_splash=1
dtparam=spi=on
dtparam=i2c1=on
dtparam=i2c_arm=on
dtoverlay=vc4-kms-v3d
dtoverlay=mcp2515-can0,oscillator=16000000,interrupt=25
initial_turbo=20
dtoverlay=disable-bt
max_framebuffers=2
```

### /boot/cmdline.txt

```
dwc_otg.lpm_enable=0 root=/dev/mmcblk0p2 rootfstype=ext4 rootwait logo.nologo loglevel=0 console=tty3 quiet silent
```

Key boot options:
- Silent boot (no splash, no logo, quiet, console redirected to tty3)
- Rootfs on mmcblk0p2, ext4
- GPU memory: 1024MB (very high, leaves ~3.3GB for system)

## 6. User Accounts

| Username | UID  | Home        | Shell     |
|----------|------|-------------|-----------|
| root     | 0    | /home/root  | /bin/sh   |
| pi       | 1000 | /home/pi    | /bin/bash |

### SSH Configuration

```
PermitRootLogin yes
PermitEmptyPasswords yes
ChallengeResponseAuthentication no
Compression no
ClientAliveInterval 15
ClientAliveCountMax 4
Subsystem sftp internal-sftp
```

## 7. Services (SysVinit Runlevel 5)

Boot order (rc5.d):

| Priority | Service           | Description                   |
|----------|-------------------|-------------------------------|
| S010     | **powertune**     | PowerTune application launch  |
| S01      | networking        | Network interfaces            |
| S02      | dbus-1            | D-Bus message bus             |
| S09      | sshd              | OpenSSH server                |
| S12      | rpcbind           | RPC port mapper               |
| S15      | mountnfs.sh       | Mount NFS filesystems         |
| S20      | apmd              | Power management              |
| S20      | ntpd              | NTP time sync                 |
| S20      | syslog            | System logging                |
| S21      | avahi-daemon      | mDNS/DNS-SD service discovery |
| S22      | ofono             | Telephony stack               |
| S64      | neard             | NFC daemon                    |
| S99      | rmnologin.sh      | Remove nologin file           |
| S99      | stop-bootlogd     | Stop boot logger              |

**PowerTune starts FIRST** (S010) before networking.

## 8. PowerTune Application

### Init Script (/etc/init.d/powertune)

Environment variables set:
```sh
export LD_LIBRARY_PATH="/usr/local/lib/openssl/openssl/lib:$LD_LIBRARY_PATH"
export LC_ALL=en_US.utf8
export QT_QPA_EGLFS_HIDECURSOR=1
export QT_QPA_EGLFS_ALWAYS_SET_MODE=1
export QT_QPA_EGLFS_KMS_ATOMIC=1
export QT_QPA_PLATFORM=eglfs
```

Startup sequence:
1. Run `/home/pi/powertune-update.sh` (auto-update check)
2. Start `/home/pi/startdaemon.sh` in background (brings up CAN, runs Generic daemon)
3. Start `/opt/PowerTune/PowertuneQMLGui -platform eglfs` in background
4. Monitor loop: if PowertuneQMLGui crashes, launch Recovery app

### Currently Running Processes

| Process             | PID | CPU%  | MEM% | RSS    |
|---------------------|-----|-------|------|--------|
| PowertuneQMLGui     | 365 | 1.3%  | 2.7% | 95 MB  |
| Generic (daemon)    | 391 | 97.4% | 0%   | 1.1 MB |
| startdaemon.sh      | 364 | 0%    | 0%   | 2.5 KB |

**Note**: The `Generic` daemon is consuming 97.4% CPU, likely a busy-wait loop.

### Application Paths

| Path                           | Contents                              |
|--------------------------------|---------------------------------------|
| /opt/PowerTune/                | Built executable + object files       |
| /opt/PowerTune/PowertuneQMLGui | Main application binary (2.7 MB)      |
| /home/pi/daemons/              | ECU protocol daemons (licensed)       |
| /home/pi/daemons/Generic       | Currently active daemon               |
| /home/pi/daemons/Key.lic       | License key file                      |
| /home/pi/daemons/Licence.lic   | License file                          |
| /home/pi/src/                  | Git repo (source code, old version)   |
| /home/pi/UserDashboards/       | Dashboard configuration files         |
| /home/pi/Logo/                 | Custom logo/graphic assets            |
| /home/pi/Recovery/             | Recovery application (built)          |
| /home/pi/Recoverysrc/          | Recovery source (git repo)            |
| /home/pi/tracks/               | Track data directory (empty)          |

### ECU Daemons (67 total)

Complete list of available ECU daemons in `/home/pi/daemons/`:
AEMV2d, AdaptronicCANd, Apexid, AudiB7d, AudiB8d, BigNET, BigNETLamda,
BlackboxM3, Boostec, BRZFRS86d, Consult, DBC, Delta, DTAFast, ECVOXCAN,
Edelbrock, Emerald, EMSCAN, EMUCANd, Emtrond, EVOXCAN, ecoboost,
FordBarraBXCAN, FordBarraBXCANOBD, FordBarraFG2XCANOBD, FordBarraFG2xCAN,
FordBarraFGMK1CAN, FordBarraFGMK1CANOBD, FTCAN20, Generic, GMCANOBD,
GMCANd, GR_Yaris, Haltechd, HEFI, Holleyd, HondataS300, Hondatad,
LifeRacing, Linkd, M800ADLSet1d, M800ADLSet3d, MaxxECUd, ME13,
MegasquirtCan, Microtechd, MotecM1d, NeuroBasic, NISSAN350Z, NISSAN370Z,
OBD, Prado, ProEFI, PTDCAND, R35, Rsport, RX8, Syvecs, SyvecsS7,
TeslaSDU, Testdaemon, WolfEMS, WRX2012, WRX2016, checkall

## 9. Qt Installation

| Property          | Value        |
|-------------------|--------------|
| Qt Version        | 5.15.7       |
| qmake Version     | 3.1          |
| Spec              | linux-g++    |
| Install Prefix    | /usr         |
| Plugins           | /usr/lib/plugins |
| QML Imports       | /usr/lib/qml |

## 10. Kernel Modules

Key loaded modules:
- **vc4** - GPU driver (352KB, 8 users)
- **mcp251x** - MCP2515 CAN controller (24KB)
- **can_raw**, **can**, **can_dev** - CAN bus stack
- **brcmfmac** - Broadcom WiFi (331KB)
- **hid_multitouch** - Touchscreen support
- **i2c_dev**, **i2c_bcm2708** - I2C support
- **spi_bcm2835** - SPI support
- **v3d** - 3D acceleration
- **drm** + helpers - Display rendering
- **snd_bcm2835** - Audio

## 11. Application Config Files

### /home/root/.config/Power-Tune/PowerTune.conf

Contains application settings (persisted by PowerTuneQMLGui).

### /home/root/.config/PowerTuneQML/PowerTuneDash.conf

Contains dashboard layout configuration.

### /.cache/Power-Tune/PowerTune/

Application cache directory (QML cache, etc).

## 12. Startup Script Details

### /home/pi/startdaemon.sh

```sh
#!/bin/sh
sudo ifdown can0
sudo ifup can0
cd /home/pi/daemons
./Generic
```

### /home/pi/powertune-update.sh

```sh
(auto-update script, runs at boot before app starts)
```

## 13. Key Observations

1. **SysVinit, not systemd** - All service management is via `/etc/init.d/` scripts
2. **PowerTune starts before networking** (S010 vs S01) - may cause issues if update check needs network
3. **Generic daemon at 97% CPU** - Likely a polling/busy-wait issue in the daemon
4. **CAN in ERROR-PASSIVE** state - suggests CAN bus issues or no connected ECU
5. **32-bit ARM** - Despite Pi 4 supporting aarch64, Yocto image is armv7l (32-bit)
6. **GPU memory 1024MB** - Very aggressive allocation, typical for EGLFS rendering
7. **No swap** configured
8. **Old source code on device** - `/home/pi/src/` contains an older version of the codebase
9. **License files present** - `/home/pi/daemons/Key.lic` and `Licence.lic` (Aug 2025)
10. **Recovery system** - Built recovery app falls back if main app crashes
11. **VSCode Server** - Previously accessed remotely via VSCode (artifacts in /home/root)
