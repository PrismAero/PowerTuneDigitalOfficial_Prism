---
title: "Haltech_CAN_Broadcast_Protocol_v2 0 tmpxwr70v94"
source: /Users/kaiwybornyprismaero/Projects/PT-Prism-Advanced/PowerTuneDigitalOfficial_Prism/docs-misc/Documents-powertune/Haltech_CAN_Broadcast_Protocol_v2 0.pdf
date: 2026-03-13 04:03:32 UTC
---

<p align="center"><img src="<../../.mdassets/Haltech_CAN_Broadcast_Protocol_v2-0-tmpxwr70v94/Haltech_CAN_Broadcast_Protocol_v2 0-figure-1.png>" alt="Haltech_CAN_Broadcast_Protocol_v2 0-figure-1.png" width="45%"></p>

## CAN BROADCAST PROTOCOL SPECIFICATION VERSION

## 2.0

## 7 February, 2012

<div align="center">

| Prepared |  Nathan | Path:     | Path:                                | Path:                                | Path:                                |
| :------- | ------: | :-------- | :----------------------------------- | :----------------------------------- | :----------------------------------- |
| Date     | 7/02/12 | Filename: | Filename:                            | Filename:                            | Filename:                            |
| Checked  |         | Title:    | CAN Broadcast Protocol Specification | CAN Broadcast Protocol Specification | CAN Broadcast Protocol Specification |
| Date     |         |           |                                      |                                      |                                      |
| Approved |         |           | Document Number:                     | Code:                                | Sheet                                |
| Date     |         | 1.0       |                                      |                                      | 1 of 1                               |

</div>

## TABLE OF CONTENTS

- [1.](#1)

## 1. INTRODUCTION

Haltech ECUs broadcast on the CAN bus a number of engine parameters/sensor readings. Third party devices can read these CAN packets and use the values for data logging, displaying on a dash, etc. This document describes the CAN packets and the data they contain.

There are two versions of this protocol. The V1 protocol is present in all Haltech Platinum ECUs to date but will be deprecated in the future. Starting from firmware versions 1.11 all Haltech Platinum ECUs will support V2, and all products that wish to interoperate with Haltech ECUs should support this version.

## 2. ENCODING

The Haltech CAN bus operates at 1MBit and uses 11-bit IDs. In this document, the first byte in the packet is considered byte zero, and the 8th byte is byte 7. Data is encoded as 'Big Endian'. IDs are expressed in Hexadecimal.

To address individual bits within a byte, the following notation is used X:Y. The X is the byte number, and the Y is the bit number. Consistent with the byte numbering, the left most bit is the most significant, and the right most bit is the least significant. Where ranges of bytes/bits is specified, the addresses are inclusive. All 16-bit values are signed two's complement.

## Examples

<div align="center">

| Bytes     |                         Description                         |
| :-------- | :---------------------------------------------------------: |
| 0 - 1     |       A 16-bit value formed from the first two bytes        |
| 2:3       |           A single bit value from bit 3 in byte 2           |
| 0:4 - 0:7 | A 4-bit value encoded in the lower nibble of the first byte |

</div>

## 3. UNITS

Converting the raw values to units is done by multiplying the value by the value in the Units column. For example, a road speed raw value of 1000 corresponds to a speed of 100km/h. If other units are required, it is the responsibility of the device reading these values to perform these conversions. All pressures are absolute, and it is necessary to subtract 101.3 kPa from the final result if gauge pressure is desired.

## 4. HALTECH V2 PROTOCOL

Not all CAN Packets will always be broadcast.

The Haltech ECU may opt not to broadcast a particular packet if that feature is not enabled.

<div align="center">

| ID       | Bytes | Channel                         |    Units | Sport |  PRO |
| :------- | ----: | :------------------------------ | -------: | :---- | ---: |
| 360      | 0 - 1 | RPM                             |      RPM | 1.11  | 1.11 |
| 360      | 2 - 3 | Manifold Pressure               |  0.1 kPa | 1.11  | 1.11 |
| 360      | 4 - 5 | Throttle Position               |    0.10% | 1.11  | 1.11 |
| 360      | 6 - 7 | Coolant Pressure                |  0.1 kPa | --    | 1.11 |
| 361      | 0 - 1 | Fuel Pressure                   |  0.1 kPa | 1.11  | 1.11 |
| 361      | 2 - 3 | Oil Pressure                    |  0.1 kPa | 1.11  | 1.11 |
| 361      | 4 - 5 | Accelerator Pedal Pos           |    0.10% | --    | 1.11 |
| 361      | 6 - 7 | Wastegate Pressure              |  0.1 kPa | --    | 1.11 |
| 362 50Hz | 0 - 1 | Injector Duty Cycle (Primary)   |    0.10% | 1.11  | 1.11 |
| 362 50Hz | 2 - 3 | Injector Duty Cycle (Secondary) |    0.10% | 1.11  | 1.11 |
| 362 50Hz | 4 - 5 | Ignition Angle (Leading)        |     0.1° | 1.11  | 1.11 |
| 362 50Hz | 6 - 7 | Ignition Angle (Trailing)       |     0.1° | 1.11  | 1.11 |
| 363      | 0 - 1 | Wheel Slip                      | 0.1 km/h | --    | 1.11 |
| 363      | 2 - 3 | Wheel Diff                      | 0.1 km/h | --    | 1.11 |
| 363      | 4 - 5 | Engine Acceleration             |  1 RPM/s | --    | 1.11 |
| 363      | 6 - 7 | Manifold Pressure 2             |  0.1 kPa | --    | 1.11 |
| 368      | 0 - 1 | Lambda 1                        |   .001 λ | 1.11  | 1.11 |
| 368      | 2 - 3 | Lambda 2                        |   .001 λ | 1.11  | 1.11 |
| 368      | 4 - 5 | Lambda 3                        |   .001 λ | --    | 1.11 |
| 368      | 6 - 7 | Lambda 4                        |   .001 λ | --    | 1.11 |
| 369      | 0 - 1 | Miss Count                      |          | 1.11  | 1.11 |
| 369      | 2 - 3 | Trigger Counter                 |          | 1.11  | 1.11 |
| 369      | 4 - 5 | Home Counter                    |          | 1.11  | 1.11 |
| 369      | 6 - 7 | Triggers Since Last Home        |          | 1.11  | 1.11 |
|          | 0 - 1 | Knock Level Logged              |          | --    | 1.11 |
| 36A      | 2 - 3 | Knock Level Logged 2            |          | --    | 1.11 |
| 36A      | 4 - 5 | Knock Retard - Bank 1           |     0.1° | --    | 1.11 |
| 36A      | 6 - 7 | Knock Retard - Bank 2           |     0.1° | --    | 1.11 |
| 36B      | 0 - 1 | Brake Pressure                  |    1 kPa | --    | 1.11 |
| 36B      | 2 - 3 | NOS Pressure                    |    1 kPa | --    | 1.11 |
| 36B      | 4 - 5 | Turbo Speed Sensor              |    1 RPM | --    | 1.11 |
| 36B      | 6 - 7 | G-Sensor                        |      TBC | --    | 1.11 |

</div>

<div align="center">

| ID   | Rate | Bytes | Channel                      |                  Units | Sport |       PRO |
| :--- | ---: | ----: | :--------------------------- | ---------------------: | :---- | --------: |
| 36C  | 20Hz | 0 - 1 | Wheelspeed Front Left        |               0.1 km/h | --    |      1.11 |
| 36C  | 20Hz | 2 - 3 | Wheelspeed Front Right       |               0.1 km/h | --    |      1.11 |
| 36C  | 20Hz | 4 - 5 | Wheelspeed Rear Left         |               0.1 km/h | --    |      1.11 |
| 36C  | 20Hz | 6 - 7 | Wheelspped Rear Right        |               0.1 km/h | --    |      1.11 |
| 36D  | 20Hz | 0 - 1 | Wheelspeed Front             |               0.1 km/h | --    |      1.11 |
| 36D  | 20Hz | 2 - 3 | Wheelspeed Rear              |               0.1 km/h | --    |      1.11 |
| 36D  | 20Hz | 4 - 5 | Exhaust Cam Angle #1         |                   0.1° | --    |      1.11 |
| 36D  | 20Hz | 6 - 7 | Exhaust Cam Angle #2         |                   0.1° | --    |      1.11 |
| 36E  | 20Hz | 0 - 1 | Fuel Cut Percentage          |                  0.10% | --    |      1.11 |
| 36E  | 20Hz | 2 - 3 | Launch Control Ign Retard    |                   0.1° | --    |      1.11 |
| 36E  | 20Hz | 4 - 5 | Launch Control Fuel Enrich   |                   0.1° | --    |      1.11 |
| 36E  | 20Hz |     6 | Reserved                     |                        | --    |        -- |
| 36E  | 20Hz |     7 | Reserved                     |                        | --    |        -- |
| 36F  | 20Hz |     0 | Reserved                     |                        | --    |        -- |
| 36F  | 20Hz |     1 | Reserved                     |                        | --    |        -- |
| 36F  | 20Hz | 2 - 3 | Boost Control Output         |                  0.10% | --    |      1.11 |
| 36F  | 20Hz | 4 - 5 | Timed Duty Output Duty 1     |                  0.10% | --    |      1.11 |
| 36F  | 20Hz | 6 - 7 | Timed Duty Output Duty 2     |                  0.10% | --    |      1.11 |
| 370  | 20Hz | 0 - 1 | Wheelspeed General           |               0.1 km/h | 1.11  |      1.11 |
| 370  | 20Hz | 2 - 3 | Gear                         | 0 = neutral, 1 = first | 1.11  |      1.11 |
| 370  | 20Hz | 4 - 5 | Intake Cam Angle #1          |                   0.1° | 1.11  |      1.11 |
| 371  |      | 6 - 7 | Intake Cam Angle #2          |                   0.1° | 1.11  |      1.11 |
| 371  |      | 0 - 1 | Fuel Flow                    |              mL/minute | --    |      1.11 |
| 371  |      | 2 - 3 | Fuel Flow Return             |              mL/minute | --    |      1.11 |
| 371  | 10Hz | 4 - 5 | Fuel Flow Differential       |              mL/minute | --    |      1.11 |
| 371  |      |     6 | Reserved                     |                        | --    |        -- |
| 371  |      |     7 | Reserved                     |                        | --    |        -- |
| 372  | 10Hz | 0 - 1 | Battery Voltage              |             0.1 V olts | 1.11  |      1.11 |
| 372  | 10Hz | 2 - 3 | Air Temp Sensor 2            |             0.1 Kelvin | --    |      1.11 |
| 372  | 10Hz | 4 - 5 | Target Boost Level           |                0.1 kPa | 1.11  |      1.11 |
| 372  | 10Hz | 6 - 7 | Barometric Pressure          |                0.1 kPa | 1.11  |      1.11 |
| 373  | 10Hz | 0 - 1 | EGT 1                        |             0.1 Kelvin | 1.11  |      1.11 |
| 373  | 10Hz | 2 - 3 | EGT 2                        |             0.1 Kelvin | 1.11  |      1.11 |
| 373  | 10Hz | 4 - 5 | EGT 3                        |             0.1 Kelvin | 1.11  |      1.11 |
|      |      | 6 - 7 | EGT 4                        |             0.1 Kelvin | 1.11  |      1.11 |
|      |      | 0 - 1 | EGT 5                        |             0.1 Kelvin | 1.11  |      1.11 |
| 374  | 10Hz | 2 - 3 | EGT 6                        |             0.1 Kelvin | 1.11  |      1.11 |
|      |      | 4 - 5 | EGT 7                        |             0.1 Kelvin | 1.11  | 1.11 1.11 |
|      |      | 6 - 7 | EGT 8                        |             0.1 Kelvin | 1.11  |           |
| 375  |      | 0 - 1 | EGT 9                        |             0.1 Kelvin | 1.11  |      1.11 |
| 375  |  10H | 2 - 3 | EGT 10                       |             0.1 Kelvin | 1.11  |      1.11 |
| 375  |    z | 4 - 5 | EGT 11                       |             0.1 Kelvin | 1.11  |      1.11 |
| 375  |      | 6 - 7 | EGT 12                       |             0.1 Kelvin | 1.11  |      1.11 |
| 3    |  5Hz | 0 - 1 | Coolant Temp                 |             0.1 Kelvin | 1.11  |      1.11 |
| 3    |      | 2 - 3 | Air Temp                     |             0.1 Kelvin | 1.11  |      1.11 |
| 3    |      | 4 - 5 | Fuel Temp                    |             0.1 Kelvin | 1.11  |      1.11 |
| 3    |      | 6 - 7 | Oil Temp                     |             0.1 Kelvin | 1.11  |      1.11 |
| 30   |      | 0 - 1 | Transmission Oil Temp        |             0.1 Kelvin | --    |      1.11 |
| 30   |      | 2 - 3 | Diff Oil Temp                |             0.1 Kelvin | --    |      1.11 |
| 30   |  5Hz | 4 - 5 | Fuel Composition             |                  0.10% | --    |      1.11 |
| 30   |      | 6 - 7 | Reserved                     |                        | --    |        -- |
| 300  |      | 0 - 1 | Reserved (Fuel Level)        |                        | --    |        -- |
| 300  |      | 2 - 3 | Fuel Consumption Rate        |                0.01L/h | 1.11  |      1.11 |
| 300  |  5Hz |  4 -5 | Average Fuel Economy         |             0.1L/100km | 1.11  |      1.11 |
| 300  |      | 6 - 7 | Reserved (Distance to Empty) |                     km | --    |        -- |
| 3000 |      | 0 - 1 | Fuel Trim Short Term Bank 1  |                  0.10% | --    |      1.11 |
| 3000 |      | 2 - 3 | Fuel Trim Short Term Bank 2  |                  0.10% | --    |      1.11 |
| 3000 |  5Hz | 4 - 5 | Fuel Trim Long Term Bank 1   |                  0.10% | --    |      1.11 |
| 3000 |      | 6 - 7 | Fuel Trim Long Term Bank 2   |                  0.10% | --    |      1.11 |
|      |      |   0:0 | Reserved                     |                        | --    |        -- |
|      |      |   1:0 | NOS Switch                   |                 1 = On | 1.11  |      1.11 |
|      |      |   1:1 | NOS Active                   |                 1 = On | 1.11  |      1.11 |
|      |      |   1:2 | Gear Switch State            |                 1 = On | --    |      1.11 |
|      |      |   1:3 | Decel Cut                    |                1 = Cut | 1.11  |      1.11 |
|      |      |   1:4 | Transient Throttle Active    |                 1 = On | 1.11  |      1.11 |
|      |      |   1:5 | Brake Pedal On               |                 1 = On | --    |      1.11 |
|      |      |   1:6 | Clutch Switch                |            1 = Pressed | --    |      1.11 |
|      |      |   1:7 | Reserved                     |                        | --    |        -- |
|      |      |   2:0 | Antilag Launch On            |                 1 = On | 1.11  |      1.11 |
|      |      |   2:1 | Antilag Launch Switch On     |                 1 = On | 1.11  |      1.11 |
|      |      |   2:2 | Aux Rev Limiter Switch       |                 1 = On | 1.11  |      1.11 |
|      |      |   2:3 | Rally Anti Lag Swich         |                 1 = On | 1.11  |      1.11 |
|      |      |   2:4 | Flat Shift State             |                 1 = On | 1.11  |      1.11 |
| 3E4  |  5Hz |   2:5 | Timed Duty Output Active     |                 1 = On | 1.11  |      1.11 |
|      |      |   2:6 | Torque Reduction Active      |                 1 = On | --    |      1.11 |
|      |      |   2:7 | Torque Reduction Cut Active  |                 1 = On | --    |      1.11 |
|      |      |     3 | Reserved                     |                        | --    |        -- |
|      |      |     4 | Reserved                     |                        | --    |        -- |
|      |      |     5 | Reserved                     |                        | --    |        -- |
|      |      |     6 | Reserved                     |                        | --    |        -- |
|      |      |   7:0 | MIL (check engine light)     |                 1 = On | 1.11  |      1.11 |
|      |      |   7:1 | Battery Light                |                 1 = On | 1.11  |      1.11 |
|      |      |   7:2 | Limp Mode Active             |                 1 = On | --    |      1.11 |
|      |      |   7:3 | Left Indicator               |                 1 = On | --    |      1.11 |
|      |      |   7:4 | Right Indicator              |                 1 = On | --    |      1.11 |
|      |      |   7:5 | High Beam Indicator          |                 1 = On | --    |      1.11 |
|      |      |   7:6 | Hand Brake Indicator         |                 1 = On | --    |      1.11 |
|      |      |   7:7 | Reserved                     |                        | --    |        -- |

</div>

## A. Revison History

<div align="center">

| Date | Version | Author | Changes |
| ---- | ------- | ------ | ------- |

</div>
