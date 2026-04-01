---
title: "AEMNet 150505_Public tmps42867qo"
source: /Users/kaiwybornyprismaero/Projects/PT-Prism-Advanced/PowerTuneDigitalOfficial_Prism/docs-misc/Documents-powertune/AEMNet 150505_Public.pdf
date: 2026-03-13 04:04:06 UTC
---

AEMnet v150505 CAN 2.0 Unless otherwise specified all messages are; 29 bit, 500 kBit/sec, 8 data bytes per message Multi -byte data is packed big endian (Motorola format, most significant byte transmitted first)

Bits numbered MSB first, with the MSB = bit7, LSB = bit0

Both unit types (SI &amp; US) should be made available to the customer whenever possible!

Message

ID: 0x01F0A000

Sources: AEM

V2 &amp; EMS - 4 (30 - 6XXX)

Infinity EMS (30 - 71XX)

## 20ms continuous (50hz)

<div align="center">

| Byte  | Bit | Bitmask | Label                                                         |              Data Type |      Scaling Offset | Range |            Scaling | Offset        | Range |                    |
| :---- | :-- | :------ | :------------------------------------------------------------ | ---------------------: | ------------------: | ----: | -----------------: | :------------ | :---- | :----------------- |
| 0 - 1 |     |         | Engine Speed                                                  |        16 bit unsigned |     0.39063 rpm/bit |     0 | 0 to 25,599.94 RPM | <==           | <==   | <==                |
| 2 - 3 |     |         | Engine Load (Deprecated 2014) Use "MAP" in 0x01F0A004 Instead |        16 bit unsigned | 0.00261230481157781 |     0 |       0 to 99.998% | <==           | <==   | <==                |
| 4 - 5 |     |         | Throttle                                                      |        16 bit unsigned |     0.0015259 %/bit |     0 |       0 to 99.998% | <==           | <==   | <==                |
| 6     |     |         | Intake Air Temp                                               | 8 bit signed, 2's comp |         1 Deg C/bit |     0 |     - 128 to 127 C | 1.8 Deg F/bit | 32    | - 198.4 to 260.6 F |
| 7     |     |         | Coolant Temp                                                  | 8 bit signed, 2's comp |         1 Deg C/bit |     0 |     - 128 to 127 C | 1.8 Deg F/bit | 32    | - 198.4 to 260.6 F |

</div>

<p align="center"><img src="<../../.mdassets/AEMNet-150505_Public-tmps42867qo/AEMNet 150505_Public-figure-1.png>" alt="AEMNet 150505_Public-figure-1.png" width="45%"></p>

<p align="center"><img src="<../../.mdassets/AEMNet-150505_Public-tmps42867qo/AEMNet 150505_Public-figure-2.png>" alt="AEMNet 150505_Public-figure-2.png" width="45%"></p>

## Message ID: 0x01F0A001

## Sources: AEM V2 &amp; EMS -4 (30 -6XXX)

20ms continuous

(50hz)

<p align="center"><img src="<../../.mdassets/AEMNet-150505_Public-tmps42867qo/AEMNet 150505_Public-figure-3.png>" alt="AEMNet 150505_Public-figure-3.png" width="45%"></p>

<div align="center">

| Byte  | Bit | Bitmask | Label  |       Data Type |          Scaling | Offset |         Range | Scaling Offset | Range |
| :---- | :-- | :------ | :----- | --------------: | ---------------: | -----: | ------------: | :------------- | :---- |
| 0 - 1 |     |         | ADCR11 | 16 bit unsigned | 0.00007782 V/bit |      0 | 0 to 5.0999 V | <== <==        | <==   |
| 2 - 3 |     |         | ADCR13 | 16 bit unsigned | 0.00007782 V/bit |      0 | 0 to 5.0999 V | <== <==        | <==   |
| 4 - 5 |     |         | ADCR14 | 16 bit unsigned | 0.00007782 V/bit |      0 | 0 to 5.0999 V | <== <==        | <==   |
| 6 - 7 |     |         | ADCR17 | 16 bit unsigned | 0.00007782 V/bit |      0 | 0 to 5.0999 V | <== <==        | <==   |

</div>

## Message ID: 0x01F0A002

## Sources: AEM V2 &amp; EMS -4 (30 -6XXX)

## 20ms continuous (50hz)

<p align="center"><img src="<../../.mdassets/AEMNet-150505_Public-tmps42867qo/AEMNet 150505_Public-figure-4.png>" alt="AEMNet 150505_Public-figure-4.png" width="45%"></p>

<div align="center">

| Byte  | Bit | Bitmask | Label  |       Data Type |
| :---- | :-- | :------ | :----- | --------------: |
| 0 - 1 |     |         | ADCR18 | 16 bit unsigned |
| 2 - 3 |     |         | ADCR15 | 16 bit unsigned |
| 4 - 5 |     |         | ADCR16 | 16 bit unsigned |
| 6 - 7 |     |         | ADCR08 | 16 bit unsigned |

</div>

Message

ID: 0x01F0A003

Sources: AEM

V2

&amp;

EMS

-

Infinity

EMS

(30

## 20ms continuous (50hz)

-

<p align="center"><img src="<../../.mdassets/AEMNet-150505_Public-tmps42867qo/AEMNet 150505_Public-figure-5.png>" alt="AEMNet 150505_Public-figure-5.png" width="45%"></p>

## SI Units ( C / kPa / kph / Lambda )

<p align="center"><img src="<../../.mdassets/AEMNet-150505_Public-tmps42867qo/AEMNet 150505_Public-figure-6.png>" alt="AEMNet 150505_Public-figure-6.png" width="45%"></p>

(30

-

6XXX)

71XX)

## SI Units ( C / kPa / kph / Lambda )

<p align="center"><img src="<../../.mdassets/AEMNet-150505_Public-tmps42867qo/AEMNet 150505_Public-figure-7.png>" alt="AEMNet 150505_Public-figure-7.png" width="45%"></p>

<div align="center">

| Byte  | Bit | Bitmask | Label           |       Data Type |        Scaling Offset | Range |                     | Offset | Scaling Range      |                     |
| :---- | :-- | :------ | :-------------- | --------------: | --------------------: | ----: | ------------------: | :----- | :----------------- | :------------------ |
| 0     |     |         | Lambda #1       |  8 bit unsigned | 0.00390625 Lambda/bit |   0.5 | 0.5 to 1.496 Lambda | 7.325  | 0.057227 AFR/bit   | 7.325 to 21.916 AFR |
| 1     |     |         | Lambda #2       |  8 bit unsigned | 0.00390625 Lambda/bit |   0.5 | 0.5 to 1.496 Lambda | 7.325  | 0.057227 AFR/bit   | 7.325 to 21.916 AFR |
| 2 - 3 |     |         | Vehicle Speed   | 16 bit unsigned |     0.0062865 kph/bit |     0 |   0 to 411.986 km/h | 0      | 0.00390625 mph/bit | 0 to 255.996 MPH    |
| 4     |     |         | Gear Calculated |  8 bit unsigned |                     1 |     0 |            0 to 255 | <==    | <==                | <==                 |
| 5     |     |         | Ign Timing      |  8 bit unsigned |        .35156 Deg/bit |  - 17 |   - 17 to 72.65 Deg | <==    | <==                | <==                 |
| 6 - 7 |     |         | Battery Volts   | 16 bit unsigned |       0.0002455 V/bit |     0 |  0 to 16.089 V olts | <==    | <==                | <==                 |

</div>

## Message ID: 0x01F0A004

## Sources: Infinity EMS (30 -71XX) V96.1 and Later

## 20ms continuous (50hz)

## SI Units ( C / kPa / kph / Lambda )

<p align="center"><img src="<../../.mdassets/AEMNet-150505_Public-tmps42867qo/AEMNet 150505_Public-figure-8.png>" alt="AEMNet 150505_Public-figure-8.png" width="45%"></p>

<div align="center">

| Byte  |     Bit | Bitmask | Label            | Data Type       |               Scaling | Offset |               Range | Scaling          | Offset    | Range                   |
| :---- | ------: | ------: | :--------------- | :-------------- | --------------------: | -----: | ------------------: | :--------------- | :-------- | :---------------------- |
| 0 - 1 |         |         | MAP              | 16 bit unsigned |           0.1 kPa/bit |      0 |    0 to 6,553.5 kPa | 0.014504 PSI/bit | - 14.6960 | - 14.696 to 935.81 PSIg |
| 2     |         |         | VE               | 8 bit unsigned  |               1 %/bit |      0 |           0 to 255% | <==              | <==       | <==                     |
| 3     |         |         | FuelPressure     | 8 bit unsigned  |     0.580151 PSIg/bit |      0 |   0 to 147.939 PSIg | <==              | <==       | <==                     |
| 4     |         |         | OilPressure      | 8 bit unsigned  |     0.580151 PSIg/bit |      0 |   0 to 147.939 PSIg | <==              | <==       | <==                     |
| 5     |         |         | LambdaTarget     | 8 bit unsigned  | 0.00390625 Lambda/bit |    0.5 | 0.5 to 1.496 Lambda | 0.057227 AFR/bit | 7.325     | 7.325 to 21.916 AFR     |
| 6     | 0 (lsb) |       0 | FuelPump         | Boolean         |   0 = false, 1 = true |      0 |                 0/1 | <==              | <==       | <==                     |
|       |       1 |       2 | Fan 1            | Boolean         |   0 = false, 1 = true |      0 |                 0/1 | <==              | <==       | <==                     |
|       |       2 |       4 | Fan 2            | Boolean         |   0 = false, 1 = true |      0 |                 0/1 | <==              | <==       | <==                     |
|       |       3 |       8 | N2O Active       | Boolean         |   0 = false, 1 = true |      0 |                 0/1 | <==              | <==       | <==                     |
|       |       4 |      16 | O2FB Active      | Boolean         |   0 = false, 1 = true |      0 |                 0/1 | <==              | <==       | <==                     |
|       |       5 |      32 | EngineProtectOut | Boolean         |   0 = false, 1 = true |      0 |                 0/1 | <==              | <==       | <==                     |
|       |       6 |      64 | MILOutput        | Boolean         |   0 = false, 1 = true |      0 |                 0/1 | <==              | <==       | <==                     |

</div>

## SI Units ( C / kPa / kph / Lambda )

<p align="center"><img src="<../../.mdassets/AEMNet-150505_Public-tmps42867qo/AEMNet 150505_Public-figure-9.png>" alt="AEMNet 150505_Public-figure-9.png" width="45%"></p>

<p align="center"><img src="<../../.mdassets/AEMNet-150505_Public-tmps42867qo/AEMNet 150505_Public-figure-10.png>" alt="AEMNet 150505_Public-figure-10.png" width="45%"></p>

SI Units ( C / kPa / kph / Lambda )

US Units ( F / PSI / MPH / AFR )

<p align="center"><img src="<../../.mdassets/AEMNet-150505_Public-tmps42867qo/AEMNet 150505_Public-figure-11.png>" alt="AEMNet 150505_Public-figure-11.png" width="45%"></p>

## US Units ( F / PSI / MPH / AFR )

<p align="center"><img src="<../../.mdassets/AEMNet-150505_Public-tmps42867qo/AEMNet 150505_Public-figure-12.png>" alt="AEMNet 150505_Public-figure-12.png" width="45%"></p>

## US Units ( F / PSI / MPH / AFR )

<p align="center"><img src="<../../.mdassets/AEMNet-150505_Public-tmps42867qo/AEMNet 150505_Public-figure-13.png>" alt="AEMNet 150505_Public-figure-13.png" width="45%"></p>

## US Units ( F / PSI / MPH / AFR )

<p align="center"><img src="<../../.mdassets/AEMNet-150505_Public-tmps42867qo/AEMNet 150505_Public-figure-14.png>" alt="AEMNet 150505_Public-figure-14.png" width="45%"></p>

## US Units ( F / PSI / MPH / AFR )

<p align="center"><img src="<../../.mdassets/AEMNet-150505_Public-tmps42867qo/AEMNet 150505_Public-figure-15.png>" alt="AEMNet 150505_Public-figure-15.png" width="45%"></p>

<p align="center"><img src="<../../.mdassets/AEMNet-150505_Public-tmps42867qo/AEMNet 150505_Public-figure-16.png>" alt="AEMNet 150505_Public-figure-16.png" width="45%"></p>

<div align="center">

| 7 (msb) | 128 | Lean Protect      | Boolean |                | 0 = false, 1 = true |     0 |  0/1 | <==  | <==  | <==  |
| :------ | --: | :---------------- | :------ | -------------: | :------------------ | ----: | ---: | :--- | :--- | :--- |
| 0 (lsb) |   0 | Oil Press Protect | Boolean | 0 = false, 1 = | true 0              |   0/1 |  <== | <==  |      | <==  |
| 1       |   2 | 2 Step Fuel       | Boolean | 0 = false, 1 = | true                | 0 0/1 |      | <==  | <==  | <==  |
| 2       |   4 | 2 Step Spark      | Boolean | 0 = false, 1 = | true 0              |       |  0/1 | <==  | <==  | <==  |
| 3       |   8 | Sync State        | Boolean |   0 = false, 1 | = true              |     0 |  0/1 | <==  | <==  | <==  |
| 4       |  16 | A/C On            | Boolean |   0 = false, 1 | = true 0            |       |  0/1 | <==  | <==  | <==  |
| 5       |  32 | BoostCut          | Boolean | 0 = false, 1 = | true                |     0 |  0/1 | <==  | <==  | <==  |
| 6       |  64 | ----              | Boolean |                | ----                |  ---- | ---- | ---- | ---- | ---- |
| 7 (msb) | 128 | ----              | Boolean |           ---- | ----                |  ---- |      | ---- | ---- | ---- |

</div>

## Message ID: 0x01F0A005

## Sources: Infinity EMS (30 -71XX) V96.1 and Later

## 20ms continuous (50hz)

SI

Units

(

C

/

kPa

/

kph

/

Lambda

)

US

Units

(

F

/

PSI

/

MPH

/

AFR

)

<div align="center">

| Byte  |     Bit | Bitmask | Label                   |       Data Type |                                       Scaling |                               Offset |                                Range | Scaling                  | Offset   | Range                   |
| :---- | ------: | ------: | :---------------------- | --------------: | --------------------------------------------: | -----------------------------------: | -----------------------------------: | :----------------------- | :------- | :---------------------- |
| 0 - 1 |         |         | LaunchRampTime [ms]     | 16 bit unsigned |                                     10 mS/bit |                                    0 |                      0 to 655,350 mS | <==                      | <==      | <==                     |
| 2 - 3 |         |         | MassAirflow [gms/s]     | 16 bit unsigned |                             .05 [gms/s] / bit |                                    0 |                  0 to 3,276.75 gms/s | .00661387 [lb/min]/bit   | 0        | 0 to 433.440 lb/min     |
| 4 - 5 |         |         | MassAirflow [gms/rev]   | 16 bit unsigned |                         .0005 [gms/rev] / bit |                                    0 |                 0 to 32.7675 gms/rev | .0000661387 [lb/rev]/bit | 0        | 0 to 4.3344 lb/rev      |
| 6     |         |         | Clutch Pressure         |  8 bit unsigned |                                    5 PSIg/bit |                                    0 |                       0 to 1275 PSIg | <==                      | <==      | <==                     |
| 7     | 0 (lsb) |       0 | Brake Sw                |         Boolean |                           0 = false, 1 = true |                                    0 |                                  0/1 | <==                      | <==      | <==                     |
|       |       1 |       2 | Clutch Sw               |         Boolean |                           0 = false, 1 = true |                                    0 |                                  0/1 | <==                      | <==      | <==                     |
|       |       2 |       4 | Shift Sw                |         Boolean |                           0 = false, 1 = true |                                    0 |                                  0/1 | <==                      | <==      | <==                     |
|       |       3 |       8 | Staged Sw               |         Boolean |                           0 = false, 1 = true |                                    0 |                                  0/1 | <==                      | <==      | <==                     |
|       |       4 |      16 | ----                    |         Boolean |                                          ---- |                                 ---- |                                 ---- | ----                     | ----     | ----                    |
|       |       5 |      32 | ----                    |         Boolean |                                          ---- |                                 ---- |                                 ---- | ----                     | ----     | ----                    |
|       |       6 |      64 | ----                    |         Boolean |                                          ---- |                                 ---- |                                 ---- | ----                     | ----     | ----                    |
|       | 7 (msb) |     128 | ----                    |         Boolean |                                          ---- |                                 ---- |                                 ---- | ----                     | ----     | ----                    |
| 0     |         |         | Inj1Pulse               |  8 bit unsigned |                                    0.1 mS/bit |                                    0 |                         0 to 25.5 mS | <==                      | <==      | <==                     |
| 1     |         |         | Inj1LambdaFB            |  8 bit unsigned |                                     0.5 %/bit |                              - 64.00 |                        - 64 to 63.5% | <==                      | <==      | <==                     |
| 2     |         |         | PrimaryInjDuty [%]      |  8 bit unsigned |                                0.392157 %/bit |                                    0 |                            0 to 100% | <==                      | <==      | <==                     |
| 3     |         |         | Mode Sw                 |  8 bit unsigned |                                        1 /bit |                                    0 |                              0 - 255 | <==                      | <==      | <==                     |
| 4     |         |         | Water Pressure          |  8 bit unsigned |                             0.580151 PSIg/bit |                                    0 |                    0 to 147.939 PSIg | <==                      | <==      | <==                     |
| 5     |         |         | Crankcase Pressure      |  8 bit unsigned |                                     1 kPa/bit |                                    0 |                         0 to 255 kPa | 0.14504 PSI/bit          | - 14.696 | - 14.696 to 22.289 PSIg |
| 6 - 7 |         |         | Est Torque              | 16 bit unsigned |                                    0.1 Nm/bit |                             - 3276.8 |                   - 3276.8 to 3276.7 | 0.0737562 ft - lbs/bit   | 0        | +/ - 2416.77 ft - lbs   |
| 0     |         |         | InjectorProbability [%] |  8 bit unsigned |                                0.392157 %/bit |                                    0 |                            0 to 100% | <==                      | <==      | <==                     |
| 1     |         |         | SparkProbability [%]    |  8 bit unsigned |                                0.392157 %/bit |                                    0 |                            0 to 100% | <==                      | <==      | <==                     |
| 2     |         |         | LambdaTrim_Knock        |  8 bit unsigned |                              0.001 Lambda/bit |                                    0 |                    0 to 0.255 Lambda | 0.01465 AFR/bit          | 0        | 0 to 3.73575 AFR        |
| 3     |         |         | Baro Press              |  8 bit unsigned |                                  0.25 kPa/bit |                                   50 |                     50 to 113.75 kPa | 0.073825 inHg/bit        | 14.76    | 14.76 to 33.5903 inHg   |
| 4     |         |         | FlexContent             |  8 bit unsigned |                                0.392157 %/bit |                                    0 |                            0 to 100% | <==                      | <==      | <==                     |
| 5     |         |         | Airbox Temp             |  8 bit unsigned |                                   1 Deg C/bit |                              - 50.00 |                        - 50 to 205 C | 1.8 Deg F/bit            | - 58     | - 58 to 401 F           |
| 6     |         |         | Oil Temp                |  8 bit unsigned |                                   1 Deg C/bit |                              - 50.00 |                        - 50 to 205 C | 1.8 Deg F/bit            | - 58     | - 58 to 401 F           |
| 7     | 0 (lsb) |       0 | LaunchTimerArmed        |         Boolean |                           0 = false, 1 = true |                                    0 |                                  0/1 | <==                      | <==      | <==                     |
| 7     |       1 |       2 | Logging Active          |         Boolean |                           0 = false, 1 = true |                                    0 |                                  0/1 | <==                      | <==      | <==                     |
| 7     |       2 |     4 8 | ModeSelect_Ign          |  2 bit unsigned | ####00## = Mode 1, ####01## = Mode 2 ####10## |                     Mode 3, ####11## |                             = Mode 4 | <==                      | <==      | <==                     |
| 7     |     3 4 |      16 | ModeSelect_Lambda       |  2 bit unsigned |          ##00#### = Mode 1, ##01#### = Mode 2 | ##00#### = Mode 1, ##01#### = Mode 2 | ##00#### = Mode 1, ##01#### = Mode 2 | <==                      | <==      | <==                     |
| 7     |     5 6 |   32 64 | ModeSelect_DBW          |  1 bit unsigned | ##10#### #0###### = Mode 1, #1###### = Mode 2 |                     Mode 3, ##11#### |                             = Mode 4 | <==                      | <==      | <==                     |
| 7     | 7 (msb) |     128 | VTEC                    |         Boolean |                           0 = false, 1 = true |                                    0 |                                  0/1 | <==                      | <==      | <==                     |
| 0     |         |         | Trans Temp              |  8 bit unsigned |                                   1 Deg C/bit |                              - 50.00 |                        - 50 to 205 C | 1.8 Deg F/bit            | - 58     | - 58 to 401 F           |
| 1 - 2 |         |         | SparkCut [RPM]          | 16 bit unsigned |                               0.39063 rpm/bit |                                    0 |                   0 to 25,599.94 RPM | <==                      | <==      | <==                     |
| 3 - 4 |         |         | FuelCut [RPM]           | 16 bit unsigned |                               0.39063 rpm/bit |                                    0 |                   0 to 25,599.94 RPM | <==                      | <==      | <==                     |
| 5     |         |         | 2StepTargetFuel [RPM]   |  8 bit unsigned |                                   100 rpm/bit |                                    0 |                      0 to 25,500 RPM | <==                      | <==      | <==                     |
| 6     |         |         | 2StepTargetSpark [RPM]  |  8 bit unsigned |                                   100 rpm/bit |                                    0 |                      0 to 25,500 RPM | <==                      | <==      | <==                     |
| 7     | 0 (lsb) |       0 | ErrorThrottle           |         Boolean |                           0 = false, 1 = true |                                    0 |                                  0/1 | <==                      | <==      | <==                     |
| 7     |       1 |       2 | ErrorCoolantTemp        |         Boolean |                           0 = false, 1 = true |                                    0 |                                  0/1 | <==                      | <==      | <==                     |
| 7     |       2 |       4 | ErrorFuelPressure       |         Boolean |                           0 = false, 1 = true |                                    0 |                                  0/1 | <==                      | <==      | <==                     |
| 7     |       3 |       8 | ErrorOilPressure        |         Boolean |                           0 = false, 1 = true |                                    0 |                                  0/1 | <==                      | <==      | <==                     |
| 7     |       4 |      16 | ErrorEBP                |         Boolean |                           0 = false, 1 = true |                                    0 |                                  0/1 | <==                      | <==      | <==                     |
| 7     |       5 |      32 | ErrorMAP                |         Boolean |                           0 = false, 1 = true |                                    0 |                                  0/1 | <==                      | <==      | <==                     |
| 7     |       6 |      64 | ErrorAirTemp            |         Boolean |                           0 = false, 1 = true |                                    0 |                                  0/1 | <==                      | <==      | <==                     |
| 7     | 7 (msb) |     128 | ErrorBaro               |         Boolean |                           0 = false, 1 = true |                                    0 |                                  0/1 | <==                      | <==      | <==                     |

</div>

SI

Units

(

C

/

kPa

/

/

/

kph kph

kph

/

/

/

Lambda

Lambda

Lambda

)

)

)

<p align="center"><img src="<../../.mdassets/AEMNet-150505_Public-tmps42867qo/AEMNet 150505_Public-figure-18.png>" alt="AEMNet 150505_Public-figure-18.png" width="45%"></p>

US

US

Units

Units

(

F

/

PSI

/

MPH

/

AFR

)

(

F

/

PSI

/

MPH

US

Units

(

F

/

PSI

/

MPH

/

/

AFR

AFR

)

)

Message ID: 0x01F0A00A Sources: Infinity EMS (30 -71XX) V96.1 and Later, with VVTi control enabled 40ms continuous (25hz) SI Units ( C / kPa / kph / Lambda ) US Units ( F / PSI / MPH / AFR )

SI

Units

(

C

/

kPa

<p align="center"><img src="<../../.mdassets/AEMNet-150505_Public-tmps42867qo/AEMNet 150505_Public-figure-19.png>" alt="AEMNet 150505_Public-figure-19.png" width="45%"></p>

SI

Units

(

C

/

kPa

<p align="center"><img src="<../../.mdassets/AEMNet-150505_Public-tmps42867qo/AEMNet 150505_Public-figure-20.png>" alt="AEMNet 150505_Public-figure-20.png" width="45%"></p>

<p align="center"><img src="<../../.mdassets/AEMNet-150505_Public-tmps42867qo/AEMNet 150505_Public-figure-21.png>" alt="AEMNet 150505_Public-figure-21.png" width="45%"></p>

<p align="center"><img src="<../../.mdassets/AEMNet-150505_Public-tmps42867qo/AEMNet 150505_Public-figure-22.png>" alt="AEMNet 150505_Public-figure-22.png" width="45%"></p>

<div align="center">

| Byte | Bit | Bitmask | Label             |      Data Type |     Scaling | Offset | Range            | Scaling | Offset | Range |
| :--- | :-- | :------ | :---------------- | -------------: | ----------: | :----- | :--------------- | :------ | :----- | :---- |
| 0    |     |         | VVC1A_Cam_Timing  | 8 bit unsigned | 0.5 deg/bit | - 50   | - 50 to 77.5 deg | <==     | <==    | <==   |
| 1    |     |         | VVC2A_Cam_Timing  | 8 bit unsigned | 0.5 deg/bit | - 50   | - 50 to 77.5 deg | <==     | <==    | <==   |
| 2    |     |         | VVC1B_Cam_Timing  | 8 bit unsigned | 0.5 deg/bit | - 50   | - 50 to 77.5 deg | <==     | <==    | <==   |
| 3    |     |         | VVC2B_Cam_Timing  | 8 bit unsigned | 0.5 deg/bit | - 50   | - 50 to 77.5 deg | <==     | <==    | <==   |
| 4    |     |         | VVC1 Target [deg] | 8 bit unsigned | 0.5 deg/bit | - 50   | - 50 to 77.5 deg | <==     | <==    | <==   |
| 5    |     |         | VVC2 Target [deg] | 8 bit unsigned | 0.5 deg/bit | - 50   | - 50 to 77.5 deg | <==     | <==    | <==   |
| 6    |     |         | ----              |           ---- |        ---- | ----   | ----             | ----    | ----   | ----  |
| 7    |     |         | ----              |           ---- |        ---- | ----   | ----             | ----    | ----   | ----  |

</div>

## Message ID: 0x01F0A00B Sources: Infinity EMS (30 -71XX) V96.1 and Later, with Boost control enabled

## 40ms continuous (25hz)

<div align="center">

| Byte  | Bit | Bitmask | Label            |       Data Type | Scaling Offset |   Range |                  | Offset    | Scaling          | Range                   |
| :---- | :-- | :------ | :--------------- | --------------: | -------------: | ------: | ---------------: | :-------- | :--------------- | :---------------------- |
| 0 - 1 |     |         | BoostTarget      | 16 bit unsigned |    0.1 kPa/bit |       0 | 0 to 6,553.5 kPa | - 14.6960 | 0.014504 PSI/bit | - 14.696 to 935.81 PSIg |
| 2 - 3 |     |         | ChargeOutPress   | 16 bit unsigned |    0.1 kPa/bit |       0 | 0 to 6,553.5 kPa | - 14.6960 | 0.014504 PSI/bit | - 14.696 to 935.81 PSIg |
| 4     |     |         | BoostControl [%] |  8 bit unsigned | 0.392157 %/bit |       0 |        0 to 100% | <==       | <==              | <==                     |
| 5     |     |         | BoostFB_PID [%]  |  8 bit unsigned | 0.392157 %/bit |       0 |        0 to 100% | <==       | <==              | <==                     |
| 6     |     |         | ChargeOutTemp    |  8 bit unsigned |    1 Deg C/bit | - 50.00 |    - 50 to 205 C | - 58      | 1.8 Deg F/bit    | - 58 to 401 F           |
| 7     |     |         | TurboSpeed [RPM] |  8 bit unsigned |    500 rpm/bit |       0 | 0 to 127,500 RPM | <==       | <==              | <==                     |

</div>

)

SI

Units

(

C

/

kPa

/

kph

/

Lambda

## Message ID: 0x01F0A00D Sources: Infinity EMS (30 -71XX) V96.1 and Later, with DBW control enabled

40ms

<div align="center">

| Byte |     Bit | Bitmask | Label                 | Data Type      |             Scaling | Offset |     Range | Scaling | Offset | Range |
| :--- | ------: | ------: | :-------------------- | :------------- | ------------------: | -----: | --------: | :------ | :----- | :---- |
| 0    |         |         | DBW_APP1              | 8 bit unsigned |      0.392157 %/bit |      0 | 0 to 100% | <==     | <==    | <==   |
| 1    |         |         | DBW_Target            | 8 bit unsigned |      0.392157 %/bit |      0 | 0 to 100% | <==     | <==    | <==   |
| 2    |         |         | DBW1_TPSA             | 8 bit unsigned |      0.392157 %/bit |      0 | 0 to 100% | <==     | <==    | <==   |
| 3    |         |         | DBW2_TPSA             | 8 bit unsigned |      0.392157 %/bit |      0 | 0 to 100% | <==     | <==    | <==   |
| 4    |         |         | ----                  | ----           |                ---- |   ---- |      ---- | ----    | ----   | ----  |
| 5 6  | 0 (lsb) |       0 | DBW_Error_APP_Corr    | Boolean        | 0 = false, 1 = true |      0 |       0/1 | <==     | <==    | <==   |
|      |       1 |       2 | DBW_Error_APP1_Range  | Boolean        | 0 = false, 1 = true |      0 |       0/1 | <==     | <==    | <==   |
|      |       2 |       4 | DBW_Error_APP2_Range  | Boolean        | 0 = false, 1 = true |      0 |       0/1 | <==     | <==    | <==   |
|      |       3 |       8 | DBW_Error_BTO         | Boolean        | 0 = false, 1 = true |      0 |       0/1 | <==     | <==    | <==   |
|      |       4 |      16 | ----                  | Boolean        |                ---- |   ---- |      ---- | ----    | ----   | ----  |
|      |       5 |      32 | ----                  | Boolean        |                ---- |   ---- |      ---- | ----    | ----   | ----  |
|      |       6 |      64 | ----                  | Boolean        |                ---- |   ---- |      ---- | ----    | ----   | ----  |
|      | 7 (msb) |     128 | ----                  | Boolean        |                ---- |   ---- |      ---- | ----    | ----   | ----  |
|      | 0 (lsb) |       0 | DBW1_Error_Fatal      | Boolean        | 0 = false, 1 = true |      0 |       0/1 | <==     | <==    | <==   |
|      |       1 |       2 | DBW1_Error_TPSA_Range | Boolean        | 0 = false, 1 = true |      0 |       0/1 | <==     | <==    | <==   |
|      |       2 |       4 | DBW1_Error_TPSB_Range | Boolean        | 0 = false, 1 = true |      0 |       0/1 | <==     | <==    | <==   |
|      |       3 |       8 | DBW1_Error_Tracking   | Boolean        | 0 = false, 1 = true |      0 |       0/1 | <==     | <==    | <==   |
|      |       4 |      16 | DBW1_Error_Current    | Boolean        | 0 = false, 1 = true |      0 |       0/1 | <==     | <==    | <==   |
|      |       5 |      32 | DBW1_Error_TPS_Corr   | Boolean        | 0 = false, 1 = true |      0 |       0/1 | <==     | <==    | <==   |
|      |       6 |      64 | ----                  | Boolean        |                ---- |   ---- |      ---- | ----    | ----   | ----  |
|      | 7 (msb) |     128 | ----                  | Boolean        |                ---- |   ---- |      ---- | ----    | ----   | ----  |
|      | 0 (lsb) |       0 | DBW2_Error_Fatal      | Boolean        | 0 = false, 1 = true |      0 |       0/1 | <==     | <==    | <==   |
|      |       1 |       2 | DBW2_Error_TPSA_Range | Boolean        | 0 = false, 1 = true |      0 |       0/1 | <==     | <==    | <==   |
|      |       2 |       4 | DBW2_Error_TPSB_Range | Boolean        | 0 = false, 1 = true |      0 |       0/1 | <==     | <==    | <==   |
|      |       3 |       8 | DBW2_Error_Tracking   | Boolean        | 0 = false, 1 = true |      0 |       0/1 | <==     | <==    | <==   |
| 7    |       4 |      16 | DBW2_Error_Current    | Boolean        | 0 = false, 1 = true |      0 |       0/1 | <==     | <==    | <==   |
|      |       5 |      32 | DBW2_Error_TPS_Corr   | Boolean        | 0 = false, 1 = true |      0 |       0/1 | <==     | <==    | <==   |
|      |       6 |      64 | ----                  | Boolean        |                ---- |   ---- |      ---- | ----    | ----   | ----  |
|      | 7 (msb) |     128 | ----                  | Boolean        |                ---- |   ---- |      ---- | ----    | ----   | ----  |

</div>

continuous

(25hz)

## Message ID: 0x01F0A010

## Sources: Infinity EMS (30 -71XX) V96.1 and Later, with Traction control enabled

## 20ms continuous (50hz)

<div align="center">

| Byte |     Bit | Bitmask | Label                  | Data Type      |             Scaling | Offset |           Range | Scaling | Offset | Range |
| :--- | ------: | ------: | :--------------------- | :------------- | ------------------: | -----: | --------------: | :------ | :----- | :---- |
| 0    |         |         | TC_FuelCut [%]         | 8 bit unsigned |      0.392157 %/bit |      0 |       0 to 100% | <==     | <==    | <==   |
| 1    |         |         | TC_SparkCut [%]        | 8 bit unsigned |      0.392157 %/bit |      0 |       0 to 100% | <==     | <==    | <==   |
| 2    |         |         | TC_Retard [degBTDC]    | 8 bit unsigned |        0.25 deg/bit |      0 |  0 to 63.75 deg | <==     | <==    | <==   |
| 3    |         |         | TC_TqReduceDBW [%]     | 8 bit unsigned |      0.392157 %/bit |      0 |       0 to 100% | <==     | <==    | <==   |
| 4    |         |         | TC\_ Mode_Sw           | 8 bit unsigned |              1 /bit |      0 |         0 - 255 | <==     | <==    | <==   |
| 5    |         |         | 3StepTargetFuel [RPM]  | 8 bit unsigned |         100 rpm/bit |      0 | 0 to 25,500 RPM | <==     | <==    | <==   |
| 6    |         |         | 3StepTargetSpark [RPM] | 8 bit unsigned |         100 rpm/bit |      0 | 0 to 25,500 RPM | <==     | <==    | <==   |
| 7    | 0 (lsb) |       0 | 3 Step Fuel            | Boolean        | 0 = false, 1 = true |      0 |             0/1 | <==     | <==    | <==   |
|      |       1 |       2 | 3 Step Spark           | Boolean        | 0 = false, 1 = true |      0 |             0/1 | <==     | <==    | <==   |
|      |       2 |       4 | 3 Step Sw              | Boolean        | 0 = false, 1 = true |      0 |             0/1 | <==     | <==    | <==   |
|      |       3 |       8 | ----                   | Boolean        | 0 = false, 1 = true |      0 |             0/1 | <==     | <==    | <==   |
|      |       4 |      16 | ----                   | Boolean        | 0 = false, 1 = true |      0 |             0/1 | <==     | <==    | <==   |
| 5    |         |      32 | ----                   | Boolean        | 0 = false, 1 = true |      0 |             0/1 | <==     | <==    | <==   |
| 6    |         |      64 | ----                   | Boolean        | 0 = false, 1 = true |      0 |             0/1 | <==     | <==    | <==   |
| 7    |   (msb) |     128 | ----                   | Boolean        | 0 = false, 1 = true |      0 |             0/1 | <==     | <==    | <==   |

</div>

SI

Units

(

C

/

kPa

/

kph

/

Lambda

)

## Message ID: 0x01F0A011 Sources: Infinity EMS (30 -71XX) V96.1 and Later, with Traction control enabled

## 20ms continuous (50hz)

SI

Units

(

C

/

kPa

/

US

US

US

US

Units

Units

Units

Units

(

(

(

(

F

F

F

F

/

/

/

/

PSI

PSI

PSI

PSI

/

/

/

/

MPH

MPH

MPH

MPH

/

/

/

/

AFR

AFR

AFR

AFR

)

)

)

)

kph

/

Lambda

)

<div align="center">

| Byte  | Bit | Bitmask | Label        |       Data Type |      Scaling |       Offset Range |           Scaling | Offset |            Range |
| :---- | :-- | :------ | :----------- | --------------: | -----------: | -----------------: | ----------------: | -----: | ---------------: |
| 0 - 1 |     |         | DLWheelSpeed | 16 bit unsigned | 0.02 kph/bit | 0 to 1310.7 km/h 0 | 0.0124274 mph/bit |      0 | 0 to 814.431 MPH |
| 2 - 3 |     |         | DRWheelSpeed | 16 bit unsigned | 0.02 kph/bit | 0 0 to 1310.7 km/h | 0.0124274 mph/bit |      0 | 0 to 814.431 MPH |
| 4 - 5 |     |         | NLWheelSpeed | 16 bit unsigned | 0.02 kph/bit | 0 0 to 1310.7 km/h | 0.0124274 mph/bit |      0 | 0 to 814.431 MPH |

</div>

SI

Units

(

C

/

kPa

/

kph

/

Lambda

)

<div align="center">

| 6 - 7 | NRWheelSpeed | 16 bit unsigned | 0.02 | kph/bit | 0 to 1310.7 km/h | 0.0124274 mph/bit | 0   | 0 to 814.431 MPH |
| ----- | ------------ | --------------- | ---- | ------- | ---------------- | ----------------- | --- | ---------------- |

</div>

Message

ID: 0x01F0A012

Sources: Infinity

EMS

20ms

(30

continuous

-

71XX)

V96.1

and

SI

Later,

Units

(

C

/

kPa with

/

kph

/

Traction

Lambda

)

control enabled

<p align="center"><img src="<../../.mdassets/AEMNet-150505_Public-tmps42867qo/AEMNet 150505_Public-figure-23.png>" alt="AEMNet 150505_Public-figure-23.png" width="45%"></p>

Message

(50hz)

ID: 0x01F0A020

## Sources: Infinity EMS (30 -71XX) V96.1 and Later, with Knock control enabled

20ms

<p align="center"><img src="<../../.mdassets/AEMNet-150505_Public-tmps42867qo/AEMNet 150505_Public-figure-24.png>" alt="AEMNet 150505_Public-figure-24.png" width="45%"></p>

Message continuous

(50hz)

ID: 0x01F0A021

## Sources: Infinity EMS (30 -71XX) V96.1 and Later, with Extended Knock control enabled

20ms

<p align="center"><img src="<../../.mdassets/AEMNet-150505_Public-tmps42867qo/AEMNet 150505_Public-figure-25.png>" alt="AEMNet 150505_Public-figure-25.png" width="45%"></p>

SI

Units

(

C

/

continuous

(50hz)

kPa

/

kph

/

Lambda

)

US

Units

(

(

(

F

F

F

/

/

/

## Message ID: 0x0000001F Sources: AEM 4 Channel UEGO (P/N 30 -2340) set on MODE 1 30 -2340N is the same except 11 bit messages headers and at 1 mBit/sec bus speed

10ms

<p align="center"><img src="<../../.mdassets/AEMNet-150505_Public-tmps42867qo/AEMNet 150505_Public-figure-26.png>" alt="AEMNet 150505_Public-figure-26.png" width="45%"></p>

<div align="center">

| Byte  | Bit | Bitmask | Label    |       Data Type | Scaling          | Offset |              Range | Scaling Offset    |            Range |
| :---- | :-- | :------ | :------- | --------------: | :--------------- | -----: | -----------------: | :---------------- | ---------------: |
| 0 - 1 |     |         | Lambda 1 | 16 bit unsigned | .0001 Lambda/bit |      0 | 0 to 6.5535 Lambda | .001465 AFR/bit 0 | 0 to 96.0088 AFR |
| 2 - 3 |     |         | Lambda 2 | 16 bit unsigned | .0001 Lambda/bit |      0 | 0 to 6.5535 Lambda | .001465 AFR/bit 0 | 0 to 96.0088 AFR |
| 4 - 5 |     |         | Lambda 3 | 16 bit unsigned | .0001 Lambda/bit |      0 | 0 to 6.5535 Lambda | .001465 AFR/bit 0 | 0 to 96.0088 AFR |
| 6 - 7 |     |         | Lambda 4 | 16 bit unsigned | .0001 Lambda/bit |      0 | 0 to 6.5535 Lambda | .001465 AFR/bit 0 | 0 to 96.0088 AFR |

</div>

SI

Units

(

C

/

kPa

/

kph

/

Lambda

)

US

Units

(

F

/

continuous

(100hz)

## Message ID: 0x00000020 Sources: AEM 4 Channel UEGO (P/N 30 -2340) set on MODE 2 30 -2340N is the same except 11 bit messages headers and at 1 mBit/sec bus speed

10ms

<div align="center">

| Byte  | Bit | Bitmask | Label    |       Data Type | Scaling          | Offset |              Range | Scaling Offset    |            Range |
| :---- | :-- | :------ | :------- | --------------: | :--------------- | -----: | -----------------: | :---------------- | ---------------: |
| 0 - 1 |     |         | Lambda 5 | 16 bit unsigned | .0001 Lambda/bit |      0 | 0 to 6.5535 Lambda | .001465 AFR/bit 0 | 0 to 96.0088 AFR |
| 2 - 3 |     |         | Lambda 6 | 16 bit unsigned | .0001 Lambda/bit |      0 | 0 to 6.5535 Lambda | .001465 AFR/bit 0 | 0 to 96.0088 AFR |
| 4 - 5 |     |         | Lambda 7 | 16 bit unsigned | .0001 Lambda/bit |      0 | 0 to 6.5535 Lambda | .001465 AFR/bit 0 | 0 to 96.0088 AFR |
| 6 - 7 |     |         | Lambda 8 | 16 bit unsigned | .0001 Lambda/bit |      0 | 0 to 6.5535 Lambda | .001465 AFR/bit 0 | 0 to 96.0088 AFR |

</div>

SI

Units

(

C

/

kPa

/

kph

/

Lambda

)

continuous

(100hz)

## Message ID: 0x00000021 Sources: AEM 4 Channel UEGO (P/N 30 -2340) set on MODE 3

## 30 -2340N is the same except 11 bit messages headers and at 1 mBit/sec bus speed

10ms continuous

(100hz)

SI

Units

(

C

/

kPa

/

kph

/

Lambda

)

US

Units

(

F

/

<div align="center">

| Byte  | Bit | Bitmask | Label    |       Data Type | Scaling          | Offset |              Range | Scaling Offset    |            Range |
| :---- | :-- | :------ | :------- | --------------: | :--------------- | -----: | -----------------: | :---------------- | ---------------: |
| 0 - 1 |     |         | Lambda 1 | 16 bit unsigned | .0001 Lambda/bit |      0 | 0 to 6.5535 Lambda | .001465 AFR/bit 0 | 0 to 96.0088 AFR |
| 2 - 3 |     |         | Lambda 3 | 16 bit unsigned | .0001 Lambda/bit |      0 | 0 to 6.5535 Lambda | .001465 AFR/bit 0 | 0 to 96.0088 AFR |
| 4 - 5 |     |         | Lambda 5 | 16 bit unsigned | .0001 Lambda/bit |      0 | 0 to 6.5535 Lambda | .001465 AFR/bit 0 | 0 to 96.0088 AFR |
| 6 - 7 |     |         | Lambda 7 | 16 bit unsigned | .0001 Lambda/bit |      0 | 0 to 6.5535 Lambda | .001465 AFR/bit 0 | 0 to 96.0088 AFR |

</div>

US

Units

(

F

/

SI

Units

(

C

/

kPa

/

kph

/

Lambda

)

US

US

Units

Units

PSI

PSI

PSI

PSI

PSI

PSI

/

/

/

/

/

/

MPH

MPH

MPH

MPH

MPH

MPH

/

/

/

/

/

/

AFR

AFR

AFR

AFR

AFR

AFR

)

)

)

)

)

)

Byte

-

-

-

Byte

-

-

-

Bit

Bit

Bitmask

Bitmask

## Message ID: 0x00000022

Sources: AEM

4 Channel UEGO (P/N 30 -2340) set on MODE 4

## 30 -2340N is the same except 11 bit messages headers and at 1 mBit/sec bus speed

## 10ms continuous (100hz)

<div align="center">

| Byte  | Bit | Bitmask | Label    |       Data Type | Scaling          | Offset |              Range | Scaling Offset    |            Range |
| :---- | :-- | :------ | :------- | --------------: | :--------------- | -----: | -----------------: | :---------------- | ---------------: |
| 0 - 1 |     |         | Lambda 2 | 16 bit unsigned | .0001 Lambda/bit |      0 | 0 to 6.5535 Lambda | .001465 AFR/bit 0 | 0 to 96.0088 AFR |
| 2 - 3 |     |         | Lambda 4 | 16 bit unsigned | .0001 Lambda/bit |      0 | 0 to 6.5535 Lambda | .001465 AFR/bit 0 | 0 to 96.0088 AFR |
| 4 - 5 |     |         | Lambda 6 | 16 bit unsigned | .0001 Lambda/bit |      0 | 0 to 6.5535 Lambda | .001465 AFR/bit 0 | 0 to 96.0088 AFR |
| 6 - 7 |     |         | Lambda 8 | 16 bit unsigned | .0001 Lambda/bit |      0 | 0 to 6.5535 Lambda | .001465 AFR/bit 0 | 0 to 96.0088 AFR |

</div>

## Message ID: 0x00000023

Sources: AEM

4 Channel UEGO (P/N 30 -2340) set on MODE 5

-

2340N

is the

## 10ms continuous (100hz)

same except

SI

(P/N

bit messages

Units

except

UEGO

same

Scaling

.0001

Lambda/bit

.0001

.0001

Lambda/bit

Lambda/bit

---

---

UEGO

same

(P/N

except

Scaling

.0001

Lambda/bit

.0001

.0001

Failsafe headers

/

(

C

/

-

kPa

/

kph

Lambda

2340.

)

set on

MODE

bit messages

SI

Units

(

headers

C

Lambda

/

kPa

/

kph

/

Offset

---

--- set

-

2340.

MODE

on bit

SI

Units

(

)

Range

to

to

6.5535

Lambda

6.5535

to

6.5535

---

---

messages headers

C

Lambda

/

kPa

/

kph

/

Offset

---

---

-

/

kPa and

at

mBit/sec

US

bus

US

mBit/sec bus

US

Scaling

.001465

AFR/bit

.001465

AFR/bit

.001465

AFR/bit

---

---- mBit/sec

bus

US

Scaling

.001465

AFR/bit

.001465

AFR/bit

.001465

AFR/bit

---

---

Units

(

F

/

speed

Units

(

F

/

speed

Units

PSI

(

F

/

/

Offset

---

---

<div align="center">

| Byte  | Bit | Bitmask | Label     |       Data Type | Scaling          | Offset |              Range | Scaling Offset    |            Range |
| :---- | :-- | :------ | :-------- | --------------: | :--------------- | -----: | -----------------: | :---------------- | ---------------: |
| 0 - 1 |     |         | Lambda 9  | 16 bit unsigned | .0001 Lambda/bit |      0 | 0 to 6.5535 Lambda | .001465 AFR/bit 0 | 0 to 96.0088 AFR |
| 2 - 3 |     |         | Lambda 10 | 16 bit unsigned | .0001 Lambda/bit |      0 | 0 to 6.5535 Lambda | 0 .001465 AFR/bit | 0 to 96.0088 AFR |
| 4 - 5 |     |         | Lambda 11 | 16 bit unsigned | .0001 Lambda/bit |      0 | 0 to 6.5535 Lambda | .001465 AFR/bit 0 | 0 to 96.0088 AFR |
| 6 - 7 |     |         | Lambda 12 | 16 bit unsigned | .0001 Lambda/bit |      0 | 0 to 6.5535 Lambda | .001465 AFR/bit 0 | 0 to 96.0088 AFR |

</div>

Message

ID: 0x00000024

Sources: AEM

Channel

the

-

2340N

is

## 10ms continuous (100hz)

Data

Type

bit unsigned

bit bit

unsigned unsigned

---

---

Label

Lambda

Lambda

Lambda

---

---

Message

ID: 0x00000025

Sources: AEM

Channel

-

2340N

is the

## 10ms continuous (100hz)

Data

Type

unsigned bit

bit bit

unsigned unsigned

---

---

Label

Lambda

Lambda

Lambda

---

---

Message

ID: 0x00000026

Sources: AEM

Wideband

10ms continuous

(100hz)

Lambda/bit

Lambda/bit

---

---

Gauge

SI

(P/N

Units

(

C

4900.

/

kph

/

Lambda

<div align="center">

| Byte  |     Bit | Bitmask | Label                       | Data Type       |             Scaling |    Offset |                    Range | Scaling         | Offset | Range              |
| :---- | ------: | ------: | :-------------------------- | :-------------- | ------------------: | --------: | -----------------------: | :-------------- | :----- | :----------------- |
| 0 - 1 |         |         | Lambda                      | 16 bit unsigned |    .0001 Lambda/bit |         0 |       0 to 6.5535 Lambda | .001465 AFR/bit | 0      | 0 to 96.0088 AFR   |
| 2 - 3 |         |         | Pressure                    | 16 bit unsigned |  0.00689476 kPa/bit | - 2.09636 | - 2.09636 to 449.752 kPa | .001 PSI/bit    | - 15   | - 15 to 50.535 PSI |
| 4 - 5 |         |         | RPM                         | 16 bit unsigned |      .39063 RPM/bit |         0 |          0 to 25,600 RPM | <==             | <==    | <==                |
| 6     | 0 (lsb) |       0 | AFR Ready                   | Boolean         | 0 = false, 1 = true |         0 |                      0/1 | <==             | <==    | <==                |
| 6     |       1 |       2 | AFR Heater Open Error       | Boolean         | 0 = false, 1 = true |         0 |                      0/1 | <==             | <==    | <==                |
| 6     |       2 |       4 | AFR CJ125 Error             | Boolean         | 0 = false, 1 = true |         0 |                      0/1 | <==             | <==    | <==                |
| 6     |       3 |       8 | AFR Sensor Heating Up       | Boolean         | 0 = false, 1 = true |         0 |                      0/1 | <==             | <==    | <==                |
| 6     |       4 |      16 | AFR Low Voltage             | Boolean         | 0 = false, 1 = true |         0 |                      0/1 | <==             | <==    | <==                |
| 6     |       5 |      32 | AFR Heater Time - Out Error | Boolean         | 0 = false, 1 = true |         0 |                      0/1 | <==             | <==    | <==                |
| 6     |       6 |      64 | AFR Heater Short Error      | Boolean         | 0 = false, 1 = true |         0 |                      0/1 | <==             | <==    | <==                |
| 6     | 7 (msb) |     128 | AFR Overtemp Error          | Boolean         | 0 = false, 1 = true |         0 |                      0/1 | <==             | <==    | <==                |
| 7     | 0 (lsb) |       0 | Alarm Status                | Boolean         | 0 = false, 1 = true |         0 |                      0/1 | <==             | <==    | <==                |
| 7     |       1 |       2 | Alarm Source                | Boolean         | 0 = false, 1 = true |         0 |                      0/1 | <==             | <==    | <==                |
| 7     |       2 |       4 | Alarm Source                | Boolean         | 0 = false, 1 = true |         0 |                      0/1 | <==             | <==    | <==                |
| 7     |       3 |       8 | Alarm Source                | Boolean         | 0 = false, 1 = true |         0 |                      0/1 | <==             | <==    | <==                |
| 7     |       4 |      16 | ---                         | Boolean         |                 --- |       --- |                      --- | ----            | ----   | ----               |
| 7     |       5 |      32 | ---                         | Boolean         |                 --- |       --- |                      --- | ----            | ----   | ----               |
| 7     |       6 |      64 | ---                         | Boolean         |                 --- |       --- |                      --- | ----            | ----   | ----               |
| 7     | 7 (msb) |     128 | ---                         | Boolean         |                 --- |       --- |                      --- | ----            | ----   | ----               |

</div>

<p align="center"><img src="<../../.mdassets/AEMNet-150505_Public-tmps42867qo/AEMNet 150505_Public-figure-27.png>" alt="AEMNet 150505_Public-figure-27.png" width="45%"></p>

and

)

Range

to

to to

6.5535

Lambda

6.5535

6.5535

---

---

Lambda

Lambda

Lambda

Lambda

## SI Units ( C / kPa / kph / Lambda )

)

and at

at

speed

Units

/

(

F

/

PSI

Offset

---

)

Range

96.0088

96.0088

96.0088

---

---

## US Units ( F / PSI / MPH / AFR )

---

PSI

PSI

/

/

MPH

MPH

MPH

MPH

/

/

/

/

AFR

AFR

AFR

to

to

to

AFR

to

to to

)

)

)

Range

96.0088

96.0088

96.0088

---

---

AFR

AFR

AFR

AFR

AFR

AFR

## Message ID: 0x00000027 Sources: AEM Wideband Failsafe Gauge (P/N 30 -4900)

10ms

<div align="center">

| Byte  | Bit | Bitmask | Label               |       Data Type | Scaling          | Offset |              Range | Scaling Offset    | Range            |
| :---- | :-- | :------ | :------------------ | --------------: | :--------------- | -----: | -----------------: | :---------------- | :--------------- |
| 0 - 1 |     |         | Lambda Upper Limit  | 16 bit unsigned | .0001 Lambda/bit |      0 | 0 to 6.5535 Lambda | .001465 AFR/bit 0 | 0 to 96.0088 AFR |
| 2 - 3 |     |         | Lambda Lower Limit  | 16 bit unsigned | .0001 Lambda/bit |      0 | 0 to 6.5535 Lambda | .001465 AFR/bit 0 | 0 to 96.0088 AFR |
| 4 - 5 |     |         | Alarm Delay Limit   | 16 bit unsigned | 1 mS/bit         |      0 |     0 to 65,535 mS | <== <==           | <==              |
| 6 - 7 |     |         | Alarm Delay Counter | 16 bit unsigned | 1 mS/bit         |      0 |     0 to 65,535 mS | <== <==           | <==              |

</div>

SI

Units

(

C

/

kPa

/

kph

/

Lambda continuous

(100hz)

## Message ID: 0x00000028 Sources: AEM Wideband Failsafe Gauge (P/N 30 -4900)

10ms

<div align="center">

| Byte  | Bit | Bitmask | Label               |       Data Type |            Scaling |  Offset |                    Range | Scaling Offset    | Range              |
| :---- | :-- | :------ | :------------------ | --------------: | -----------------: | ------: | -----------------------: | :---------------- | :----------------- |
| 0 - 1 |     |         | Alarm Lambda        | 16 bit unsigned |   .0001 Lambda/bit |       0 |       0 to 6.5535 Lambda | 0 .001465 AFR/bit | 0 to 96.0088 AFR   |
| 2 - 3 |     |         | Alarm Pressure      | 16 bit unsigned | 0.00689476 kPa/bit | 2.09636 | - 2.09636 to 449.752 kPa | .001 PSI/bit - 15 | - 15 to 50.535 PSI |
| 4 - 5 |     |         | Alarm Reset Limit   | 16 bit unsigned |           1 mS/bit |       0 |           0 to 65,535 mS | <== <==           | <==                |
| 6 - 7 |     |         | Alarm Reset Counter | 16 bit unsigned |           1 mS/bit |       0 |           0 to 65,535 mS | <== <==           | <==                |

</div>

US

US

Units

Units

(

(

F

F

/

/

SI

Units

(

C

/

kPa

/

kph

/

Lambda

)

)

(100hz)

only in

alarm mode

## Message ID: 0x000001AF Sources: AEM 4 Channel UEGO (P/N 30 -2340) set on MODE 1 30 -2340N is the same except 11 bit messages headers and at 1 mBit/sec bus speed

40ms

<div align="center">

|        |       Bit | Bitmask | Label                                                  | Data Type       |                                 Scaling | Offset |                Range | Scaling  | Offset      | Range         |
| :----- | --------: | ------: | :----------------------------------------------------- | :-------------- | --------------------------------------: | -----: | -------------------: | :------- | :---------- | :------------ |
| Byte 0 |   0 (lsb) |       0 | AFR 1 Ready                                            | Boolean 0 =     |                         false, 1 = true |      0 |              0/1 <== |          | <==         | <==           |
|        |         1 |       2 | AFR 1 Heater Open Error                                | Boolean         |                     0 = false, 1 = true |      0 |              0/1 <== |          | <==         | <==           |
|        |         2 |       4 | AFR 1 VMError                                          | Boolean         |                     0 = false, 1 = true |      0 |                  0/1 | <==      | <==         | <==           |
|        |         3 |       8 | AFR 1 UN Error                                         | Boolean         |                     0 = false, 1 = true |      0 |                  0/1 | <==      | <==         | <==           |
|        |         4 |      16 | AFR 1 IP Error                                         | Boolean         |                     0 = false, 1 = true |  0 0/1 |                      | <==      | <==         | <==           |
|        |         5 |      32 | AFR 1 Heater Time - Out Error                          | Boolean         |                     0 = false, 1 = true |      0 |                  0/1 | <==      | <==         | <==           |
|        |         6 |      64 | AFR 1 Heater Short Error                               | Boolean         |                     0 = false, 1 = true |      0 |                  0/1 | <==      | <==         | <==           |
|        |   7 (msb) |     128 | AFR 1 Overtemp Error                                   | Boolean         |                     0 = false, 1 = true |      0 |                  0/1 | <==      | <==         | <==           |
|        |   0 (lsb) |       0 | AFR 2 Ready                                            | Boolean         |                     0 = false, 1 = true |      0 |                  0/1 | <==      | <==         | <==           |
|        |         1 |       2 | AFR 2 Heater Open Error                                | Boolean         |                     0 = false, 1 = true |      0 |                  0/1 | <==      | <==         | <==           |
|        |         2 |       4 | AFR 2 VMError                                          | Boolean         |                     0 = false, 1 = true |      0 |                  0/1 | <==      | <==         | <==           |
|        |         3 |       8 | AFR 2 UN Error                                         | Boolean         |                     0 = false, 1 = true |      0 |                  0/1 | <==      | <==         | <==           |
| 1      |         4 |      16 | AFR 2 IP Error                                         | Boolean         |                     0 = false, 1 = true |      0 |                  0/1 | <==      | <==         | <==           |
|        |         5 |      32 | AFR 2 Heater Time - Out Error                          | Boolean         |                     0 = false, 1 = true |      0 |                  0/1 | <==      | <==         | <==           |
|        |         6 |      64 | AFR 2 Heater Short Error                               | Boolean         |                     0 = false, 1 = true |      0 |                  0/1 | <==      | <==         | <==           |
|        |   7 (msb) |     128 | AFR 2 Overtemp Error                                   | Boolean         |                     0 = false, 1 = true |      0 |                  0/1 | <==      | <==         | <==           |
|        |   0 (lsb) |       0 | AFR 3 Ready                                            | Boolean         |                     0 = false, 1 = true |      0 |                  0/1 | <==      | <==         | <==           |
|        |         1 |       2 | AFR 3 Heater Open Error                                | Boolean         |                     0 = false, 1 = true |      0 |                  0/1 | <==      | <==         | <==           |
|        |         2 |       4 | AFR 3 VMError                                          | Boolean         |                     0 = false, 1 = true |      0 |                  0/1 | <==      | <==         | <==           |
|        |         3 |       8 | AFR 3 UN Error                                         | Boolean         |                     0 = false, 1 = true |      0 |                  0/1 | <==      | <==         | <==           |
| 2      |         4 |      16 | AFR 3 IP Error                                         | Boolean         |                     0 = false, 1 = true |      0 |                  0/1 | <==      | <==         | <==           |
|        |         5 |      32 | AFR 3 Heater Time - Out Error                          | Boolean         |                     0 = false, 1 = true |      0 |                  0/1 | <==      | <==         | <==           |
|        |         6 |      64 | AFR 3 Heater Short Error                               | Boolean         |                     0 = false, 1 = true |      0 |                  0/1 | <==      | <==         | <==           |
|        |   7 (msb) |     128 | AFR 3 Overtemp Error                                   | Boolean         |                     0 = false, 1 = true |      0 |                  0/1 | <==      | <==         | <==           |
|        |   0 (lsb) |       0 | AFR 4 Ready                                            | Boolean         |                     0 = false, 1 = true |      0 |                  0/1 | <==      | <==         | <==           |
|        |         1 |       2 | AFR 4 Heater Open Error                                | Boolean         |                     0 = false, 1 = true |      0 |                  0/1 | <==      | <==         | <==           |
|        |         2 |       4 | AFR 4 VMError                                          | Boolean         |                     0 = false, 1 = true |      0 |                  0/1 | <==      | <==         | <==           |
|        |         3 |       8 | AFR 4 UN Error                                         | Boolean         |                     0 = false, 1 = true |      0 |                  0/1 | <==      | <==         | <==           |
| 3      |         4 |      16 | AFR 4 IP Error                                         | Boolean         |                     0 = false, 1 = true |      0 |                  0/1 | <==      | <==         | <==           |
|        |       5 6 |   32 64 | AFR 4 Heater Time - Out Error AFR 4 Heater Short Error | Boolean Boolean | 0 = false, 1 = true 0 = false, 1 = true |    0 0 |              0/1 0/1 | <== <==  | <== <==     | <== <==       |
|        |   7 (msb) |     128 | AFR 4 Overtemp Error                                   | Boolean         |                     0 = false, 1 = true |      0 |                  0/1 | <==      | <==         | <==           |
|        | 0 (lsb) 1 |     0 2 | UEGO Low Voltage Error EBP sensor ready                | Boolean Boolean | 0 = false, 1 = true 0 = false, 1 = true |    0 0 |              0/1 0/1 | <== <==  | <== <== <== | <== <==       |
|        |         2 |       4 | EBP sensor Error Low Volt                              | Boolean         |                     0 = false, 1 = true |      0 |                  0/1 | <==      |             | <==           |
| 4      |         3 |       8 | EBP sensor detected                                    | Boolean         |                     0 = false, 1 = true |      0 |                  0/1 | <==      | <==         | <==           |
|        |         4 |      16 | CAN Config Mode                                        | Boolean         |                     0 = false, 1 = true |      0 |                  0/1 | <==      | <==         | <==           |
|        |         5 |      32 | CAN Config Mode                                        | Boolean         |                     0 = false, 1 = true |        |                  0/1 | <==      | <==         | <==           |
|        |         6 |      64 | CAN Config Mode                                        | Boolean         |                                         |      0 |                  0/1 | <==      | <==         |               |
|        |           |         |                                                        |                 |                     0 = false, 1 = true |      0 |                      |          |             | <==           |
|        |   7 (msb) |     128 | CAN Config Mode                                        | Boolean         |                     0 = false, 1 = true |      0 |                  0/1 | <==      | <==         | <==           |
| 5      |   0 (lsb) |       0 | Reserved                                               | Boolean         |                     0 = false, 1 = true |      0 |                  0/1 | <==      | <==         | <==           |
| 5      |         1 |       2 | Reserved                                               | Boolean         |                     0 = false, 1 = true |      0 |                  0/1 | <==      | <==         | <==           |
| 5      |       2 3 |       4 | Reserved                                               | Boolean         |                     0 = false, 1 = true |    0 0 |                  0/1 | <==      | <== <==     | <==           |
| 5      |         4 |       8 | Reserved                                               | Boolean         |                     0 = false, 1 = true |        |                  0/1 | <==      | <==         | <== <==       |
| 5      |           |      16 | Sensor 4 Heating up                                    | Boolean         |                     0 = false, 1 = true |      0 |                  0/1 | <==      |             |               |
| 5      |       5 6 |   32 64 | Sensor 3 Heating up Sensor 2 Heating up                | Boolean Boolean | 0 = false, 1 = true 0 = false, 1 = true |    0 0 |              0/1 0/1 | <== <==  | <== <==     | <== <==       |
|        |   7 (msb) |     128 | Sensor 1 Heating up Exhaust Pressure 1                 | Boolean 16 bit  |          0 = false, 1 = true 0.00689476 |      0 | 0/1 to 4,518.48 kPag | <== .001 | <== 0       | <== to 655.35 |
| 6 - 7  |           |         |                                                        | unsigned        |                                kPag/bit |      0 |                    0 | psig/bit |             | 0 psig        |

</div>

SI

Units

(

C

/

kPa

/

kph

/

Lambda

)

US

Units

(

F

/

continuous

(25hz)

## Message ID: 0x000001B0 Sources: AEM 4 Channel UEGO (P/N 30 -2340) set on MODE 2 30 -2340N is the same except 11 bit messages headers and at 1 mBit/sec bus speed

40ms continuous

(25hz)

SI

Units

(

C

/

kPa

/

kph

/

Lambda

)

US

Units

(

F

/

<div align="center">

| Byte Bit Bitmask | Label | Data Type | Scaling | Offset | Range | Scaling | Offset | Range |
| ---------------- | ----- | --------- | ------- | ------ | ----- | ------- | ------ | ----- |

</div>

PSI

PSI

PSI

PSI

/

/

/

/

MPH

MPH

MPH

MPH

/

/

/

/

AFR

AFR

AFR

AFR

)

)

)

)

<div align="center">

|     |         0 (lsb) |     0 | AFR 5 Ready                                 | Boolean                     |                 0 = false, 1 = true |                    0 | 0/1 <==       | <==     | <==              |
| :-- | --------------: | ----: | :------------------------------------------ | :-------------------------- | ----------------------------------: | -------------------: | :------------ | :------ | :--------------- |
|     |               1 |     2 | AFR 5 Heater Open Error                     | Boolean 0 = false, 1 = true |                                   0 |                  0/1 | <==           | <==     | <==              |
|     |               2 |     4 | AFR 5 VMError                               | Boolean                     |                 0 = false, 1 = true |                0 0/1 | <==           | <==     | <==              |
|     |               3 |     8 | AFR 5 UN Error                              | Boolean                     |                 0 = false, 1 = true |                0 0/1 | <==           | <==     | <==              |
| 0   |               4 |    16 | AFR 5 IP Error                              | Boolean 0 =                 |                   false, 1 = true 0 |                  0/1 | <==           | <==     | <==              |
|     |               5 |    32 | AFR 5 Heater Time - Out Error               | Boolean 0 =                 |                     false, 1 = true |                0 0/1 | <==           | <==     | <==              |
|     |               6 |    64 | AFR 5 Heater Short Error                    | 0 = false,                  |                          1 = true 0 |                  0/1 | <==           | <==     | <==              |
|     |         7 (msb) |   128 | AFR 5 Overtemp Error                        | Boolean Boolean 0 =         |                   false, 1 = true 0 |                  0/1 | <==           | <==     | <==              |
| 1   |         0 (lsb) |     0 | AFR 6 Ready                                 | Boolean                     |                 0 = false, 1 = true |                0 0/1 | <==           | <==     | <==              |
|     |               1 |     2 | AFR 6 Heater Open Error                     | Boolean 0 =                 |                   false, 1 = true 0 |                  0/1 | <==           | <==     | <==              |
|     |               2 |     4 | AFR 6 VMError                               | Boolean 0 =                 |                   false, 1 = true 0 |                  0/1 | <==           | <==     | <==              |
|     |               3 |     8 | AFR 6 UN Error                              | Boolean 0 =                 |                   false, 1 = true 0 |                  0/1 | <==           | <==     | <==              |
|     |               4 |    16 | AFR 6 IP Error                              | Boolean 0 =                 |                   false, 1 = true 0 |                  0/1 | <==           | <==     | <==              |
|     |               5 |    32 | AFR 6 Heater Time - Out Error               | Boolean 0 =                 |                   false, 1 = true 0 |                  0/1 | <==           | <==     | <==              |
|     |               6 |    64 | AFR 6 Heater Short Error                    | Boolean                     |                 0 = false, 1 = true |                0 0/1 | <==           | <==     | <==              |
|     |         7 (msb) |   128 | AFR 6 Overtemp Error                        | Boolean 0 =                 |                   false, 1 = true 0 |                  0/1 | <==           | <==     | <==              |
|     |         0 (lsb) |     0 | AFR 7 Ready                                 | Boolean                     |                 0 = false, 1 = true |                0 0/1 | <==           | <==     | <==              |
|     |               1 |     2 | AFR 7 Heater Open Error                     | Boolean 0 =                 |                     false, 1 = true |                0 0/1 | <==           | <==     | <==              |
|     |               2 |     4 | AFR 7 VMError                               | Boolean 0 =                 |                   false, 1 = true 0 |                  0/1 | <==           | <==     | <==              |
|     |               3 |     8 | AFR 7 UN Error                              | Boolean                     |                 0 = false, 1 = true |                0 0/1 | <==           | <==     | <==              |
| 2   |               4 |    16 | AFR 7 IP Error                              | Boolean 0 =                 |                     false, 1 = true |                0 0/1 | <==           | <==     | <==              |
|     |               5 |    32 | AFR 7 Heater Time - Out Error               | Boolean                     |                 0 = false, 1 = true |                0 0/1 | <==           | <==     | <==              |
|     |               6 |    64 | AFR 7 Heater Short Error                    | Boolean 0 =                 |                   false, 1 = true 0 |                  0/1 | <==           | <==     | <==              |
|     |         7 (msb) |   128 | AFR 7 Overtemp Error                        | Boolean                     |                 0 = false, 1 = true |                0 0/1 | <==           | <==     | <==              |
|     |         0 (lsb) |     0 | AFR 8 Ready                                 | Boolean                     |                 0 = false, 1 = true |                0 0/1 | <==           | <==     | <==              |
|     |               1 |     2 | AFR 8 Heater Open Error                     | Boolean                     |                 0 = false, 1 = true |                0 0/1 | <==           | <==     | <==              |
|     |               2 |     4 | AFR 8 VMError                               | Boolean                     |                 0 = false, 1 = true |                0 0/1 | <==           | <==     | <==              |
|     |               3 |     8 | AFR 8 UN Error                              | Boolean                     |                 0 = false, 1 = true |                0 0/1 | <==           | <==     | <==              |
| 3   |               4 |    16 | AFR 8 IP Error                              | Boolean 0 =                 |                     false, 1 = true |                0 0/1 | <==           | <==     | <==              |
|     |               5 |    32 | AFR 8 Heater Time - Out Error               | Boolean 0                   |                   = false, 1 = true |                0 0/1 | <==           | <==     | <==              |
|     |               6 |    64 | AFR 8 Heater Short Error                    | Boolean 0 =                 |                   false, 1 = true 0 |                  0/1 | <==           | <==     | <==              |
| 4   | 7 (msb) 0 (lsb) | 128 0 | AFR 8 Overtemp Error UEGO Low Voltage Error | Boolean 0 = Boolean 0 =     | false, 1 = true 0 false, 1 = true 0 |              0/1 0/1 | <== <==       | <== <== | <== <==          |
| 4   |               1 |     2 | EBP sensor ready                            | Boolean                     |                 0 = false, 1 = true |                0 0/1 | <==           | <==     | <==              |
| 4   |               2 |     4 | EBP sensor Error Low Volt                   | Boolean                     |                 0 = false, 1 = true |                0 0/1 | <==           | <==     | <==              |
| 4   |               3 |     8 | EBP sensor detected                         | Boolean                     |                 0 = false, 1 = true |                0 0/1 | <==           | <==     | <==              |
| 4   |               4 |    16 | CAN Config Mode                             | Boolean 0 =                 |                   false, 1 = true 0 |                  0/1 | <==           | <==     | <==              |
| 4   |               5 |    32 | CAN Config Mode                             | Boolean                     |                 0 = false, 1 = true |                0 0/1 | <==           | <==     | <==              |
| 4   |               6 |    64 | CAN Config Mode                             | Boolean                     |                 0 = false, 1 = true |                0 0/1 | <==           | <==     | <==              |
| 4   |         7 (msb) |   128 | CAN Config Mode                             | Boolean                     |                 0 = false, 1 = true |                0 0/1 | <==           | <==     | <==              |
| 5   |         0 (lsb) |     0 | Reserved                                    | Boolean                     |                                true |                0 0/1 | <==           | <==     | <==              |
| 5   |               1 |     2 | Reserved                                    | Boolean                     |  0 = false, 1 = 0 = false, 1 = true |                0 0/1 | <==           | <==     | <==              |
| 5   |               2 |     4 | Reserved                                    | Boolean 0 =                 |                     false, 1 = true |                0 0/1 | <==           | <==     | <==              |
| 5   |               3 |     8 | Reserved                                    | Boolean                     |                 0 = false, 1 = true |                0 0/1 | <==           | <==     | <==              |
| 5   |               4 |    16 | Sensor 8 Heating up                         | Boolean                     |                 0 = false, 1 = true |                0 0/1 | <==           | <==     | <==              |
| 5   |               5 |    32 | Sensor 7 Heating up                         | Boolean                     |                 0 = false, 1 = true |                0 0/1 | <==           | <==     | <==              |
| 5   |               6 |    64 | Sensor 6 Heating up                         | Boolean                     |                 0 = false, 1 = true |                0 0/1 | <==           | <==     | <==              |
| 5   |         7 (msb) |   128 | Sensor 5 Heating up                         | Boolean                     |                 0 = false, 1 = true |                0 0/1 | <==           | <==     | <==              |
|     |           6 - 7 | 6 - 7 | Exhaust Pressure 2                          | 16 bit unsigned             |                 0.00689476 kPag/bit | 0 0 to 4,518.48 kPag | .001 psig/bit | 0       | 0 to 655.35 psig |

</div>

## Message ID: 0x000001B1 Sources: AEM 4 Channel UEGO (P/N 30 -2340) set on MODE 3 30 -2340N is the same except 11 bit messages headers and at 1 mBit/sec bus speed

40ms continuous

(25hz)

SI

Units

(

C

/

kPa

/

kph

/

Lambda

)

US

Units

(

F

/

PSI

/

MPH

/

AFR

)

<div align="center">

| Byte |     Bit | Bitmask | Label                         | Data Type |             Scaling | Offset | Range | Scaling | Offset | Range |
| :--- | ------: | ------: | :---------------------------- | :-------- | ------------------: | -----: | ----: | :------ | :----- | :---- |
| 0    | 0 (lsb) |       0 | AFR 1 Ready                   | Boolean   | 0 = false, 1 = true |      0 |   0/1 | <==     | <==    | <==   |
| 0    |       1 |       2 | AFR 1 Heater Open Error       | Boolean   | 0 = false, 1 = true |      0 |   0/1 | <==     | <==    | <==   |
| 0    |       2 |       4 | AFR 1 VMError                 | Boolean   | 0 = false, 1 = true |      0 |   0/1 | <==     | <==    | <==   |
| 0    |       3 |       8 | AFR 1 UN Error                | Boolean   | 0 = false, 1 = true |      0 |   0/1 | <==     | <==    | <==   |
| 0    |       4 |      16 | AFR 1 IP Error                | Boolean   | 0 = false, 1 = true |      0 |   0/1 | <==     | <==    | <==   |
| 0    |       5 |      32 | AFR 1 Heater Time - Out Error | Boolean   | 0 = false, 1 = true |      0 |   0/1 | <==     | <==    | <==   |
| 0    |       6 |      64 | AFR 1 Heater Short Error      | Boolean   | 0 = false, 1 = true |      0 |   0/1 | <==     | <==    | <==   |
| 0    | 7 (msb) |     128 | AFR 1 Overtemp Error          | Boolean   | 0 = false, 1 = true |      0 |   0/1 | <==     | <==    | <==   |
| 1    | 0 (lsb) |       0 | AFR 3 Ready                   | Boolean   | 0 = false, 1 = true |      0 |   0/1 | <==     | <==    | <==   |
| 1    |       1 |       2 | AFR 3 Heater Open Error       | Boolean   | 0 = false, 1 = true |      0 |   0/1 | <==     | <==    | <==   |
| 1    |       2 |       4 | AFR 3 VMError                 | Boolean   | 0 = false, 1 = true |      0 |   0/1 | <==     | <==    | <==   |
| 1    |       3 |       8 | AFR 3 UN Error                | Boolean   | 0 = false, 1 = true |      0 |   0/1 | <==     | <==    | <==   |
| 1    |       4 |      16 | AFR 3 IP Error                | Boolean   | 0 = false, 1 = true |      0 |   0/1 | <==     | <==    | <==   |
| 1    |       5 |      32 | AFR 3 Heater Time - Out Error | Boolean   | 0 = false, 1 = true |      0 |   0/1 | <==     | <==    | <==   |
| 1    |       6 |      64 | AFR 3 Heater Short Error      | Boolean   | 0 = false, 1 = true |      0 |   0/1 | <==     | <==    | <==   |
| 1    | 7 (msb) |     128 | AFR 3 Overtemp Error          | Boolean   | 0 = false, 1 = true |      0 |   0/1 | <==     | <==    | <==   |
| 2    | 0 (lsb) |       0 | AFR 5 Ready                   | Boolean   | 0 = false, 1 = true |      0 |   0/1 | <==     | <==    | <==   |
| 2    |       1 |       2 | AFR 5 Heater Open Error       | Boolean   | 0 = false, 1 = true |      0 |   0/1 | <==     | <==    | <==   |
| 2    |       2 |       4 | AFR 5 VMError                 | Boolean   | 0 = false, 1 = true |      0 |   0/1 | <==     | <==    | <==   |
| 2    |       3 |       8 | AFR 5 UN Error                | Boolean   | 0 = false, 1 = true |      0 |   0/1 | <==     | <==    | <==   |
| 2    |       4 |      16 | AFR 5 IP Error                | Boolean   | 0 = false, 1 = true |      0 |   0/1 | <==     | <==    | <==   |
| 2    |       5 |      32 | AFR 5 Heater Time - Out Error | Boolean   | 0 = false, 1 = true |      0 |   0/1 | <==     | <==    | <==   |
| 2    |       6 |      64 | AFR 5 Heater Short Error      | Boolean   | 0 = false, 1 = true |      0 |   0/1 | <==     | <==    | <==   |
| 3    | 7 (msb) |     128 | AFR 5 Overtemp Error          | Boolean   | 0 = false, 1 = true |      0 |   0/1 | <==     | <==    | <==   |
| 3    | 0 (lsb) |       0 | AFR 7 Ready                   | Boolean   | 0 = false, 1 = true |      0 |   0/1 | <==     | <==    | <==   |
| 3    |       1 |       2 | AFR 7 Heater Open Error       | Boolean   | 0 = false, 1 = true |      0 |   0/1 | <==     | <==    | <==   |
| 3    |       2 |       4 | AFR 7 VMError                 | Boolean   | 0 = false, 1 = true |      0 |   0/1 | <==     | <==    | <==   |
| 3    |       3 |       8 | AFR 7 UN Error                | Boolean   | 0 = false, 1 = true |      0 |   0/1 | <==     | <==    | <==   |
| 3    |       4 |      16 | AFR 7 IP Error                | Boolean   | 0 = false, 1 = true |      0 |   0/1 | <==     | <==    | <==   |
| 3    |       5 |      32 | AFR 7 Heater Time - Out Error | Boolean   | 0 = false, 1 = true |      0 |   0/1 | <==     | <==    | <==   |
| 3    |       6 |      64 | AFR 7 Heater Short Error      | Boolean   | 0 = false, 1 = true |      0 |   0/1 | <==     | <==    | <==   |
| 3    | 7 (msb) |     128 | AFR 7 Overtemp Error          | Boolean   | 0 = false, 1 = true |      0 |   0/1 | <==     | <==    | <==   |
|      | 0 (lsb) |       0 | UEGO Low Voltage Error        | Boolean   | 0 = false, 1 = true |      0 |   0/1 | <==     | <==    | <==   |
|      |       1 |       2 | EBP sensor ready              | Boolean   | 0 = false, 1 = true |      0 |   0/1 | <==     | <==    | <==   |
|      |       2 |       4 | EBP sensor Error Low Volt     | Boolean   | 0 = false, 1 = true |      0 |   0/1 | <==     | <==    | <==   |
|      |       3 |       8 | EBP sensor detected           | Boolean   | 0 = false, 1 = true |      0 |   0/1 | <==     | <==    | <==   |

</div>

<p align="center"><img src="<../../.mdassets/AEMNet-150505_Public-tmps42867qo/AEMNet 150505_Public-figure-28.png>" alt="AEMNet 150505_Public-figure-28.png" width="45%"></p>

<div align="center">

|       |       4 |  16 | CAN Config Mode     | Boolean         | 0 = false, 1 = true |   0 |                0/1 | <==           | <== | <==              |
| :---- | ------: | --: | :------------------ | :-------------- | ------------------: | --: | -----------------: | :------------ | :-- | :--------------- |
|       |       5 |  32 | CAN Config Mode     | Boolean         | 0 = false, 1 = true |   0 |                0/1 | <==           | <== | <==              |
|       |       6 |  64 | CAN Config Mode     | Boolean         | 0 = false, 1 = true |   0 |                0/1 | <==           | <== | <==              |
|       | 7 (msb) | 128 | CAN Config Mode     | Boolean         | 0 = false, 1 = true |   0 |                0/1 | <==           | <== | <==              |
|       | 0 (lsb) |   0 | Reserved            | Boolean         | 0 = false, 1 = true |   0 |                0/1 | <==           | <== | <==              |
|       |       1 |   2 | Reserved            | Boolean         | 0 = false, 1 = true |   0 |                0/1 | <==           | <== | <==              |
|       |       2 |   4 | Reserved            | Boolean         | 0 = false, 1 = true |   0 |                0/1 | <==           | <== | <==              |
|       |       3 |   8 | Reserved            | Boolean         | 0 = false, 1 = true |   0 |                0/1 | <==           | <== | <==              |
| 5     |       4 |  16 | Sensor 7 Heating up | Boolean         | 0 = false, 1 = true |   0 |                0/1 | <==           | <== | <==              |
|       |       5 |  32 | Sensor 5 Heating up | Boolean         | 0 = false, 1 = true |   0 |                0/1 | <==           | <== | <==              |
|       |       6 |  64 | Sensor 3 Heating up | Boolean         | 0 = false, 1 = true |   0 |                0/1 | <==           | <== | <==              |
|       | 7 (msb) | 128 | Sensor 1 Heating up | Boolean         | 0 = false, 1 = true |   0 |                0/1 | <==           | <== | <==              |
| 6 - 7 |         |     | Exhaust Pressure 1  | 16 bit unsigned | 0.00689476 kPag/bit |   0 | 0 to 4,518.48 kPag | .001 psig/bit | 0   | 0 to 655.35 psig |

</div>

Message

ID: 0x000001B2

Sources: AEM

Channel

-

2340N

40ms is

the continuous

(25hz)

<p align="center"><img src="<../../.mdassets/AEMNet-150505_Public-tmps42867qo/AEMNet 150505_Public-figure-29.png>" alt="AEMNet 150505_Public-figure-29.png" width="45%"></p>

UEGO

set on

same

(P/N

except

-

2340.

SI

bit

MODE

messages

Units

(

C

/

kPa

/

kph

headers

/

Lambda

)

bus

US

speed

Units

(

F

/

PSI

/

MPH

/

AFR

)

<div align="center">

| Byte  |       Bit |                                       Bitmask | Label                   |                   Data Type |             Scaling |               Offset | Range Scaling | Offset  | Range            |
| :---- | --------: | --------------------------------------------: | :---------------------- | --------------------------: | ------------------: | -------------------: | :------------ | :------ | :--------------- |
| 0     |   0 (lsb) |                                 0 AFR 2 Ready | Boolean                 |         0 = false, 1 = true |                   0 |                  0/1 | <==           | <==     | <==              |
|       |         1 |                     2 AFR 2 Heater Open Error | Boolean                 |         0 = false, 1 = true |                   0 |                  0/1 | <==           | <==     | <==              |
|       |         2 |                               4 AFR 2 VMError | Boolean                 |         0 = false, 1 = true |                   0 |                  0/1 | <==           | <==     | <==              |
|       |         3 |                              8 AFR 2 UN Error | Boolean                 |         0 = false, 1 = true |                   0 |                  0/1 | <==           | <==     | <==              |
|       |         4 |                             16 AFR 2 IP Error | Boolean                 |         0 = false, 1 = true |                   0 |                  0/1 | <==           | <==     | <==              |
|       |         5 |              32 AFR 2 Heater Time - Out Error | Boolean                 |         0 = false, 1 = true |                   0 |                  0/1 | <==           | <==     | <==              |
|       |         6 |                   64 AFR 2 Heater Short Error | Boolean                 |         0 = false, 1 = true |                   0 |                  0/1 | <==           | <==     | <==              |
|       |   7 (msb) |                      128 AFR 2 Overtemp Error | Boolean                 |         0 = false, 1 = true |                   0 |                  0/1 | <==           | <==     | <==              |
|       |   0 (lsb) |                                 0 AFR 4 Ready | Boolean                 |         0 = false, 1 = true |                   0 |                  0/1 | <==           | <==     | <==              |
|       |         1 |                     2 AFR 4 Heater Open Error | Boolean                 |         0 = false, 1 = true |                   0 |                  0/1 | <==           | <==     | <==              |
|       |         2 |                               4 AFR 4 VMError | Boolean                 |         0 = false, 1 = true |                   0 |                  0/1 | <==           | <==     | <==              |
|       |         3 |                              8 AFR 4 UN Error | Boolean                 |         0 = false, 1 = true |                   0 |                  0/1 | <==           | <==     | <==              |
| 1     |         4 |                             16 AFR 4 IP Error | Boolean                 |         0 = false, 1 = true |                   0 |                  0/1 | <==           | <==     | <==              |
|       |         5 |                          32 AFR 4 Heater Time | - Out Error Boolean     |         0 = false, 1 = true |                   0 |                  0/1 | <==           | <==     | <==              |
|       |         6 |                         64 AFR 4 Heater Short | Error Boolean           |         0 = false, 1 = true |                   0 |                  0/1 | <==           | <==     | <==              |
|       |   7 (msb) |                                     128 AFR 4 | Error Boolean           |         0 = false, 1 = true |                   0 |                  0/1 | <==           | <==     | <==              |
|       |   0 (lsb) |                              Overtemp 0 AFR 6 | Ready                   | Boolean 0 = false, 1 = true |                   0 |                  0/1 | <==           | <==     | <==              |
|       |         1 |                                2 AFR 6 Heater | Open Error              | Boolean 0 = false, 1 = true |                   0 |                  0/1 | <==           | <==     | <==              |
|       |         2 |                               4 AFR 6 VMError | Boolean                 |         0 = false, 1 = true |                   0 |                  0/1 | <==           | <==     | <==              |
|       |         3 |                              8 AFR 6 UN Error | Boolean                 |                         0 = |   false, 1 = true 0 |                  0/1 | <==           | <==     | <==              |
| 2     |         4 |                                   16 AFR 6 IP | Error Boolean           |         0 = false, 1 = true |                   0 |                  0/1 | <==           | <==     | <==              |
|       |         5 |              32 AFR 6 Heater Time - Out Error | Boolean                 |         0 = false, 1 = true |                   0 |                  0/1 | <==           | <==     | <==              |
|       |         6 |                         64 AFR 6 Heater Short | Error Boolean           |         0 = false, 1 = true |                   0 |                  0/1 | <==           | <==     | <==              |
|       |   7 (msb) |                      128 AFR 6 Overtemp Error | Boolean                 |                0 = false, 1 |            = true 0 |                  0/1 | <==           | <==     | <==              |
| 3     |   0 (lsb) |                                 0 AFR 8 Ready | Boolean                 |                0 = false, 1 |            = true 0 |                  0/1 | <==           | <==     | <==              |
| 3     |         1 |                                             2 | AFR 8 Heater Open Error |                 Boolean 0 = |   false, 1 = true 0 |                  0/1 | <==           | <==     | <==              |
| 3     |         2 |                                             4 | AFR 8 VMError           |          Boolean 0 = false, |          1 = true 0 |                  0/1 | <==           | <==     | <==              |
| 3     |         3 |                                       8 AFR 8 | UN Error                | Boolean 0 = false, 1 = true |                   0 |                  0/1 | <==           | <==     | <==              |
| 3     |         4 |                                            16 | AFR 8 IP Error          | Boolean 0 = false, 1 = true |                   0 |                  0/1 | <==           | <==     | <==              |
| 3     |         5 |              32 AFR 8 Heater Time - Out Error | Boolean                 |         0 = false, 1 = true |                   0 |                  0/1 | <==           | <==     | <==              |
| 3     |         6 |                   64 AFR 8 Heater Short Error | Boolean                 |         0 = false, 1 = true |                   0 |                  0/1 | <==           | <==     | <==              |
| 3     |   7 (msb) |                            128 AFR 8 Overtemp | Error Boolean           |         0 = false, 1 = true |                   0 |                  0/1 | <==           | <==     | <==              |
| 4     |   0 (lsb) |                      0 UEGO Low Voltage Error |                         | Boolean 0 = false, 1 = true |                   0 |                  0/1 | <==           | <==     | <==              |
| 4     |         1 |                                  2 EBP sensor | ready Boolean           |         0 = false, 1 = true |                   0 |                  0/1 | <==           | <==     | <==              |
| 4     |         2 |                        4 EBP sensor Error Low | Volt Boolean            |         0 = false, 1 = true |                   0 |                  0/1 | <==           | <==     | <==              |
| 4     |         3 |                         8 EBP sensor detected | Boolean                 |         0 = false, 1 = true |                   0 |                  0/1 | <==           | <==     | <==              |
| 4     |         4 |                            16 CAN Config Mode | Boolean                 |                  0 = false, |          1 = true 0 |                  0/1 | <==           | <==     | <==              |
| 4     |         5 |                            32 CAN Config Mode | Boolean                 |         0 = false, 1 = true |                   0 |                  0/1 | <==           | <==     | <==              |
| 4     |         6 |                            64 CAN Config Mode | Boolean                 |         0 = false, 1 = true |                   0 |                  0/1 | <==           | <==     | <==              |
| 4     |   7 (msb) |                           128 CAN Config Mode | Boolean                 |         0 = false, 1 = true |                   0 |                  0/1 | <==           | <==     | <==              |
| 5     |   0 (lsb) |                                         0 --- | Boolean                 |                         --- |                 --- |                  --- | ----          | ----    | ----             |
| 5     |         1 |                                         2 --- | Boolean                 |                         --- |                 --- |                  --- | ----          | ----    | ----             |
| 5     |         2 |                                         4 --- | Boolean                 |                         --- |                 --- |                  --- | ----          | ----    | ----             |
| 5     |         3 |                                         8 --- | Boolean                 |                         --- |                 --- |                  --- | ----          | ----    | ----             |
| 5     |       4 5 | 16 Sensor 8 Heating up 32 Sensor 6 Heating up | Boolean Boolean         |       0 = false, 0 = false, | 1 = true 0 1 = true |            0/1 0 0/1 | <== <==       | <== <== | <== <==          |
| 5     |           |                        64 Sensor 4 Heating up | Boolean                 |         0 = false, 1 = true |                   0 |                  0/1 | <==           | <==     | <==              |
| 5     | 6 7 (msb) |                          128 Sensor 2 Heating | up Boolean              |              0 = false, 1 = |                true |                0 0/1 | <==           | <==     | <==              |
| 6 - 7 |           |                                       Exhaust | Pressure 2              |             16 bit unsigned | 0.00689476 kPag/bit | 0 0 to 4,518.48 kPag | .001 psig/bit | 0       | 0 to 655.35 psig |

</div>

## Message ID: 0x000001B3 Sources: AEM 4 Channel UEGO (P/N 30 -2340) set on MODE 5 30 -2340N is the same except 11 bit messages headers and at 1 mBit/sec bus speed

40ms continuous

(25hz)

SI

Units

(

C

/

kPa

/

kph

/

Lambda

)

US

Units

(

F

/

<div align="center">

| Byte |     Bit |       Bitmask | Label                          | Data Type      |             Scaling | Offset | Range | Scaling | Offset | Range |
| :--- | ------: | ------------: | :----------------------------- | :------------- | ------------------: | -----: | ----: | :------ | :----- | :---- |
| 0    | 0 (lsb) | 0 AFR 9 Ready | Boolean                        | 0 = false, 1 = |                true |      0 |   0/1 | <==     | <==    | <==   |
| 0    |       1 |             2 | AFR 9 Heater Open Error        | Boolean        | 0 = false, 1 = true |      0 |   0/1 | <==     | <==    | <==   |
| 0    |       2 |             4 | AFR 9 VMError                  | Boolean        | 0 = false, 1 = true |      0 |   0/1 | <==     | <==    | <==   |
| 0    |       3 |             8 | AFR 9 UN Error                 | Boolean        | 0 = false, 1 = true |      0 |   0/1 | <==     | <==    | <==   |
| 0    |       4 |            16 | AFR 9 IP Error                 | Boolean        | 0 = false, 1 = true |      0 |   0/1 | <==     | <==    | <==   |
| 0    |       5 |            32 | AFR 9 Heater Time - Out Error  | Boolean        | 0 = false, 1 = true |      0 |   0/1 | <==     | <==    | <==   |
|      |       6 |            64 | AFR 9 Heater Short Error       | Boolean        | 0 = false, 1 = true |      0 |   0/1 | <==     | <==    | <==   |
|      | 7 (msb) |           128 | AFR 9 Overtemp Error           | Boolean        | 0 = false, 1 = true |      0 |   0/1 | <==     | <==    | <==   |
|      | 0 (lsb) |             0 | AFR 10 Ready                   | Boolean        | 0 = false, 1 = true |      0 |   0/1 | <==     | <==    | <==   |
|      |       1 |             2 | AFR 10 Heater Open Error       | Boolean        | 0 = false, 1 = true |      0 |   0/1 | <==     | <==    | <==   |
|      |       2 |             4 | AFR 10 VMError                 | Boolean        | 0 = false, 1 = true |      0 |   0/1 | <==     | <==    | <==   |
| 1    |       3 |             8 | AFR 10 UN Error                | Boolean        | 0 = false, 1 = true |      0 |   0/1 | <==     | <==    | <==   |
| 1    |       4 |            16 | AFR 10 IP Error                | Boolean        | 0 = false, 1 = true |      0 |   0/1 | <==     | <==    | <==   |
|      |       5 |            32 | AFR 10 Heater Time - Out Error | Boolean        | 0 = false, 1 = true |      0 |   0/1 | <==     | <==    | <==   |

</div>

and at

mBit/sec

PSI

/

MPH

/

AFR

)

<div align="center">

| 6       |  64 | AFR 10 Heater Short Error      | Boolean         | 0 = false, 1 = true |   0 |                0/1 | <==           | <==  | <==              |
| :------ | --: | :----------------------------- | :-------------- | ------------------: | --: | -----------------: | :------------ | :--- | :--------------- |
| 7 (msb) | 128 | AFR 10 Overtemp Error          | Boolean         | 0 = false, 1 = true |   0 |                0/1 | <==           | <==  | <==              |
| 0 (lsb) |   0 | AFR 11 Ready                   | Boolean         | 0 = false, 1 = true |   0 |                0/1 | <==           | <==  | <==              |
| 1       |   2 | AFR 11 Heater Open Error       | Boolean         | 0 = false, 1 = true |   0 |                0/1 | <==           | <==  | <==              |
| 2       |   4 | AFR 11 VMError                 | Boolean         | 0 = false, 1 = true |   0 |                0/1 | <==           | <==  | <==              |
| 3       |   8 | AFR 11 UN Error                | Boolean         | 0 = false, 1 = true |   0 |                0/1 | <==           | <==  | <==              |
| 4       |  16 | AFR 11 IP Error                | Boolean         | 0 = false, 1 = true |   0 |                0/1 | <==           | <==  | <==              |
| 5       |  32 | AFR 11 Heater Time - Out Error | Boolean         | 0 = false, 1 = true |   0 |                0/1 | <==           | <==  | <==              |
| 6       |  64 | AFR 11 Heater Short Error      | Boolean         | 0 = false, 1 = true |   0 |                0/1 | <==           | <==  | <==              |
| 7 (msb) | 128 | AFR 11 Overtemp Error          | Boolean         | 0 = false, 1 = true |   0 |                0/1 | <==           | <==  | <==              |
| 0 (lsb) |   0 | AFR 12 Ready                   | Boolean         | 0 = false, 1 = true |   0 |                0/1 | <==           | <==  | <==              |
| 1       |   2 | AFR 12 Heater Open Error       | Boolean         | 0 = false, 1 = true |   0 |                0/1 | <==           | <==  | <==              |
| 2       |   4 | AFR 12 VMError                 | Boolean         | 0 = false, 1 = true |   0 |                0/1 | <==           | <==  | <==              |
| 3       |   8 | AFR 12 UN Error                | Boolean         | 0 = false, 1 = true |   0 |                0/1 | <==           | <==  | <==              |
| 4       |  16 | AFR 12 IP Error                | Boolean         | 0 = false, 1 = true |   0 |                0/1 | <==           | <==  | <==              |
| 5       |  32 | AFR 12 Heater Time - Out Error | Boolean         | 0 = false, 1 = true |   0 |                0/1 | <==           | <==  | <==              |
| 6       |  64 | AFR 12 Heater Short Error      | Boolean         | 0 = false, 1 = true |   0 |                0/1 | <==           | <==  | <==              |
| 7 (msb) | 128 | AFR 12 Overtemp Error          | Boolean         | 0 = false, 1 = true |   0 |                0/1 | <==           | <==  | <==              |
| 0 (lsb) |   0 | UEGO Low Voltage Error         | Boolean         | 0 = false, 1 = true |   0 |                0/1 | <==           | <==  | <==              |
| 1       |   2 | EBP sensor ready               | Boolean         | 0 = false, 1 = true |   0 |                0/1 | <==           | <==  | <==              |
| 2       |   4 | EBP sensor Error Low Volt      | Boolean         | 0 = false, 1 = true |   0 |                0/1 | <==           | <==  | <==              |
| 3       |   8 | EBP sensor detected            | Boolean         | 0 = false, 1 = true |   0 |                0/1 | <==           | <==  | <==              |
| 4       |  16 | CAN Config Mode                | Boolean         | 0 = false, 1 = true |   0 |                0/1 | <==           | <==  | <==              |
| 5       |  32 | CAN Config Mode                | Boolean         | 0 = false, 1 = true |   0 |                0/1 | <==           | <==  | <==              |
| 6       |  64 | CAN Config Mode                | Boolean         | 0 = false, 1 = true |   0 |                0/1 | <==           | <==  | <==              |
| 7 (msb) | 128 | CAN Config Mode                | Boolean         | 0 = false, 1 = true |   0 |                0/1 | <==           | <==  | <==              |
| 0 (lsb) |   0 | ---                            | Boolean         |                 --- | --- |                --- | ----          | ---- | ----             |
| 1       |   2 | ---                            | Boolean         |                 --- | --- |                --- | ----          | ---- | ----             |
| 2       |   4 | ---                            | Boolean         |                 --- | --- |                --- | ----          | ---- | ----             |
| 3       |   8 | ---                            | Boolean         |                 --- | --- |                --- | ----          | ---- | ----             |
| 4       |  16 | Sensor 12 Heating up           | Boolean         | 0 = false, 1 = true |   0 |                0/1 | <==           | <==  | <==              |
| 5       |  32 | Sensor 11 Heating up           | Boolean         | 0 = false, 1 = true |   0 |                0/1 | <==           | <==  | <==              |
| 6       |  64 | Sensor 10 Heating up           | Boolean         | 0 = false, 1 = true |   0 |                0/1 | <==           | <==  | <==              |
| 7 (msb) | 128 | Sensor 9 Heating up            | Boolean         | 0 = false, 1 = true |   0 |                0/1 | <==           | <==  | <==              |
|         |     | Exhaust Pressure 2             | 16 bit unsigned | 0.00689476 kPag/bit |   0 | 0 to 4,518.48 kPag | .001 psig/bit | 0    | 0 to 655.35 psig |

</div>

## Message ID: 0x000001B4 Sources: AEM 4 Channel UEGO (P/N 30 -2340) set on MODE 6 30 -2340N is the same except 11 bit messages headers and at 1 mBit/sec bus speed

40ms continuous

(25hz)

SI

Units

(

C

/

kPa

/

kph

/

Lambda

)

US

Units

(

F

/

PSI

/

MPH

/

AFR

)

<div align="center">

| Byte  |     Bit | Bitmask | Label                                 | Data Type              |             Scaling | Offset |              Range | Scaling       | Offset | Range            |
| :---- | ------: | ------: | :------------------------------------ | :--------------------- | ------------------: | -----: | -----------------: | :------------ | :----- | :--------------- |
| 0     | 0 (lsb) |       0 | AFR 1 Ready                           | Boolean 0 = false, 1 = |                true |      0 |            0/1 <== | <==           |        | <==              |
| 0     |       1 |       2 |                                       | Boolean 0 =            |   false, 1 = true 0 |    0/1 |                <== | <==           |        | <==              |
| 0     |       2 |       4 | AFR 1 Heater Open Error AFR 1 VMError | Boolean 0              |   = false, 1 = true |  0 0/1 |                    | <==           | <==    | <==              |
| 0     |       3 |       8 | AFR 1 UN Error                        | Boolean                | 0 = false, 1 = true |      0 |                0/1 | <==           | <==    | <==              |
| 0     |       4 |      16 | AFR 1 IP Error                        | Boolean 0              |   = false, 1 = true |  0 0/1 |                <== |               | <==    | <==              |
| 0     |       5 |      32 | AFR 1 Heater Time - Out Error         | Boolean                | 0 = false, 1 = true |      0 |                0/1 | <==           | <==    | <==              |
| 0     |       6 |      64 | AFR 1 Heater Short Error              | Boolean                | 0 = false, 1 = true |      0 |                0/1 | <==           | <==    | <==              |
| 0     | 7 (msb) |     128 | AFR 1 Overtemp Error                  | Boolean                | 0 = false, 1 = true |      0 |                0/1 | <==           | <==    | <==              |
| 1     | 0 (lsb) |       0 | AFR 2 Ready                           | Boolean                | 0 = false, 1 = true |      0 |                0/1 | <==           | <==    | <==              |
| 1     |       1 |       2 | AFR 2 Heater Open Error               | Boolean                | 0 = false, 1 = true |      0 |                0/1 | <==           | <==    | <==              |
| 1     |       2 |       4 | AFR 2 VMError                         | Boolean                | 0 = false, 1 = true |      0 |                0/1 | <==           | <==    | <==              |
| 1     |       3 |       8 | AFR 2 UN Error                        | Boolean                | 0 = false, 1 = true |      0 |                0/1 | <==           | <==    | <==              |
| 1     |       4 |      16 | AFR 2 IP Error                        | Boolean                | 0 = false, 1 = true |      0 |                0/1 | <==           | <==    | <==              |
| 1     |       5 |      32 | AFR 2 Heater Time - Out Error         | Boolean                | 0 = false, 1 = true |      0 |                0/1 | <==           | <==    | <==              |
| 1     |       6 |      64 | AFR 2 Heater Short Error              | Boolean                | 0 = false, 1 = true |      0 |                0/1 | <==           | <==    | <==              |
| 1     | 7 (msb) |     128 | AFR 2 Overtemp Error                  | Boolean                | 0 = false, 1 = true |      0 |                0/1 | <==           | <==    | <==              |
| 2     | 0 (lsb) |       0 | AFR 3 Ready                           | Boolean                | 0 = false, 1 = true |      0 |                0/1 | <==           | <==    | <==              |
| 2     |       1 |       2 | AFR 3 Heater Open Error               | Boolean                | 0 = false, 1 = true |      0 |                0/1 | <==           | <==    | <==              |
| 2     |       2 |       4 | AFR 3 VMError                         | Boolean                | 0 = false, 1 = true |      0 |                0/1 | <==           | <==    | <==              |
| 2     |       3 |       8 | AFR 3 UN Error                        | Boolean                | 0 = false, 1 = true |      0 |                0/1 | <==           | <==    | <==              |
| 2     |       4 |      16 | AFR 3 IP Error                        | Boolean                | 0 = false, 1 = true |      0 |                0/1 | <==           | <==    | <==              |
| 2     |       5 |      32 | AFR 3 Heater Time - Out Error         | Boolean                | 0 = false, 1 = true |      0 |                0/1 | <==           | <==    | <==              |
| 2     |       6 |      64 | AFR 3 Heater Short Error              | Boolean                | 0 = false, 1 = true |      0 |                0/1 | <==           | <==    | <==              |
| 2     | 7 (msb) |     128 | AFR 3 Overtemp Error                  | Boolean                | 0 = false, 1 = true |      0 |                0/1 | <==           | <==    | <==              |
| 3     |         |         | ---                                   | Boolean                |                 --- |    --- |                --- | ----          | ----   | ----             |
| 4     | 0 (lsb) |       0 | UEGO Low Voltage Error                | Boolean                | 0 = false, 1 = true |      0 |                0/1 | <==           | <==    | <==              |
|       |       1 |       2 | EBP sensor ready                      | Boolean                | 0 = false, 1 = true |      0 |                0/1 | <==           | <==    | <==              |
|       |       2 |       4 | EBP sensor Error Low Volt             | Boolean                | 0 = false, 1 = true |      0 |                0/1 | <==           | <==    | <==              |
|       |       3 |       8 | EBP sensor detected                   | Boolean                | 0 = false, 1 = true |      0 |                0/1 | <==           | <==    | <==              |
|       |       4 |      16 | CAN Config Mode                       | Boolean                | 0 = false, 1 = true |      0 |                0/1 | <==           | <==    | <==              |
|       |       5 |      32 | CAN Config Mode                       | Boolean                | 0 = false, 1 = true |      0 |                0/1 | <==           | <==    | <==              |
|       |       6 |      64 | CAN Config Mode                       | Boolean                | 0 = false, 1 = true |      0 |                0/1 | <==           | <==    | <==              |
|       | 7 (msb) |     128 | CAN Config Mode                       | Boolean                | 0 = false, 1 = true |      0 |                0/1 | <==           | <==    | <==              |
|       | 0 (lsb) |       0 | ---                                   | Boolean                |                 --- |    --- |                --- | ----          | ----   | ----             |
|       |       1 |       2 | ---                                   | Boolean                |                 --- |    --- |                --- | ----          | ----   | ----             |
|       |       2 |       4 | ---                                   | Boolean                |                 --- |    --- |                --- | ----          | ----   | ----             |
|       |       3 |       8 | ---                                   | Boolean                |                 --- |    --- |                --- | ----          | ----   | ----             |
| 5     |       4 |      16 | ---                                   | Boolean                |                 --- |    --- |                --- | ----          | ----   | ----             |
|       |       5 |      32 | Sensor 3 Heating up                   | Boolean                | 0 = false, 1 = true |      0 |                0/1 | <==           | <==    | <==              |
|       |       6 |      64 | Sensor 2 Heating up                   | Boolean                | 0 = false, 1 = true |      0 |                0/1 | <==           | <==    | <==              |
|       | 7 (msb) |     128 | Sensor 1 Heating up                   | Boolean                | 0 = false, 1 = true |      0 |                0/1 | <==           | <==    | <==              |
| 6 - 7 |         |         | Exhaust Pressure 1                    | 16 bit unsigned        | 0.00689476 kPag/bit |      0 | 0 to 4,518.48 kPag | .001 psig/bit | 0      | 0 to 655.35 psig |

</div>

Message ID: 0x000001B5 Sources: AEM 4 Channel UEGO (P/N 30 -2340) set on MODE 7 30 -2340N is the same except 11 bit messages headers and at 1 mBit/sec bus speed 40ms continuous (25hz) SI Units ( C / kPa / kph / Lambda ) US Units ( F / PSI / MPH / AFR )

<div align="center">

| Byte  |     Bit | Bitmask | Label                         | Data Type       |             Scaling | Offset |            Range | Scaling       | Offset | Range            |
| :---- | ------: | ------: | :---------------------------- | :-------------- | ------------------: | -----: | ---------------: | :------------ | :----- | :--------------- |
| 0     | 0 (lsb) |       0 | AFR 4 Ready                   | Boolean         | 0 = false, 1 = true |      0 |              0/1 | <==           | <==    | <==              |
| 0     |       1 |       2 | AFR 4 Heater Open Error       | Boolean         | 0 = false, 1 = true |      0 |          0/1 <== |               | <==    | <==              |
| 0     |       2 |       4 | AFR 4 VMError                 | Boolean         | 0 = false, 1 = true |      0 |              0/1 | <==           | <==    | <==              |
| 0     |       3 |       8 | AFR 4 UN Error                | Boolean         | 0 = false, 1 = true |      0 |              0/1 | <==           | <==    | <==              |
| 0     |       4 |      16 | AFR 4 IP Error                | Boolean         | 0 = false, 1 = true |      0 |              0/1 | <==           | <==    | <==              |
| 0     |       5 |      32 | AFR 4 Heater Time - Out Error | Boolean         | 0 = false, 1 = true |      0 |              0/1 | <==           | <==    | <==              |
| 0     |       6 |      64 | AFR 4 Heater Short Error      | Boolean         | 0 = false, 1 = true |      0 |              0/1 | <==           | <==    | <==              |
| 0     | 7 (msb) |     128 | AFR 4 Overtemp Error          | Boolean         | 0 = false, 1 = true |      0 |              0/1 | <==           | <==    | <==              |
| 1     | 0 (lsb) |       0 | AFR 5 Ready                   | Boolean         | 0 = false, 1 = true |      0 |              0/1 | <==           | <==    | <==              |
| 1     |       1 |       2 | AFR 5 Heater Open Error       | Boolean         | 0 = false, 1 = true |      0 |              0/1 | <==           | <==    | <==              |
| 1     |       2 |       4 | AFR 5 VMError                 | Boolean         | 0 = false, 1 = true |      0 |              0/1 | <==           | <==    | <==              |
| 1     |       3 |       8 | AFR 5 UN Error                | Boolean         | 0 = false, 1 = true |      0 |              0/1 | <==           | <==    | <==              |
| 1     |       4 |      16 | AFR 5 IP Error                | Boolean         | 0 = false, 1 = true |      0 |              0/1 | <==           | <==    | <==              |
| 1     |       5 |      32 | AFR 5 Heater Time - Out Error | Boolean         | 0 = false, 1 = true |      0 |              0/1 | <==           | <==    | <==              |
| 1     |       6 |      64 | AFR 5 Heater Short Error      | Boolean         | 0 = false, 1 = true |      0 |              0/1 | <==           | <==    | <==              |
| 1     | 7 (msb) |     128 | AFR 5 Overtemp Error          | Boolean         | 0 = false, 1 = true |      0 |              0/1 | <==           | <==    | <==              |
| 2     | 0 (lsb) |       0 | AFR 6 Ready                   | Boolean         | 0 = false, 1 = true |      0 |              0/1 | <==           | <==    | <==              |
| 2     |       1 |       2 | AFR 6 Heater Open Error       | Boolean         | 0 = false, 1 = true |      0 |              0/1 | <==           | <==    | <==              |
| 2     |       2 |       4 | AFR 6 VMError                 | Boolean         | 0 = false, 1 = true |      0 |              0/1 | <==           | <==    | <==              |
| 2     |       3 |       8 |                               | Boolean         | 0 = false, 1 = true |      0 |              0/1 | <==           | <==    | <==              |
| 2     |         |         | AFR 6 UN Error                |                 |                     |        |                  |               |        |                  |
| 2     |       5 |      32 | AFR 6 Heater Time - Out Error | Boolean         | 0 = false, 1 = true |      0 |              0/1 | <==           | <==    | <==              |
| 2     |       6 |      64 | AFR 6 Heater Short Error      | Boolean         | 0 = false, 1 = true |      0 |              0/1 | <==           | <==    | <==              |
| 2     | 7 (msb) |     128 | AFR 6 Overtemp Error          | Boolean         | 0 = false, 1 = true |      0 |              0/1 | <==           | <==    | <==              |
| 3     |         |         | ---                           | Boolean         |                 --- |    --- |              --- | ----          | ----   | ----             |
| 4     | 0 (lsb) |       0 | UEGO Low Voltage Error        | Boolean         | 0 = false, 1 = true |      0 |              0/1 | <==           | <==    | <==              |
|       |       1 |       2 | EBP sensor ready              | Boolean         | 0 = false, 1 = true |      0 |              0/1 | <==           | <==    | <==              |
|       |       2 |       4 | EBP sensor Error Low Volt     | Boolean         | 0 = false, 1 = true |      0 |              0/1 | <==           | <==    | <==              |
|       |       3 |       8 | EBP sensor detected           | Boolean         | 0 = false, 1 = true |      0 |              0/1 | <==           | <==    | <==              |
|       |       4 |      16 | CAN Config Mode               | Boolean         | 0 = false, 1 = true |      0 |              0/1 | <==           | <==    | <==              |
|       |       5 |      32 | CAN Config Mode               | Boolean         | 0 = false, 1 = true |      0 |              0/1 | <==           | <==    | <==              |
|       |       6 |      64 | CAN Config Mode               | Boolean         | 0 = false, 1 = true |      0 |              0/1 | <==           | <==    | <==              |
|       | 7 (msb) |     128 | CAN Config Mode               | Boolean         | 0 = false, 1 = true |      0 |              0/1 | <==           | <==    | <==              |
|       | 0 (lsb) |       0 | ---                           | Boolean         |                 --- |    --- |              --- | ----          | ----   | ----             |
|       |       1 |       2 | ---                           | Boolean         |                 --- |    --- |              --- | ----          | ----   | ----             |
|       |       2 |       4 | ---                           | Boolean         |                 --- |    --- |              --- | ----          | ----   | ----             |
|       |       3 |       8 | ---                           | Boolean         |                 --- |    --- |              --- | ----          | ----   | ----             |
| 5     |       4 |      16 | ---                           | Boolean         |                 --- |    --- |              --- | ----          | ----   | ----             |
|       |       5 |      32 | Sensor 6 Heating up           | Boolean         | 0 = false, 1 = true |      0 |              0/1 | <==           | <==    | <==              |
|       |       6 |      64 | Sensor 5 Heating up           | Boolean         | 0 = false, 1 = true |      0 |              0/1 | <==           | <==    | <==              |
|       | 7 (msb) |     128 | Sensor 4 Heating up           | Boolean         | 0 = false, 1 = true |      0 |              0/1 | <==           | <==    | <==              |
| 6 - 7 |         |         | Exhaust Pressure 2            | 16 bit unsigned |       .001 psig/bit |      0 | 0 to 655.35 psig | .001 psig/bit | 0      | 0 to 655.35 psig |

</div>
