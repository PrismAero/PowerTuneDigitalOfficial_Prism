#ifndef ADAPTRONICSELECT_H
#define ADAPTRONICSELECT_H
#include <QModbusClient>
#include <QModbusDataUnit>
#include <QModbusReply>
#include <QObject>
#include <QtSerialPort/QSerialPort>


class Serialport;
class QModbusClient;
class QModbusReply;
class EngineData;
class VehicleData;
class SensorData;

class AdaptronicSelect : public QObject
{
    Q_OBJECT

public:
    explicit AdaptronicSelect(QObject *parent = nullptr);
    explicit AdaptronicSelect(EngineData *engineData, VehicleData *vehicleData, SensorData *sensorData,
                             QObject *parent = nullptr);
    ~AdaptronicSelect() override;

public slots:
    void openConnection(const QString &portName);
    void closeConnection();
    void AdaptronicStartStream();
    void readyToRead();
    void decodeAdaptronic(QModbusDataUnit serialdata);

private:
    EngineData *m_engineData;
    VehicleData *m_vehicleData;
    SensorData *m_sensorData;
    QModbusReply *lastRequest;
    QModbusClient *modbusDevice;
    QModbusDataUnit readRequest() const;


signals:
    void sig_adaptronicReadFinished();
};


#endif  // ADAPTRONICSELECT_H
