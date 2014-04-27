#! @addtogroup sil2linuxmp-cmake
#! @{
#!
#! @file FindRMTOO.cmake
#! @brief Find and provide the Rmtoo library
#!
#! Usage:
#! FIND_PACKAGE(RMTOO)
#!
#! Sets:
#! - @ref RMTOO_FOUND
#! - @ref RMTOO_ROOT_DIR
#! - @ref RMTOO_CONTRIB_DIR
#! - @ref RMTOO_EXECUTABLE
#! - @ref RMTOO_NORMALIZE_DEPENDENCIES_EXECUTABLE
#! - @ref RMTOO_NORMALIZE_PRICING_GRAPH_EXECUTABLE
#!
#! @author Bernhard Noelte

# Assure all the defaults are available
INCLUDE(ConfigDefault)
INCLUDE(FunctionParseArguments)
INCLUDE(ProcessorCount)

#  We definitely need that
FIND_PACKAGE(PythonInterp 2 REQUIRED)
FIND_PACKAGE(GIT REQUIRED)
FIND_PACKAGE(PANDOC 1.11 REQUIRED)
FIND_PACKAGE(GRAPHVIZ REQUIRED)
FIND_PACKAGE(DOCLIFTER REQUIRED)


#! @brief Stringify list elements
#!
#! Call it like RMTOO_STRINGIFY_LIST(MY_OUT_LIST "${MY_IN_LIST}")
#!
#! @param[in] _in_list List of elements to stringify as one parameter,\n
#!                     List elemenst delimited by ;.
#! @param[out] _out_list Name of resulting list with elements stringified.
#!
FUNCTION(RMTOO_STRINGIFY_LIST _out_list _in_list)
    UNSET(RMTOO_STRINGIFIED_LIST)
    #MESSAGE(STATUS "RMTOO_STRINGIFY: \"${_out_list}\" \"${_in_list}\"")
    FOREACH(ELEMENT ${_in_list})
	LIST(APPEND RMTOO_STRINGIFIED_LIST "\"${ELEMENT}\"")
    ENDFOREACH(ELEMENT ${_in_list})
    #MESSAGE(STATUS "RMTOO_STRINGIFY: returns \"${_out_list}\" \"${RMTOO_STRINGIFIED_LIST}\"")
    SET(${_out_list} ${RMTOO_STRINGIFIED_LIST} PARENT_SCOPE)
ENDFUNCTION(RMTOO_STRINGIFY_LIST _out_list _in_list)


#! @brief Get basename of file. 
#!
#! Remove the extension but keep the rest; including path.
#!
#! Call it like RMTOO_BASENAME(MY_BASENAME_FILENAME ${MY_FILENAME})
#!
#! @param[in] _in_filename Filename with extension.
#! @param[out] _out_filename Name of variable to set to filename without extension..
FUNCTION(RMTOO_BASENAME _out_filename _in_filename)
    GET_FILENAME_COMPONENT(FILENAME_PATH ${_in_filename} PATH)
    GET_FILENAME_COMPONENT(FILENAME_WE ${_in_filename} NAME_WE)
    SET(${_out_filename} "${FILENAME_PATH}/${FILENAME_WE}" PARENT_SCOPE)
ENDFUNCTION(RMTOO_BASENAME _out_filename _in_filename)


#! @brief Donwload, and build rmtoo
#!
#! @return RMTOO_ROOT_DIR Toplevel directory of Rmtoo
#! @return RMTOO_READY
FUNCTION(RMTOO_MAKE)
    MESSAGE(STATUS "RMTOO_MAKE called: ${ARGN}.")

    #-------------------- parse function arguments -------------------

    SET(prefix RMTOO_MAKE)
    SET(options)
    SET(one_value_args)
    SET(multi_value_args)

    FUNCTION_PARSE_ARGUMENTS("${prefix}" "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN} )

    #------------------- finished parsing arguments --------------------
    
    # -- Branch to use for RMTOO
    SET(${prefix}_BRANCH "master")

    # ------------------------------------------------------------------
    # -- Make a master tracking git directory
    # ------------------------------------------------------------------
    GIT_WC_SETUP("${SIL2LINUXMP_SUPPORT_DIR}" "rmtoo-master-ignore"
                "http://git.code.sf.net/p/rmtoo/code"
                "${${prefix}_BRANCH}" "RMTOO")
    IF(NOT RMTOO_WC_FOUND)
        MESSAGE(STATUS "Command 'GIT_WC_SETUP' failed")
        SET("${prefix}_READY" false PARENT_SCOPE)
        RETURN()
    ENDIF()
    
    SET(${prefix}_WORKING_DIR "${SIL2LINUXMP_SUPPORT_DIR}/rmtoo-master-ignore")
    SET(${prefix}_TRACKING "development") # branch to be tracked
    
    # -- Master git dir for rmtoo available, make shure it is up to date
    SET(${prefix}_COMMAND "${GIT_EXECUTABLE}" "fetch")
    EXECUTE_PROCESS(COMMAND ${prefix}_COMMAND
                    WORKING_DIRECTORY "${${prefix}_WORKING_DIR}"
                    TIMEOUT 60
                    RESULT_VARIABLE ${prefix}_RESULT
                    ERROR_VARIABLE ${prefix}_ERROR
                    OUTPUT_VARIABLE ${prefix}_OUTPUT
                    OUTPUT_STRIP_TRAILING_WHITESPACE)
    IF(NOT ${${prefix}_RESULT} EQUAL 0)
        # MESSAGE(STATUS "Command '" ${${prefix}_COMMAND} "' in directory ${${prefix}_WORKING_DIR} failed (${${prefix}_RESULT}) with output:\n${${prefix}_ERROR}")
        # This not an error. May be just the timeout elapsed due to a missing internet connection
    ENDIF()
    
    # -- Move tracking branch of master rmtoo git to origin/<branch>
    SET(${prefix}_COMMAND "${GIT_EXECUTABLE}" "update-ref" "refs/heads/${${prefix}_BRANCH}" "origin/${${prefix}_BRANCH}")
    EXECUTE_PROCESS(COMMAND ${${prefix}_COMMAND}
                    WORKING_DIRECTORY "${${prefix}_WORKING_DIR}"
                    RESULT_VARIABLE ${prefix}_RESULT
                    ERROR_VARIABLE ${prefix}_ERROR
                    OUTPUT_VARIABLE ${prefix}_OUTPUT
                    OUTPUT_STRIP_TRAILING_WHITESPACE)
    IF(NOT ${${prefix}_RESULT} EQUAL 0)
        MESSAGE(STATUS "Command '" ${${prefix}_COMMAND} "' in directory ${${prefix}_WORKING_DIR} failed (${${prefix}_RESULT}) with output:\n${${prefix}_ERROR}")
        # This not an error. May be just the timeout elapsed due to a missing internet connection
    ENDIF()

    SET(${prefix}_COMMAND "${GIT_EXECUTABLE}" "reset" "--hard" "${${prefix}_BRANCH}")
    EXECUTE_PROCESS(COMMAND ${${prefix}_COMMAND}
                    WORKING_DIRECTORY "${${prefix}_WORKING_DIR}"
                    RESULT_VARIABLE ${prefix}_RESULT
                    ERROR_VARIABLE ${prefix}_ERROR
                    OUTPUT_VARIABLE ${prefix}_OUTPUT
                    OUTPUT_STRIP_TRAILING_WHITESPACE)
    IF(NOT ${${prefix}_RESULT} EQUAL 0)
        MESSAGE(STATUS "Command '" ${${prefix}_COMMAND} "' in directory ${${prefix}_WORKING_DIR} failed (${${prefix}_RESULT}) with output:\n${${prefix}_ERROR}")
        # This not an error. May be just the timeout elapsed due to a missing internet connection
    ENDIF()
    
    # ------------------------------------------------------------------
    # -- Make a clone git directory
    # ------------------------------------------------------------------
    SET(${prefix}_COMMAND MASTER_DIR "${${prefix}_WORKING_DIR}"
                          GIT_DIR "${CMAKE_BINARY_DIR}/rmtoo-clone"
                          BRANCH "${${prefix}_BRANCH}")
    GIT_CLONE_SETUP(${${prefix}_COMMAND})
    IF(NOT GIT_CLONE_SETUP_READY)
        MESSAGE(STATUS "GIT_CLONE_SETUP failed")
        SET("${prefix}_READY" false PARENT_SCOPE)
        RETURN()
    ENDIF()
    
    # We now work in the clone repository
    SET(${prefix}_WORKING_DIR "${CMAKE_BINARY_DIR}/rmtoo-clone")
    
    # ------------------------------------------------------------------
    # -- Make a branch on top of RMTOO branch for patching
    # ------------------------------------------------------------------
    SET(${prefix}_COMMAND GIT_DIR "${${prefix}_WORKING_DIR}"
                          TAG "${${prefix}_BRANCH}"
                          BRANCH "sil2linuxmp")
    GIT_BRANCH(${${prefix}_COMMAND})
    IF(NOT GIT_BRANCH_READY)
        MESSAGE(STATUS "GIT_BRANCH failed")
        SET("${prefix}_READY" false PARENT_SCOPE)
        RETURN()
    ENDIF()

    # ------------------------------------------------------------------
    # -- Apply application patches
    # ------------------------------------------------------------------
    SET(${prefix}_PATCHSET_COMMIT_MSG "${CMAKE_PROJECT_NAME}")
    FILE(GLOB ${prefix}_PATCHSETS "${SIL2LINUXMP_TOOLS_DIR}/rmtoo/*-patchset")
    LIST(SORT ${prefix}_PATCHSETS)
    #  Apply patches
    SET(${prefix}_COMMAND PATCHSETS "${${prefix}_PATCHSETS}"
                          GIT_DIR "${${prefix}_WORKING_DIR}"
                          COMMIT_MSG_HEADER "${${prefix}_PATCHSET_COMMIT_MSG}")
    GIT_PATCH_SET(${${prefix}_COMMAND})
    IF(NOT GIT_PATCH_SET_READY)
        MESSAGE(STATUS "GIT_PATCH_SET '" ${${prefix}_COMMAND} "' failed (${GIT_PATCH_SET_READY})!")
        SET(${prefix}_READY false PARENT_SCOPE)
        RETURN()
    ENDIF()
    
    # ------------------------------------------------------------------
    # -- Configure Rmtoo
    # ------------------------------------------------------------------

    # Nothing to configure
    
    # ------------------------------------------------------------------
    # -- Make Rmtoo
    # ------------------------------------------------------------------
    
    # nothing to make
    
    SET(RMTOO_ROOT_DIR "${${prefix}_WORKING_DIR}" PARENT_SCOPE)
    SET(RMTOO_CONTRIB_DIR "${${prefix}_WORKING_DIR}/contrib" PARENT_SCOPE)

    SET(${prefix}_READY true PARENT_SCOPE)

ENDFUNCTION(RMTOO_MAKE)

    
RMTOO_MAKE()

# ------------------------------------------------------------------
# -- Check for rmtoo avaialable
# ------------------------------------------------------------------
MESSAGE(STATUS "Rmtoo: Searching for rmtoo in ${RMTOO_ROOT_DIR}!")
FIND_FILE(RMTOO_EXECUTABLE 	NAMES "rmtoo"
                                PATHS "${RMTOO_ROOT_DIR}/bin" NO_DEFAULT_PATH NO_CMAKE_FIND_ROOT_PATH)
FIND_FILE(RMTOO_NORMALIZE_DEPENDENCIES_EXECUTABLE  NAMES "rmtoo-normalize-dependencies"
                                PATHS "${RMTOO_ROOT_DIR}/bin" NO_DEFAULT_PATH NO_CMAKE_FIND_ROOT_PATH)
FIND_FILE(RMTOO_NORMALIZE_PRICING_GRAPH_EXECUTABLE  NAMES "rmtoo-pricing-graph"
                                PATHS "${RMTOO_ROOT_DIR}/bin" NO_DEFAULT_PATH NO_CMAKE_FIND_ROOT_PATH)

# handle the QUIETLY and REQUIRED arguments and set xxx_FOUND to TRUE if
# all listed variables are TRUE
INCLUDE(FindPackageHandleStandardArgs)

FIND_PACKAGE_HANDLE_STANDARD_ARGS("RMTOO" DEFAULT_MSG RMTOO_ROOT_DIR
                                                     RMTOO_CONTRIB_DIR
                                                     RMTOO_EXECUTABLE
                                                     RMTOO_NORMALIZE_DEPENDENCIES_EXECUTABLE
                                                     RMTOO_NORMALIZE_PRICING_GRAPH_EXECUTABLE)

IF(NOT RMTOO_FOUND)
    # No rmtoo available
    RETURN()
ENDIF()

#! @brief Add a rmtoo target that runs rmtoo to generate the documentation.
#!
#! The rmtoo target is added to the doc target as a dependency.
#! i.e.: the documentation is built with:
#! - make doc
#!
#! @param CONFIG_FILE_IN <file>                Use file as template for rmtoo configuration file.\n
#!                                             Defaults to <"${SIL2LINUXMP_TOOLS_DIR}/rmtoo/Config_json.in>
#! @param CONFIG_FILE <file>                   Generate configuration for rmtoo in this file.\n
#!                                             Defaults to <"${CMAKE_BINARY_DIR}/rmtoo/Config.json>
#! @param GLOBAL_MODULES_DIRECTORIES <dir ....> Absolute path(es) where python modules (relative path(es)) will be searched.
#!                                             Defaults to <${RMTOO_ROOT_DIR}>.
#! @param GLOBAL_LOGGING_STDOUT_LOGLEVEL <debug|info|warn|error> Loglevel for standard out stream.\n
#!                                             Defaults to <warn>.
#! @param GLOBAL_LOGGING_TRACER_LOGLEVEL <debug|info|warn|error> Loglevel for standard out stream.\n
#!                                             Defaults to <debug>.
#! @param GLOBAL_LOGGING_TRACER_FILENAME <filename> Filename of log file. \n
#!                                             Defaults to <${CMAKE_BINARY_DIR}/rmtoo/tracer.log>.
#! @param PROCESSING_ANALYTICS_STOP_ON_ERRORS <true|false> Shall we stop on errors when doing analytics.\n
#!                                             Defaults to <false>.
#! @param REQUIREMENTS_INPUT_DEFAULT_LANGUAGE <en_GB|en_US|de> Language of requirements.\n
#!                                             Defaults to <en_GB>.
#! @param REQUIREMENTS_INPUT_DEPENDENCY_NOTATION <Depends on|Solved by> The way dependencies are specified.\n
#!                                             Defaults to <Solved by>.
#! @param REQUIREMENTS_TXTFILE_MAX_LINE_LENGTH <length in chars> The way dependencies are specified.\n
#!                                             Defaults to <80>.
#! @param REQUIREMENTS_INVENTORS <inventor name...> List of inventor names.\n
#!                                             Defaults to <>.
#! @param REQUIREMENTS_STAKEHOLDERS <stakeholder name...> List of stakeholder names.\n
#!                                             Defaults to <>.
#! @param TOPIC1_NAME <name> 		       Name of topic.\n
#!                                             Defaults to <${CMAKE_PROJECT_NAME}>.
#! @param TOPIC1_TITLE <title> 		       Title of topic document.\n
#!                                             Defaults to <${CMAKE_PROJECT_NAME}>.
#! @param TOPIC1_SUBTITLE <subtitle>	       Subtitle of topic document.\n
#!                                             Defaults to <>.
#! @param TOPIC1_REQUIREMENTS_DIRS <dir ...>   Directories where the requirements files for topic 1 are stored.\n
#!                                             Defaults to <requirements>.
#! @param TOPIC1_TOPICS_DIRS <dir ...>         Directories where the topic files for topic 1 are stored.\n
#!                                             Defaults to <topics>.
#! @param TOPIC1_CONSTRAINTS_DIRS <dir ...>    Directories where the constraint files for topic 1 are stored.\n
#!                                             Defaults to <constraints>.
#! @param TOPIC1_TEXTS_DIRS <dir ...>          Directories where the text and image files for topic 1 are stored.\n
#!                                             Defaults to <texts>.
#! @param TOPIC1_ROOT_NODE                     The root topic of topic 1.\n
#!                                             Defaults to <${TOPIC1_NAME}>.
#! @param TOPIC1_OUTPUT_GRAPH_FILENAME         Name of the file to output the requirements graph 1 for topic 1 to.\n
#!                                             Defaults to <${CMAKE_BINARY_DIR}/rmtoo/artifacts/req-${TOPIC1_NAME}-graph1.dot>
#! @param TOPIC1_OUTPUT_GRAPH2_FILENAME        Name of the file to output the requirements graph 2 for topic 1 to.\n
#!                                             Defaults to <${CMAKE_BINARY_DIR}rmtoo/artifacts/req-${TOPIC1_NAME}-graph2.dot>
#! @param TOPIC1_OUTPUT_HTML_FOOTER            Name of the file to include as HTML footer in HTML output for topic 1.\n
#!                                             Defaults to <${SIL2LINUXMP_TOOLS_DIR}/rmtoo/footer.hml>
#! @param TOPIC1_OUTPUT_HTML_HEADER            Name of the file to include as HTML header in HTML output for topic 1.\n
#!                                             Defaults to <${SIL2LINUXMP_TOOLS_DIR}/rmtoo/header.hml>
#! @param TOPIC1_OUTPUT_HTML_DIRECTORY         Name of the directory to create the HTML doumentation for topic 1 in.\n
#!                                             Defaults to <${CMAKE_BINARY_DIR}/rmtoo/artifacts/html-${TOPIC1_NAME}>
#! @param TOPIC1_OUTPUT_LATEX2_TOPICS_FILENAME Name of the file to output the latex2 document for the topics of topic 1 to.\n
#!                                             Defaults to <${CMAKE_BINARY_DIR}/rmtoo/artifacts/req-${TOPIC1_NAME}-topics.tex>
#! @param TOPIC1_OUTPUT_LATEX2_MASTER_TEMPLATE Name of the template file to use as latex2 requirements master document for topic 1.\n
#!                                             The master document must include ${TOPIC1_OUTPUT_LATEX2_TOPICS_FILENAME}, ... to build a document.\n
#!                                             Defaults to <${SIL2LINUXMP_TOOLS_DIR}/rmtoo/requirements_tex.in>
#! @param TOPIC1_OUTPUT_LATEX2_MASTER_FILENAME Generate latex2 requirements master document for topic 1 in this file.\n
#!                                             The file will be created from the template defined by TOPIC1_OUTPUT_LATEX2_MASTER_TEMPLATE.
#!                                             Defaults to <${CMAKE_BINARY_DIR}/rmtoo/artifacts/req-${TOPIC1_NAME}.tex>
#! @param TOPIC1_OUTPUT_PANDOC1_DIRECTORY      Name of the directory to create the pandoc doumentation for topic 1 in.\n
#!                                             Defaults to <${CMAKE_BINARY_DIR}/rmtoo/artifacts/pandoc-${TOPIC1_NAME}>
#! @param TOPIC1_OUTPUT_PANDOC1_BASENAME       Basename of the files to generate in output directory for topic 1.\n
#!                                             Defaults to <${TOPIC1_NAME}>
#! @param TOPIC1_OUTPUT_PANDOC1_FILTERS_DIRECTORY Name of the directory to search for additional filters for topic 1.\n
#!                                             Defaults to <${SIL2LINUXMP_TOOLS_DIR}/rmtoo/filters>
#! @param TOPIC1_OUTPUT_PANDOC1_COVER_IMAGE    Name of the cover image for topic 1.\n
#!                                             Defaults to <http://a.fsdn.com/con/app/proj/rmtoo/screenshots/322716.jpg>
#! @param TOPIC1_OUTPUT_VERSION_FILENAME       Name of the file to output the current version from the vcs for topic 1 to.\n
#!                                             Defaults to <${CMAKE_BINARY_DIR}/rmtoo/artifacts/req-${TOPIC1_NAME}-version.txt>
#! @param TOPIC1_OUTPUT_STATS_BURNDOWN_FILENAME Name of the file to output the burndown statistics for topic 1 to.\n
#!                                             Defaults to <${CMAKE_BINARY_DIR}/rmtoo/artifacts/stats-${TOPIC1_NAME}-burndown.csv>\n
#! @param TOPIC1_OUTPUT_STATS_SPRINTBURNDOWN_FILENAME Name of the file to output the sprint burndown statistics for topic 1 to.\n
#!                                             Defaults to <${CMAKE_BINARY_DIR}/rmtoo/artifacts/stats-${TOPIC1_NAME}-sprintburndown.csv>\n
#! @param TOPIC1_OUTPUT_STATS_REQSCNT_FILENAME  Name of the file to output the requirements count statistics for topic 1 to.\n
#!                                             Defaults to <${CMAKE_BINARY_DIR}/rmtoo/artifacts/stats-${TOPIC1_NAME}-reqcnt.csv>
#! @param TOPIC2...			       See TOPIC1...
#! @param TOPIC3...                            See TOPIC1...
#!
#!
FUNCTION(RMTOO_ADD)
    MESSAGE(STATUS "RMTOO_ADD called: ${ARGN}.")

    #-------------------- parse function arguments -------------------

    SET(prefix RMTOO_ADD)
    SET(options)
    SET(one_value_args CONFIG_FILE_IN CONFIG_FILE
                       GLOBAL_LOGGING_STDOUT_LOGLEVEL GLOBAL_LOGGING_TRACER_LOGLEVEL GLOBAL_LOGGING_TRACER_FILENAME
                       PROCESSING_ANALYTICS_STOP_ON_ERRORS
                       REQUIREMENTS_INPUT_DEFAULT_LANGUAGE REQUIREMENTS_INPUT_DEPENDENCY_NOTATION REQUIREMENTS_TXTFILE_MAX_LINE_LENGTH
                       TOPIC1_NAME TOPIC1_TITLE TOPIC1_SUBTITLE TOPIC1_ROOT_NODE 
                       TOPIC1_OUTPUT_GRAPH_FILENAME TOPIC1_OUTPUT_GRAPH2_FILENAME
                       TOPIC1_OUTPUT_HTML_FOOTER TOPIC1_OUTPUT_HTML_HEADER TOPIC1_OUTPUT_HTML_DIRECTORY
                       TOPIC1_OUTPUT_LATEX2_TOPICS_FILENAME TOPIC1_OUTPUT_LATEX2_MASTER_TEMPLATE TOPIC1_OUTPUT_LATEX2_MASTER_FILENAME
                       TOPIC1_OUTPUT_PANDOC1_DIRECTORY TOPIC1_OUTPUT_PANDOC1_FILTERS_DIRECTORY
                       TOPIC1_OUTPUT_VERSION_FILENAME
                       TOPIC1_OUTPUT_STATS_BURNDOWN_FILENAME TOPIC1_OUTPUT_STATS_REQSCNT_FILENAME
                       TOPIC2_NAME TOPIC2_TITLE TOPIC2_SUBTITLE TOPIC2_ROOT_NODE 
                       TOPIC2_OUTPUT_GRAPH_FILENAME TOPIC2_OUTPUT_GRAPH2_FILENAME
                       TOPIC2_OUTPUT_HTML_FOOTER TOPIC2_OUTPUT_HTML_HEADER TOPIC2_OUTPUT_HTML_DIRECTORY
                       TOPIC2_OUTPUT_LATEX2_TOPICS_FILENAME TOPIC2_OUTPUT_LATEX2_MASTER_TEMPLATE TOPIC2_OUTPUT_LATEX2_MASTER_FILENAME
                       TOPIC3_OUTPUT_PANDOC1_DIRECTORY TOPIC2_OUTPUT_PANDOC1_FILTERS_DIRECTORY
                       TOPIC2_OUTPUT_VERSION_FILENAME
                       TOPIC2_OUTPUT_STATS_BURNDOWN_FILENAME TOPIC2_OUTPUT_STATS_REQSCNT_FILENAME
                       TOPIC3_NAME TOPIC3_TITLE TOPIC3_SUBTITLE TOPIC3_ROOT_NODE 
                       TOPIC3_OUTPUT_GRAPH_FILENAME TOPIC3_OUTPUT_GRAPH2_FILENAME
                       TOPIC3_OUTPUT_HTML_FOOTER TOPIC3_OUTPUT_HTML_HEADER TOPIC3_OUTPUT_HTML_DIRECTORY
                       TOPIC3_OUTPUT_LATEX2_TOPICS_FILENAME TOPIC3_OUTPUT_LATEX2_MASTER_TEMPLATE TOPIC3_OUTPUT_LATEX2_MASTER_FILENAME
                       TOPIC3_OUTPUT_PANDOC1_DIRECTORY TOPIC3_OUTPUT_PANDOC1_FILTERS_DIRECTORY
                       TOPIC3_OUTPUT_VERSION_FILENAME
                       TOPIC3_OUTPUT_STATS_BURNDOWN_FILENAME TOPIC3_OUTPUT_STATS_REQSCNT_FILENAME
                       )
    SET(multi_value_args GLOBAL_MODULES_DIRECTORIES
			 REQUIREMENTS_INVENTORS REQUIREMENTS_STAKEHOLDERS
			 TOPIC1_REQUIREMENTS_DIRS TOPIC1_TOPICS_DIRS TOPIC1_CONSTRAINTS_DIRS TOPIC1_TEXTS_DIRS
			 TOPIC2_REQUIREMENTS_DIRS TOPIC2_TOPICS_DIRS TOPIC2_CONSTRAINTS_DIRS TOPIC2_TEXTS_DIRS
			 TOPIC3_REQUIREMENTS_DIRS TOPIC3_TOPICS_DIRS TOPIC3_CONSTRAINTS_DIRS TOPIC3_TEXTS_DIRS
                         )

    FUNCTION_PARSE_ARGUMENTS("${prefix}" "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN})
    
    #------------------- finished parsing arguments ----------------------

    #------------------- prepare parameters ------------------------------
    IF(NOT ${prefix}_CONFIG_FILE_IN)
        SET(${prefix}_CONFIG_FILE_IN "${SIL2LINUXMP_TOOLS_DIR}/rmtoo/Config_json.in")
    ENDIF()
    GET_FILENAME_COMPONENT(RMTOO_CONFIG_INPUT_PATH ${${prefix}_CONFIG_FILE_IN} PATH)

    IF(NOT ${prefix}_CONFIG_FILE)
        SET(${prefix}_CONFIG_FILE "${CMAKE_BINARY_DIR}/rmtoo/Config.json")
    ENDIF()
    GET_FILENAME_COMPONENT(RMTOO_CONFIG_OUTPUT_PATH ${${prefix}_CONFIG_FILE} PATH)

    IF(NOT ${prefix}_GLOBAL_MODULES_DIRECTORIES)
        SET(${prefix}_GLOBAL_MODULES_DIRECTORIES "${RMTOO_ROOT_DIR}")
    ENDIF()
    
    IF(NOT ${prefix}_GLOBAL_LOGGING_STDOUT_LOGLEVEL)
	SET(${prefix}_GLOBAL_LOGGING_STDOUT_LOGLEVEL "warn")
    ENDIF()
    
    IF(NOT ${prefix}_GLOBAL_LOGGING_TRACER_LOGLEVEL)
        SET(${prefix}_GLOBAL_LOGGING_TRACER_LOGLEVEL "debug")
    ENDIF()
    
    IF(NOT ${prefix}_GLOBAL_LOGGING_TRACER_FILENAME)
	SET(${prefix}_GLOBAL_LOGGING_TRACER_FILENAME "${CMAKE_BINARY_DIR}/rmtoo/tracer.log")
    ENDIF()
    
    IF(NOT ${prefix}_PROCESSING_ANALYTICS_STOP_ON_ERRORS)
        SET(${prefix}_PROCESSING_ANALYTICS_STOP_ON_ERRORS "false")
    ELSE()
        SET(${prefix}_PROCESSING_ANALYTICS_STOP_ON_ERRORS "true")
    ENDIF()
    
    IF(NOT ${prefix}_REQUIREMENTS_INPUT_DEFAULT_LANGUAGE)
        SET(${prefix}_REQUIREMENTS_INPUT_DEFAULT_LANGUAGE "en_GB")
    ENDIF()
    
    IF(NOT ${prefix}_REQUIREMENTS_INPUT_DEPENDENCY_NOTATION)
        SET(${prefix}_REQUIREMENTS_INPUT_DEPENDENCY_NOTATION "Solved by")
    ENDIF()
    
    IF(NOT ${prefix}_REQUIREMENTS_TXTFILE_MAX_LINE_LENGTH)
        SET(${prefix}_REQUIREMENTS_TXTFILE_MAX_LINE_LENGTH "160")
    ENDIF()
    
    IF(NOT ${prefix}_REQUIREMENTS_INVENTORS)
        SET(${prefix}_REQUIREMENTS_INVENTORS "")
    ENDIF()

    IF(NOT ${prefix}_REQUIREMENTS_STAKEHOLDERS)
        SET(${prefix}_REQUIREMENTS_STAKEHOLDERS "")
    ENDIF()

    IF(NOT ${prefix_TOPIC1_NAME})
	# Generate at least one topic
        SET(${prefix}_TOPIC1_NAME "${CMAKE_PROJECT_NAME}")
    ENDIF()
    FOREACH(TOPIC "TOPIC1" "TOPIC2" "TOPIC3")
	IF(${prefix}_${TOPIC}_NAME)
	    IF(NOT ${prefix}_${TOPIC}_TITLE)
                SET(${prefix}_${TOPIC}_TITLE "${${prefix}_${TOPIC}_NAME}")
	    ENDIF()
	    IF(NOT ${prefix}_${TOPIC}_SUBTITLE)
                SET(${prefix}_${TOPIC}_SUBTITLE "---")
	    ENDIF()
	    IF(NOT ${prefix}_${TOPIC}_REQUIREMENTS_DIRS)
                SET(${prefix}_${TOPIC}_REQUIREMENTS_DIRS "requirements")
	    ENDIF()
	    IF(NOT ${prefix}_${TOPIC}_TOPICS_DIRS)
                SET(${prefix}_${TOPIC}_TOPICS_DIRS "topics")
	    ENDIF()
	    IF(NOT ${prefix}_${TOPIC}_CONSTRAINTS_DIRS)
                SET(${prefix}_${TOPIC}_CONSTRAINTS_DIRS "constraints")
	    ENDIF()
            IF(NOT ${prefix}_${TOPIC}_TEXTS_DIRS)
                SET(${prefix}_${TOPIC}_TEXTS_DIRS "texts")
            ENDIF()
	    IF(NOT ${prefix}_${TOPIC}_ROOT_NODE)
                SET(${prefix}_${TOPIC}_ROOT_NODE "${${prefix}_${TOPIC}_NAME}")
	    ENDIF()
	    #IF(NOT ${prefix}_${TOPIC}_OUTPUT_GRAPH_FILENAME)
            #    SET(${prefix}_${TOPIC}_OUTPUT_GRAPH_FILENAME "${CMAKE_BINARY_DIR}/rmtoo/artifacts/req-${${prefix}_${TOPIC}_NAME}-graph1.dot")
	    #ENDIF()
	    #IF(NOT ${prefix}_${TOPIC}_OUTPUT_GRAPH2_FILENAME)
            #    SET(${prefix}_${TOPIC}_OUTPUT_GRAPH2_FILENAME "${CMAKE_BINARY_DIR}/rmtoo/artifacts/req-${${prefix}_${TOPIC}_NAME}-graph2.dot")
	    #ENDIF()
	    IF(NOT ${prefix}_${TOPIC}_OUTPUT_HTML_FOOTER)
                SET(${prefix}_${TOPIC}_OUTPUT_HTML_FOOTER "${SIL2LINUXMP_TOOLS_DIR}/rmtoo/footer.html")
	    ENDIF()
	    IF(NOT ${prefix}_${TOPIC}_OUTPUT_HTML_HEADER)
                SET(${prefix}_${TOPIC}_OUTPUT_HTML_HEADER "${SIL2LINUXMP_TOOLS_DIR}/rmtoo/header.html")
	    ENDIF()
	    #IF(NOT ${prefix}_${TOPIC}_OUTPUT_HTML_DIRECTORY)
            #    SET(${prefix}_${TOPIC}_OUTPUT_HTML_DIRECTORY "${CMAKE_BINARY_DIR}/rmtoo/artifacts/html-${${prefix}_${TOPIC}_NAME}")
	    #ENDIF()
	    #IF(NOT ${prefix}_${TOPIC}_OUTPUT_LATEX2_TOPICS_FILENAME)
            #    SET(${prefix}_${TOPIC}_OUTPUT_LATEX2_TOPICS_FILENAME "${CMAKE_BINARY_DIR}/rmtoo/artifacts/req-${${prefix}_${TOPIC}_NAME}-topics.tex")
	    #ENDIF()
            IF(NOT ${prefix}_${TOPIC}_OUTPUT_LATEX2_MASTER_TEMPLATE)
                SET(${prefix}_${TOPIC}_OUTPUT_LATEX2_MASTER_TEMPLATE "${SIL2LINUXMP_TOOLS_DIR}/rmtoo/requirements_tex.in")
            ENDIF()
            IF(NOT ${prefix}_${TOPIC}_OUTPUT_LATEX2_MASTER_FILENAME)
                SET(${prefix}_${TOPIC}_OUTPUT_LATEX2_MASTER_FILENAME "${CMAKE_BINARY_DIR}/rmtoo/artifacts/req-${${prefix}_${TOPIC}_NAME}.tex")
            ENDIF()
	    #IF(NOT ${prefix}_${TOPIC}_OUTPUT_PANDOC1_DIRECTORY)
            #    SET(${prefix}_${TOPIC}_OUTPUT_PANDOC1_DIRECTORY "${CMAKE_BINARY_DIR}/rmtoo/artifacts/pandoc-${${prefix}_${TOPIC}_NAME}")
	    #ENDIF()
	    IF(NOT ${prefix}_${TOPIC}_OUTPUT_PANDOC1_BASENAME)
                SET(${prefix}_${TOPIC}_OUTPUT_PANDOC1_BASENAME "${${prefix}_${TOPIC}_NAME}")
	    ENDIF()
            IF(NOT ${prefix}_${TOPIC}_OUTPUT_PANDOC1_FILTERS_DIRECTORY)
                SET(${prefix}_${TOPIC}_OUTPUT_PANDOC1_FILTERS_DIRECTORY "${SIL2LINUXMP_TOOLS_DIR}/rmtoo/filters")
            ENDIF()
            IF(NOT ${prefix}_${TOPIC}_OUTPUT_PANDOC1_COVER_IMAGE)
                SET(${prefix}_${TOPIC}_OUTPUT_PANDOC1_COVER_IMAGE "http://a.fsdn.com/con/app/proj/rmtoo/screenshots/322716.jpg")
            ENDIF()
            #IF(NOT ${prefix}_${TOPIC}_OUTPUT_VERSION_FILENAME)
            #    SET(${prefix}_${TOPIC}_OUTPUT_VERSION_FILENAME "${CMAKE_BINARY_DIR}/rmtoo/artifacts/req-${${prefix}_${TOPIC}_NAME}-version.txt")
            #ENDIF()
            #IF(NOT ${prefix}_${TOPIC}_OUTPUT_STATS_BURNDOWN_FILENAME)
            #    SET(${prefix}_${TOPIC}_OUTPUT_STATS_BURNDOWN_FILENAME "${CMAKE_BINARY_DIR}/rmtoo/artifacts/stats-${${prefix}_${TOPIC}_NAME}-burndown.csv")
            #ENDIF()
            #IF(NOT ${prefix}_${TOPIC}_OUTPUT_STATS_SPRINTBURNDOWN_FILENAME)
            #    SET(${prefix}_${TOPIC}_OUTPUT_STATS_SPRINTBURNDOWN_FILENAME "${CMAKE_BINARY_DIR}/rmtoo/artifacts/stats-${${prefix}_${TOPIC}_NAME}-sprintburndown.csv")
            #ENDIF()
            #IF(NOT ${prefix}_${TOPIC}_OUTPUT_STATS_REQSCNT_FILENAME)
            #    SET(${prefix}_${TOPIC}_OUTPUT_STATS_REQSCNT_FILENAME "${CMAKE_BINARY_DIR}/rmtoo/artifacts/stats-${${prefix}_${TOPIC}_NAME}-reqcnt.csv")
            #ENDIF()
	ENDIF(${prefix}_${TOPIC}_NAME)
    ENDFOREACH(TOPIC "TOPIC1" "TOPIC2" "TOPIC3")
    
    #------------------- finishing preparing parameters ---------------

    UNSET(TOPIC_DOCUMENTS_RMTOO) # All files that are created by one rmtoo call.
    UNSET(TOPIC_DOCUMENTS_EXTRA) # Extra document(s) that are created either created by rmtoo or from the rmtoo files.
    UNSET(TOPIC_DEPENDS)
    ADD_CUSTOM_TARGET(rmtoo_doc) # A target to build documentation that depends on rmtoo generated documentation.
                                 # Rmtoo documentation is build by the target rmtoo_run.

    #------------------- Configure configuration file(s) ---------------------------
    SET(RMTOO_CONFIG_GLOBAL_MODULES_DIRECTORIES ${${prefix}_GLOBAL_MODULES_DIRECTORIES})
    RMTOO_STRINGIFY_LIST(RMTOO_CONFIG_GLOBAL_MODULES_DIRECTORIES "${RMTOO_CONFIG_GLOBAL_MODULES_DIRECTORIES}")
    STRING(REPLACE ";" "," RMTOO_CONFIG_GLOBAL_MODULES_DIRECTORIES "${RMTOO_CONFIG_GLOBAL_MODULES_DIRECTORIES}")

    SET(RMTOO_CONFIG_GLOBAL_LOGGING_STDOUT_LOGLEVEL ${${prefix}_GLOBAL_LOGGING_STDOUT_LOGLEVEL})

    SET(RMTOO_CONFIG_GLOBAL_LOGGING_TRACER_LOGLEVEL ${${prefix}_GLOBAL_LOGGING_TRACER_LOGLEVEL})

    SET(RMTOO_CONFIG_GLOBAL_LOGGING_TRACER_FILENAME ${${prefix}_GLOBAL_LOGGING_TRACER_FILENAME})

    SET(RMTOO_CONFIG_PROCESSING_ANALYTICS_STOP_ON_ERRORS ${${prefix}_PROCESSING_ANALYTICS_STOP_ON_ERRORS})

    SET(RMTOO_CONFIG_REQUIREMENTS_INPUT_DEFAULT_LANGUAGE ${${prefix}_REQUIREMENTS_INPUT_DEFAULT_LANGUAGE})

    SET(RMTOO_CONFIG_REQUIREMENTS_INPUT_DEPENDENCY_NOTATION ${${prefix}_REQUIREMENTS_INPUT_DEPENDENCY_NOTATION})

    SET(RMTOO_CONFIG_REQUIREMENTS_TXTFILE_MAX_LINE_LENGTH ${${prefix}_REQUIREMENTS_TXTFILE_MAX_LINE_LENGTH})
    
    SET(RMTOO_CONFIG_REQUIREMENTS_INVENTORS ${${prefix}_REQUIREMENTS_INVENTORS})
    RMTOO_STRINGIFY_LIST(RMTOO_CONFIG_REQUIREMENTS_INVENTORS "${RMTOO_CONFIG_REQUIREMENTS_INVENTORS}")
    STRING(REPLACE ";" "," RMTOO_CONFIG_REQUIREMENTS_INVENTORS "${RMTOO_CONFIG_REQUIREMENTS_INVENTORS}")
    
    SET(RMTOO_CONFIG_REQUIREMENTS_STAKEHOLDERS ${${prefix}_REQUIREMENTS_STAKEHOLDERS})
    RMTOO_STRINGIFY_LIST(RMTOO_CONFIG_REQUIREMENTS_STAKEHOLDERS "${RMTOO_CONFIG_REQUIREMENTS_STAKEHOLDERS}")
    STRING(REPLACE ";" "," RMTOO_CONFIG_REQUIREMENTS_STAKEHOLDERS "${RMTOO_CONFIG_REQUIREMENTS_STAKEHOLDERS}")
    
    SET(RMTOO_CONFIG_TOPICS "")
    FOREACH(TOPIC "TOPIC1" "TOPIC2" "TOPIC3")
	IF(${prefix}_${TOPIC}_NAME)
	    # Prepare lists
	    RMTOO_STRINGIFY_LIST(TOPIC_REQUIREMENTS_DIRS "${${prefix}_${TOPIC}_REQUIREMENTS_DIRS}")
	    STRING(REPLACE ";" "," TOPIC_REQUIREMENTS_DIRS "${TOPIC_REQUIREMENTS_DIRS}")
	    RMTOO_STRINGIFY_LIST(TOPIC_TOPICS_DIRS "${${prefix}_${TOPIC}_TOPICS_DIRS}")
	    STRING(REPLACE ";" "," TOPIC_TOPICS_DIRS "${TOPIC_TOPICS_DIRS}")
	    RMTOO_STRINGIFY_LIST(TOPIC_CONSTRAINTS_DIRS "${${prefix}_${TOPIC}_CONSTRAINTS_DIRS}")
	    STRING(REPLACE ";" "," TOPIC_CONSTRAINTS_DIRS "${TOPIC_CONSTRAINTS_DIRS}")
            RMTOO_STRINGIFY_LIST(TOPIC_TEXTS_DIRS "${${prefix}_${TOPIC}_TEXTS_DIRS}")
            STRING(REPLACE ";" "," TOPIC_TEXTS_DIRS "${TOPIC_TEXTS_DIRS}")
	    
	    IF(RMTOO_CONFIG_TOPICS)
	        # Add comma between topics
                SET(RMTOO_CONFIG_TOPICS "${RMTOO_CONFIG_TOPICS},\n")
	    ENDIF()
	    SET(RMTOO_CONFIG_TOPICS "${RMTOO_CONFIG_TOPICS}"
	        "\"${${prefix}_${TOPIC}_NAME}\": {\n"
		"  \"sources\": [\n"
		"    [\n"
		"      \"filesystem\", {\n"
		"        \"requirements_dirs\": [ ${TOPIC_REQUIREMENTS_DIRS} ],\n"
		"        \"topics_dirs\": [ ${TOPIC_TOPICS_DIRS} ],\n"
		"        \"topic_root_node\": \"${${prefix}_${TOPIC}_ROOT_NODE}\",\n"
		"        \"constraints_dirs\": [ ${TOPIC_CONSTRAINTS_DIRS} ]\n"
		"      }\n"
		"    ]\n"
		"  ],\n"
		"  \"output\": {\n")
		# Collect dependency info for call of rmtoo.
		FOREACH(TOPIC_INPUT_DIRECTORY ${${prefix}_${TOPIC}_REQUIREMENTS_DIRS})
		    FILE(GLOB TOPIC_INPUT_FILES "${TOPIC_INPUT_DIRECTORY}/*.req")
		    LIST(APPEND TOPIC_DEPENDS ${TOPIC_INPUT_FILES})
		ENDFOREACH()
		FOREACH(TOPIC_INPUT_DIRECTORY ${${prefix}_${TOPIC}_TOPICS_DIRS})
		    FILE(GLOB TOPIC_INPUT_FILES "${TOPIC_INPUT_DIRECTORY}/*.tic")
		    LIST(APPEND TOPIC_DEPENDS ${TOPIC_INPUT_FILES})
		ENDFOREACH()
		FOREACH(TOPIC_INPUT_DIRECTORY ${${prefix}_${TOPIC}_CONSTRAINTS_DIRS})
		    FILE(GLOB TOPIC_INPUT_FILES "${TOPIC_INPUT_DIRECTORY}/*.ctr")
		    LIST(APPEND TOPIC_DEPENDS ${TOPIC_INPUT_FILES})
		ENDFOREACH()
		FOREACH(TOPIC_INPUT_DIRECTORY ${${prefix}_${TOPIC}_TEXTS_DIRS})
		    FILE(GLOB TOPIC_INPUT_FILES "${TOPIC_INPUT_DIRECTORY}/*.md")
		    LIST(APPEND TOPIC_DEPENDS ${TOPIC_INPUT_FILES})
		ENDFOREACH()
		
	    IF(${prefix}_${TOPIC}_OUTPUT_GRAPH_FILENAME)
	    	MESSAGE(STATUS "Rmtoo: graph output to ${${prefix}_${TOPIC}_OUTPUT_GRAPH_FILENAME}")
		SET(RMTOO_CONFIG_TOPICS "${RMTOO_CONFIG_TOPICS}"
		"    \"graph\": [\n"
		"      {\n"
		"        \"output_filename\": \"${${prefix}_${TOPIC}_OUTPUT_GRAPH_FILENAME}\"\n"
		"      }\n"
                "    ],\n")
		LIST(APPEND TOPIC_DOCUMENTS_RMTOO "${${prefix}_${TOPIC}_OUTPUT_GRAPH_FILENAME}")
		# Commands to create png from graph1
		RMTOO_BASENAME(TOPIC_FILENAME_WE ${${prefix}_${TOPIC}_OUTPUT_GRAPH_FILENAME})
		ADD_CUSTOM_COMMAND(TARGET rmtoo_doc POST_BUILD
				  COMMAND ${GRAPHVIZ_UNFLATTEN_EXECUTABLE} -l 23 -o ${TOPIC_FILENAME_WE}_unflatted.dot ${${prefix}_${TOPIC}_OUTPUT_GRAPH_FILENAME}
				  COMMAND ${GRAPHVIZ_DOT_EXECUTABLE} -Tpng -o ${TOPIC_FILENAME_WE}.png ${TOPIC_FILENAME_WE}_unflatted.dot
				  COMMENT "Generating documents: ${TOPIC_FILENAME_WE}.png from ${${prefix}_${TOPIC}_OUTPUT_GRAPH_FILENAME}!"
				  )
		LIST(APPEND TOPIC_DOCUMENTS_EXTRA "${TOPIC_FILENAME_WE}.png")
            ENDIF()
            
	    IF(${prefix}_${TOPIC}_OUTPUT_GRAPH2_FILENAME)
    	    	MESSAGE(STATUS "Rmtoo: graph2 output to ${${prefix}_${TOPIC}_OUTPUT_GRAPH2_FILENAME}")
		SET(RMTOO_CONFIG_TOPICS "${RMTOO_CONFIG_TOPICS}"
		"    \"graph2\": [\n"
		"      {\n"
		"        \"output_filename\": \"${${prefix}_${TOPIC}_OUTPUT_GRAPH2_FILENAME}\"\n"
		"      }\n"
		"    ],\n")
		LIST(APPEND TOPIC_DOCUMENTS_RMTOO "${${prefix}_${TOPIC}_OUTPUT_GRAPH2_FILENAME}")
		# Commands to create png from graph2
		RMTOO_BASENAME(TOPIC_FILENAME_WE ${${prefix}_${TOPIC}_OUTPUT_GRAPH2_FILENAME})
		ADD_CUSTOM_COMMAND(TARGET rmtoo_doc POST_BUILD
				  COMMAND ${GRAPHVIZ_UNFLATTEN_EXECUTABLE} -l 23 -o ${TOPIC_FILENAME_WE}_unflatted.dot ${${prefix}_${TOPIC}_OUTPUT_GRAPH2_FILENAME}
				  COMMAND ${GRAPHVIZ_DOT_EXECUTABLE} -Tpng -o ${TOPIC_FILENAME_WE}.png ${TOPIC_FILENAME_WE}_unflatted.dot
				  COMMENT "Generating documents: ${TOPIC_FILENAME_WE}.png from ${${prefix}_${TOPIC}_OUTPUT_GRAPH2_FILENAME}!"
				  )
		LIST(APPEND TOPIC_DOCUMENTS_EXTRA "${TOPIC_FILENAME_WE}.png")
            ENDIF()
            
	    IF(${prefix}_${TOPIC}_OUTPUT_HTML_DIRECTORY)
	        MESSAGE(STATUS "Rmtoo: html output to ${${prefix}_${TOPIC}_OUTPUT_HTML_DIRECTORY}")
		SET(RMTOO_CONFIG_TOPICS "${RMTOO_CONFIG_TOPICS}"
		"    \"html\": [\n"
		"      {\n"
		"        \"footer\": \"${${prefix}_${TOPIC}_OUTPUT_HTML_FOOTER}\",\n"
		"        \"header\": \"${${prefix}_${TOPIC}_OUTPUT_HTML_HEADER}\",\n"
		"        \"output_directory\": \"${${prefix}_${TOPIC}_OUTPUT_HTML_DIRECTORY}\"\n"
		"      }\n"
                "    ],\n")
		LIST(APPEND TOPIC_DOCUMENTS_RMTOO "${${prefix}_${TOPIC}_OUTPUT_HTML_DIRECTORY}/${${prefix}_${TOPIC}_ROOT_NODE}.html")
		LIST(APPEND TOPIC_DOCUMENTS_EXTRA "${${prefix}_${TOPIC}_OUTPUT_HTML_DIRECTORY}/${${prefix}_${TOPIC}_ROOT_NODE}.html")
		# Mark HTML directories to be cleaned
		SET_PROPERTY(DIRECTORY APPEND PROPERTY
			     ADDITIONAL_MAKE_CLEAN_FILES
			     "${${prefix}_${TOPIC}_OUTPUT_HTML_DIRECTORY}")
            ENDIF()
            
	    IF(${prefix}_${TOPIC}_OUTPUT_LATEX2_TOPICS_FILENAME)
	        MESSAGE(STATUS "Rmtoo: latex2 output to ${${prefix}_${TOPIC}_OUTPUT_LATEX2_TOPICS_FILENAME}")
		SET(RMTOO_CONFIG_TOPICS "${RMTOO_CONFIG_TOPICS}"
		"    \"latex2\": [\n"
		"      {\n"
		"        \"output_filename\": \"${${prefix}_${TOPIC}_OUTPUT_LATEX2_TOPICS_FILENAME}\"\n"
		"      }\n"
		"    ],\n")
		LIST(APPEND TOPIC_DOCUMENTS_RMTOO "${${prefix}_${TOPIC}_OUTPUT_LATEX2_TOPICS_FILENAME}")
		# -- Configure TeX requirements document master
		SET(RMTOO_CONFIG_TEX_TITLE "${${prefix}_${TOPIC}_TITLE}")
		SET(RMTOO_CONFIG_TEX_SUBTITLE "${${prefix}_${TOPIC}_SUBTITLE}")
		SET(RMTOO_CONFIG_TEX_VERSION_FILENAME "${${prefix}_${TOPIC}_OUTPUT_VERSION_FILENAME}")
		SET(RMTOO_CONFIG_TEX_TOPICS_FILENAME "${${prefix}_${TOPIC}_OUTPUT_LATEX2_TOPICS_FILENAME}")
		RMTOO_BASENAME(RMTOO_CONFIG_TEX_STATS_BURNDOWN_FILENAME ${${prefix}_${TOPIC}_OUTPUT_STATS_BURNDOWN_FILENAME})
		SET(RMTOO_CONFIG_TEX_STATS_BURNDOWN_FILENAME "${RMTOO_CONFIG_TEX_STATS_BURNDOWN_FILENAME}.pdf")
		RMTOO_BASENAME(RMTOO_CONFIG_TEX_STATS_SPRINTBURNDOWN_FILENAME ${${prefix}_${TOPIC}_OUTPUT_STATS_SPRINTBURNDOWN_FILENAME})
		SET(RMTOO_CONFIG_TEX_STATS_SPRINTBURNDOWN_FILENAME "${RMTOO_CONFIG_TEX_STATS_SPRINTBURNDOWN_FILENAME}.pdf")
		RMTOO_BASENAME(RMTOO_CONFIG_TEX_STATS_REQSCNT_FILENAME ${${prefix}_${TOPIC}_OUTPUT_STATS_REQSCNT_FILENAME})
		SET(RMTOO_CONFIG_TEX_STATS_REQSCNT_FILENAME "${RMTOO_CONFIG_TEX_STATS_REQSCNT_FILENAME}.pdf")
		CONFIGURE_FILE("${${prefix}_${TOPIC}_OUTPUT_LATEX2_MASTER_TEMPLATE}" "${${prefix}_${TOPIC}_OUTPUT_LATEX2_MASTER_FILENAME}" @ONLY)
		# -- Create topic pdf document by latex2
		# Two extra calls are needed: one for the requirements converting and one for
		# backlog creation.
		SET(TOPIC_FILENAME "${${prefix}_${TOPIC}_OUTPUT_LATEX2_MASTER_FILENAME}")
		GET_FILENAME_COMPONENT(TOPIC_PATH ${TOPIC_FILENAME} PATH)
		GET_FILENAME_COMPONENT(TOPIC_FILENAME_WE ${TOPIC_FILENAME} NAME_WE)
		SET(TOPIC_FILENAME_WE "${TOPIC_PATH}/${TOPIC_FILENAME_WE}")
		ADD_CUSTOM_COMMAND(OUTPUT "${TOPIC_FILENAME_WE}.pdf"
				  COMMAND gnuplot ${${TOPIC}_CONFIG_PLOT_REQSCNT}
				  COMMAND epstopdf ${${TOPIC}_CONFIG_EPSTOPDF_REQSCNT}
				  COMMAND gnuplot ${${TOPIC}_CONFIG_PLOT_BURNDOWN}
				  COMMAND epstopdf ${${TOPIC}_CONFIG_EPSTOPDF_BURNDOWN}
				  COMMAND gnuplot ${${TOPIC}_CONFIG_PLOT_SPRINTBURNDOWN}
				  COMMAND epstopdf ${${TOPIC}_CONFIG_EPSTOPDF_SPRINTBURNDOWN}
				  COMMAND pdflatex ${TOPIC_FILENAME}
				  COMMAND pdflatex ${TOPIC_FILENAME}
				  COMMAND pdflatex ${TOPIC_FILENAME}
				  COMMENT "Generating PDF document: ${TOPIC_FILENAME_WE}.pdf!"
				  DEPENDS "${${TOPIC}_CONFIG_PLOT_REQSCNT}"
					  "${${prefix}_${TOPIC}_OUTPUT_STATS_REQSCNT_FILENAME}"
					  "${${TOPIC}_CONFIG_PLOT_BURNDOWN}"
					  "${${prefix}_${TOPIC}_OUTPUT_STATS_BURNDOWN_FILENAME}"
					  "${${TOPIC}_CONFIG_PLOT_SPRINTBURNDOWN}"
					  "${${prefix}_${TOPIC}_OUTPUT_STATS_SPRINTBURNDOWN_FILENAME}"
					  "${${prefix}_${TOPIC}_OUTPUT_LATEX2_TOPICS_FILENAME}"
				  WORKING_DIRECTORY "${TOPIC_PATH}"
				  )
		LIST(APPEND TOPIC_DOCUMENTS_EXTRA "${TOPIC_FILENAME_WE}.pdf")
            ENDIF()
            
	    IF(${prefix}_${TOPIC}_OUTPUT_PANDOC1_DIRECTORY)
		MESSAGE(STATUS "Rmtoo: pandoc1 output to ${${prefix}_${TOPIC}_OUTPUT_PANDOC1_DIRECTORY}")
		SET(RMTOO_CONFIG_TOPICS "${RMTOO_CONFIG_TOPICS}"
                "    \"pandoc1\": [\n"
                "      {\n"
                "        \"filter_directory\": \"${${prefix}_${TOPIC}_OUTPUT_PANDOC1_FILTERS_DIRECTORY}\",\n"
                "        \"filter_dot_preprocess\": \"${GRAPHVIZ_UNFLATTEN_EXECUTABLE} -l 23\",\n"
                "        \"texts_dirs\": [ ${TOPIC_TEXTS_DIRS} ],\n"
                "        \"output_directory\": \"${${prefix}_${TOPIC}_OUTPUT_PANDOC1_DIRECTORY}\",\n"
                "        \"output_basename\": \"${${prefix}_${TOPIC}_OUTPUT_PANDOC1_BASENAME}\",\n"
                "        \"output_title\": \"${${prefix}_${TOPIC}_TITLE}\",\n"
                "        \"output_subtitle\": \"${${prefix}_${TOPIC}_SUBTITLE}\",\n"
                "        \"output_cover_image\": \"/home/bernhard/sil2linuxmp-prep/specifications/texts/sil2linuxmp_go.jpg\"\n"
                "      }\n"
                "    ],\n")              
		LIST(APPEND TOPIC_DOCUMENTS_RMTOO "${${prefix}_${TOPIC}_OUTPUT_PANDOC1_DIRECTORY}/${${prefix}_${TOPIC}_OUTPUT_PANDOC1_BASENAME}.md"
						  "${${prefix}_${TOPIC}_OUTPUT_PANDOC1_DIRECTORY}/${${prefix}_${TOPIC}_OUTPUT_PANDOC1_BASENAME}.pdf"
						  "${${prefix}_${TOPIC}_OUTPUT_PANDOC1_DIRECTORY}/${${prefix}_${TOPIC}_OUTPUT_PANDOC1_BASENAME}.html")
            ENDIF()
            
	    IF(${prefix}_${TOPIC}_OUTPUT_STATS_BURNDOWN_FILENAME)
	        MESSAGE(STATUS "Rmtoo: stats_burndown1 output to ${${prefix}_${TOPIC}_OUTPUT_STATS_BURNDOWN_FILENAME}")
		SET(RMTOO_CONFIG_TOPICS "${RMTOO_CONFIG_TOPICS}"
                "    \"stats_burndown1\": [\n"
                "      {\n"
                "        \"output_filename\": \"${${prefix}_${TOPIC}_OUTPUT_STATS_BURNDOWN_FILENAME}\"\n"
                "      }\n"
                "    ],\n")
		LIST(APPEND TOPIC_DOCUMENTS_RMTOO "${${prefix}_${TOPIC}_OUTPUT_STATS_BURNDOWN_FILENAME}")
		# -- Configure gnuplot configuration files for burndown statistics
		SET(RMTOO_CONFIG_PLOT_BURNDOWN_INPUT_FILENAME ${${prefix}_${TOPIC}_OUTPUT_STATS_BURNDOWN_FILENAME})
		GET_FILENAME_COMPONENT(RMTOO_CONFIG_PLOT_BURNDOWN_INPUT_PATH ${RMTOO_CONFIG_PLOT_BURNDOWN_INPUT_FILENAME} PATH)
		GET_FILENAME_COMPONENT(RMTOO_CONFIG_PLOT_BURNDOWN_OUTPUT_FILENAME_WE ${RMTOO_CONFIG_PLOT_BURNDOWN_INPUT_FILENAME} NAME_WE)
		SET(${TOPIC}_CONFIG_PLOT_BURNDOWN "${RMTOO_CONFIG_OUTPUT_PATH}/gnuplot-stats-burndown-${${prefix}_${TOPIC}_NAME}.inc")
		SET(${TOPIC}_CONFIG_EPSTOPDF_BURNDOWN "${RMTOO_CONFIG_PLOT_BURNDOWN_INPUT_PATH}/${RMTOO_CONFIG_PLOT_BURNDOWN_OUTPUT_FILENAME_WE}.eps")
		SET(RMTOO_CONFIG_PLOT_BURNDOWN_OUTPUT_FILENAME "${${TOPIC}_CONFIG_EPSTOPDF_BURNDOWN}")
		CONFIGURE_FILE("${RMTOO_CONFIG_INPUT_PATH}/gnuplot_stats_burndown_inc.in" "${${TOPIC}_CONFIG_PLOT_BURNDOWN}" @ONLY)
            ENDIF()
            
	    IF(${prefix}_${TOPIC}_OUTPUT_STATS_SPRINTBURNDOWN_FILENAME)
	        MESSAGE(STATUS "Rmtoo: stats_sprint_burndown1 output to ${${prefix}_${TOPIC}_OUTPUT_STATS_SPRINTBURNDOWN_FILENAME}")
		SET(RMTOO_CONFIG_TOPICS "${RMTOO_CONFIG_TOPICS}"
                "    \"stats_sprint_burndown1\": [\n"
                "      {\n"
                "        \"output_filename\": \"${${prefix}_${TOPIC}_OUTPUT_STATS_SPRINTBURNDOWN_FILENAME}\"\n"
                "      }\n"
                "    ],\n")
		LIST(APPEND TOPIC_DOCUMENTS_RMTOO "${${prefix}_${TOPIC}_OUTPUT_STATS_SPRINTBURNDOWN_FILENAME}")
		# -- Configure gnuplot configuration files for sprint burndown statistics
		SET(RMTOO_CONFIG_PLOT_SPRINTBURNDOWN_INPUT_FILENAME ${${prefix}_${TOPIC}_OUTPUT_STATS_SPRINTBURNDOWN_FILENAME})
		GET_FILENAME_COMPONENT(RMTOO_CONFIG_PLOT_SPRINTBURNDOWN_INPUT_PATH ${RMTOO_CONFIG_PLOT_SPRINTBURNDOWN_INPUT_FILENAME} PATH)
		GET_FILENAME_COMPONENT(RMTOO_CONFIG_PLOT_SPRINTBURNDOWN_OUTPUT_FILENAME_WE ${RMTOO_CONFIG_PLOT_SPRINTBURNDOWN_INPUT_FILENAME} NAME_WE)
		SET(${TOPIC}_CONFIG_PLOT_SPRINTBURNDOWN "${RMTOO_CONFIG_OUTPUT_PATH}/gnuplot-stats-sprintburndown-${${prefix}_${TOPIC}_NAME}.inc")
		SET(${TOPIC}_CONFIG_EPSTOPDF_SPRINTBURNDOWN "${RMTOO_CONFIG_PLOT_SPRINTBURNDOWN_INPUT_PATH}/${RMTOO_CONFIG_PLOT_SPRINTBURNDOWN_OUTPUT_FILENAME_WE}.eps")
		SET(RMTOO_CONFIG_PLOT_SPRINTBURNDOWN_OUTPUT_FILENAME "${${TOPIC}_CONFIG_EPSTOPDF_SPRINTBURNDOWN}")
		CONFIGURE_FILE("${RMTOO_CONFIG_INPUT_PATH}/gnuplot_stats_sprint_burndown_inc.in" "${${TOPIC}_CONFIG_PLOT_SPRINTBURNDOWN}" @ONLY)
            ENDIF()
            
	    IF(${prefix}_${TOPIC}_OUTPUT_STATS_REQSCNT_FILENAME)
		MESSAGE(STATUS "Rmtoo: stats_reqs_cnt output to ${${prefix}_${TOPIC}_OUTPUT_STATS_REQSCNT_FILENAME}")
		SET(RMTOO_CONFIG_TOPICS "${RMTOO_CONFIG_TOPICS}"
                "    \"stats_reqs_cnt\": [\n"
                "      {\n"
                "        \"output_filename\": \"${${prefix}_${TOPIC}_OUTPUT_STATS_REQSCNT_FILENAME}\"\n"
                "      }\n"
                "    ],\n")
		LIST(APPEND TOPIC_DOCUMENTS_RMTOO "${${prefix}_${TOPIC}_OUTPUT_STATS_REQSCNT_FILENAME}")
		# -- Configure gnuplot configuration files for sprint burndown statistics
		SET(RMTOO_CONFIG_PLOT_REQSCNT_INPUT_FILENAME ${${prefix}_${TOPIC}_OUTPUT_STATS_REQSCNT_FILENAME})
		GET_FILENAME_COMPONENT(RMTOO_CONFIG_PLOT_REQSCNT_INPUT_PATH ${RMTOO_CONFIG_PLOT_REQSCNT_INPUT_FILENAME} PATH)
		GET_FILENAME_COMPONENT(RMTOO_CONFIG_PLOT_REQSCNT_OUTPUT_FILENAME_WE ${RMTOO_CONFIG_PLOT_REQSCNT_INPUT_FILENAME} NAME_WE)
		SET(${TOPIC}_CONFIG_PLOT_REQSCNT "${RMTOO_CONFIG_OUTPUT_PATH}/gnuplot-stats-reqscnt-${${prefix}_${TOPIC}_NAME}.inc")
		SET(${TOPIC}_CONFIG_EPSTOPDF_REQSCNT "${RMTOO_CONFIG_PLOT_REQSCNT_INPUT_PATH}/${RMTOO_CONFIG_PLOT_REQSCNT_OUTPUT_FILENAME_WE}.eps")
		SET(RMTOO_CONFIG_PLOT_REQSCNT_OUTPUT_FILENAME "${${TOPIC}_CONFIG_EPSTOPDF_REQSCNT}")
		CONFIGURE_FILE("${RMTOO_CONFIG_INPUT_PATH}/gnuplot_stats_reqs_cnt_inc.in" "${${TOPIC}_CONFIG_PLOT_REQSCNT}" @ONLY)
            ENDIF()
            
            # We always produce this.
            	MESSAGE(STATUS "Rmtoo: version1 output to ${${prefix}_${TOPIC}_OUTPUT_VERSION_FILENAME}")
		SET(RMTOO_CONFIG_TOPICS "${RMTOO_CONFIG_TOPICS}"
		"    \"version1\": [\n"
		"      {\n"
		"        \"output_filename\": \"${${prefix}_${TOPIC}_OUTPUT_VERSION_FILENAME}\"\n"
		"      }\n"
                "    ]\n"
		"  }\n"
		"}")
		LIST(APPEND TOPIC_DOCUMENTS_RMTOO "${${prefix}_${TOPIC}_OUTPUT_VERSION_FILENAME}")

	    STRING(REPLACE ";" "      " RMTOO_CONFIG_TOPICS "${RMTOO_CONFIG_TOPICS}")
	    
	ENDIF()
    ENDFOREACH(TOPIC "TOPIC1" "TOPIC2" "TOPIC3")
    
    CONFIGURE_FILE("${${prefix}_CONFIG_FILE_IN}" "${${prefix}_CONFIG_FILE}" @ONLY)
    
    #------------------- Finish Configure config file --------------------

    #------------------- Set target -----------------------------------

    # Target to execute rmtoo and produce rmtoo documentation output.
    ADD_CUSTOM_TARGET(rmtoo_run
                      COMMAND "env" "PYTHONPATH=${RMTOO_ROOT_DIR}"
                              ${PYTHON_EXECUTABLE} "${RMTOO_EXECUTABLE}" "-" "-j" "file://${${prefix}_CONFIG_FILE}"
                      WORKING_DIRECTORY "${CMAKE_BINARY_DIR}"
                      COMMENT "Generating documents: ${TOPIC_DOCUMENTS_RMTOO}!"
                      DEPENDS ${TOPIC_DEPENDS})

    ADD_DEPENDENCIES(rmtoo_doc rmtoo_run)
                      
    GET_TARGET_PROPERTY(DOC_TARGET doc TYPE)
    if(NOT DOC_TARGET)
        ADD_CUSTOM_TARGET(doc)
    endif()

    ADD_DEPENDENCIES(doc rmtoo_doc)

ENDFUNCTION(RMTOO_ADD)


#! @} sil2linuxmp-cmake
