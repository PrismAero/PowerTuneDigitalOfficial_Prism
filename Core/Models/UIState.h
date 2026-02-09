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
 * - RPM bar styles
 *
 * Part of the DashBoard God Object refactoring (TODO-001)
 * Extracted to isolate UI state from sensor data for better event handling.
 */

#ifndef UISTATE_H
#define UISTATE_H

#include <QObject>
#include <QStringList>

class UIState : public QObject
{
    Q_OBJECT

    // * Edit mode - controls whether gauges can be dragged/edited
    Q_PROPERTY(int draggable READ draggable WRITE setdraggable NOTIFY draggableChanged)

    // * Dashboard configuration lists
    Q_PROPERTY(QStringList maindashsetup READ maindashsetup WRITE setmaindashsetup NOTIFY maindashsetupChanged)
    Q_PROPERTY(QStringList dashfiles READ dashfiles WRITE setdashfiles NOTIFY dashfilesChanged)
    Q_PROPERTY(QStringList dashsetup1 READ dashsetup1 WRITE setdashsetup1 NOTIFY dashsetup1Changed)
    Q_PROPERTY(QStringList dashsetup2 READ dashsetup2 WRITE setdashsetup2 NOTIFY dashsetup2Changed)
    Q_PROPERTY(QStringList dashsetup3 READ dashsetup3 WRITE setdashsetup3 NOTIFY dashsetup3Changed)
    Q_PROPERTY(QStringList backroundpictures READ backroundpictures WRITE setbackroundpictures NOTIFY backroundpicturesChanged)

    // * Display brightness (0-255)
    Q_PROPERTY(int Brightness READ Brightness WRITE setBrightness NOTIFY BrightnessChanged)

    // * Number of visible dashboards
    Q_PROPERTY(int Visibledashes READ Visibledashes WRITE setVisibledashes NOTIFY VisibledashesChanged)

    // * Pi screen detection flag
    Q_PROPERTY(bool screen READ screen WRITE setscreen NOTIFY screenChanged)

    // * RPM bar style selectors for each dashboard
    Q_PROPERTY(int rpmstyle1 READ rpmstyle1 WRITE setrpmstyle1 NOTIFY rpmstyle1Changed)
    Q_PROPERTY(int rpmstyle2 READ rpmstyle2 WRITE setrpmstyle2 NOTIFY rpmstyle2Changed)
    Q_PROPERTY(int rpmstyle3 READ rpmstyle3 WRITE setrpmstyle3 NOTIFY rpmstyle3Changed)

public:
    explicit UIState(QObject *parent = nullptr);

    // * Getters
    int draggable() const { return m_draggable; }
    int Brightness() const { return m_Brightness; }
    int Visibledashes() const { return m_Visibledashes; }
    bool screen() const { return m_screen; }
    int rpmstyle1() const { return m_rpmstyle1; }
    int rpmstyle2() const { return m_rpmstyle2; }
    int rpmstyle3() const { return m_rpmstyle3; }
    QStringList maindashsetup() const { return m_maindashsetup; }
    QStringList dashfiles() const { return m_dashfiles; }
    QStringList dashsetup1() const { return m_dashsetup1; }
    QStringList dashsetup2() const { return m_dashsetup2; }
    QStringList dashsetup3() const { return m_dashsetup3; }
    QStringList backroundpictures() const { return m_backroundpictures; }

public slots:
    // * Setters
    void setdraggable(int draggable);
    void setBrightness(int Brightness);
    void setVisibledashes(int Visibledashes);
    void setscreen(bool screen);
    void setrpmstyle1(int rpmstyle1);
    void setrpmstyle2(int rpmstyle2);
    void setrpmstyle3(int rpmstyle3);
    void setmaindashsetup(const QStringList &maindashsetup);
    void setdashfiles(const QStringList &dashfiles);
    void setdashsetup1(const QStringList &dashsetup1);
    void setdashsetup2(const QStringList &dashsetup2);
    void setdashsetup3(const QStringList &dashsetup3);
    void setbackroundpictures(const QStringList &backroundpictures);

signals:
    void draggableChanged(int draggable);
    void BrightnessChanged(int Brightness);
    void VisibledashesChanged(int Visibledashes);
    void screenChanged(bool screen);
    void rpmstyle1Changed(int rpmstyle1);
    void rpmstyle2Changed(int rpmstyle2);
    void rpmstyle3Changed(int rpmstyle3);
    void maindashsetupChanged(const QStringList &maindashsetup);
    void dashfilesChanged(const QStringList &dashfiles);
    void dashsetup1Changed(const QStringList &dashsetup1);
    void dashsetup2Changed(const QStringList &dashsetup2);
    void dashsetup3Changed(const QStringList &dashsetup3);
    void backroundpicturesChanged(const QStringList &backroundpictures);

private:
    int m_draggable = 0;
    int m_Brightness = 255;
    int m_Visibledashes = 3;
    bool m_screen = false;
    int m_rpmstyle1 = 0;
    int m_rpmstyle2 = 0;
    int m_rpmstyle3 = 0;
    QStringList m_maindashsetup;
    QStringList m_dashfiles;
    QStringList m_dashsetup1;
    QStringList m_dashsetup2;
    QStringList m_dashsetup3;
    QStringList m_backroundpictures;
};

#endif  // UISTATE_H
