/**
 * @file UIState.cpp
 * @brief Implementation of UIState model
 */

#include "UIState.h"

UIState::UIState(QObject *parent)
    : QObject(parent),
      m_dashSetups(3),
      m_rpmStyles(3, 0)
{
}

void UIState::setdraggable(int draggable)
{
    if (m_draggable == draggable)
        return;

    m_draggable = draggable;
    emit draggableChanged(m_draggable);
}

void UIState::setBrightness(int Brightness)
{
    if (m_Brightness == Brightness)
        return;

    m_Brightness = Brightness;
    emit brightnessChanged(m_Brightness);
}

void UIState::setVisibledashes(int Visibledashes)
{
    if (m_Visibledashes == Visibledashes)
        return;

    m_Visibledashes = Visibledashes;
    emit VisibledashesChanged(m_Visibledashes);
}

void UIState::setscreen(bool screen)
{
    if (m_screen == screen)
        return;

    m_screen = screen;
    emit screenChanged(m_screen);
}

void UIState::setDashboardCount(int count)
{
    if (count < 1)
        count = 1;
    if (m_dashboardCount == count)
        return;

    m_dashboardCount = count;
    ensureDashCapacity(count - 1);
    emit dashboardCountChanged(m_dashboardCount);
}

void UIState::setmaindashsetup(const QStringList &maindashsetup)
{
    if (m_maindashsetup == maindashsetup)
        return;

    m_maindashsetup = maindashsetup;
    emit maindashsetupChanged(m_maindashsetup);
}

void UIState::setdashfiles(const QStringList &dashfiles)
{
    if (m_dashfiles == dashfiles)
        return;

    m_dashfiles = dashfiles;
    emit dashfilesChanged(m_dashfiles);
}

void UIState::setbackroundpictures(const QStringList &backroundpictures)
{
    if (m_backroundpictures == backroundpictures)
        return;

    m_backroundpictures = backroundpictures;
    emit backroundpicturesChanged(m_backroundpictures);
}

QStringList UIState::dashSetup(int index) const
{
    if (index < 0 || index >= m_dashSetups.size())
        return {};
    return m_dashSetups.at(index);
}

int UIState::rpmStyle(int index) const
{
    if (index < 0 || index >= m_rpmStyles.size())
        return 0;
    return m_rpmStyles.at(index);
}

void UIState::setDashSetup(int index, const QStringList &setup)
{
    if (index < 0)
        return;

    ensureDashCapacity(index);

    if (m_dashSetups.at(index) == setup)
        return;

    m_dashSetups[index] = setup;
    emit dashSetupChanged(index, setup);

    if (index == 0) emit dashsetup1Changed(setup);
    else if (index == 1) emit dashsetup2Changed(setup);
    else if (index == 2) emit dashsetup3Changed(setup);
}

void UIState::setRpmStyle(int index, int style)
{
    if (index < 0)
        return;

    ensureDashCapacity(index);

    if (m_rpmStyles.at(index) == style)
        return;

    m_rpmStyles[index] = style;
    emit rpmStyleChanged(index, style);

    if (index == 0) emit rpmstyle1Changed(style);
    else if (index == 1) emit rpmstyle2Changed(style);
    else if (index == 2) emit rpmstyle3Changed(style);
}

void UIState::ensureDashCapacity(int index)
{
    while (m_dashSetups.size() <= index)
        m_dashSetups.append(QStringList());
    while (m_rpmStyles.size() <= index)
        m_rpmStyles.append(0);
}
