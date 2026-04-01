/**
 * @file UIState.h
 * @brief UI interaction state model for PowerTune dashboard
 *
 * This class encapsulates all UI-related state properties that control
 * dashboard interaction behavior, including:
 * - Edit mode (draggable) state
 * - Display brightness
 * - Visible dashboard count
 * - Screen detection
 * - RPM bar styles (indexed)
 * - Dashboard setup data (indexed)
 *
 * Part of the DashBoard God Object refactoring (TODO-001)
 * Extracted to isolate UI state from sensor data for better event handling.
 */

#ifndef UISTATE_H
#define UISTATE_H

#include <QObject>
#include <QStringList>
#include <QVector>

class UIState : public QObject
{
    Q_OBJECT

    Q_PROPERTY(int draggable READ draggable WRITE setdraggable NOTIFY draggableChanged)
    Q_PROPERTY(QStringList maindashsetup READ maindashsetup WRITE setmaindashsetup NOTIFY maindashsetupChanged)
    Q_PROPERTY(QStringList dashfiles READ dashfiles WRITE setdashfiles NOTIFY dashfilesChanged)
    Q_PROPERTY(
        QStringList backroundpictures READ backroundpictures WRITE setbackroundpictures NOTIFY backroundpicturesChanged)
    Q_PROPERTY(int Brightness READ Brightness WRITE setBrightness NOTIFY brightnessChanged)
    Q_PROPERTY(int Visibledashes READ Visibledashes WRITE setVisibledashes NOTIFY VisibledashesChanged)
    Q_PROPERTY(bool screen READ screen WRITE setscreen NOTIFY screenChanged)
    Q_PROPERTY(int dashboardCount READ dashboardCount WRITE setDashboardCount NOTIFY dashboardCountChanged)

    // Legacy properties kept for backward compatibility with existing QML bindings
    Q_PROPERTY(QStringList dashsetup1 READ dashsetup1 NOTIFY dashsetup1Changed)
    Q_PROPERTY(QStringList dashsetup2 READ dashsetup2 NOTIFY dashsetup2Changed)
    Q_PROPERTY(QStringList dashsetup3 READ dashsetup3 NOTIFY dashsetup3Changed)
    Q_PROPERTY(int rpmstyle1 READ rpmstyle1 NOTIFY rpmstyle1Changed)
    Q_PROPERTY(int rpmstyle2 READ rpmstyle2 NOTIFY rpmstyle2Changed)
    Q_PROPERTY(int rpmstyle3 READ rpmstyle3 NOTIFY rpmstyle3Changed)

public:
    explicit UIState(QObject *parent = nullptr);

    int draggable() const { return m_draggable; }
    int Brightness() const { return m_Brightness; }
    int Visibledashes() const { return m_Visibledashes; }
    bool screen() const { return m_screen; }
    int dashboardCount() const { return m_dashboardCount; }
    QStringList maindashsetup() const { return m_maindashsetup; }
    QStringList dashfiles() const { return m_dashfiles; }
    QStringList backroundpictures() const { return m_backroundpictures; }

    // Indexed accessors for dynamic dashboard support
    Q_INVOKABLE QStringList dashSetup(int index) const;
    Q_INVOKABLE int rpmStyle(int index) const;

    // Legacy getters delegate to indexed containers
    QStringList dashsetup1() const { return dashSetup(0); }
    QStringList dashsetup2() const { return dashSetup(1); }
    QStringList dashsetup3() const { return dashSetup(2); }
    int rpmstyle1() const { return rpmStyle(0); }
    int rpmstyle2() const { return rpmStyle(1); }
    int rpmstyle3() const { return rpmStyle(2); }

public slots:
    void setdraggable(int draggable);
    void setBrightness(int Brightness);
    void setVisibledashes(int Visibledashes);
    void setscreen(bool screen);
    void setDashboardCount(int count);
    void setmaindashsetup(const QStringList &maindashsetup);
    void setdashfiles(const QStringList &dashfiles);
    void setbackroundpictures(const QStringList &backroundpictures);

    // Indexed setters for dynamic dashboard support
    void setDashSetup(int index, const QStringList &setup);
    void setRpmStyle(int index, int style);

    // Legacy setters delegate to indexed containers
    void setdashsetup1(const QStringList &dashsetup) { setDashSetup(0, dashsetup); }
    void setdashsetup2(const QStringList &dashsetup) { setDashSetup(1, dashsetup); }
    void setdashsetup3(const QStringList &dashsetup) { setDashSetup(2, dashsetup); }
    void setrpmstyle1(int rpmstyle) { setRpmStyle(0, rpmstyle); }
    void setrpmstyle2(int rpmstyle) { setRpmStyle(1, rpmstyle); }
    void setrpmstyle3(int rpmstyle) { setRpmStyle(2, rpmstyle); }

signals:
    void draggableChanged(int draggable);
    void brightnessChanged(int Brightness);
    void VisibledashesChanged(int Visibledashes);
    void screenChanged(bool screen);
    void dashboardCountChanged(int count);
    void maindashsetupChanged(const QStringList &maindashsetup);
    void dashfilesChanged(const QStringList &dashfiles);
    void backroundpicturesChanged(const QStringList &backroundpictures);

    void dashSetupChanged(int index, const QStringList &setup);
    void rpmStyleChanged(int index, int style);

    // Legacy signals emitted alongside indexed ones for backward compatibility
    void dashsetup1Changed(const QStringList &dashsetup);
    void dashsetup2Changed(const QStringList &dashsetup);
    void dashsetup3Changed(const QStringList &dashsetup);
    void rpmstyle1Changed(int rpmstyle);
    void rpmstyle2Changed(int rpmstyle);
    void rpmstyle3Changed(int rpmstyle);

private:
    void ensureDashCapacity(int index);

    int m_draggable = 0;
    int m_Brightness = 255;
    int m_Visibledashes = 1;
    bool m_screen = false;
    int m_dashboardCount = 3;
    QStringList m_maindashsetup;
    QStringList m_dashfiles;
    QStringList m_backroundpictures;
    QVector<QStringList> m_dashSetups;
    QVector<int> m_rpmStyles;
};

#endif  // UISTATE_H
