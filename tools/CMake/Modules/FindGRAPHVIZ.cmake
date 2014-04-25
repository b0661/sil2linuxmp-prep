## Copyright (c) 2011, David Pineau
## Copyright (c) 2013 Jonathan Anderson
## All rights reserved.

## Redistribution and use in source and binary forms, with or without
## modification, are permitted provided that the following conditions are met:
##  * Redistributions of source code must retain the above copyright
##    notice, this list of conditions and the following disclaimer.
##  * Redistributions in binary form must reproduce the above copyright
##    notice, this list of conditions and the following disclaimer in the
##    documentation and/or other materials provided with the distribution.
##  * Neither the name of the copyright holder nor the names of its contributors
##    may be used to endorse or promote products derived from this software
##    without specific prior written permission.

## THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
## AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
## IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
## ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER AND CONTRIBUTORS BE
## LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
## CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
## SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
## INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
## CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
## ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
## POSSIBILITY OF SUCH DAMAGE.

#! @addtogroup sil2linuxmp-cmake
#! @{
#!
#! @file FindGRAPHVIZ.cmake
#! @brief Find and provide the Graphviz tools.
#!
#! Usage:
#! FIND_PACKAGE(DOT)
#!
#! Sets:
#! - @ref GRAPHVIZ_FOUND
#! - @ref GRAPHVIZ_DOT_EXECUTABLE
#! - @ref GRAPHVIZ_UNFLATTEN_EXECUTABLE
#!
#! @author David Pineau
#! @author Jonathan Anderson
#! @author Bernhard Noelte

# Assure all the defaults are available
INCLUDE(ConfigDefault)
INCLUDE(FunctionParseArguments)

#! Check dot output capability.
#!
#! @param DOT <path to dot>
#! @param FORMATS <output formats> List of png,  pdf
#! @return GRAPHVIZ_DOT_CHECK_READY True if dot can produce the requested output.
FUNCTION(GRAPHVIZ_DOT_CHECK)
    MESSAGE(STATUS "GRAPHVIZ_DOT_CHECK called: ${ARGN}.")

    #-------------------- parse function arguments -------------------

    SET(prefix GRAPHVIZ_DOT_CHECK)
    SET(options)
    SET(one_value_args DOT)
    SET(multi_value_args FORMATS)

    FUNCTION_PARSE_ARGUMENTS("${prefix}" "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN} )

    #------------------- finished parsing arguments --------------------
    #
    # Test that the 'dot' we found actually does the right thing.
    #
    SET(${prefix}_WORKING_DIR "${CMAKE_CURRENT_BINARY_DIR}/CMakeFiles/CMakeTmp")
    SET(${prefx}_INPUT "${${prefix}_WORKING_DIR}/test.dot")
    FILE(WRITE ${${prefx}_INPUT} "digraph foo { a -> b; }")    
    
    FOREACH(FORMAT ${${prefix}_FORMATS})
	SET(${prefix}_COMMAND "${GIT_EXECUTABLE}" "fetch")
	EXECUTE_PROCESS(COMMAND ${prefix}_COMMAND
			WORKING_DIRECTORY "${${prefix}_WORKING_DIR}"
			TIMEOUT 60
			RESULT_VARIABLE ${prefix}_RESULT
			ERROR_VARIABLE ${prefix}_ERROR
			OUTPUT_VARIABLE ${prefix}_OUTPUT
			OUTPUT_STRIP_TRAILING_WHITESPACE)
	IF(NOT ${${prefix}_RESULT} EQUAL 0)
	    MESSAGE(STATUS "Command '" ${${prefix}_COMMAND} "' in directory ${${prefix}_WORKING_DIR} failed (${${prefix}_RESULT}) with output \n${${prefix}_ERROR}")
	    SET("${prefix}_READY" false PARENT_SCOPE)
	    RETURN()
	ENDIF()

	#
	# The execution returned 0, but did it do the right thing?
	#

	# Did we just blat the result to stdout?
	if (NOT "${${prefix}_OUTPUT}" STREQUAL "")
	    MESSAGE(STATUS "dot ignored -o, emitted ${FORMAT} output to stdout")
	    SET("${prefix}_READY" false PARENT_SCOPE)
	    RETURN()
	ENDIF()
	
	# Did we produce anything useful?
	FILE(READ ${${prefx}_INPUT}.${FORMAT} OUTPUT HEX)
	IF("${OUTPUT}" STREQUAL "")
	    MESSAGE(STATUS "dot -T${FORMAT} produced an empty file")
	    SET("${prefix}_READY" false PARENT_SCOPE)
	    RETURN()
	ENDIF()
    ENDFOREACH(FORMAT ${${prefix}_FORAMTS})

    SET("${prefix}_READY" true PARENT_SCOPE)
ENDFUNCTION(GRAPHVIZ_DOT_CHECK)


SET(GRAPHVIZ_PATHS
      # UNIX paths
      "/bin"
      "/usr/bin"
      "/usr/local/bin"
      "/opt/bin"
      "/opt/local/bin"

      # Windows paths
      "$ENV{ProgramFiles}/Graphviz 2.21/bin"
      "C:/Program Files/Graphviz 2.21/bin"
      "$ENV{ProgramFiles}/ATT/Graphviz/bin"
      "C:/Program Files/ATT/Graphviz/bin"
      [HKEY_LOCAL_MACHINE\\SOFTWARE\\ATT\\Graphviz;InstallPath]/bin

      # Mac OS X Bundle paths
      /Applications/Graphviz.app/Contents/MacOS
      /Applications/Doxygen.app/Contents/Resources
      /Applications/Doxygen.app/Contents/MacOS
      )

      
FIND_PROGRAM(GRAPHVIZ_DOT_EXECUTABLE
    NAMES dot
    PATHS ${GRAPHVIZ_PATHS}
    DOC "Graphviz dot tool for generating an image graph from a dot file"
)


FIND_PROGRAM(GRAPHVIZ_UNFLATTEN_EXECUTABLE
    NAMES unflatten
    PATHS ${GRAPHVIZ_PATHS}
    DOC "Graphviz unflatten tool for agjusting the directed graph from a dot file"
)


IF(GRAPHVIZ_DOT_EXECUTABLE)
    # Check for correct output 
    GRAPHVIZ_DOT_CHECK(DOT ${GRAPHVIZ_DOT_EXECUTABLE} FORMATS png pdf)
    
    IF(NOT GRAPHVIZ_DOT_CHECK_READY)
	UNSET(GRAPHVIZ_DOT_EXECUTABLE)
    ENDIF(NOT GRAPHVIZ_DOT_CHECK_READY)

ENDIF(GRAPHVIZ_DOT_EXECUTABLE)


FIND_PACKAGE_HANDLE_STANDARD_ARGS("GRAPHVIZ" DEFAULT_MSG GRAPHVIZ_DOT_EXECUTABLE
							 GRAPHVIZ_UNFLATTEN_EXECUTABLE)

#! @} sil2linuxmp-cmake