#! @addtogroup sil2linuxmp-cmake
#! @{
#!
#! @file ConfigDefault.cmake
#! @brief Macro to set a default configuration.
#!
#! Usage:
#! INCLUDE(ConfigDefault)
#!
#! Provides:
#! @li @ref CONFIG_DEFAULT
#! @li @ref CONFIG_OVERRIDE

IF(DEFINED CONFIG_DEFAULT_FILE)
   MESSAGE(STATUS "${CMAKE_CURRENT_LIST_FILE}: called again; aborted!")
   RETURN()
ELSE()
   SET(CONFIG_DEFAULT_FILE ${CMAKE_CURRENT_LIST_FILE})
   MESSAGE(STATUS "${CMAKE_CURRENT_LIST_FILE}: called")
ENDIF()


#! @brief Set default value for undefined configuration option and cache it
#!
#! Set cached configuration value if the configuration option is not defined already.
#!
#! @param _option Configuration option
#! @param _value Default value
MACRO(CONFIG_DEFAULT _option _value)
    IF(NOT DEFINED ${_option})
        SET(${_option} ${_value} CACHE INTERNAL "Set by ${CMAKE_CURRENT_LIST_FILE}")
    ELSE()
        # Make sure the defined value gets cached
        # SET(${_option} ${${_option}} CACHE INTERNAL)
    ENDIF()
ENDMACRO(CONFIG_DEFAULT)


#! @brief Override configuration value and cache it
#!
#! Override configuration value and cache it, even if already defined.
#!
#! @param _option Configuration option
#! @param _value Value
MACRO(CONFIG_OVERRIDE _option _value)
   SET(${_option} ${_value} CACHE INTERNAL "Set by ${CMAKE_CURRENT_LIST_FILE}" FORCE)
ENDMACRO(CONFIG_OVERRIDE)


# Setup common defaults
CONFIG_DEFAULT(SIL2LINUXMP_ROOT_DIR "${CMAKE_CURRENT_LIST_DIR}/../../..")
CONFIG_DEFAULT(SIL2LINUXMP_SUPPORT_DIR "${SIL2LINUXMP_ROOT_DIR}/support")
CONFIG_DEFAULT(SIL2LINUXMP_TOOLS_DIR "${SIL2LINUXMP_ROOT_DIR}/tools")


#! @}
