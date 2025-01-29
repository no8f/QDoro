cmake_minimum_required(VERSION 3.16)

project(QDoro VERSION 0.1 LANGUAGES CXX)

set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTOUIC ON)
set(CMAKE_AUTORCC ON)

set(CPM_SOURCE_CACHE .cache/CPM)

find_package(Qt6 REQUIRED COMPONENTS Quick QuickControls2 Widgets)

qt_standard_project_setup(REQUIRES 6.5)

qt_policy(SET QTP0004 NEW)

qt_add_executable(appQDoro
    src/main.cpp
)

qt_add_qml_module(appQDoro
    URI QDoro
    VERSION 1.0
    QML_FILES
        qml/Main.qml
        QML_FILES qml/Dashboard/PomodoroTimer.qml
        QML_FILES qml/Dashboard/Components/TodoList.qml
        RESOURCES rsc.qrc
        SOURCES src/trayicon.h src/trayicon.cpp
)

target_include_directories(appQDoro PRIVATE src)

include(cmake/CPM.cmake)

CPMAddPackage(
    NAME WinToast
    GIT_TAG master
    GITHUB_REPOSITORY mohabouje/WinToast
)

target_link_libraries(appQDoro PRIVATE WinToast)
target_include_directories(WinToast INTERFACE ${WinToast_SOURCE_DIR}/include)

# Apply patch manually using execute_process
if (WinToast_ADDED)
    message(STATUS "Applying patch to WinToast...")

    execute_process(
        COMMAND git apply ${CMAKE_SOURCE_DIR}/patches/wintoast_fix.patch
        WORKING_DIRECTORY ${WinToast_SOURCE_DIR}
        RESULT_VARIABLE PATCH_RESULT
        ERROR_VARIABLE PATCH_ERROR
    )

    if (PATCH_RESULT)
        message(STATUS "Patch does not apply for current version.")
    else()
        message(STATUS "Patch applied successfully.")
    endif()
endif()

# Qt for iOS sets MACOSX_BUNDLE_GUI_IDENTIFIER automatically since Qt 6.1.
# If you are developing for iOS or macOS you should consider setting an
# explicit, fixed bundle identifier manually though.
set_target_properties(appQDoro PROPERTIES
#    MACOSX_BUNDLE_GUI_IDENTIFIER com.example.appQDoro
    MACOSX_BUNDLE_BUNDLE_VERSION ${PROJECT_VERSION}
    MACOSX_BUNDLE_SHORT_VERSION_STRING ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR}
    MACOSX_BUNDLE TRUE
    WIN32_EXECUTABLE TRUE
)

target_link_libraries(appQDoro
    PRIVATE
    Qt6::Quick
    Qt6::QuickControls2
    Qt6::Widgets
    dwmapi
)

include(GNUInstallDirs)
install(TARGETS appQDoro
    BUNDLE DESTINATION .
    LIBRARY DESTINATION ${CMAKE_INSTALL_LIBDIR}
    RUNTIME DESTINATION ${CMAKE_INSTALL_BINDIR}
)
