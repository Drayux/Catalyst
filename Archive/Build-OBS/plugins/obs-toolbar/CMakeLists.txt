cmake_minimum_required(VERSION 3.16...3.21)

# Change obs-plugintemplate to your plugin's name in a machine-readable format (e.g.:
# obs-myawesomeplugin) and set
project(obs-toolbar VERSION 0.1.2)
add_library(obs-toolbar MODULE)

# Replace `Your Name Here` with the name (yours or your organization's) you want to see as the
# author of the plugin (in the plugin's metadata itself and in the installers)
set(PLUGIN_AUTHOR "Azi")

# Replace `com.example.obs-plugin-template` with a unique Bundle ID for macOS releases (used both in
# the installer and when submitting the installer for notarization)
set(MACOS_BUNDLEID "com.asriel.obs-toolbar")

# Replace `me@contoso.com` with the maintainer email address you want to put in Linux packages
set(LINUX_MAINTAINER_EMAIL "8140068+MisutaaAsriel@users.noreply.github.com")

# Add your custom source files here - header files are optional and only required for visibility
# e.g. in Xcode or Visual Studio
target_sources(obs-toolbar PRIVATE src/plugin-main.cpp forms/toolbar.qrc)

# ../obs-studio/UI/window-basic-main.cpp ../obs-studio/UI/window-basic-settings.cpp

# add_subdirectory(../obs-studio/deps/libff deps)

# target_include_directories(obs-toolbar PRIVATE AFTER
# $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/../obs-studio/UI/>
# $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/../obs-studio/UI/forms>
# $<BUILD_INTERFACE:${CMAKE_SOURCE_DIR}/../obs-studio/deps/libff)

include("./cmake/ObsPluginHelpers.cmake")

# Import libobs as main plugin dependency
set(libobs_DIR "/home/Downloads/Repositories/OBS/29.1.3/build/libobs/")
find_package(libobs REQUIRED)
target_link_libraries(obs-toolbar PRIVATE OBS::libobs)
# include(cmake/ObsPluginHelpers.cmake)

# Uncomment these lines if you want to use the OBS Frontend API in your plugin

set(obs-frontend-api_DIR "/home/Downloads/Repositories/OBS/29.1.3/build/UI/obs-frontend-api/")
find_package(obs-frontend-api REQUIRED)
target_link_libraries(obs-toolbar PRIVATE OBS::obs-frontend-api)

# AUTOUIC Paths AUTOUIC_SEARCH_PATHS
# "${CMAKE_SOURCE_DIR}/forms;${CMAKE_SOURCE_DIR}/../obs-studio/UI/forms"

# Uncomment those lines if you want to use Qt in your plugin

find_qt(COMPONENTS Widgets Core)
target_link_libraries(obs-toolbar PRIVATE Qt::Core Qt::Widgets)
set_target_properties(
  obs-toolbar
  PROPERTIES AUTOMOC ON
             AUTOUIC ON
             AUTORCC ON
             AUTOUIC_SEARCH_PATHS "${CMAKE_SOURCE_DIR}/forms")

set(CMAKE_INCLUDE_CURRENT_DIR ON)

configure_file(src/plugin-macros.h.in ${CMAKE_SOURCE_DIR}/src/plugin-macros.generated.h)

target_sources(obs-toolbar PRIVATE src/plugin-macros.generated.h)

# /!\ TAKE NOTE: No need to edit things past this point /!\

# --- Platform-independent build settings ---

target_include_directories(obs-toolbar PRIVATE ${CMAKE_SOURCE_DIR}/src
                                                         ${CMAKE_SOURCE_DIR}/forms)

# --- End of section ---

# --- Windows-specific build settings and tasks ---
if(OS_WINDOWS)
  configure_file(cmake/bundle/windows/installer-Windows.iss.in
                 ${CMAKE_BINARY_DIR}/installer-Windows.generated.iss)

  configure_file(cmake/bundle/windows/resource.rc.in ${CMAKE_BINARY_DIR}/obs-toolbar.rc)
  target_sources(obs-toolbar PRIVATE ${CMAKE_BINARY_DIR}/obs-toolbar.rc)

  if(MSVC)
    target_compile_options(obs-toolbar PRIVATE /W4)
  endif()
  # --- End of section ---

  # -- macOS specific build settings and tasks --
elseif(OS_MACOS)
  configure_file(cmake/bundle/macos/installer-macos.pkgproj.in
                 ${CMAKE_BINARY_DIR}/installer-macos.generated.pkgproj)

  set(MACOSX_PLUGIN_GUI_IDENTIFIER "${MACOS_BUNDLEID}")
  set(MACOSX_PLUGIN_BUNDLE_VERSION "${CMAKE_PROJECT_VERSION}")
  set(MACOSX_PLUGIN_SHORT_VERSION_STRING "1")

  target_compile_options(obs-toolbar PRIVATE -Wall)
  # --- End of section ---

  # --- Linux-specific build settings and tasks ---
else()
  target_compile_options(obs-toolbar PRIVATE -Wall)
endif()
# --- End of section ---

setup_plugin_target(obs-toolbar)
