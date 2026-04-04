set(POWERTUNE_TEST_SUPPORT_SOURCES
    ${CMAKE_SOURCE_DIR}/src/Core/AppSettings.cpp
    ${CMAKE_SOURCE_DIR}/src/Core/AppSettingsOverlay.cpp
    ${CMAKE_SOURCE_DIR}/src/Core/DiagnosticsProvider.cpp
    ${CMAKE_SOURCE_DIR}/src/Core/PropertyRouter.cpp
    ${CMAKE_SOURCE_DIR}/src/Core/SensorRegistry.cpp
    ${CMAKE_SOURCE_DIR}/src/Core/Config/ExBoardConfigManager.cpp
    ${CMAKE_SOURCE_DIR}/src/Core/Config/PTExtenderConfigManager.cpp
    ${CMAKE_SOURCE_DIR}/src/Core/Services/DemoModeService.cpp
    ${CMAKE_SOURCE_DIR}/src/Core/Services/ScreenControlService.cpp
    ${CMAKE_SOURCE_DIR}/src/Core/Services/DashboardLockService.cpp
    ${CMAKE_SOURCE_DIR}/src/Core/Config/OverlayConfigDefaults.cpp
    ${CMAKE_SOURCE_DIR}/src/Core/Config/OverlayConfigService.cpp
    ${CMAKE_SOURCE_DIR}/src/Core/Models/UIState.cpp
    ${CMAKE_SOURCE_DIR}/src/Core/Models/EngineData.cpp
    ${CMAKE_SOURCE_DIR}/src/Core/Models/VehicleData.cpp
    ${CMAKE_SOURCE_DIR}/src/Core/Models/GPSData.cpp
    ${CMAKE_SOURCE_DIR}/src/Core/Models/AnalogInputs.cpp
    ${CMAKE_SOURCE_DIR}/src/Core/Models/DigitalInputs.cpp
    ${CMAKE_SOURCE_DIR}/src/Core/Models/ExpanderBoardData.cpp
    ${CMAKE_SOURCE_DIR}/src/Core/Models/TimingData.cpp
    ${CMAKE_SOURCE_DIR}/src/Core/Models/ConnectionData.cpp
    ${CMAKE_SOURCE_DIR}/src/Core/Models/SettingsData.cpp
    ${CMAKE_SOURCE_DIR}/src/Core/Models/VehicleRpmSettingsModel.cpp
    ${CMAKE_SOURCE_DIR}/src/Can/CanTransport.cpp
    ${CMAKE_SOURCE_DIR}/src/Can/Protocols/ExBoardCan.cpp
    ${CMAKE_SOURCE_DIR}/src/Can/Protocols/PTExtenderCan.cpp
    ${CMAKE_SOURCE_DIR}/src/DFI/DfiSerialReader.cpp
    ${CMAKE_SOURCE_DIR}/src/DFI/kawasaki_dfi_comm.c
    ${CMAKE_SOURCE_DIR}/src/Hardware/Extender.cpp
    ${CMAKE_SOURCE_DIR}/src/Utils/DataLogger.cpp
    ${CMAKE_SOURCE_DIR}/src/Utils/SteinhartCalculator.cpp
    ${CMAKE_SOURCE_DIR}/src/Utils/CalibrationHelper.cpp
    ${CMAKE_SOURCE_DIR}/src/Utils/OverlayPositionManager.cpp
    ${CMAKE_SOURCE_DIR}/src/Can/CanInterface.h
)

add_library(powertune_test_support STATIC ${POWERTUNE_TEST_SUPPORT_SOURCES})
target_include_directories(powertune_test_support
    PUBLIC
        ${CMAKE_SOURCE_DIR}
        ${CMAKE_SOURCE_DIR}/src
        ${CMAKE_SOURCE_DIR}/src/Can
        ${CMAKE_SOURCE_DIR}/src/Core
        ${CMAKE_SOURCE_DIR}/src/Core/Config
        ${CMAKE_SOURCE_DIR}/src/Core/Services
        ${CMAKE_SOURCE_DIR}/src/Hardware
        ${CMAKE_SOURCE_DIR}/src/Utils
        ${CMAKE_BINARY_DIR}/generated
        ${CMAKE_CURRENT_SOURCE_DIR}
)
target_link_libraries(powertune_test_support
    PUBLIC
        Qt6::Core
        Qt6::Gui
        Qt6::Network
        Qt6::Qml
        Qt6::Quick
        Qt6::QuickControls2
        Qt6::SerialBus
        Qt6::SerialPort
        Qt6::Multimedia
        Qt6::Test
)

function(powertune_add_test target_name)
    qt_add_executable(${target_name} ${ARGN})
    target_link_libraries(${target_name} PRIVATE powertune_test_support Qt6::Test)
    add_test(NAME ${target_name} COMMAND ${target_name})

    get_target_property(_qt_qmake_path Qt6::qmake IMPORTED_LOCATION)
    if(_qt_qmake_path)
        get_filename_component(_qt_bin_dir "${_qt_qmake_path}" DIRECTORY)
        set_tests_properties(${target_name} PROPERTIES
            ENVIRONMENT "PATH=${_qt_bin_dir};$ENV{PATH}"
        )
    endif()
endfunction()

powertune_add_test(AppSettingsSchemaAuditTest
    ${CMAKE_CURRENT_SOURCE_DIR}/Core/AppSettingsSchemaAuditTest.cpp
)

powertune_add_test(SettingsBootstrapHydrationTest
    ${CMAKE_CURRENT_SOURCE_DIR}/Core/SettingsBootstrapHydrationTest.cpp
)

powertune_add_test(MainAndVehicleSettingsRoundTripTest
    ${CMAKE_CURRENT_SOURCE_DIR}/Core/MainAndVehicleSettingsRoundTripTest.cpp
)

powertune_add_test(OverlayPersistenceTest
    ${CMAKE_CURRENT_SOURCE_DIR}/Core/OverlayPersistenceTest.cpp
)

powertune_add_test(ServiceAndManagerSettingsTest
    ${CMAKE_CURRENT_SOURCE_DIR}/Core/ServiceAndManagerSettingsTest.cpp
)
