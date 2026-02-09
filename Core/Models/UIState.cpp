/**
 * @file UIState.cpp
 * @brief Implementation of UIState model
 */

#include "UIState.h"

UIState::UIState(QObject *parent)
    : QObject(parent)
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
    emit BrightnessChanged(m_Brightness);
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

void UIState::setrpmstyle1(int rpmstyle1)
{
    if (m_rpmstyle1 == rpmstyle1)
        return;

    m_rpmstyle1 = rpmstyle1;
    emit rpmstyle1Changed(m_rpmstyle1);
}

void UIState::setrpmstyle2(int rpmstyle2)
{
    if (m_rpmstyle2 == rpmstyle2)
        return;

    m_rpmstyle2 = rpmstyle2;
    emit rpmstyle2Changed(m_rpmstyle2);
}

void UIState::setrpmstyle3(int rpmstyle3)
{
    if (m_rpmstyle3 == rpmstyle3)
        return;

    m_rpmstyle3 = rpmstyle3;
    emit rpmstyle3Changed(m_rpmstyle3);
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

void UIState::setdashsetup1(const QStringList &dashsetup1)
{
    if (m_dashsetup1 == dashsetup1)
        return;

    m_dashsetup1 = dashsetup1;
    emit dashsetup1Changed(m_dashsetup1);
}

void UIState::setdashsetup2(const QStringList &dashsetup2)
{
    if (m_dashsetup2 == dashsetup2)
        return;

    m_dashsetup2 = dashsetup2;
    emit dashsetup2Changed(m_dashsetup2);
}

void UIState::setdashsetup3(const QStringList &dashsetup3)
{
    if (m_dashsetup3 == dashsetup3)
        return;

    m_dashsetup3 = dashsetup3;
    emit dashsetup3Changed(m_dashsetup3);
}

void UIState::setbackroundpictures(const QStringList &backroundpictures)
{
    if (m_backroundpictures == backroundpictures)
        return;

    m_backroundpictures = backroundpictures;
    emit backroundpicturesChanged(m_backroundpictures);
}
