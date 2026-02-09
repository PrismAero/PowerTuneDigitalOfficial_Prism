# UDP Receiver Data Flow Modularization Plan

## Executive Summary

This plan details the migration of UDP receiver data flow from the monolithic `DashBoard` class to the individual domain-specific data models. Currently, the UDP receiver (`UDPReceiver.cpp`) contains a massive switch statement (~300 cases) that directly calls `m_dashboard->setXXX()` methods. This plan transforms that architecture to route data through the appropriate domain models (`EngineData`, `VehicleData`, `FlagsData`, etc.).

---

## Current State Analysis

### Problem Statement

1. **Tight Coupling**: `UDPReceiver` directly references `DashBoard` with ~300 setter calls
2. **God Object**: `DashBoard` contains ~535 Q_PROPERTY declarations (~7,958 lines)
3. **No Separation of Concerns**: UDP receiver mixes data from all domains in one switch statement
4. **Maintenance Burden**: Adding a new sensor requires changes in 3+ places
5. **QML Access Pattern**: QML files use `Dashboard.property` for all data access

### Existing Infrastructure

**Domain Models Already Created (in `Core/Models/`):**
- `UIState` - UI interaction state (7 properties) - INTEGRATED
- `EngineData` - Engine metrics (~180 properties) - CREATED, NOT WIRED
- `VehicleData` - Vehicle data (~70 properties) - CREATED, NOT WIRED
- `GPSData` - GPS data (~10 properties) - CREATED, NOT WIRED
- `AnalogInputs` - Analog sensors (~45 properties) - CREATED, NOT WIRED
- `DigitalInputs` - Digital inputs (~20 properties) - CREATED, NOT WIRED
- `ExpanderBoardData` - Expander board (~20 properties) - CREATED, NOT WIRED
- `ElectricMotorData` - EV motor data (~30 properties) - CREATED, NOT WIRED
- `FlagsData` - ECU flags (~50 properties) - CREATED, NOT WIRED
- `TimingData` - Timing data (~10 properties) - CREATED, NOT WIRED
- `SensorData` - Generic sensors (~20 properties) - CREATED, NOT WIRED
- `ConnectionData` - Connection status (~15 properties) - CREATED, NOT WIRED
- `SettingsData` - Settings (~50 properties) - CREATED, NOT WIRED

**QML Context Properties Exposed (in `connect.cpp:145-160`):**
- `Dashboard`, `UI`, `Engine`, `Vehicle`, `GPS`, `Analog`, `Digital`
- `Expander`, `Motor`, `Flags`, `Timing`, `Sensor`, `Connection`, `Settings`

**Current UDP Data Flow:**
```
UDP Packet → UDPReceiver::processPendingDatagrams() → m_dashboard->setXXX() → QML
```

**Target UDP Data Flow:**
```
UDP Packet → UDPReceiver::processPendingDatagrams() → m_<domain>->setXXX() → QML
                                                    ↓
                                            (Optional facade)
                                                    ↓
                                            m_dashboard->setXXX() (deprecated)
```

---

## Phase 1: Infrastructure Setup

### 1.1 Update UDPReceiver to Accept Model Pointers

**Files to Modify:**
- `Utils/UDPReceiver.h`
- `Utils/UDPReceiver.cpp`
- `Core/connect.cpp`

**Changes:**

#### UDPReceiver.h
```cpp
#ifndef UDPRECEIVER_H
#define UDPRECEIVER_H

#include <QObject>

// * Forward declarations
class QUdpSocket;
class DashBoard;
class EngineData;
class VehicleData;
class GPSData;
class AnalogInputs;
class DigitalInputs;
class ExpanderBoardData;
class ElectricMotorData;
class FlagsData;
class SensorData;

class udpreceiver : public QObject
{
    Q_OBJECT

public:
    explicit udpreceiver(QObject *parent = nullptr);
    
    // * New constructor with model pointers
    explicit udpreceiver(
        DashBoard *dashboard,
        EngineData *engineData,
        VehicleData *vehicleData,
        GPSData *gpsData,
        AnalogInputs *analogInputs,
        DigitalInputs *digitalInputs,
        ExpanderBoardData *expanderData,
        ElectricMotorData *motorData,
        FlagsData *flagsData,
        SensorData *sensorData,
        QObject *parent = nullptr
    );
    
    // * Legacy constructor (deprecated, for backward compatibility)
    explicit udpreceiver(DashBoard *dashboard, QObject *parent = nullptr);

private:
    // * Model pointers
    DashBoard *m_dashboard;
    EngineData *m_engineData;
    VehicleData *m_vehicleData;
    GPSData *m_gpsData;
    AnalogInputs *m_analogInputs;
    DigitalInputs *m_digitalInputs;
    ExpanderBoardData *m_expanderData;
    ElectricMotorData *m_motorData;
    FlagsData *m_flagsData;
    SensorData *m_sensorData;
    
    QUdpSocket *udpSocket = nullptr;
    int m_units;
    
public slots:
    void processPendingDatagrams();
    void startreceiver();
    void closeConnection();
};

#endif // UDPRECEIVER_H
```

### 1.2 Task Checklist - Phase 1

- [ ] Update `UDPReceiver.h` with model pointers
- [ ] Update `UDPReceiver.cpp` constructor to accept model pointers
- [ ] Update `Connect::Connect()` to pass model pointers to UDPReceiver
- [ ] Verify compilation succeeds
- [ ] Create unit test for UDPReceiver initialization

---

## Phase 2: UDP Identifier Mapping

### 2.1 Complete UDP Identifier to Model Mapping

This maps every UDP identifier to its target domain model:

#### Engine Data (EngineData) - ~95 identifiers
| UDP ID | Property | Current Call |
|--------|----------|--------------|
| 6 | AFR | m_dashboard->setAFR() |
| 7 | airtempensor2 | m_dashboard->setairtempensor2() |
| 10 | antilaglauchswitch | m_dashboard->setantilaglauchswitch() |
| 11 | antilaglaunchon | m_dashboard->setantilaglaunchon() |
| 16 | auxrevlimitswitch | m_dashboard->setauxrevlimitswitch() |
| 17 | AUXT | m_dashboard->setAUXT() |
| 18 | avfueleconomy | m_dashboard->setavfueleconomy() |
| 19 | battlight | m_dashboard->setbattlight() |
| 20 | boostcontrol | m_dashboard->setboostcontrol() |
| 21 | BoostDuty | m_dashboard->setBoostDuty() |
| 22 | BoostPres | m_dashboard->setBoostPres() |
| 23 | Boosttp | m_dashboard->setBoosttp() |
| 24 | Boostwg | m_dashboard->setBoostwg() |
| 30 | decelcut | m_dashboard->setdecelcut() |
| 33 | Dwell | m_dashboard->setDwell() |
| 34-45 | egt1-12 | m_dashboard->setegt1-12() |
| 46 | EngLoad | m_dashboard->setEngLoad() |
| 47-48 | excamangle1-2 | m_dashboard->setexcamangle1-2() |
| 81 | flatshiftstate | m_dashboard->setflatshiftstate() |
| 82-89 | Fuelc, fuelclevel, fuelcomposition, fuelconsrate, fuelcutperc, fuelflow, fuelflowdiff, fuelflowret | m_dashboard->setXXX() |
| 100-105 | FuelPress, Fueltemp, fueltrimlongtbank1-2, fueltrimshorttbank1-2 | m_dashboard->setXXX() |
| 120 | IdleValue | m_dashboard->setIdleValue() |
| 121-125 | Ign, Ign1-4 | m_dashboard->setIgn1-4() |
| 126-127 | incamangle1-2 | m_dashboard->setincamangle1-2() |
| 128-134 | Inj, Inj1-4, InjDuty, injms | m_dashboard->setXXX() |
| 135 | Intaketemp | m_dashboard->setIntaketemp() |
| 136 | Iscvduty | m_dashboard->setIscvduty() |
| 137-141 | Knock, knocklevlogged1-2, knockretardbank1-2 | m_dashboard->setXXX() |
| 142-146 | LAMBDA, lambda2-4, LAMBDATarget | m_dashboard->setXXX() |
| 147-148 | launchcontolfuelenrich, launchctrolignretard | m_dashboard->setXXX() |
| 149 | Leadingign | m_dashboard->setLeadingign() |
| 151 | limpmode | m_dashboard->setlimpmode() |
| 152-154 | MAF1V, MAF2V, MAFactivity | m_dashboard->setXXX() |
| 155-156 | MAP, MAP2 | m_dashboard->setXXX() |
| 157 | mil | m_dashboard->setmil() |
| 158 | missccount | m_dashboard->setmissccount() |
| 159 | Moilp | m_dashboard->setMoilp() |
| 161-162 | na1, na2 | m_dashboard->setXXX() |
| 163-165 | nosactive, nospress, nosswitch | m_dashboard->setXXX() |
| 166-167 | O2volt, O2volt_2 | m_dashboard->setXXX() |
| 169 | oilpres | m_dashboard->setoilpres() |
| 170 | oiltemp | m_dashboard->setoiltemp() |
| 171 | pim | m_dashboard->setpim() |
| 173 | Power | m_dashboard->setPower() |
| 174 | PressureV | m_dashboard->setPressureV() |
| 175 | Primaryinp | m_dashboard->setPrimaryinp() |
| 176 | rallyantilagswitch | m_dashboard->setrallyantilagswitch() |
| 179 | rpm | m_dashboard->setrpm() |
| 181 | Secinjpulse | m_dashboard->setSecinjpulse() |
| 201 | targetbstlelkpa | m_dashboard->settargetbstlelkpa() |
| 202 | ThrottleV | m_dashboard->setThrottleV() |
| 203-205 | timeddutyout1-2, timeddutyoutputactive | m_dashboard->setXXX() |
| 207 | Torque | m_dashboard->setTorque() |
| 208-209 | torqueredcutactive, torqueredlevelactive | m_dashboard->setXXX() |
| 210 | TPS | m_dashboard->setTPS() |
| 211 | Trailingign | m_dashboard->setTrailingign() |
| 212 | transientthroactive | m_dashboard->settransientthroactive() |
| 213 | transoiltemp | m_dashboard->settransoiltemp() |
| 214-215 | triggerccounter, triggersrsinceasthome | m_dashboard->setXXX() |
| 216 | TRIM | m_dashboard->setTRIM() |
| 218 | turborpm | m_dashboard->setturborpm() |
| 219 | ecu | m_dashboard->setecu() |
| 220 | wastegatepress | m_dashboard->setwastegatepress() |
| 221 | Watertemp | m_dashboard->setWatertemp() |
| 228 | BatteryV | m_dashboard->setBatteryV() |
| 229 | Intakepress | m_dashboard->setIntakepress() |
| 271 | GearOilPress | m_dashboard->setGearOilPress() |
| 275 | InjDuty2 | m_dashboard->setInjDuty2() |
| 276 | InjAngle | m_dashboard->setInjAngle() |
| 278 | BoostPreskpa | m_dashboard->setBoostPreskpa() |
| 290 | tractionControl | m_dashboard->settractionControl() |
| 400 | igncut | m_dashboard->setigncut() |
| 403 | dsettargetslip | m_dashboard->setdsettargetslip() |
| 404 | tractionctlpowerlimit | m_dashboard->settractionctlpowerlimit() |
| 405-407 | knockallpeak, knockcorr, knocklastcyl | m_dashboard->setXXX() |
| 408-409 | totalfueltrim, totaligncomp | m_dashboard->setXXX() |
| 410 | egthighest | m_dashboard->setegthighest() |
| 411-414 | cputempecu, errorcodecount, lostsynccount, egtdiff | m_dashboard->setXXX() |
| 415-416 | activeboosttable, activetunetable | m_dashboard->setXXX() |
| 827-829 | oilpressurelamp, overtempalarm, alternatorfail | m_dashboard->setXXX() |
| 830 | turborpm2 | m_dashboard->setturborpm2() |
| 831 | AuxTemp1 | m_dashboard->setAuxTemp1() |
| 916-923 | AFRcyl1-8 | m_dashboard->setAFRcyl1-8() |
| 925-928 | AFRLEFTBANKTARGET, AFRRIGHTBANKTARGET, AFRLEFTBANKACTUAL, AFRRIGHTBANKACTUAL | m_dashboard->setXXX() |
| 929 | BOOSTOFFSET | m_dashboard->setBOOSTOFFSET() |
| 930-933 | REVLIM3STEP, REVLIM2STEP, REVLIMGIGHSIDE, REVLIMBOURNOUT | m_dashboard->setXXX() |
| 934-935 | LEFTBANKO2CORR, RIGHTBANKO2CORR | m_dashboard->setXXX() |
| 936-940 | TRACTIONCTRLOFFSET, DRIVESHAFTOFFSET, TCCOMMAND, FSLCOMMAND, FSLINDEX | m_dashboard->setXXX() |
| 941 | PANVAC | m_dashboard->setPANVAC() |
| 942-949 | Cyl1_O2_Corr - Cyl8_O2_Corr | m_dashboard->setCyl1_O2_Corr() |
| 950-953 | RotaryTrimpot1-3, CalibrationSelect | m_dashboard->setXXX() |

#### Vehicle Data (VehicleData) - ~35 identifiers
| UDP ID | Property | Current Call |
|--------|----------|--------------|
| 1 | accelpedpos | m_dashboard->setaccelpedpos() |
| 2 | AccelTimer | m_dashboard->setAccelTimer() |
| 3-5 | accelx, accely, accelz | m_dashboard->setaccelx-z() |
| 8 | ambipress | m_dashboard->setambipress() |
| 9 | ambitemp | m_dashboard->setambitemp() |
| 26 | brakepress | m_dashboard->setbrakepress() |
| 27 | clutchswitchstate | m_dashboard->setclutchswitchstate() |
| 28 | compass | m_dashboard->setcompass() |
| 29 | coolantpress | m_dashboard->setcoolantpress() |
| 31 | diffoiltemp | m_dashboard->setdiffoiltemp() |
| 32 | distancetoempty | m_dashboard->setdistancetoempty() |
| 106 | Gear | m_dashboard->setGear() |
| 107 | gearswitch | m_dashboard->setgearswitch() |
| 111 | gpsSpeed | m_dashboard->setgpsSpeed() |
| 113 | lowBeam | m_dashboard->setlowBeam() |
| 114-116 | gyrox, gyroy, gyroz | m_dashboard->setgyrox-z() |
| 117 | handbrake | m_dashboard->sethandbrake() |
| 118 | highbeam | m_dashboard->sethighbeam() |
| 119 | homeccounter | m_dashboard->sethomeccounter() |
| 150 | leftindicator | m_dashboard->setleftindicator() |
| 160 | MVSS | m_dashboard->setMVSS() |
| 168 | Odo | m_dashboard->setOdo() |
| 178 | rightindicator | m_dashboard->setrightindicator() |
| 191 | FuelLevel | m_dashboard->setFuelLevel() |
| 194 | SteeringWheelAngle | m_dashboard->setSteeringWheelAngle() |
| 199 | Speed | m_dashboard->setSpeed() |
| 200 | SVSS | m_dashboard->setSVSS() |
| 217 | Trip | m_dashboard->setTrip() |
| 222-227 | wheeldiff, wheelslip, wheelspdftleft, wheelspdftright, wheelspdrearleft, wheelspdrearright | m_dashboard->setXXX() |
| 401-402 | undrivenavgspeed, drivenavgspeed | m_dashboard->setXXX() |
| 826 | autogear | m_dashboard->setautogear() |
| 864-871 | TiretempLF-RR, TirepresLF-RR | m_dashboard->setXXX() |
| 924 | Gearoffset | m_dashboard->setGearoffset() |

#### Flags Data (FlagsData) - ~50 identifiers
| UDP ID | Property | Current Call |
|--------|----------|--------------|
| 49-73 | Flag1-25 | m_dashboard->setFlag1-25() |
| 808-823 | FlagString1-16 | m_dashboard->setFlagString1-16() |
| 800-807 | SensorString1-8 | m_dashboard->setSensorString1-8() |

#### Analog Inputs (AnalogInputs) - ~35 identifiers
| UDP ID | Property | Current Call |
|--------|----------|--------------|
| 12-15 | auxcalc1-4 | m_dashboard->setauxcalc1-4() |
| 182-189 | sens1-8 | m_dashboard->setsens1-8() |
| 190 | genericoutput1 | m_dashboard->setgenericoutput1() |
| 260-270 | Analog0-10 | m_dashboard->setAnalog0-10() |
| 286-298 | Userchannel1-12 | m_dashboard->setUserchannel1-12() |

#### Digital Inputs (DigitalInputs) - ~8 identifiers
| UDP ID | Property | Current Call |
|--------|----------|--------------|
| 279-285 | DigitalInput1-7 | m_dashboard->setDigitalInput1-7() |

#### Expander Board Data (ExpanderBoardData) - ~17 identifiers
| UDP ID | Property | Current Call |
|--------|----------|--------------|
| 900-907 | EXDigitalInput1-8 | m_dashboard->setEXDigitalInput1-8() |
| 908-915 | EXAnalogInput0-7 | m_dashboard->setEXAnalogInput0-7() |
| 999 | frequencyDIEX1 | m_dashboard->setfrequencyDIEX1() |

#### Electric Motor Data (ElectricMotorData) - ~25 identifiers
| UDP ID | Property | Current Call |
|--------|----------|--------------|
| 832-841 | IGBTPhaseATemp, IGBTPhaseBTemp, IGBTPhaseCTemp, GateDriverTemp, ControlBoardTemp, RtdTemp1-5 | m_dashboard->setXXX() |
| 842-843 | EMotorTemperature, TorqueShudder | m_dashboard->setXXX() |
| 844-851 | DigInput1FowardSw - DigInput8Bool | m_dashboard->setXXX() |
| 852-863 | EMotorAngle, EMotorSpeed, ElectricalOutFreq, DeltaResolverFiltered, PhaseACurrent, PhaseBCurrent, PhaseCCurrent, DCBusCurrent, DCBusVoltage, OutputVoltage, VABvdVoltage, VBCvqVoltage | m_dashboard->setXXX() |

#### Sensor/Connection Data - ~5 identifiers
| UDP ID | Property | Current Call |
|--------|----------|--------------|
| 825 | Error | m_dashboard->setError() |

### 2.2 Task Checklist - Phase 2

- [ ] Create mapping documentation (CSV/JSON) for automated migration
- [ ] Verify all 300+ UDP identifiers are mapped
- [ ] Identify any unmapped properties
- [ ] Create test data generator for each domain

---

## Phase 3: Incremental Migration

### 3.1 Migration Strategy

Migrate one domain at a time to minimize risk:

**Order of Migration (by risk/complexity):**
1. FlagsData (50 properties) - Simple numeric/string flags
2. DigitalInputs (8 properties) - Simple boolean inputs
3. AnalogInputs (45 properties) - Numeric sensor values
4. ExpanderBoardData (17 properties) - External board data
5. VehicleData (70 properties) - Vehicle dynamics
6. EngineData (180 properties) - Core engine data (highest risk)
7. ElectricMotorData (25 properties) - EV-specific data
8. GPSData (10 properties) - Location data

### 3.2 Migration Pattern for Each Domain

For each domain:

1. **Add model pointer to UDPReceiver** (if not already done)
2. **Create a parallel code path** that writes to both:
   - The new model (`m_<domain>->setXXX()`)
   - The legacy dashboard (`m_dashboard->setXXX()`)
3. **Update QML files** to use new model reference
4. **Verify functionality** with test data
5. **Remove legacy dashboard call** once QML is updated

### 3.3 Example: Migrating FlagsData (Flag1-25)

**Step 1: Update UDPReceiver switch statement**

```cpp
// Before:
case 49:
    m_dashboard->setFlag1(Value);
    break;

// After (parallel):
case 49:
    m_flagsData->setFlag1(Value);
    m_dashboard->setFlag1(Value);  // TODO: Remove after QML migration
    break;
```

**Step 2: Find all QML files using these properties**

Search for `Dashboard.Flag1`, `Dashboard.Flag2`, etc. in:
- `PowerTune/Gauges/*.qml`
- `PowerTune/Settings/*.qml`
- `PowerTune/Core/*.qml`

**Step 3: Update QML bindings**

```qml
// Before:
value: Dashboard.Flag1

// After:
value: Flags.Flag1
```

**Step 4: Remove legacy call from UDPReceiver**

### 3.4 Task Checklist - Phase 3

#### 3.4.1 FlagsData Migration
- [ ] Update UDPReceiver for Flag1-25 (cases 49-73)
- [ ] Update UDPReceiver for FlagString1-16 (cases 808-823)
- [ ] Update UDPReceiver for SensorString1-8 (cases 800-807)
- [ ] Search and update QML files using `Dashboard.Flag*`
- [ ] Search and update QML files using `Dashboard.FlagString*`
- [ ] Search and update QML files using `Dashboard.SensorString*`
- [ ] Test with UDP data
- [ ] Remove legacy dashboard calls

#### 3.4.2 DigitalInputs Migration
- [ ] Update UDPReceiver for DigitalInput1-7 (cases 279-285)
- [ ] Search and update QML files using `Dashboard.DigitalInput*`
- [ ] Test with UDP data
- [ ] Remove legacy dashboard calls

#### 3.4.3 AnalogInputs Migration
- [ ] Update UDPReceiver for Analog0-10 (cases 260-270)
- [ ] Update UDPReceiver for sens1-8 (cases 182-189)
- [ ] Update UDPReceiver for auxcalc1-4 (cases 12-15)
- [ ] Update UDPReceiver for Userchannel1-12 (cases 286-298)
- [ ] Search and update QML files
- [ ] Test with UDP data
- [ ] Remove legacy dashboard calls

#### 3.4.4 ExpanderBoardData Migration
- [ ] Update UDPReceiver for EXDigitalInput1-8 (cases 900-907)
- [ ] Update UDPReceiver for EXAnalogInput0-7 (cases 908-915)
- [ ] Update UDPReceiver for frequencyDIEX1 (case 999)
- [ ] Search and update QML files using `Dashboard.EX*`
- [ ] Test with UDP data
- [ ] Remove legacy dashboard calls

#### 3.4.5 VehicleData Migration
- [ ] Update UDPReceiver for speed/gear/odometer properties
- [ ] Update UDPReceiver for wheel speed properties
- [ ] Update UDPReceiver for tire temp/pressure properties
- [ ] Update UDPReceiver for accelerometer/gyroscope properties
- [ ] Update UDPReceiver for lights/indicators properties
- [ ] Search and update QML files
- [ ] Test with UDP data
- [ ] Remove legacy dashboard calls

#### 3.4.6 EngineData Migration (LARGEST)
- [ ] Update UDPReceiver for RPM, boost, MAP properties
- [ ] Update UDPReceiver for fuel system properties
- [ ] Update UDPReceiver for ignition/injector properties
- [ ] Update UDPReceiver for temperature properties
- [ ] Update UDPReceiver for O2/Lambda/AFR properties
- [ ] Update UDPReceiver for knock properties
- [ ] Update UDPReceiver for EGT properties
- [ ] Update UDPReceiver for traction control properties
- [ ] Search and update ALL QML files (this is the big one)
- [ ] Test with UDP data
- [ ] Remove legacy dashboard calls

#### 3.4.7 ElectricMotorData Migration
- [ ] Update UDPReceiver for IGBT/motor temp properties
- [ ] Update UDPReceiver for motor state properties
- [ ] Update UDPReceiver for current/voltage properties
- [ ] Search and update QML files using `Dashboard.*Motor*`
- [ ] Test with UDP data
- [ ] Remove legacy dashboard calls

---

## Phase 4: QML File Updates

### 4.1 Files Requiring Updates

Based on the codebase analysis, these QML files need property reference updates:

**High Impact Files (many Dashboard references):**
- `PowerTune/Gauges/RoundGauge.qml` (2438 lines) - Dynamic property access
- `PowerTune/Gauges/SquareGauge.qml` (1306 lines) - Dynamic property access
- `PowerTune/Gauges/Cluster.qml` - Main cluster display
- `PowerTune/Gauges/Userdash1.qml`, `Userdash2.qml`, `Userdash3.qml`
- `PowerTune/Core/Main.qml` (662 lines)

**Medium Impact Files:**
- `PowerTune/Settings/DashSelector.qml`
- `PowerTune/Settings/DashSelectorWidget.qml`
- `PowerTune/Gauges/CircularGaugeStyle.qml`
- `PowerTune/Gauges/TachometerStyle.qml`
- `PowerTune/Gauges/VerticalBarGauge.qml`

**Special Handling Required:**
Files using dynamic property access like:
```qml
value: Dashboard[mainvaluename]
```
Will need a mapping function or conditional logic to route to the correct model.

### 4.2 Dynamic Property Access Strategy

For files using bracket notation (`Dashboard[propertyName]`):

**Option A: Property Mapping Object**
Create a QML helper that routes property names to the correct model:

```qml
// In a helper file or component
function getProperty(propertyName) {
    // Engine properties
    if (["rpm", "boost", "MAP", ...].includes(propertyName))
        return Engine[propertyName];
    // Vehicle properties
    if (["speed", "gear", ...].includes(propertyName))
        return Vehicle[propertyName];
    // Fallback to Dashboard (deprecated)
    return Dashboard[propertyName];
}
```

**Option B: Dashboard as Facade**
Keep Dashboard as a facade that forwards all property access to underlying models. This is already partially implemented.

**Recommendation: Option B** - Use Dashboard as a read-only facade during transition, then deprecate over time.

### 4.3 Task Checklist - Phase 4

- [ ] Create property-to-model mapping documentation
- [ ] Create helper function for dynamic property routing
- [ ] Update `RoundGauge.qml` dynamic access pattern
- [ ] Update `SquareGauge.qml` dynamic access pattern
- [ ] Update `Cluster.qml` direct property bindings
- [ ] Update `Main.qml` property bindings
- [ ] Update all `Userdash*.qml` files
- [ ] Update Settings QML files
- [ ] Update remaining Gauges QML files
- [ ] Verify all UI bindings work correctly

---

## Phase 5: Dashboard Facade Deprecation

### 5.1 Deprecation Strategy

1. **Mark deprecated methods** in `dashboard.h` with `[[deprecated]]` attribute
2. **Add forwarding logic** in Dashboard setters to route to models
3. **Log deprecation warnings** when Dashboard setters are called directly
4. **Remove deprecated code** after all callers are migrated

### 5.2 Example Facade Pattern

```cpp
// In dashboard.h
class DashBoard : public QObject
{
    // ... existing code ...
    
    // * Phase 5: Forwarding to EngineData
    [[deprecated("Use EngineData::setrpm() instead")]]
    void setrpm(qreal rpm) {
        if (m_engineData) {
            m_engineData->setrpm(rpm);
        }
        // Legacy: emit signal for backward compatibility
        if (m_rpm != rpm) {
            m_rpm = rpm;
            emit rpmChanged(rpm);
        }
    }
};
```

### 5.3 Task Checklist - Phase 5

- [ ] Add `EngineData*` pointer to Dashboard
- [ ] Add `VehicleData*` pointer to Dashboard
- [ ] Add forwarding logic for all deprecated setters
- [ ] Add deprecation attributes to legacy methods
- [ ] Add deprecation logging (optional)
- [ ] Update Connect.cpp to inject model pointers into Dashboard
- [ ] Test backward compatibility
- [ ] Document migration path for external callers

---

## Phase 6: Other Data Sources

### 6.1 Identify Other Dashboard Callers

Besides UDPReceiver, these classes also call Dashboard setters:

1. **ECU Protocol Classes:**
   - `ECU/Apexi.cpp`
   - `ECU/AdaptronicSelect.cpp`
   - `ECU/arduino.cpp`
   - Various OBD/CAN protocol handlers

2. **Hardware Classes:**
   - `Hardware/gps.cpp`
   - `Hardware/sensors.cpp`
   - `Hardware/Extender.cpp`

3. **Utility Classes:**
   - `Utils/Calculations.cpp`

### 6.2 Migration Plan for Other Callers

Apply the same pattern as UDPReceiver:
1. Add model pointers to constructor
2. Update setter calls to use models
3. Remove legacy Dashboard calls

### 6.3 Task Checklist - Phase 6

- [ ] Audit all files calling Dashboard setters
- [ ] Update Apexi protocol handler
- [ ] Update AdaptronicSelect protocol handler
- [ ] Update Arduino handler
- [ ] Update GPS handler
- [ ] Update Sensors handler
- [ ] Update Extender handler
- [ ] Update Calculations handler
- [ ] Update any remaining callers

---

## Phase 7: Cleanup and Documentation

### 7.1 Final Cleanup Tasks

- [ ] Remove unused Dashboard properties
- [ ] Remove unused Dashboard methods
- [ ] Update CMakeLists.txt if needed
- [ ] Remove deprecated code after verification
- [ ] Update project documentation

### 7.2 Documentation Updates

- [ ] Update README with new architecture
- [ ] Create data flow diagram
- [ ] Document QML property access patterns
- [ ] Create developer guide for adding new sensors

---

## Implementation Timeline Estimate

| Phase | Tasks | Dependencies |
|-------|-------|--------------|
| Phase 1 | Infrastructure Setup | None |
| Phase 2 | UDP Mapping | Phase 1 |
| Phase 3 | Incremental Migration | Phase 2 |
| Phase 4 | QML Updates | Phase 3 (per domain) |
| Phase 5 | Dashboard Facade | Phase 4 |
| Phase 6 | Other Data Sources | Phase 5 |
| Phase 7 | Cleanup | All phases |

---

## Risk Assessment

### High Risk Areas

1. **Dynamic QML Property Access** - Files using `Dashboard[propertyName]` need careful handling
2. **EngineData Migration** - Largest domain with most QML dependencies
3. **Signal/Slot Timing** - Ensure signals fire correctly after migration

### Mitigation Strategies

1. **Parallel Writes** - Write to both old and new during transition
2. **Incremental Testing** - Test each domain before moving to next
3. **Feature Flags** - Use compile-time flags to switch between old/new
4. **Rollback Plan** - Keep Dashboard facade working as fallback

---

## Appendix A: Property Count Summary

| Model | Properties | UDP IDs | QML Context |
|-------|------------|---------|-------------|
| EngineData | ~180 | ~95 | Engine |
| VehicleData | ~70 | ~35 | Vehicle |
| FlagsData | ~50 | ~50 | Flags |
| AnalogInputs | ~45 | ~35 | Analog |
| ElectricMotorData | ~25 | ~25 | Motor |
| DigitalInputs | ~20 | ~8 | Digital |
| ExpanderBoardData | ~17 | ~17 | Expander |
| GPSData | ~10 | ~5 | GPS |
| TimingData | ~10 | ~5 | Timing |
| SensorData | ~20 | ~5 | Sensor |
| ConnectionData | ~15 | ~2 | Connection |
| SettingsData | ~50 | 0 | Settings |
| UIState | 7 | 0 | UI |
| **Total** | **~519** | **~282** | |

---

## Appendix B: Quick Reference - Model Selection

When adding a new UDP identifier, use this guide:

| Data Type | Model | QML Context |
|-----------|-------|-------------|
| RPM, boost, fuel, ignition, temps | EngineData | Engine |
| Speed, gear, wheel, tire, accel | VehicleData | Vehicle |
| GPS coordinates, altitude, satellites | GPSData | GPS |
| Analog0-10, sens1-8, auxcalc | AnalogInputs | Analog |
| DigitalInput1-7 | DigitalInputs | Digital |
| EXDigitalInput, EXAnalogInput | ExpanderBoardData | Expander |
| IGBT temps, motor current/voltage | ElectricMotorData | Motor |
| Flag1-25, FlagString1-16 | FlagsData | Flags |
| Generic sensor values | SensorData | Sensor |
| Connection status, errors | ConnectionData | Connection |
| Configuration values | SettingsData | Settings |
| UI interaction state | UIState | UI |
