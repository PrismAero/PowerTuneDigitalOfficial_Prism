# CMakeLists.txt for PowerTune Digital Dashboard
# Primary Qt 6 CMake build configuration for IDE tooling, local development,
# and cross-platform builds.

cmake_minimum_required(VERSION 3.16)

project(PowerTuneQMLGui
    VERSION 1.0.0
    DESCRIPTION "PowerTune Digital Dashboard for automotive ECU monitoring"
    LANGUAGES CXX
)

option(POWERTUNE_ENABLE_WINDEPLOYQT "Run windeployqt as a post-build step on Windows" ON)

# * Build metadata exposed to runtime UI
set(POWERTUNE_VERSION_LABEL "1.5.9 Beta Unreleased" CACHE STRING "Runtime application version label")
set(POWERTUNE_BUILD_PROFILE "${CMAKE_BUILD_TYPE}" CACHE STRING "Build profile label")
if(POWERTUNE_BUILD_PROFILE STREQUAL "")
    set(POWERTUNE_BUILD_PROFILE "Release")
endif()
set(POWERTUNE_BUILD_DATE_UTC "" CACHE STRING "Build date in UTC ISO-8601. Leave empty to stamp once per build directory.")
if(POWERTUNE_BUILD_DATE_UTC STREQUAL "")
    string(TIMESTAMP _powertune_build_date_utc "%Y-%m-%dT%H:%M:%SZ" UTC)
    set(POWERTUNE_BUILD_DATE_UTC "${_powertune_build_date_utc}" CACHE STRING "Build date in UTC ISO-8601. Leave empty to stamp once per build directory." FORCE)
endif()
execute_process(
    COMMAND git rev-parse --short=12 HEAD
    WORKING_DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}
    OUTPUT_VARIABLE POWERTUNE_GIT_COMMIT
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_QUIET
)
if(POWERTUNE_GIT_COMMIT STREQUAL "")
    set(POWERTUNE_GIT_COMMIT "unknown")
endif()
set(POWERTUNE_BUILD_DEPENDENCIES "Qt ${QT_VERSION}; Yocto Scarthgap; meta-qt6" CACHE STRING "Dependency summary")
set(POWERTUNE_BUILD_NOTES "Beta unreleased build." CACHE STRING "Build notes shown in settings UI")
configure_file(
    ${CMAKE_CURRENT_SOURCE_DIR}/src/Core/BuildInfo.h.in
    ${CMAKE_CURRENT_BINARY_DIR}/generated/BuildInfo.h
    @ONLY
)

# * C++ Standard Configuration
set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# * Qt Configuration
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

# * Silence optional Vulkan wrapper probe noise on Windows when Vulkan SDK
# * headers are not installed. This project does not require Vulkan.
if(WIN32)
    set(CMAKE_DISABLE_FIND_PACKAGE_WrapVulkanHeaders ON)
endif()

# * Find Qt 6 packages
find_package(Qt6 REQUIRED COMPONENTS
    Core
    Gui
    Qml
    Quick
    QuickControls2
    Network
    SerialBus
    Multimedia
)

# * Optional ShaderTools - kept available for future Qt 6 effects
find_package(Qt6 COMPONENTS ShaderTools QUIET)

# Brightness control is detected at runtime via Connect::checkifraspberrypi().
# ddcutil (or sysfs backlight) presence is probed on startup -- no compile-time flag needed.

# * Source files - Core
set(CORE_SOURCES
    src/Core/Connect.cpp
    src/Core/ConnectSystemActions.cpp
    src/Core/AppSettings.cpp
    src/Core/AppSettingsOverlay.cpp
    src/Core/PropertyRouter.cpp
    src/Core/SensorRegistry.cpp
    src/Core/DiagnosticsProvider.cpp
    src/Utils/DifferentialSensorCalc.cpp
    src/Core/Config/ExBoardConfigManager.cpp
    src/Core/Config/PTExtenderConfigManager.cpp
    src/Core/Services/DemoModeService.cpp
    src/Core/Services/UpdateManagerService.cpp
    src/Core/Services/ScreenControlService.cpp
    src/Core/Services/DashboardLockService.cpp
    src/Core/Config/OverlayConfigDefaults.cpp
    src/Core/Models/UIState.cpp
    src/Core/Models/EngineData.cpp
    src/Core/Models/VehicleData.cpp
    src/Core/Models/GPSData.cpp
    src/Core/Models/AnalogInputs.cpp
    src/Core/Models/DigitalInputs.cpp
    src/Core/Models/ExpanderBoardData.cpp
    src/Core/Models/TimingData.cpp
    src/Core/Models/ConnectionData.cpp
    src/Core/Models/SettingsData.cpp
    src/Core/Models/CanFrameModel.cpp
)

set(CORE_HEADERS
    src/Core/Connect.h
    src/Core/AppSettings.h
    src/Core/PropertyRouter.h
    src/Core/SensorRegistry.h
    src/Core/DiagnosticsProvider.h
    src/Utils/DifferentialSensorCalc.h
    src/Core/Config/ExBoardConfigManager.h
    src/Core/Config/PTExtenderConfigManager.h
    src/Core/Services/DemoModeService.h
    src/Core/Services/UpdateManagerService.h
    src/Core/Services/ScreenControlService.h
    src/Core/Services/DashboardLockService.h
    src/Core/Config/OverlayConfigDefaults.h
    src/Core/Models/UIState.h
    src/Core/Models/DataModels.h
    src/Core/Models/EngineData.h
    src/Core/Models/VehicleData.h
    src/Core/Models/GPSData.h
    src/Core/Models/AnalogInputs.h
    src/Core/Models/DigitalInputs.h
    src/Core/Models/ExpanderBoardData.h
    src/Core/Models/TimingData.h
    src/Core/Models/ConnectionData.h
    src/Core/Models/SettingsData.h
    src/Core/Models/CanFrameModel.h
)

set(CAN_SOURCES
    src/Can/CanStartupManager.cpp
    src/Can/CanTransport.cpp
    src/Can/CanManager.cpp
    src/Can/Protocols/ExBoardCan.cpp
    src/Can/Protocols/PTExtenderCan.cpp
)

set(CAN_HEADERS
    src/Can/CanInterface.h
    src/Can/CanStartupManager.h
    src/Can/CanTransport.h
    src/Can/CanManager.h
    src/Can/Protocols/ExBoardCan.h
    src/Can/Protocols/PTExtenderCan.h
)

# * Source files - Hardware interfaces
set(HARDWARE_SOURCES
    src/Hardware/Extender.cpp
)

set(HARDWARE_HEADERS
    src/Hardware/Extender.h
)

# * Source files - Utilities
set(UTILS_SOURCES
    src/Utils/DataLogger.cpp
    src/Utils/Calculations.cpp
    src/Utils/SteinhartCalculator.cpp
    src/Utils/CalibrationHelper.cpp
    src/Utils/DownloadManager.cpp
    src/Utils/OverlayPositionManager.cpp
    src/Utils/ShiftIndicatorHelper.cpp
    src/Utils/WifiScanner.cpp
)

set(UTILS_HEADERS
    src/Utils/DataLogger.h
    src/Utils/Calculations.h
    src/Utils/SteinhartCalculator.h
    src/Utils/CalibrationHelper.h
    src/Utils/DownloadManager.h
    src/Utils/OverlayPositionManager.h
    src/Utils/ShiftIndicatorHelper.h
    src/Utils/WifiScanner.h
)

# * Combine all sources
set(PROJECT_SOURCES
    src/main.cpp
    ${CORE_SOURCES}
    ${CAN_SOURCES}
    ${HARDWARE_SOURCES}
    ${UTILS_SOURCES}
)

set(PROJECT_HEADERS
    ${CORE_HEADERS}
    ${CAN_HEADERS}
    ${HARDWARE_HEADERS}
    ${UTILS_HEADERS}
)

# * Create executable
qt_add_executable(${PROJECT_NAME}
    MANUAL_FINALIZATION
    ${PROJECT_SOURCES}
    ${PROJECT_HEADERS}
)

# * Include directories
target_include_directories(${PROJECT_NAME} PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}
    ${CMAKE_CURRENT_BINARY_DIR}/generated
    ${CMAKE_CURRENT_SOURCE_DIR}/src
    ${CMAKE_CURRENT_SOURCE_DIR}/src/Can
    ${CMAKE_CURRENT_SOURCE_DIR}/src/Core
    ${CMAKE_CURRENT_SOURCE_DIR}/src/Core/Config
    ${CMAKE_CURRENT_SOURCE_DIR}/src/Core/Services
    ${CMAKE_CURRENT_SOURCE_DIR}/src/Hardware
    ${CMAKE_CURRENT_SOURCE_DIR}/src/Utils
)

# * Link Qt libraries
target_link_libraries(${PROJECT_NAME} PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
    Qt6::QuickControls2
    Qt6::Network
    Qt6::SerialBus
    Qt6::Multimedia
)

if(WIN32)
    set(_powertune_windeployqt "")

    if(DEFINED ENV{POWERTUNE_QT_PREFIX} AND EXISTS "$ENV{POWERTUNE_QT_PREFIX}/bin/windeployqt.exe")
        set(_powertune_windeployqt "$ENV{POWERTUNE_QT_PREFIX}/bin/windeployqt.exe")
    else()
        get_target_property(_qt_qmake_path Qt6::qmake IMPORTED_LOCATION)
        if(_qt_qmake_path)
            get_filename_component(_qt_bin_dir "${_qt_qmake_path}" DIRECTORY)
            if(EXISTS "${_qt_bin_dir}/windeployqt.exe")
                set(_powertune_windeployqt "${_qt_bin_dir}/windeployqt.exe")
            endif()
        endif()
    endif()

    if(_powertune_windeployqt)
        if(POWERTUNE_ENABLE_WINDEPLOYQT)
            add_custom_command(TARGET ${PROJECT_NAME} POST_BUILD
                COMMAND "${_powertune_windeployqt}"
                            $<IF:$<CONFIG:Debug>,--debug,--release>
                        --qmldir "${CMAKE_CURRENT_SOURCE_DIR}"
                        "$<TARGET_FILE:${PROJECT_NAME}>"
                COMMENT "Deploying Qt runtime with windeployqt"
                VERBATIM
            )
        endif()

        # * Manual deployment target for generating Qt DLLs on demand.
        # * Keeps normal incremental dev builds fast.
        add_custom_target(powertune_deploy_runtime
            COMMAND "${_powertune_windeployqt}"
                        $<IF:$<CONFIG:Debug>,--debug,--release>
                    --qmldir "${CMAKE_CURRENT_SOURCE_DIR}"
                    "$<TARGET_FILE:${PROJECT_NAME}>"
            COMMENT "Deploying Qt runtime with windeployqt"
            DEPENDS ${PROJECT_NAME}
            VERBATIM
        )
    elseif(POWERTUNE_ENABLE_WINDEPLOYQT)
        message(WARNING "windeployqt.exe not found. Set POWERTUNE_QT_PREFIX to enable automatic Windows deployment.")
    endif()
endif()

# * PowerTune QML Sub-Modules
# * Provides organized imports: PowerTune.Core, PowerTune.Settings, PowerTune.Gauges, PowerTune.Utils
qt_policy(SET QTP0004 NEW)
    
    # * Define singletons
    set_source_files_properties(PowerTune/Utils/Translator.qml PROPERTIES
        QT_QML_SINGLETON_TYPE TRUE
    )
    set_source_files_properties(PowerTune/Dashboard/DashboardTheme.qml PROPERTIES
        QT_QML_SINGLETON_TYPE TRUE
    )
    set_source_files_properties(PowerTune/UI/SettingsTheme.qml PROPERTIES
        QT_QML_SINGLETON_TYPE TRUE
    )
    set_source_files_properties(Prism/Keyboard/KeyboardTheme.qml PROPERTIES
        QT_QML_SINGLETON_TYPE TRUE
    )
    
    # * Create backing library targets for QML modules
    qt_add_library(PowerTuneUtilsLib STATIC)
    qt_add_library(PowerTuneCoreLib STATIC)
    qt_add_library(PowerTuneUiLib STATIC)
    qt_add_library(PowerTuneSettingsLib STATIC)
    qt_add_library(GaugesSharedLib STATIC)
    qt_add_library(GaugesRaceDashLib STATIC)
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
            PowerTune/Core/BootSplash.qml
            PowerTune/Core/SettingsManager.qml
            PowerTune/Core/BoardConfig/ExBoardAnalog.qml
            PowerTune/Core/BoardConfig/ExtenderBoardTab.qml
            PowerTune/Core/BoardConfig/ExBoardSection.qml
            PowerTune/Core/PTExtender/PTExtenderConfigPage.qml
            PowerTune/Core/PTExtender/PTExtenderSystemSection.qml
            PowerTune/Core/PTExtender/PTExtenderGpiSection.qml
            PowerTune/Core/PTExtender/PTExtenderRelaySection.qml
            PowerTune/Core/PTExtender/PTExtenderTimingSection.qml
            PowerTune/Core/PTExtender/PTExtenderLedSection.qml
            PowerTune/Core/PTExtender/PTExtenderIndicatorSection.qml
            PowerTune/Core/PTExtender/LedAnimationPreview.qml
            PowerTune/Core/PTExtender/LogicRuleEditor.qml
            PowerTune/Core/PTExtender/PTExtenderDfiSection.qml
            PowerTune/Core/SensorConfig/AnalogChannelConfigPopup.qml
            PowerTune/Core/BoardConfig/BoardConfigSection.qml
            PowerTune/Core/BoardConfig/DigitalInputsSection.qml
            PowerTune/Core/SensorConfig/DiffSensorConfigPopup.qml
            PowerTune/Core/SensorConfig/GearSensorConfigPopup.qml
            PowerTune/Core/SensorConfig/SpeedSensorConfigPopup.qml
            PowerTune/Core/BrightnessPopup.qml
        RESOURCE_PREFIX /qt/qml
        OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/qt/qml/PowerTune/Core
    )

    # * PowerTune.UI module - Shared non-gauge UI primitives
    qt_add_qml_module(PowerTuneUiLib
        URI PowerTune.UI
        VERSION 1.0
        QML_FILES
            PowerTune/UI/SettingsTheme.qml
            PowerTune/UI/SettingsPage.qml
            PowerTune/UI/SettingsSection.qml
            PowerTune/UI/SettingsRow.qml
            PowerTune/UI/StyledButton.qml
            PowerTune/UI/StyledComboBox.qml
            PowerTune/UI/StyledSwitch.qml
            PowerTune/UI/StyledTextField.qml
            PowerTune/UI/StyledCheckBox.qml
            PowerTune/UI/StyledSpinBox.qml
            PowerTune/UI/StyledColorPicker.qml
            PowerTune/UI/ConnectionStatusIndicator.qml
            PowerTune/UI/SensorPicker.qml
        RESOURCE_PREFIX /qt/qml
        OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/qt/qml/PowerTune/UI
    )
    
    # * PowerTune.Settings module - Settings pages
    qt_add_qml_module(PowerTuneSettingsLib
        URI PowerTune.Settings
        VERSION 1.0
        QML_FILES
            PowerTune/Settings/MainSettings.qml
            PowerTune/Settings/Main/MainSettingsContent.qml
            PowerTune/Settings/DisplaySettings.qml
            PowerTune/Settings/DashSelector.qml
            PowerTune/Settings/DashSelectorWidget.qml
            PowerTune/Settings/VehicleRPMSettings.qml
            PowerTune/Settings/NetworkSettings.qml
            PowerTune/Settings/DiagnosticsSettings.qml
            PowerTune/Settings/Diagnostics/DiagSystemInfoSection.qml
            PowerTune/Settings/Diagnostics/DiagSensorLogSection.qml
            PowerTune/Settings/Diagnostics/DiagAnalogSection.qml
            PowerTune/Settings/Diagnostics/DiagDigitalSection.qml
            PowerTune/Settings/Diagnostics/DiagExpanderSection.qml
            PowerTune/Settings/Diagnostics/DiagCanSection.qml
            PowerTune/Settings/WifiCountryList.qml
        RESOURCE_PREFIX /qt/qml
        OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/qt/qml/PowerTune/Settings
    )
    
    # * PowerTune.Gauges.Shared module - Shared helpers, datasources, singletons
    qt_add_qml_module(GaugesSharedLib
        URI PowerTune.Gauges.Shared
        VERSION 1.0
        QML_FILES
            PowerTune/Gauges/Shared/Warning.qml
            PowerTune/Gauges/Shared/WarningLoader.qml
            PowerTune/Gauges/Shared/WarningFlashTimer.qml
            PowerTune/Gauges/Shared/ActiveCodesDisplay.qml
        RESOURCE_PREFIX /qt/qml
        OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/qt/qml/PowerTune/Gauges/Shared
    )

    # * PowerTune.Gauges.RaceDash module - Race dash live widgets
    qt_add_qml_module(GaugesRaceDashLib
        URI PowerTune.Gauges.RaceDash
        VERSION 1.0
        IMPORTS PowerTune.UI PowerTune.Gauges.Shared
        SOURCES
            PowerTune/Gauges/RaceDash/geohelpers/RaceArcItem.cpp
            PowerTune/Gauges/RaceDash/geohelpers/RaceArcItem.h
        QML_FILES
            PowerTune/Gauges/RaceDash/ArcGauge.qml
            PowerTune/Gauges/RaceDash/ArcAlertMarker.qml
            PowerTune/Gauges/RaceDash/GaugeReadout.qml
            PowerTune/Gauges/RaceDash/ShiftIndicator.qml
            PowerTune/Gauges/RaceDash/SensorCard.qml
            PowerTune/Gauges/RaceDash/StatusBox.qml
            PowerTune/Gauges/RaceDash/BrakeBiasBar.qml
            PowerTune/Gauges/RaceDash/BottomStatusBar.qml
            PowerTune/Gauges/RaceDash/GearIndicator.qml
            PowerTune/Gauges/RaceDash/TachCluster.qml
            PowerTune/Gauges/RaceDash/SpeedCluster.qml
        RESOURCE_PREFIX /qt/qml
        OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/qt/qml/PowerTune/Gauges/RaceDash
    )
    target_link_libraries(GaugesRaceDashLib PRIVATE
        Qt6::Gui
        Qt6::Qml
        Qt6::Quick
    )
    target_include_directories(GaugesRaceDashLib PRIVATE
        ${CMAKE_CURRENT_SOURCE_DIR}/PowerTune/Gauges/RaceDash/geohelpers
    )
    
    # * PowerTune.Dashboard module - User dashboard canvas and panels
    qt_add_qml_module(PrismPTDashboardLib
        URI PowerTune.Dashboard
        VERSION 1.0
        IMPORTS PowerTune.UI PowerTune.Gauges.Shared PowerTune.Gauges.RaceDash
        QML_FILES
            PowerTune/Dashboard/DashboardTheme.qml
            PowerTune/Dashboard/RaceDash.qml
            PowerTune/Dashboard/DraggableOverlay.qml
            PowerTune/Dashboard/OverlayConfigPopup.qml
            PowerTune/Dashboard/OverlayConfig/OverlayDataSection.qml
            PowerTune/Dashboard/OverlayConfig/OverlayArcSection.qml
            PowerTune/Dashboard/OverlayConfig/OverlayAlertSection.qml
            PowerTune/Dashboard/OverlayConfig/OverlayGearShiftSection.qml
            PowerTune/Dashboard/OverlayConfig/OverlayBiasTextSection.qml
        RESOURCE_PREFIX /qt/qml
        OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/qt/qml/PowerTune/Dashboard
    )
    
    # * PowerTune.Keyboard module - Custom virtual keyboard
    qt_add_qml_module(PrismKeyboardLib
        URI PowerTune.Keyboard
        VERSION 1.0
        QML_FILES
            Prism/Keyboard/KeyboardTheme.qml
            Prism/Keyboard/KeyIcon.qml
            Prism/Keyboard/KeyButton.qml
            Prism/Keyboard/NumericPad.qml
            Prism/Keyboard/QwertyLayout.qml
            Prism/Keyboard/PrismKeyboard.qml
        RESOURCE_PREFIX /qt/qml
        OUTPUT_DIRECTORY ${CMAKE_BINARY_DIR}/qt/qml/PowerTune/Keyboard
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
            Resources/graphics/RoundGaugeRing.png
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

    # * Link all QML modules to main executable
    target_link_libraries(${PROJECT_NAME} PRIVATE
        PowerTuneUtilsLibplugin
        PowerTuneCoreLibplugin
        PowerTuneUiLibplugin
        PowerTuneSettingsLibplugin
        GaugesSharedLibplugin
        GaugesRaceDashLibplugin
        PrismPTDashboardLibplugin
        PrismKeyboardLibplugin
    )

# * QML Import paths for Qt Creator and Qt Design Studio
set(QML_IMPORT_PATH
    "${CMAKE_BINARY_DIR}/qt/qml"
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
