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
class TimingData;
class ConnectionData;
class SettingsData;

// * Full includes for convenience
#include "AnalogInputs.h"
#include "ConnectionData.h"
#include "DigitalInputs.h"
#include "EngineData.h"
#include "ExpanderBoardData.h"
#include "GPSData.h"
#include "SettingsData.h"
#include "TimingData.h"
#include "UIState.h"
#include "VehicleData.h"

#endif  // DATAMODELS_H
