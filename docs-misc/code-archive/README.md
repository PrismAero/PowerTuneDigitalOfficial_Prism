# Code Archive

Archived C++ source files removed from the active CMake build during the 2026
refactoring. These files are fully functional but not currently compiled -- no
active source file references them.

They are preserved here for reference and potential future restoration.

## Archived Files

### Core/serialport.h / .cpp

Thin `QSerialPort` subclass adding a convenience `setParity(int)` method.
Dependency of both GPS and Speedo below. If either is restored, this must be
restored first.

### Hardware/gps.h / .cpp

NMEA serial GPS receiver driver. Connects to a uBlox GPS via serial port,
parses GPRMC/GPGGA/GPVTG sentences, populates `GPSData` model, and implements
lap-timer finish-line crossing detection via `TimingData`. GPS data now arrives
through the UDP daemon path instead (UDPReceiver idents 108-112).
Depends on: `serialport.h`

### Hardware/sensors.h / .cpp

Raspberry Pi SenseHat hardware sensor wrapper (QAccelerometer, QGyroscope,
QCompass, QAmbientTemperatureSensor, QPressureSensor). Writes readings into
`VehicleData` properties. Self-contained apart from the VehicleData model
dependency.

### Hardware/gopro.h / .cpp

GoPro WiFi remote control (Hero 2/3/4). Sends HTTP start/stop recording
commands to `10.5.5.9`. Fully self-contained, only depends on Qt Network.

### Utils/Speedo.h / .cpp

Serial speed sensor reader. Hardcoded to COM16 at 57600 baud -- appears to be
a test prototype. Speed data now comes from the ECU daemon via UDP.
Depends on: `serialport.h`

### Utils/iomapdata.h / .cpp

KML/text track data loader for the GPS lap timer feature. Reads track files
from `/home/pi/KTracks/`, provides `QGeoPath` data and start/finish line
coordinates to QML. Would require adding `QtPositioning` to `find_package`
if restored.

## Restoration

To bring any file back into the build:

1. Move the `.cpp` and `.h` back to their original directory
2. Add to the appropriate `SOURCES` / `HEADERS` list in `CMakeLists.txt`
3. Verify `#include` dependencies are satisfied
4. Add any new Qt module dependencies to `find_package`
