/**
 * @file dashboard.cpp
 * @brief Minimal DashBoard coordination class implementation
 *
 * All sensor/vehicle/engine data properties and Steinhart-Hart calculation logic
 * have been extracted to domain models (Core/Models/) and utility classes
 * (Utils/SteinhartCalculator). This file contains only lifecycle management
 * and UIState coordination.
 */

#include "dashboard.h"
#include "Models/UIState.h"

/**
 * @brief Construct a minimal DashBoard coordination object
 * @param parent QObject parent for Qt ownership
 */
DashBoard::DashBoard(QObject *parent)
    : QObject(parent),
      m_uiState(nullptr),
      m_steinhartCalc(nullptr),
      m_rpmSmoother(nullptr),
      m_speedSmoother(nullptr)
{
}

/**
 * @brief Sets UIState model pointer for facade forwarding
 *
 * UI-related properties (draggable, Brightness, Visibledashes, screen,
 * rpmstyle1-3, maindashsetup, dashfiles, dashsetup1-3, backroundpictures)
 * have been fully moved to UIState. This method is retained for any
 * future cross-model coordination needs.
 *
 * @param uiState Pointer to UIState model instance
 */
void DashBoard::setUIState(UIState *uiState)
{
    if (m_uiState == uiState)
        return;

    m_uiState = uiState;
}
