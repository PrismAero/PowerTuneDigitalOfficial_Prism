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
)

set(CORE_HEADERS
    Core/connect.h
    Core/dashboard.h
    Core/serialport.h
    Core/appsettings.h
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

# * PowerTune QML Module (Qt6 only)
# * This provides a single import for all PowerTune components: import PowerTune 1.0
if(${QT_VERSION_MAJOR} GREATER_EQUAL 6)
    # * Suppress Qt policy warning about qmldir files
    qt_policy(SET QTP0004 OLD)
    
    qt_add_qml_module(${PROJECT_NAME}
        URI PowerTune
        VERSION 1.0
        QML_FILES
            PowerTune/CircularGauge.qml
            PowerTune/CircularGaugeStyle.qml
            PowerTune/Gauge.qml
            PowerTune/GaugeStyle.qml
            PowerTune/Translator.qml
        RESOURCES
            PowerTune/Translator.js
        NO_RESOURCE_TARGET_PATH
    )
endif()

# * QML Import paths for Qt Creator and Qt Design Studio
set(QML_IMPORT_PATH
    "${CMAKE_CURRENT_SOURCE_DIR}/QML"
    "${CMAKE_CURRENT_SOURCE_DIR}/Gauges"
    "${CMAKE_CURRENT_SOURCE_DIR}/Settings"
    "${CMAKE_CURRENT_SOURCE_DIR}/GPSTracks"
    "${CMAKE_CURRENT_SOURCE_DIR}/PowerTune"
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
