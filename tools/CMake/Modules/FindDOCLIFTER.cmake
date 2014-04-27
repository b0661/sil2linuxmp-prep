#! @addtogroup sil2linuxmp-cmake
#! @{
#!
#! @file FindDOCLIFTER.cmake
#! @brief Find pandoc.
#!
#! Install in Ubuntu by sudo apt-get install doclifter
#! Usage:
#! FIND_PACKAGE(DOCLIFTER)
#!
#! Sets:
#! - @ref DOCLIFTER_FOUND
#! - @ref DOCLIFTER_EXECUTABLE
#! - @rer DOCLIFTER_VERSION
#!
#! @author Bernhard Noelte

# Assure all the defaults are available
INCLUDE(ConfigDefault)
INCLUDE(FunctionParseArguments)



find_program(DOCLIFTER_EXECUTABLE
  NAMES
    doclifter
  PATHS
    $ENV{PROGRAMFILES}
  DOC
    "translates documents written in troff macros to DocBook"
  )

if(DOCLIFTER_EXECUTABLE)
  execute_process(COMMAND ${DOCLIFTER_EXECUTABLE} -V
    OUTPUT_VARIABLE DOCLIFTER_VERSION
    )
  string(REGEX REPLACE "^doclifter version ([.0-9]+).*" "\\1"
    DOCLIFTER_VERSION "${DOCLIFTER_VERSION}"
    )
endif()

include(FindPackageHandleStandardArgs)
find_package_handle_standard_args(DOCLIFTER
  REQUIRED_VARS DOCLIFTER_EXECUTABLE
  VERSION_VAR DOCLIFTER_VERSION
  )

mark_as_advanced(DOCLIFTER_EXECUTABLE)


#! @} sil2linuxmp-cmake
