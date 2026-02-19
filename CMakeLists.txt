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
    SerialPort
    SerialBus
    Charts
    Positioning
    Sensors
    Multimedia
    Widgets
)

# * Optional: Location module (may not be available on all platforms)
find_package(Qt${QT_VERSION_MAJOR} COMPONENTS Location QUIET)

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

# * Optional: ddcutil support (Linux display brightness control)
if(EXISTS "/usr/lib/libddcutil.so.4")
    add_compile_definitions(HAVE_DDCUTIL)
endif()

# * Source files - Core
set(CORE_SOURCES
    Core/connect.cpp
    Core/dashboard.cpp
    Core/serialport.cpp
    Core/appsettings.cpp
    Core/PropertyRouter.cpp
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
)

set(CORE_HEADERS
    Core/connect.h
    Core/dashboard.h
    Core/serialport.h
    Core/appsettings.h
    Core/PropertyRouter.h
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
)

# * Source files - ECU protocols
set(ECU_SOURCES
    ECU/Apexi.cpp
    ECU/AdaptronicSelect.cpp
    ECU/arduino.cpp
    ECU/obd.cpp
)

set(ECU_HEADERS
    ECU/Apexi.h
    ECU/AdaptronicSelect.h
    ECU/arduino.h
    ECU/obd.h
)

# * Source files - Hardware interfaces
set(HARDWARE_SOURCES
    Hardware/Extender.cpp
    Hardware/gopro.cpp
    Hardware/gps.cpp
    Hardware/sensors.cpp
)

set(HARDWARE_HEADERS
    Hardware/Extender.h
    Hardware/gopro.h
    Hardware/gps.h
    Hardware/sensors.h
)

# * Source files - Utilities
set(UTILS_SOURCES
    Utils/DataLogger.cpp
    Utils/Calculations.cpp
    Utils/SteinhartCalculator.cpp
    Utils/SignalSmoother.cpp
    Utils/downloadmanager.cpp
    Utils/iomapdata.cpp
    Utils/ParseGithubData.cpp
    Utils/shcalc.cpp
    Utils/textprogressbar.cpp
    Utils/UDPReceiver.cpp
    Utils/wifiscanner.cpp
    Utils/Speedo.cpp
)

set(UTILS_HEADERS
    Utils/DataLogger.h
    Utils/Calculations.h
    Utils/SteinhartCalculator.h
    Utils/SignalSmoother.h
    Utils/downloadmanager.h
    Utils/iomapdata.h
    Utils/ParseGithubData.h
    Utils/shcalc.h
    Utils/Speedo.h
    Utils/textprogressbar.h
    Utils/UDPReceiver.h
    Utils/wifiscanner.h
)

# * Combine all sources
set(PROJECT_SOURCES
    main.cpp
    ${CORE_SOURCES}
    ${ECU_SOURCES}
    ${HARDWARE_SOURCES}
    ${UTILS_SOURCES}
)

set(PROJECT_HEADERS
    ${CORE_HEADERS}
    ${ECU_HEADERS}
    ${HARDWARE_HEADERS}
    ${UTILS_HEADERS}
)

# * QML Resource file
set(QML_RESOURCES
    qml.qrc
)

# * Create executable
if(${QT_VERSION_MAJOR} GREATER_EQUAL 6)
    qt_add_executable(${PROJECT_NAME}
        MANUAL_FINALIZATION
        ${PROJECT_SOURCES}
        ${PROJECT_HEADERS}
        ${QML_RESOURCES}
    )
else()
    add_executable(${PROJECT_NAME}
        ${PROJECT_SOURCES}
        ${PROJECT_HEADERS}
        ${QML_RESOURCES}
    )
endif()

# * Include directories
target_include_directories(${PROJECT_NAME} PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_SOURCE_DIR}/Core
    ${CMAKE_CURRENT_SOURCE_DIR}/ECU
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
    Qt${QT_VERSION_MAJOR}::SerialPort
    Qt${QT_VERSION_MAJOR}::SerialBus
    Qt${QT_VERSION_MAJOR}::Charts
    Qt${QT_VERSION_MAJOR}::Positioning
    Qt${QT_VERSION_MAJOR}::Sensors
    Qt${QT_VERSION_MAJOR}::Multimedia
    Qt${QT_VERSION_MAJOR}::Widgets
)

# * Link Location if available
if(Qt${QT_VERSION_MAJOR}Location_FOUND)
    target_link_libraries(${PROJECT_NAME} PRIVATE
        Qt${QT_VERSION_MAJOR}::Location
    )
endif()

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
    
    # * Define singleton for Translator
    set_source_files_properties(PowerTune/Utils/Translator.qml PROPERTIES
        QT_QML_SINGLETON_TYPE TRUE
    )
    
    # * Create backing library targets for QML modules
    qt_add_library(PowerTuneUtilsLib STATIC)
    qt_add_library(PowerTuneCoreLib STATIC)
    qt_add_library(PowerTuneSettingsLib STATIC)
    qt_add_library(PowerTuneGaugesLib STATIC)
    
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
            PowerTune/Core/SerialSettings.qml
            PowerTune/Core/ExBoardAnalog.qml
            PowerTune/Core/AnalogInputs.qml
            PowerTune/Core/ConsultRegs.qml
            PowerTune/Core/OBDPIDS.qml
            PowerTune/Core/BrightnessPopUp.qml
            PowerTune/Core/Laptimecontainer.qml
        RESOURCE_PREFIX /qt/qml
        OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/qt/qml/PowerTune/Core
    )
    
    # * PowerTune.Settings module - Settings pages
    qt_add_qml_module(PowerTuneSettingsLib
        URI PowerTune.Settings
        VERSION 1.0
        QML_FILES
            PowerTune/Settings/MainSettings.qml
            PowerTune/Settings/DashSelector.qml
            PowerTune/Settings/DashSelectorWidget.qml
            PowerTune/Settings/SenseHatSettings.qml
            PowerTune/Settings/WarnGearSettings.qml
            PowerTune/Settings/SpeedSettings.qml
            PowerTune/Settings/AnalogSettings.qml
            PowerTune/Settings/RPMSettings.qml
            PowerTune/Settings/StartupSettings.qml
            PowerTune/Settings/NetworkSettings.qml
            PowerTune/Settings/CanMonitor.qml
            PowerTune/Settings/HelpPage.qml
            PowerTune/Settings/WifiCountryList.qml
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
        OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/qt/qml/PowerTune/Settings
    )
    
    # * PowerTune.Gauges module - All gauge components
    qt_add_qml_module(PowerTuneGaugesLib
        URI PowerTune.Gauges
        VERSION 1.0
        QML_FILES
            # Qt6 gauge replacements
            PowerTune/Gauges/CircularGauge.qml
            PowerTune/Gauges/CircularGaugeStyle.qml
            PowerTune/Gauges/Gauge.qml
            PowerTune/Gauges/GaugeStyle.qml
            # Gauge styles
            PowerTune/Gauges/DashboardGaugeStyle.qml
            PowerTune/Gauges/TachometerStyle.qml
            PowerTune/Gauges/NormalGaugeStyle.qml
            PowerTune/Gauges/RPMBarStyle1.qml
            PowerTune/Gauges/RPMBarStyle2.qml
            PowerTune/Gauges/RPMBarStyle3.qml
            # Gauge components
            PowerTune/Gauges/RoundGauge.qml
            PowerTune/Gauges/BarGauge.qml
            PowerTune/Gauges/VerticalBarGauge.qml
            PowerTune/Gauges/SquareGauge.qml
            PowerTune/Gauges/SquareGaugeMain.qml
            PowerTune/Gauges/SquareGaugeRaceDash.qml
            PowerTune/Gauges/RPMBar.qml
            PowerTune/Gauges/GaugeNeedle_minus90to180.qml
            PowerTune/Gauges/GaugeNeedle_minus180to90.qml
            # Dashboard views
            PowerTune/Gauges/Cluster.qml
            PowerTune/Gauges/Dashboard.qml
            PowerTune/Gauges/SportDash.qml
            PowerTune/Gauges/Advanced.qml
            # Specialty gauges
            PowerTune/Gauges/GPS.qml
            PowerTune/Gauges/ForceMeter.qml
            PowerTune/Gauges/Charts.qml
            PowerTune/Gauges/Dyno.qml
            PowerTune/Gauges/VirtualDyno.qml
            PowerTune/Gauges/SpeedMeasurements.qml
            PowerTune/Gauges/TyreMonitor.qml
            PowerTune/Gauges/ShiftLights.qml
            # Sensor displays
            PowerTune/Gauges/PFCSensors.qml
            PowerTune/Gauges/HaltechFlags.qml
            PowerTune/Gauges/SensorTest.qml
            PowerTune/Gauges/ConsultTest.qml
            # User dashboards
            PowerTune/Gauges/Userdash1.qml
            PowerTune/Gauges/Userdash2.qml
            PowerTune/Gauges/Userdash3.qml
            # Media/utility
            PowerTune/Gauges/Camera.qml
            PowerTune/Gauges/Mediaplayer.qml
            PowerTune/Gauges/Screentoggle.qml
            PowerTune/Gauges/Keypad.qml
            # UI helpers
            PowerTune/Gauges/Picture.qml
            PowerTune/Gauges/StatePicture.qml
            PowerTune/Gauges/StateGIF.qml
            PowerTune/Gauges/MyTextLabel.qml
            PowerTune/Gauges/ColorList.qml
            PowerTune/Gauges/ColorpickerCombobox.qml
            PowerTune/Gauges/DatasourcesList.qml
            PowerTune/Gauges/Datasources.qml
            # Warning system
            PowerTune/Gauges/Warning.qml
            PowerTune/Gauges/WarningLoader.qml
        RESOURCES
            PowerTune/Gauges/createMaindash.js
            PowerTune/Gauges/createPicture.js
            PowerTune/Gauges/createRoundGauge.js
            PowerTune/Gauges/createsquaregaugeUserDash.js
            PowerTune/Gauges/createStateGIF.js
            PowerTune/Gauges/createStatePicture.js
            PowerTune/Gauges/createText.js
            PowerTune/Gauges/createverticalbargauge.js
        RESOURCE_PREFIX /qt/qml
        OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/qt/qml/PowerTune/Gauges
    )
    
    # * Link all QML modules to main executable
    target_link_libraries(${PROJECT_NAME} PRIVATE
        PowerTuneUtilsLibplugin
        PowerTuneCoreLibplugin
        PowerTuneSettingsLibplugin
        PowerTuneGaugesLibplugin
    )
endif()

# * QML Import paths for Qt Creator and Qt Design Studio
set(QML_IMPORT_PATH
    "${CMAKE_CURRENT_SOURCE_DIR}/PowerTune"
    "${CMAKE_CURRENT_SOURCE_DIR}/PowerTune/Core"
    "${CMAKE_CURRENT_SOURCE_DIR}/PowerTune/Settings"
    "${CMAKE_CURRENT_SOURCE_DIR}/PowerTune/Gauges"
    "${CMAKE_CURRENT_SOURCE_DIR}/PowerTune/Utils"
    "${CMAKE_CURRENT_SOURCE_DIR}/GPSTracks"
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
