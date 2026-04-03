#ifndef DFISERIALREADER_H
#define DFISERIALREADER_H

#include <QElapsedTimer>
#include <QObject>
#include <QSerialPort>
#include <QSet>
#include <QString>
#include <QStringList>
#include <QTimer>

extern "C" {
#include "kawasaki_dfi_comm.h"
}

class AppSettings;
class VehicleData;
class DiagnosticsProvider;
class SensorRegistry;

class DfiSerialReader : public QObject
{
    Q_OBJECT

    Q_PROPERTY(int gear READ gear NOTIFY gearChanged)
    Q_PROPERTY(QString gearString READ gearString NOTIFY gearChanged)
    Q_PROPERTY(QString activeCodes READ activeCodes NOTIFY activeCodesChanged)
    Q_PROPERTY(int checksumErrors READ checksumErrors NOTIFY statusUpdated)
    Q_PROPERTY(int groupsReceived READ groupsReceived NOTIFY statusUpdated)
    Q_PROPERTY(bool connected READ connected NOTIFY connectedChanged)
    Q_PROPERTY(bool hasSignal READ hasSignal NOTIFY statusUpdated)
    Q_PROPERTY(QString portPath READ portPath WRITE setPortPath NOTIFY portPathChanged)
    Q_PROPERTY(bool enabled READ enabled WRITE setEnabled NOTIFY enabledChanged)

public:
    explicit DfiSerialReader(QObject *parent = nullptr);
    ~DfiSerialReader() override;

    void setAppSettings(AppSettings *settings);
    void setVehicleData(VehicleData *vehicleData);
    void setDiagnosticsProvider(DiagnosticsProvider *diag);
    void setSensorRegistry(SensorRegistry *registry);

    int gear() const;
    QString gearString() const;
    QString activeCodes() const;
    int checksumErrors() const;
    int groupsReceived() const;
    bool connected() const;
    bool hasSignal() const;
    QString portPath() const;
    bool enabled() const;

    void setPortPath(const QString &path);
    void setEnabled(bool on);

    Q_INVOKABLE void start();
    Q_INVOKABLE void stop();

    Q_INVOKABLE bool isCodeSuppressed(int code) const;
    Q_INVOKABLE void suppressCode(int code);
    Q_INVOKABLE void unsuppressCode(int code);
    Q_INVOKABLE void suppressAllKnownCodes();
    Q_INVOKABLE void enableAllCodes();
    Q_INVOKABLE QStringList suppressedCodeList() const;

    Q_INVOKABLE static QString dfiCodeDescription(int code);

    static constexpr int KnownCodeCount = 27;
    static const int KnownCodes[KnownCodeCount];

signals:
    void gearChanged(int gear);
    void activeCodesChanged(const QString &codes);
    void statusUpdated();
    void connectedChanged(bool connected);
    void portPathChanged(const QString &path);
    void enabledChanged(bool enabled);

private slots:
    void onReadyRead();
    void onSerialError(QSerialPort::SerialPortError error);
    void checkSignalTimeout();

private:
    void loadSuppressedCodes();
    void saveSuppressedCodes();
    void publishStatus(const dfi_status_t *status);
    QString buildFilteredCodeString(const dfi_status_t *status) const;

    static void statusCallback(const dfi_status_t *status, void *userData);

    QSerialPort *m_serial = nullptr;
    QElapsedTimer m_elapsedTimer;
    dfi_decoder_t m_decoder{};
    QTimer m_signalTimer;

    AppSettings *m_appSettings = nullptr;
    VehicleData *m_vehicleData = nullptr;
    DiagnosticsProvider *m_diagnosticsProvider = nullptr;
    SensorRegistry *m_sensorRegistry = nullptr;

    QString m_portPath;
    bool m_enabled = false;
    bool m_connected = false;
    bool m_hasSignal = false;

    int m_gear = -1;
    QString m_activeCodes;
    QSet<int> m_suppressedCodes;

    static constexpr int SIGNAL_TIMEOUT_MS = 5000;
};

#endif  // DFISERIALREADER_H
