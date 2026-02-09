/**
 * @file DataModels.h
 * @brief Convenience header for all data model classes
 *
 * This header provides forward declarations and includes for all domain-specific
 * data model classes created as part of the DashBoard God Object refactoring (TODO-001).
 *
 * Include this header when you need access to all data models, or include
 * individual headers for specific models.
 */

#ifndef DATAMODELS_H
#define DATAMODELS_H

// * Forward declarations for use with pointers/references
class UIState;
class EngineData;
class VehicleData;
class GPSData;
class AnalogInputs;
class DigitalInputs;
class ExpanderBoardData;
class ElectricMotorData;
class FlagsData;
class TimingData;
class SensorData;
class ConnectionData;
class SettingsData;

// * Full includes for convenience
#include "UIState.h"
#include "AnalogInputs.h"
#include "DigitalInputs.h"
#include "ElectricMotorData.h"
#include "EngineData.h"
#include "ExpanderBoardData.h"
#include "FlagsData.h"
#include "GPSData.h"
#include "TimingData.h"
#include "VehicleData.h"
#include "SensorData.h"
#include "ConnectionData.h"
#include "SettingsData.h"

#endif  // DATAMODELS_H
