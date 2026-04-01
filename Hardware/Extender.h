#ifndef EXTENDER_H
#define EXTENDER_H

#include "../Can/Protocols/ExBoardCan.h"

class Extender : public ExBoardCan
{
    Q_OBJECT

public:
    explicit Extender(QObject *parent = nullptr);
    explicit Extender(DigitalInputs *digitalInputs, ExpanderBoardData *expanderBoardData, EngineData *engineData,
                      SettingsData *settingsData, VehicleData *vehicleData, ConnectionData *connectionData,
                      QObject *parent = nullptr);
    ~Extender() override;
};

#endif  // EXTENDER_H
