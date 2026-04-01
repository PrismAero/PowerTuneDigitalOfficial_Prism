#include "Extender.h"

Extender::Extender(QObject *parent) : ExBoardCan(parent) {}

Extender::Extender(DigitalInputs *digitalInputs, ExpanderBoardData *expanderBoardData, EngineData *engineData,
                   SettingsData *settingsData, VehicleData *vehicleData, ConnectionData *connectionData,
                   QObject *parent)
    : ExBoardCan(digitalInputs, expanderBoardData, engineData, settingsData, vehicleData, connectionData, parent)
{}

Extender::~Extender() = default;
