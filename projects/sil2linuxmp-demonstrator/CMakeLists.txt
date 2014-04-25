#! @addtogroup sil2linuxmp-cmake
#! @{

#! @file sil2linuxmp-demonstrator/CMakeLists.cmake
#! @brief sil2linuxmp-demonstrator - Setup the CMAKE build variables for the SIL2LInuxMP demo project.
#!

#! Use with -DCMAKE_TOOLCHAIN_FILE=<root directory of sil2linuxmp>/tools/CMake/Toolchain-....cmake

CMAKE_MINIMUM_REQUIRED(VERSION 2.8)

SET(SIL2LINUXMP_PROJECT_NAME sil2linuxmp-demonstrator)

# Set directories for project specific (not generic SIL2LinuxMP) requirements.
SET(SIL2LINUXMP_PROJECT_REQUIREMENTS_DIR "${CMAKE_SOURCE_DIR}/specifications/requirements")
SET(SIL2LINUXMP_PROJECT_TOPICS_DIR "${CMAKE_SOURCE_DIR}/specifications/topics")
SET(SIL2LINUXMP_PROJECT_CONSTRAINTS_DIR "${CMAKE_SOURCE_DIR}/specifications/constraints")
SET(SIL2LINUXMP_PROJECT_TEXTS_DIR "${CMAKE_SOURCE_DIR}/specifications/texts")

SET(CMAKE_MODULE_PATH "${CMAKE_CURRENT_LIST_DIR}/../../tools/CMake/Modules")

# Use the information provided and build the project
INCLUDE(UseSIL2LinuxMP)

#! @}



