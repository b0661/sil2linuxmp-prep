#! @addtogroup sil2linuxmp-cmake
#! @{
#!
#! @file FindDOXYGEN.cmake
#! @brief Find doxygen.
#!
#! Usage:
#! FIND_PACKAGE(DOXYGEN)
#!
#! Sets:
#! - DOXYGEN_FOUND		True if doxygen was found.
#! - DOXYGEN_EXECUTABLE	Path to the doxygen binary.
#! - DOXYGEN_VERSION	Version of found doxygen binary.
#!
#! If Doxygen is found, the following function(s) are defined:
#! - @ref DOXYGEN_ADD
#!
#! The module uses the native CMake FindDoxygen module to do the basic work.
#! It additionally provides a CMake doxygen input filter.
#!
#! DOCUMENTING THE SOURCE:
#!
#! For C, C++, Java, ... files see Doxygen.
#!
#! For CMake files:
#! - You can use any of Doxygens commands in your CMake script file, after starting a Doxygen comment with "#!".
#! - The special cmake filter executable recognizes the following CMake constructs:
#!   -  Comments starting with "#!"
#!      - The token "#!" will be replaced with "///" and the rest of the comment line is printed out unmodified.
#!   - Macro definitions
#!     - A CMake macro is converted to a C function.
#!     - For example, the CMake macro
#!         macro(MyCMakeMacro arg1 arg2)
#!         endmacro()
#!       will be converted to the C function
#!         MyCMakeMacro(arg1, arg2)
#!   - Function definitions
#!     - A CMake function is converted to a C function.
#!     - For example, the CMake function
#!         function(MyCMakeFunction arg1)
#!         endfunction()
#!       will be converted to the C function
#!         MyCMakeFunction(arg1)
#!       Function definitions by \@fn must be done by \@fn FUNCTION(func_name par1 par2)
#!   - Variable declaration
#!     - A CMake SET command that follows a Doxygen comment is converted to a variable declaration
#!     - For example, The CMake SET command
#!         SET(MY_VAR "this is my world")
#!       will be converted to the C variable declaration
#!         CMAKE_VARIABLE MY_VAR;
#!     - A CMake SET command that follows an IF command that follows a Doxygen comment will also be converted.
#!     - Any ELSE or ELSEIF path will not be regarded and replaced by whitespace.
#!
#!
#! This file is a merge of two packages.
#! - CMakeDoxygenFilter from Sascha Zelzer - http://github.com/saschazelzer/CMakeDoxygenFilter.
#! - UseDoxygen from Tobias Rautenkranz - http://tobias.rautenkranz.ch/cmake/doxygen
#!
#!
#! @par CMakeDoxygenFilter
#!
#! @copyright Copyright (c) German Cancer Research Center, Division of Medical and Biological Informatics
#!
#! Licensed under the Apache License, Version 2.0 (the "License");
#!
#! You may not use this file except in compliance with the License.
#! You may obtain a copy of the License at
#!
#! http://www.apache.org/licenses/LICENSE-2.0
#!
#! Unless required by applicable law or agreed to in writing, software
#! distributed under the License is distributed on an "AS IS" BASIS,
#! WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#! See the License for the specific language governing permissions and
#! limitations under the License.
#!
#! @par UseDoxygen
#!
#! @copyright Copyright (c) 2009, 2010, 2011 Tobias Rautenkranz <tobias@rautenkranz.ch>
#!
#! Redistribution and use in source and binary forms, with or without
#! modification, are permitted provided that the following conditions
#! are met:
#!
#! @li 1. Redistributions of source code must retain the copyright notice,
#!        this list of conditions and the following disclaimer.
#! @li 2. Redistributions in binary form must reproduce the copyright notice,
#!        this list of conditions and the following disclaimer in the
#!        documentation and/or other materials provided with the distribution.
#! @li 3. The name of the author may not be used to endorse or promote products
#!        derived from this software without specific prior written permission.
#!
#! THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
#! IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
#! OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
#! IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
#! INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
#! NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
#! DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
#! THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
#! (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
#! THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#!
#!
#! @author Bernhard Noelte


FIND_PACKAGE(Doxygen)


IF(DOXYGEN_FOUND)

#! @brief Download and compile a CMake doxygen input filter
#!
#! @param OUT <out-file> (optional) Supply an absolute filename for
#!                       the generated executable.
#! @param NAMESPACE <namespace> (optional) Supply a C++ namespace in
#!                              which the generated function declrarations
#!                              should be wrapped.
#!
#! @return This function sets the <code>DOXYGEN_CMAKE_FILTER_EXECUTABLE</code>
#!         variable to the absolute path of the generated input filter executable
#!         in the parent scope. If <out-file> is specified, they will be the same.
#!
#! This CMake function compiles the http://github.com/saschazelzer/CMakeDoxygenFilter
#! project into a doxygen input filter executable. See
#! http://github.com/saschazelzer/CMakeDoxygenFilter/blob/master/README for more details.
#!
#! Minimal adapted to be used for CoMoLib/ Contiki cmake (Bernhard Noelte).
#!
#! @author Sascha Zelzer
#! @author Bernhard Noelte
#!
FUNCTION(DOXYGEN_CMAKEFILTER_COMPILE)

    # Useless to cross compile
    IF(CMAKE_CROSSCOMPILING)
        RETURN()
    ENDIF(CMAKE_CROSSCOMPILING)

  #-------------------- parse function arguments -------------------

  set(DEFAULT_ARGS)
  set(prefix "FILTER")
  set(arg_names "OUT;NAMESPACE")
  set(option_names "")

  foreach(arg_name ${arg_names})
    set(${prefix}_${arg_name})
  endforeach(arg_name)

  foreach(option ${option_names})
    set(${prefix}_${option} FALSE)
  endforeach(option)

  set(current_arg_name DEFAULT_ARGS)
  set(current_arg_list)

  foreach(arg ${ARGN})
    set(larg_names ${arg_names})
    list(FIND larg_names "${arg}" is_arg_name)
    if(is_arg_name GREATER -1)
      set(${prefix}_${current_arg_name} ${current_arg_list})
      set(current_arg_name "${arg}")
      set(current_arg_list)
    else(is_arg_name GREATER -1)
      set(loption_names ${option_names})
      list(FIND loption_names "${arg}" is_option)
      if(is_option GREATER -1)
        set(${prefix}_${arg} TRUE)
      else(is_option GREATER -1)
        set(current_arg_list ${current_arg_list} "${arg}")
      endif(is_option GREATER -1)
    endif(is_arg_name GREATER -1)
  endforeach(arg ${ARGN})

  set(${prefix}_${current_arg_name} ${current_arg_list})

  #------------------- finished parsing arguments ----------------------

  if(FILTER_OUT)
    set(copy_file "${FILTER_OUT}")
  else()
    set(copy_file "${CMAKE_RUNTIME_OUTPUT_DIRECTORY}/CMakeDoxygenFilter${CMAKE_EXECUTABLE_SUFFIX}")
  endif()

  set(compile_defs "")
  if(FILTER_NAMESPACE)
    set(compile_defs "${compile_defs} -DUSE_NAMESPACE=${FILTER_NAMESPACE}")
  endif()

    FIND_FILE(cmake_doxygen_filter_src "CMakeDoxygenFilter.cpp"
            PATHS "${COMOLIB_ROOT_DIR}/tools/CMakeDoxygenFilter"
            DOC "Path to the CMakeDoxygenFilter.cpp source file"
            NO_DEFAULT_PATH
            NO_CMAKE_FIND_ROOT_PATH) # NO_CMAKE_FIND_ROOT_PATH - otherwise not found when crosscompiling
    MESSAGE("cmake_doxygen_filter_src ${cmake_doxygen_filter_src}")

    IF(NOT cmake_doxygen_filter_src)

        set(cmake_doxygen_filter_url "https://github.com/saschazelzer/CMakeDoxygenFilter/raw/master/CMakeDoxygenFilter.cpp")
        set(cmake_doxygen_filter_src "${CMAKE_CURRENT_BINARY_DIR}/CMakeDoxygenFilter.cpp")

        # If downloading on Windows fails with a "unsupported protocol" error, your CMake
        # version is not build with SSL support. Either build CMake yourself with
        # CMAKE_USE_OPENSSL enabled, or copy https://github.com/saschazelzer/CMakeDoxygenFilter/raw/master/CMakeDoxygenFilter.cpp
        # into your repository and set cmake_doxygen_filter_src to your local copy
        # and remove the download code below.
        file(DOWNLOAD "${cmake_doxygen_filter_url}" "${cmake_doxygen_filter_src}" STATUS status)
        list(GET status 0 error_code)
        list(GET status 1 error_msg)
        if(error_code)
        message(FATAL_ERROR "error: Failed to download ${cmake_doxygen_filter_url} - ${error_msg}")
        endif()

    ENDIF(NOT cmake_doxygen_filter_src)

  try_compile(result_var
              "${CMAKE_CURRENT_BINARY_DIR}"
              "${cmake_doxygen_filter_src}"
              COMPILE_DEFINITIONS ${compile_defs}
              OUTPUT_VARIABLE compile_output
              COPY_FILE ${copy_file}
             )

  if(NOT result_var)
    message(FATAL_ERROR "error: Faild to compile ${cmake_doxygen_filter_src} (result: ${result_var})\n${compile_output}")
  endif()

  set(DOXYGEN_CMAKEFILTER_EXECUTABLE "${copy_file}" PARENT_SCOPE)

endfunction()


#! @brief Add a doxygen target that runs doxygen to generate the html
#!        and optionally the LaTeX API documentation.
#!
#! The doxygen target is added to the doc target as a dependency.
#! i.e.: the API documentation is built with:
#! - make doc
#!
#! @param DOXYFILE_IN <doxyfile-in> (optional) Supply an absolute filename for a doxyfile template file. \
#!                                             The doxyfile template will be configured before used as \
#!                                             Doxyfile.
#! @param DOXYFILE <doxyfile> (optional)       Supply an absolute filename for a doxyfile file. \
#!                                             If a template is provided, it will be written to this. \
#!                                             Otherwise an already available Doxyfile will be used.
#! @param CMAKEFILTER_EXECUTABLE <cmakefilter> (optional) Supply an absolute filename for a cmakefilter.
#! @param FILE_PATTERNS <patterns> (optional) Set the file patterns that are used to identify Doxygen source files. \
#!                                            Defaults to "CMakeLists.txt *.cmake *.c *.cc *.cxx *.cpp *.c++ *.java *.ii *.ixx *.ipp *.i++ *.inl *.h *.hh *.hxx *.hpp *.h++ *.idl *.odl *.cs *.php *.php3 *.inc *.m *.mm *.py *.f90"
#! @param OUTPUT_DIR <dir> (optional) Path where the Doxygen output is stored. \
#!                                    Defaults to "${CMAKE_CURRENT_BINARY_DIR}/doc".
#! @param OUTPUT_DIR_LATEX <rel-dir> (optional) Directory relative to OUTPUT_DIR where the Doxygen LaTeX output is stored. \
#!                                              Defaults to "latex".
#! @param OUTPUT_DIR_HTML <rel-dir> (optional)  Directory relative to OUTPUT_DIR where the Doxygen html output is stored. \
#!                                              Defaults to "html".
#! @param SOURCE_DIR <dir> (optional) Path where the Doxygen input files are. \
#!                                    Defaults to the current source directory.
#! @param EXTRA_SOURCE_DIRS <dir> (optional) Additional source diretories/files for Doxygen to scan. \
#!                                           The Paths should be in double quotes and separated by space. \
#!                                           e.g.: "${CMAKE_CURRENT_BINARY_DIR}/foo.c" "${CMAKE_CURRENT_BINARY_DIR}/bar/"
#! @param IMAGE_PATH <dir or file> (optional) Files or directories that contain image that are included \
#!                                            in the documentation.
#! @param WITH_LATEX LaTeX documentation shall also be built.
#!
#!
FUNCTION(DOXYGEN_ADD)
    #-------------------- parse function arguments -------------------

    set(DEFAULT_ARGS)
    set(prefix "DOXYGEN")
    set(arg_names "DOXYFILE_IN;DOXYFILE;CMAKEFILTER_EXECUTABLE;FILE_PATTERNS;OUTPUT_DIR;OUTPUT_DIR_LATEX;OUTPUT_DIR_HTML;SOURCE_DIR;EXTRA_SOURCE_DIRS;IMAGE_PATH")
    set(option_names "WITH_LATEX")

    foreach(arg_name ${arg_names})
        set(${prefix}_${arg_name})
    endforeach(arg_name)

    foreach(option ${option_names})
        set(${prefix}_${option} FALSE)
    endforeach(option)

    set(current_arg_name DEFAULT_ARGS)
    set(current_arg_list)

    foreach(arg ${ARGN})
        set(larg_names ${arg_names})
        list(FIND larg_names "${arg}" is_arg_name)
        if(is_arg_name GREATER -1)
            set(${prefix}_${current_arg_name} ${current_arg_list})
            set(current_arg_name "${arg}")
            set(current_arg_list)
        else(is_arg_name GREATER -1)
            set(loption_names ${option_names})
            list(FIND loption_names "${arg}" is_option)
            if(is_option GREATER -1)
                set(${prefix}_${arg} TRUE)
            else(is_option GREATER -1)
                set(current_arg_list ${current_arg_list} "${arg}")
            endif(is_option GREATER -1)
        endif(is_arg_name GREATER -1)
    endforeach(arg ${ARGN})

    set(${prefix}_${current_arg_name} ${current_arg_list})

    #------------------- finished parsing arguments ----------------------

    #------------------- prepare parameters ------------------------------
    IF(NOT DOXYGEN_DOXYFILE_IN AND DOXYGEN_DOXYFILE)
        # Reuse existing Doxyfile
        SET(DOXYGEN_DOXYFILE_IN ${DOXYGEN_DOXYFILE})
    ENDIF()

    IF(NOT DOXYGEN_DOXYFILE_IN)
        FIND_FILE(DOXYGEN_DOXYFILE_IN "Doxyfile.in"
                PATHS "${CMAKE_CURRENT_SOURCE_DIR}" "${CONTIKI_CONFIG_INPUT_DIR}"
                DOC "Path to the doxygen configuration template file"
                NO_DEFAULT_PATH
                NO_CMAKE_FIND_ROOT_PATH) # NO_CMAKE_FIND_ROOT_PATH - otherwise not found when crosscompiling
    ENDIF()

    IF(NOT DOXYGEN_DOXYFILE)
        SET(DOXYGEN_DOXYFILE "${CMAKE_CURRENT_BINARY_DIR}/Doxyfile")
    ENDIF()

    IF(NOT DOXYGEN_CMAKEFILTER_EXECUTABLE)
        FIND_PROGRAM(DOXYGEN_CMAKEFILTER_EXECUTABLE "CMakeDoxygenFilter"
                PATHS "${CONTIKI_TOOLS_BINARY_DIR}"
                DOC "The doxygen filter for CMake files."
                NO_DEFAULT_PATH
                NO_CMAKE_FIND_ROOT_PATH) # NO_CMAKE_FIND_ROOT_PATH - otherwise not found when crosscompiling

        IF((NOT DOXYGEN_CMAKEFILTER_EXECUTABLE) AND (NOT CMAKE_CROSSCOMPILING))
            # We have to build the doxygen cmake filter
            DOXYGEN_CMAKEFILTER_COMPILE(OUT "${CONTIKI_TOOLS_BINARY_DIR}/CMakeDoxygenFilter${CMAKE_EXECUTABLE_SUFFIX}")
        ENDIF()
    ENDIF()

    IF(NOT DOXYGEN_FILE_PATTERNS)
        SET(DOXYGEN_FILE_PATTERNS "*.c *.cc *.cxx *.cpp *.c++ *.java *.ii *.ixx *.ipp *.i++ *.inl *.h *.hh *.hxx *.hpp *.h++ *.idl *.odl *.cs *.php *.php3 *.inc *.m *.mm *.md *.py *.f90")
    ENDIF()

    IF(DOXYGEN_CMAKEFILTER_EXECUTABLE)
        SET(DOXYGEN_FILE_PATTERNS "CMakeLists.txt *.cmake ${DOXYGEN_FILE_PATTERNS}")
        SET(DOXYGEN_FILTER_PATTERNS
        "CMakeLists.txt=${DOXYGEN_CMAKEFILTER_EXECUTABLE} *.cmake=${DOXYGEN_CMAKEFILTER_EXECUTABLE}")
    ENDIF()

    IF(NOT DOXYGEN_OUTPUT_DIR)
        SET(DOXYGEN_OUTPUT_DIR "${CMAKE_CURRENT_BINARY_DIR}/doc")
    ENDIF()

    IF(NOT DOXYGEN_OUTPUT_DIR_LATEX)
        SET(DOXYGEN_OUTPUT_DIR_LATEX "latex")
    ENDIF()

    IF(NOT DOXYGEN_OUTPUT_DIR_HTML)
        SET(DOXYGEN_OUTPUT_DIR_HTML "html")
    ENDIF()

    IF(NOT DOXYGEN_SOURCE_DIR)
        SET(DOXYGEN_SOURCE_DIR "${CMAKE_CURRENT_SOURCE_DIR}")
    ENDIF()

    IF(NOT DOXYGEN_EXTRA_SOURCE_DIRS)
        SET(DOXYGEN_EXTRA_SOURCE_DIRS "")
    ELSE()
        # Make a list with spaces (instead of ;)
        STRING(REPLACE ";" " " DOXYGEN_EXTRA_SOURCE_DIRS "${DOXYGEN_EXTRA_SOURCE_DIRS}")
    ENDIF()

    IF(NOT DOXYGEN_WITH_LATEX)
        SET(DOXYGEN_WITH_LATEX "NO")
    ELSE()
        FIND_PACKAGE(LATEX)
        FIND_PROGRAM(DOXYGEN_DOXYFILE_MAKE make)
        IF(LATEX_COMPILER AND MAKEINDEX_COMPILER AND DOXYFILE_MAKE)
            SET(DOXYGEN_WITH_LATEX "YES")
            IF(PDFLATEX_COMPILER)
                SET(DOXYGEN_WITH_PDFLATEX "YES")
            ELSE()
                SET(DOXYGEN_WITH_PDFLATEX "NO")
            ENDIF()
        ELSE()
          SET(DOXYGEN_WITH_LATEX "NO")
        ENDIF()
    ENDIF()

    IF(NOT DOXYGEN_DOT_FOUND)
        SET(DOXYGEN_WITH_DOT "NO")
    ELSE()
        SET(DOXYGEN_WITH_DOT "YES")
    ENDIF()

    #------------------- finishing preparing parameters ---------------


    #------------------- Configure Doxyfile ---------------------------
    CONFIGURE_FILE("${DOXYGEN_DOXYFILE_IN}" "${DOXYGEN_DOXYFILE}" @ONLY)
    #------------------- Finish Configure Doxyfile --------------------

    #------------------- Set target -----------------------------------
    SET_PROPERTY(DIRECTORY APPEND PROPERTY
        ADDITIONAL_MAKE_CLEAN_FILES
        "${DOXYGEN_OUTPUT_DIR}/${DOXYGEN_OUTPUT_DIR_HTML}")

    ADD_CUSTOM_TARGET(doxygen
        COMMAND "${DOXYGEN_EXECUTABLE}"
            "${DOXYGEN_DOXYFILE}"
        WORKING_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}"
        COMMENT "Writing documentation to ${DOXYGEN_OUTPUT_DIR}..."
        SOURCES ${SOURCE_DIR} ${EXTRA_SOURCE_DIRS})


    IF(DOXYGEN_WITH_LATEX)
        SET_PROPERTY(DIRECTORY APPEND PROPERTY
            ADDITIONAL_MAKE_CLEAN_FILES
            "${DOXYGEN_OUTPUT_DIR}/${DOXYGEN_OUTPUT_DIR_LATEX}")

        ADD_CUSTOM_COMMAND(TARGET doxygen POST_BUILD
            COMMAND "${DOXYGEN_DOXYFILE_MAKE}"
            WORKING_DIRECTORY "${DOXYGEN_OUTPUT_DIR}/${DOXYGEN_OUTPUT_DIR_LATEX}"
            COMMENT	"Running LaTeX for Doxygen documentation in ${DOXYGEN_OUTPUT_DIR}/${DOXYGEN_OUTPUT_DIR_LATEX}..."
            )
    ENDIF()

    GET_TARGET_PROPERTY(DOC_TARGET doc TYPE)
    if(NOT DOC_TARGET)
        ADD_CUSTOM_TARGET(doc)
    endif()

    ADD_DEPENDENCIES(doc doxygen)

ENDFUNCTION()


ENDIF(DOXYGEN_FOUND)

#! @} sil2linuxmp-cmake
