# CMakeLists.txt for PowerTune Digital Dashboard
# This CMake configuration mirrors the qmake .pro file and provides modern CMake support
# for IDE tooling, clangd integration, and cross-platform builds.

cmake_minimum_required(VERSION 3.16)

project(PowerTuneQMLGui
    VERSION 1.0.0
    DESCRIPTION "PowerTune Digital Dashboard for automotive ECU monitoring"
    LANGUAGES CXX
)

# * C++ Standard Configuration
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# * Qt Configuration
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

# * Find Qt packages - supports both Qt5 and Qt6
find_package(QT NAMES Qt6 Qt5 REQUIRED COMPONENTS Core)
find_package(Qt${QT_VERSION_MAJOR} REQUIRED COMPONENTS
    Core
    Gui
    Qml
    Quick
    QuickControls2
    Network
    SerialBus
)

# * Qt6-specific: Qt5Compat for GraphicalEffects and other Qt5 modules
if(${QT_VERSION_MAJOR} GREATER_EQUAL 6)
    find_package(Qt6 COMPONENTS Core5Compat QUIET)
    if(Qt6Core5Compat_FOUND)
        set(Qt6Qt5Compat_FOUND TRUE)
        message(STATUS "Qt5Compat (Core5Compat) found - GraphicalEffects available")
    else()
        message(WARNING "Qt5Compat not found - some graphical effects may not work")
    endif()
    
    # * ShaderTools for Qt6 effects
    find_package(Qt6 COMPONENTS ShaderTools QUIET)
endif()

# Brightness control is detected at runtime via Connect::checkifraspberrypi().
# ddcutil (or sysfs backlight) presence is probed on startup -- no compile-time flag needed.

# * Source files - Core
set(CORE_SOURCES
    Core/connect.cpp
    Core/dashboard.cpp
    Core/appsettings.cpp
    Core/PropertyRouter.cpp
    Core/SensorRegistry.cpp
    Core/DiagnosticsProvider.cpp
    Core/Models/UIState.cpp
    Core/Models/EngineData.cpp
    Core/Models/VehicleData.cpp
    Core/Models/GPSData.cpp
    Core/Models/AnalogInputs.cpp
    Core/Models/DigitalInputs.cpp
    Core/Models/ExpanderBoardData.cpp
    Core/Models/ElectricMotorData.cpp
    Core/Models/FlagsData.cpp
    Core/Models/TimingData.cpp
    Core/Models/SensorData.cpp
    Core/Models/ConnectionData.cpp
    Core/Models/SettingsData.cpp
    Core/Models/CanFrameModel.cpp
)

set(CORE_HEADERS
    Core/connect.h
    Core/dashboard.h
    Core/appsettings.h
    Core/PropertyRouter.h
    Core/SensorRegistry.h
    Core/DiagnosticsProvider.h
    Core/Models/UIState.h
    Core/Models/DataModels.h
    Core/Models/EngineData.h
    Core/Models/VehicleData.h
    Core/Models/GPSData.h
    Core/Models/AnalogInputs.h
    Core/Models/DigitalInputs.h
    Core/Models/ExpanderBoardData.h
    Core/Models/ElectricMotorData.h
    Core/Models/FlagsData.h
    Core/Models/TimingData.h
    Core/Models/SensorData.h
    Core/Models/ConnectionData.h
    Core/Models/SettingsData.h
    Core/Models/CanFrameModel.h
)

# * Source files - Hardware interfaces
set(HARDWARE_SOURCES
    Hardware/Extender.cpp
)

set(HARDWARE_HEADERS
    Hardware/Extender.h
)

# * Source files - Utilities
set(UTILS_SOURCES
    Utils/DataLogger.cpp
    Utils/Calculations.cpp
    Utils/SteinhartCalculator.cpp
    Utils/CalibrationHelper.cpp
    Utils/SignalSmoother.cpp
    Utils/downloadmanager.cpp
    Utils/ParseGithubData.cpp
    Utils/shcalc.cpp
    Utils/textprogressbar.cpp
    Utils/UDPReceiver.cpp
    Utils/UdpTestSimulator.cpp
    Utils/OverlayConfigManager.cpp
    Utils/ShiftIndicatorHelper.cpp
    Utils/wifiscanner.cpp
)

set(UTILS_HEADERS
    Utils/DataLogger.h
    Utils/Calculations.h
    Utils/SteinhartCalculator.h
    Utils/CalibrationHelper.h
    Utils/SignalSmoother.h
    Utils/downloadmanager.h
    Utils/ParseGithubData.h
    Utils/shcalc.h
    Utils/textprogressbar.h
    Utils/UDPReceiver.h
    Utils/UdpTestSimulator.h
    Utils/OverlayConfigManager.h
    Utils/ShiftIndicatorHelper.h
    Utils/wifiscanner.h
)

# * Combine all sources
set(PROJECT_SOURCES
    main.cpp
    ${CORE_SOURCES}
    ${HARDWARE_SOURCES}
    ${UTILS_SOURCES}
)

set(PROJECT_HEADERS
    ${CORE_HEADERS}
    ${HARDWARE_HEADERS}
    ${UTILS_HEADERS}
)

# * Create executable
if(${QT_VERSION_MAJOR} GREATER_EQUAL 6)
    qt_add_executable(${PROJECT_NAME}
        MANUAL_FINALIZATION
        ${PROJECT_SOURCES}
        ${PROJECT_HEADERS}
    )
else()
    add_executable(${PROJECT_NAME}
        ${PROJECT_SOURCES}
        ${PROJECT_HEADERS}
    )
endif()

# * Include directories
target_include_directories(${PROJECT_NAME} PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/Core
    ${CMAKE_CURRENT_SOURCE_DIR}/Hardware
    ${CMAKE_CURRENT_SOURCE_DIR}/Utils
)

# * Link Qt libraries
target_link_libraries(${PROJECT_NAME} PRIVATE
    Qt${QT_VERSION_MAJOR}::Core
    Qt${QT_VERSION_MAJOR}::Gui
    Qt${QT_VERSION_MAJOR}::Qml
    Qt${QT_VERSION_MAJOR}::Quick
    Qt${QT_VERSION_MAJOR}::QuickControls2
    Qt${QT_VERSION_MAJOR}::Network
    Qt${QT_VERSION_MAJOR}::SerialBus
)

# * Link Qt5Compat for GraphicalEffects (Qt6 only)
if(${QT_VERSION_MAJOR} GREATER_EQUAL 6 AND Qt6Qt5Compat_FOUND)
    target_link_libraries(${PROJECT_NAME} PRIVATE
        Qt6::Core5Compat
    )
endif()

# * PowerTune QML Sub-Modules (Qt6 only)
# * Provides organized imports: PowerTune.Core, PowerTune.Settings, PowerTune.Gauges, PowerTune.Utils
if(${QT_VERSION_MAJOR} GREATER_EQUAL 6)
    # * Suppress Qt policy warning about qmldir files
    qt_policy(SET QTP0004 OLD)
    
    # * Define singletons
    set_source_files_properties(PowerTune/Utils/Translator.qml PROPERTIES
        QT_QML_SINGLETON_TYPE TRUE
    )
    set_source_files_properties(PowerTune/Gauges/Shared/DatasourceService.qml PROPERTIES
        QT_QML_SINGLETON_TYPE TRUE
    )
    set_source_files_properties(PowerTune/Dashboard/DashboardTheme.qml PROPERTIES
        QT_QML_SINGLETON_TYPE TRUE
    )
    set_source_files_properties(PowerTune/Settings/components/SettingsTheme.qml PROPERTIES
        QT_QML_SINGLETON_TYPE TRUE
    )
    
    # * Create backing library targets for QML modules
    qt_add_library(PowerTuneUtilsLib STATIC)
    qt_add_library(PowerTuneCoreLib STATIC)
    qt_add_library(PowerTuneUiLib STATIC)
    qt_add_library(PowerTuneSettingsLib STATIC)
    qt_add_library(GaugesSharedLib STATIC)
    qt_add_library(PrismPTDashboardLib STATIC)
    qt_add_library(PrismKeyboardLib STATIC)

    
    # * PowerTune.Utils module - Translator singleton and icon utilities
    qt_add_qml_module(PowerTuneUtilsLib
        URI PowerTune.Utils
        VERSION 1.0
        QML_FILES
            PowerTune/Utils/Translator.qml
            PowerTune/Utils/MaterialIcon.qml
        RESOURCES
            PowerTune/Utils/Translator.js
        RESOURCE_PREFIX /qt/qml
        OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/qt/qml/PowerTune/Utils
    )
    
    # * PowerTune.Core module - Main application pages
    qt_add_qml_module(PowerTuneCoreLib
        URI PowerTune.Core
        VERSION 1.0
        QML_FILES
            PowerTune/Core/Main.qml
            PowerTune/Core/Intro.qml
            PowerTune/Core/SettingsManager.qml
            PowerTune/Core/ExBoardAnalog.qml
            PowerTune/Core/AnalogInputs.qml
            PowerTune/Core/BrightnessPopUp.qml
        RESOURCE_PREFIX /qt/qml
        OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/qt/qml/PowerTune/Core
    )

    # * PowerTune.UI module - Shared non-gauge UI primitives
    qt_add_qml_module(PowerTuneUiLib
        URI PowerTune.UI
        VERSION 1.0
        QML_FILES
            PowerTune/Settings/components/SettingsTheme.qml
            PowerTune/Settings/components/SettingsPage.qml
            PowerTune/Settings/components/SettingsSection.qml
            PowerTune/Settings/components/SettingsRow.qml
            PowerTune/Settings/components/StyledButton.qml
            PowerTune/Settings/components/StyledComboBox.qml
            PowerTune/Settings/components/StyledSwitch.qml
            PowerTune/Settings/components/StyledTextField.qml
            PowerTune/Settings/components/StyledCheckBox.qml
            PowerTune/Settings/components/ConnectionStatusIndicator.qml
        RESOURCE_PREFIX /qt/qml
        OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/qt/qml/PowerTune/UI
    )
    
    # * PowerTune.Settings module - Settings pages
    qt_add_qml_module(PowerTuneSettingsLib
        URI PowerTune.Settings
        VERSION 1.0
        QML_FILES
            PowerTune/Settings/MainSettings.qml
            PowerTune/Settings/DashSelector.qml
            PowerTune/Settings/DashSelectorWidget.qml
            PowerTune/Settings/VehicleRPMSettings.qml
            PowerTune/Settings/NetworkSettings.qml
            PowerTune/Settings/CanMonitor.qml
            PowerTune/Settings/DiagnosticsSettings.qml
            PowerTune/Settings/DashboardTestSim.qml
            PowerTune/Settings/HelpPage.qml
            PowerTune/Settings/WifiCountryList.qml
        RESOURCE_PREFIX /qt/qml
        OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/qt/qml/PowerTune/Settings
    )
    
    # * PowerTune.Gauges.Shared module - Shared helpers, datasources, singletons
    qt_add_qml_module(GaugesSharedLib
        URI PowerTune.Gauges.Shared
        VERSION 1.0
        QML_FILES
            PowerTune/Gauges/Shared/DatasourcesList.qml
            PowerTune/Gauges/Shared/DatasourceService.qml
            PowerTune/Gauges/Shared/Warning.qml
            PowerTune/Gauges/Shared/WarningLoader.qml
        RESOURCE_PREFIX /qt/qml
        OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/qt/qml/PowerTune/Gauges/Shared
    )
    
    # * PrismPT.Dashboard module - User dashboard canvas and panels
    qt_add_qml_module(PrismPTDashboardLib
        URI PrismPT.Dashboard
        VERSION 1.0
        QML_FILES
            PowerTune/Dashboard/DashboardTheme.qml
            PowerTune/Dashboard/UserDashboard.qml
            PowerTune/Dashboard/RaceDash.qml
            PowerTune/Dashboard/ArcGauge.qml
            PowerTune/Dashboard/ShiftIndicator.qml
            PowerTune/Dashboard/SensorCard.qml
            PowerTune/Dashboard/StatusBox.qml
            PowerTune/Dashboard/BrakeBiasBar.qml
            PowerTune/Dashboard/BottomStatusBar.qml
            PowerTune/Dashboard/GearIndicator.qml
            PowerTune/Dashboard/ArcFillOverlay.qml
            PowerTune/Dashboard/DraggableOverlay.qml
            PowerTune/Dashboard/OverlayConfigPopup.qml
        RESOURCE_PREFIX /qt/qml
        OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/qt/qml/PrismPT/Dashboard
    )
    
    # * Prism.Keyboard module - Custom virtual keyboard
    qt_add_qml_module(PrismKeyboardLib
        URI Prism.Keyboard
        VERSION 1.0
        QML_FILES
            Prism/Keyboard/KeyButton.qml
            Prism/Keyboard/NumericPad.qml
            Prism/Keyboard/QwertyLayout.qml
            Prism/Keyboard/PrismKeyboard.qml
        RESOURCE_PREFIX /qt/qml
        OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/qt/qml/Prism/Keyboard
    )
    
    # * Static assets (graphics, fonts) - embedded directly into the executable
    qt_add_resources(${PROJECT_NAME} "resources"
        PREFIX /
        FILES
            Resources/fonts/MaterialSymbolsOutlined.ttf
            Resources/fonts/HyperspaceRaceVariable.otf
            Resources/fonts/Lato-Regular.ttf
            Resources/fonts/Lato-Bold.ttf
            Resources/fonts/Lato-Italic.ttf
            Resources/fonts/Lato-BoldItalic.ttf
            Resources/fonts/Lato-Light.ttf
            Resources/fonts/Lato-LightItalic.ttf
            Resources/fonts/Lato-Thin.ttf
            Resources/fonts/Lato-ThinItalic.ttf
            Resources/fonts/Lato-Black.ttf
            Resources/fonts/Lato-BlackItalic.ttf
            Resources/fonts/JetBrainsMono-Regular.ttf
            Resources/graphics/Logo.png
            Resources/graphics/brightness.png
            Resources/graphics/brightnessIncrease.png
            Resources/graphics/brightnessDecrease.png
            Resources/graphics/contactQR.png
            Resources/graphics/facebookQR.png
            Resources/graphics/instagramQR.png
            Resources/graphics/userManualQR.png
            Resources/graphics/warrantyQR.png
            Resources/graphics/Tacho_Mitte.png
            Resources/graphics/vertrevcanvas.png
            Resources/graphics/next.png
            Resources/graphics/pause.png
            Resources/graphics/play.png
            Resources/graphics/previous.png
            Resources/graphics/ledgreen.png
            Resources/graphics/ledoff.png
            Resources/graphics/ledred.png
            Resources/graphics/ledyellow.png
            Resources/graphics/RPM_BG.png
            Resources/graphics/RPM_Fill.png
            Resources/graphics/empty.png
            Resources/graphics/fill.png
            Resources/graphics/fueltechempty.png
            Resources/graphics/fueltechfill.png
            Resources/graphics/Racedash.png
            Resources/graphics/Racedash800x480.png
            Resources/graphics/Racedash_AiM.png
            Resources/graphics/needle.svg
            Resources/graphics/RoungGaugeRing.png
            Resources/graphics/green_Light.png
            Resources/graphics/Indicator_left.png
            Resources/graphics/Indicator_left_off.png
            Resources/graphics/Indicator_right.png
            Resources/graphics/Indicator_right_off.png
            Resources/graphics/MainDash.png
            Resources/graphics/MainDashBlue.png
            Resources/graphics/MainDashnew.png
            Resources/graphics/SelectStategif.png
            Resources/graphics/StateGIF.gif
            Resources/graphics/rotary.gif
            Resources/graphics/selectStateImage.png
            Resources/graphics/slectImage.png
            Resources/graphics/test.png
            Resources/graphics/Flags/ae.png
            Resources/graphics/Flags/de.png
            Resources/graphics/Flags/es.png
            Resources/graphics/Flags/fr.png
            Resources/graphics/Flags/jp.png
            Resources/graphics/Flags/us.png
    )

    # * Compile GLSL shaders to .qsb bundles for RaceDash arc gauges
    if(Qt6ShaderTools_FOUND)
        qt_add_shaders(${PROJECT_NAME} "racedash_shaders"
            BATCHABLE
            PRECOMPILE
            OPTIMIZED
            PREFIX "/shaders"
            FILES
                Shaders/arcgauge.vert
                Shaders/arcgauge.frag
        )
    else()
        message(WARNING "Qt6 ShaderTools not found - RaceDash arc gauge shaders will not be compiled")
    endif()

    # * Link all QML modules to main executable
    target_link_libraries(${PROJECT_NAME} PRIVATE
        PowerTuneUtilsLibplugin
        PowerTuneCoreLibplugin
        PowerTuneUiLibplugin
        PowerTuneSettingsLibplugin
        GaugesSharedLibplugin
        PrismPTDashboardLibplugin
        PrismKeyboardLibplugin
    )
endif()

# * QML Import paths for Qt Creator and Qt Design Studio
set(QML_IMPORT_PATH
    "${CMAKE_CURRENT_SOURCE_DIR}/PowerTune"
    "${CMAKE_CURRENT_SOURCE_DIR}/PowerTune/Core"
    "${CMAKE_CURRENT_SOURCE_DIR}/PowerTune/Settings"
    "${CMAKE_CURRENT_SOURCE_DIR}/PowerTune/UI"
    "${CMAKE_CURRENT_SOURCE_DIR}/PowerTune/Gauges/Shared"
    "${CMAKE_CURRENT_SOURCE_DIR}/PowerTune/Utils"
    "${CMAKE_CURRENT_SOURCE_DIR}/PowerTune/Dashboard"
    CACHE STRING "Qt Creator/Design Studio QML import paths"
    FORCE
)

# * Set application properties
set_target_properties(${PROJECT_NAME} PROPERTIES
    MACOSX_BUNDLE_GUI_IDENTIFIER com.powertune.digital
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

# * Installation rules
include(GNUInstallDirs)
install(TARGETS ${PROJECT_NAME}
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)

# * Qt6 finalization
if(QT_VERSION_MAJOR EQUAL 6)
    qt_finalize_executable(${PROJECT_NAME})
endif()

# * Export compile_commands.json for clangd and other tools
set(CMAKE_EXPORT_COMPILE_COMMANDS ON)

# * Print configuration summary
message(STATUS "")
message(STATUS "PowerTune Build Configuration:")
message(STATUS "  Qt Version: ${QT_VERSION}")
message(STATUS "  C++ Standard: ${CMAKE_CXX_STANDARD}")
message(STATUS "  Build Type: ${CMAKE_BUILD_TYPE}")
message(STATUS "  Install Prefix: ${CMAKE_INSTALL_PREFIX}")
message(STATUS "")
