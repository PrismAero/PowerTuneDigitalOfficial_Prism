---
title: "Haltech CAN Protocol Document v1.1 tmpvu9g5hh1"
source: /Users/kaiwybornyprismaero/Projects/PT-Prism-Advanced/PowerTuneDigitalOfficial_Prism/docs-misc/Documents-powertune/Haltech CAN Protocol Document v1.1.pdf
date: 2026-03-13 04:03:11 UTC
---

## Haltech CAN Protocol Document

The current Haltech CAN protocol is based on the AIM CAN protocol. The protocol operates at a bit rate of 1Mbit/sec. It uses the base format (CAN 2.0a - 11 bit identifiers).

<div align="center">

| ID    |    Byte | Channel             | Units                                   |  Resolution |
| :---- | ------: | :------------------ | :-------------------------------------- | ----------: |
| 0x010 |   0 - 1 | RPM                 | RPM                                     |       1 RPM |
| 0x010 |   2 - 3 | Road Speed          | Km/h                                    |    0.1 km/h |
| 0x010 |   4 - 5 | Oil Pressure        | Bar                                     |     0.1 Bar |
| 0x010 |   6 - 7 | N/A 1               | 0                                       |             |
| 0x011 |   8 - 9 | Coolant Temperature | Deg C                                   |   0.1 Deg C |
| 0x011 | 10 - 11 | Fuel Pressure       | Bar                                     |     0.1 Bar |
| 0x011 | 12 - 13 | Battery Voltage     | Volts                                   | 0.01 V olts |
| 0x011 | 14 - 15 | Throttle Position   | %                                       |        0.1% |
| 0x012 | 16 - 17 | Manifold Pressure   | mBar                                    |      1 mBar |
| 0x012 | 18 - 19 | Air Temperature     | Deg C                                   |   0.1 Deg C |
| 0x012 | 20 - 21 | N/A 2               | 0                                       |             |
| 0x012 | 22 - 23 | Lambda              | Lambda                                  |     0.001 λ |
| 0x013 | 24 - 25 | Ignition Advance    | Degrees                                 |     0.1 Deg |
|       | 26 - 27 | Gear                | 0 = neutral, 1 = first, 2 = second, etc |             |
|       | 28 - 29 | Injector Duty Cycle | %                                       |          1% |
|       |      30 | Data Bytes Sent     | 30                                      |             |
|       |      31 | Marker Byte 1 ^     | FC                                      |             |
| 0x014 |      32 | Marker Byte 2 ^     | FB                                      |             |
| 0x014 |      33 | Marker Byte 3 ^     | FA                                      |             |
| 0x014 |      34 | Checksum \*         |                                         |             |

</div>

1. This channel is Oil Temperature in the original AIM CAN protocol. It has the units of Deg C and a resolution of 0.1 Deg C. Currently Haltech ECU's do not take in such information. It is reserved as a channel with the same units and resolution as to maintain compatibility with the AIM Dash. A zero is sent in its place.
2. This channel is Exhaust Gas Temperature in the original AIM CAN protocol. It has the units of Deg C and a resolution of 1 Deg C. Currently Haltech ECU's do not take in such information. It is reserved as a channel with the same units and resolution as to maintain compatibility with the AIM Dash. A zero is sent in its place.
3. ^. Marker Bytes are from the original AIM CAN protocol and are in to maintain compatibility.
4. \*. Checksum is the sum of all bytes of the structure up to and including marker byte.
5. Absolute pressure
6. This value comes through as gauge pressure, meaning 0 mBar is equal to 1013 mBar absolute pressure.

<div align="center">

| Channel             | Units                                   |     m |   c | Sign |   Min |   Max |
| :------------------ | :-------------------------------------- | ----: | --: | :--- | ----: | ----: |
| RPM                 | RPM                                     |     1 |   0 | N    |     0 | 16000 |
| Road Speed          | Km/h                                    |   0.1 |   0 | N    |     0 |   400 |
| Oil Pressure 1      | Bar                                     |   0.1 |   0 | Y    |     0 |   327 |
| Coolant Temperature | Deg C                                   |   0.1 |   0 | Y    |  -400 |  1270 |
| Fuel Pressure 1     | Bar                                     |   0.1 |   0 | Y    |     0 |   327 |
| Battery Voltage     | Volts                                   |  0.01 |   0 | N    |     0 | 16000 |
| Throttle Position   | %                                       |   0.1 |   0 | N    |     0 |  1000 |
| Manifold Pressure 2 | mBar                                    |     1 |   0 | Y    | -1000 | 32767 |
| Air Temperature     | Deg C                                   |   0.1 |   0 | Y    |  -400 |  1270 |
| Lambda              | Lambda                                  | 0.001 |   0 | N    |   680 |  1361 |
| Ignition Advance    | Degrees                                 |   0.1 |   0 | Y    | -25.6 |   600 |
| Gear                | 0 = neutral, 1 = first, 2 = second, etc |     1 |   0 | N    |     0 |     6 |
| Injector Duty Cycle | %                                       |     1 |   0 | N    |     0 |  1000 |

</div>
