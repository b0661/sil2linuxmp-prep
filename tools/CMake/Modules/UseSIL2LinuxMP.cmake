#! @addtogroup sil2linuxmp-cmake
#! @{
#!
#! @file UseSIL2LinuxMP.cmake
#! @brief Set up everything to use SIL2LinuxMP.
#! @author Bernhard Noelte
#!
#! Usage:
#! INCLUDE(UseSIL2LinuxMP)
#!


MESSAGE(STATUS "${CMAKE_CURRENT_LIST_FILE}: called")
IF(DEFINED USE_SIL2LINUXMP_FILE)
   MESSAGE(STATUS "Recursive Call of ${USE_SIL2LINUXMP_FILE}")
   RETURN()
ELSE()
   SET(USE_SIL2LINUXMP_FILE ${CMAKE_CURRENT_LIST_FILE})
ENDIF()

CMAKE_MINIMUM_REQUIRED(VERSION 2.8)

SET(CMAKE_SYSTEM_VERSION 0)

# Enforce out of source builds, we rely on that
# (see http://stackoverflow.com/questions/1208681/with-cmake-how-would-you-disable-in-source-builds)
SET(CMAKE_DISABLE_SOURCE_CHANGES ON)
SET(CMAKE_DISABLE_IN_SOURCE_BUILD ON)

## Provide maximum information for other tools (CLANG)
SET(CMAKE_EXPORT_COMPILE_COMMANDS ON)


# ---------------------------------------------
# --- Set the project
# ---------------------------------------------
PROJECT(${SIL2LINUXMP_PROJECT_NAME})
#
# - Compilers are now fixed
#


# --- Make everything verbose
# Eclipse relies on default include paths such as /usr/include to find and index header files.
# One can manually enter more include paths from the "Project Properties" dialog but there is a much easier way
# for Eclipse to pick up on any 'non-default' include paths needed by your project.
# Eclipse has a mechanism in place to 'Discover' these locations. The mechanism works by parsing the
# compiler invocation looking for "-I" arguments then adds these directories to the list of include paths
# to index. In order for this discovery process to work you need to build your project at least once with
# the CMAKE_VERBOSE_MAKEFILE to true.
# (see http://www.vtk.org/Wiki/CMake:Eclipse_UNIX_Tutorial)
SET(CMAKE_VERBOSE_MAKEFILE ON)


# -- General helper functions and macros
# Default configuration and commands for settings
INCLUDE(ConfigDefault)
# Function argument parsing
INCLUDE(FunctionParseArguments)
# Number of processors of the build computer
INCLUDE(ProcessorCount)


# -- Add rmtoo target to the project

# rmtoo requirements management tool
FIND_PACKAGE(RMTOO REQUIRED)

# Assure there is the one and only project master requirement for the project
FIND_FILE(SIL2LINUX_PROJECT_MASTER_REQUIREMENT
          NAME "${SIL2LINUXMP_PROJECT_NAME}.req"
          PATHS ${SIL2LINUXMP_PROJECT_REQUIREMENTS_DIR}
                "${CMAKE_BINARY_DIR}/rmtoo/requirements"
          NO_DEFAULT_PATH NO_CMAKE_FIND_ROOT_PATH)
IF(NOT SIL2LINUX_PROJECT_MASTER_REQUIREMENT)
    # Create default project master requirement
    SET(SIL2LINUX_PROJECT_MASTER_REQUIREMENT_DIR "${CMAKE_BINARY_DIR}/rmtoo/requirements")
    FILE(MAKE_DIRECTORY ${SIL2LINUX_PROJECT_MASTER_REQUIREMENT_DIR})
    CONFIGURE_FILE("${SIL2LINUXMP_TOOLS_DIR}/rmtoo/master_requirement_req.in" "${SIL2LINUX_PROJECT_MASTER_REQUIREMENT_DIR}/${SIL2LINUXMP_PROJECT_NAME}.req" @ONLY)
ELSE()
    UNSET(SIL2LINUX_PROJECT_MASTER_REQUIREMENT_DIR)
ENDIF()

# Add target for project requirements/ documentation
RMTOO_ADD(REQUIREMENTS_INVENTORS "Authors"
          REQUIREMENTS_STAKEHOLDERS "Requirements Manager" Designer Implementer Tester Verifier Validator Integrator Assessor Community 
                                    "Configuration Manager"
          TOPIC1_NAME "${SIL2LINUXMP_PROJECT_NAME}"
          TOPIC1_SUBTITLE "Certification Package"
          TOPIC1_REQUIREMENTS_DIRS "${SIL2LINUXMP_ROOT_DIR}/specifications/requirements"
                                   ${SIL2LINUX_PROJECT_MASTER_REQUIREMENT_DIR} ${SIL2LINUXMP_PROJECT_REQUIREMENTS_DIR} 
          TOPIC1_TOPICS_DIRS "${SIL2LINUXMP_ROOT_DIR}/specifications/topics" ${SIL2LINUXMP_PROJECT_TOPICS_DIR}
          TOPIC1_CONSTRAINTS_DIRS "${SIL2LINUXMP_ROOT_DIR}/specifications/constraints" ${SIL2LINUXMP_PROJECT_CONSTRAINTS_DIR}
          TOPIC1_TEXTS_DIRS "${SIL2LINUXMP_ROOT_DIR}/specifications/texts" ${SIL2LINUXMP_PROJECT_TEXTS_DIR}
          TOPIC1_ROOT_NODE "SIL2LinuxMP"
          TOPIC1_OUTPUT_GRAPH_FILENAME "${CMAKE_BINARY_DIR}/certification-package/graph1.dot"
          TOPIC1_OUTPUT_GRAPH2_FILENAME "${CMAKE_BINARY_DIR}/certification-package/graph2.dot"
          TOPIC1_OUTPUT_VERSION_FILENAME "${CMAKE_BINARY_DIR}/certification-package/version.txt"
          TOPIC1_OUTPUT_STATS_REQSCNT_FILENAME "${CMAKE_BINARY_DIR}/certification-package/reqcnt.csv"
          TOPIC1_OUTPUT_PANDOC1_DIRECTORY "${CMAKE_BINARY_DIR}/certification-package"
          TOPIC1_OUTPUT_PANDOC1_BASENAME "${SIL2LINUXMP_PROJECT_NAME}"
          )


#! @} sil2linuxmp-cmake
