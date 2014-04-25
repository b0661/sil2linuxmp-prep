################################################################################
#
#  Program: 3D Slicer
#
#  Copyright (c) 2010 Kitware Inc.
#
#  See Doc/copyright/copyright.txt
#  or http://www.slicer.org/copyright/copyright.txt for details.
#
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.
#
#  This file was originally developed by Jean-Christophe Fillion-Robin, Kitware Inc.
#  and was partially funded by NIH grant 3P41RR013218-12S1
#
################################################################################

#! @addtogroup sil2linuxmp-cmake
#! @{
#!
#! @file FindGIT.cmake
#! @brief Find a Git SCM client.
#!
#! Usage:
#! FIND_PACKAGE(GIT)
#!
#! Sets:
#! - GIT_FOUND		True if Git was found.
#! - GIT_EXECUTABLE	Path to the git binary.
#! - GIT_VERSION	Version of found git binary.
#!
#! If Git is found, the following function(s) are defined:
#! - @ref GIT_WC_INFO 
#! - @ref GIT_WC_SETUP
#!
#! @author http://trac.evemu.org/browser/trunk/cmake/FindGit.cmake
#! @author Jean-Christophe Fillion-Robin, Kitware Inc.
#! @author Bernhard Noelte

IF(GIT_EXECUTABLE)
    # Already in cache, be silent
    SET(GIT_FIND_QUIETLY true)
ENDIF()

# Assure all the defaults are available
INCLUDE(ConfigDefault)
INCLUDE(FunctionParseArguments)

# Look for 'git' or 'eg' (easy git)
SET(GIT_NAMES git eg)

# Prefer .cmd variants on Windows unless running in a Makefile
# in the MSYS shell.
IF(WIN32)
    IF(NOT CMAKE_GENERATOR MATCHES "MSYS")
        SET(GIT_NAMES git.cmd git eg.cmd eg)
    ENDIF()
ENDIF()

FIND_PROGRAM(GIT_EXECUTABLE ${GIT_NAMES}
             PATHS "C:/Program Files/Git/bin" "C:/Program Files (x86)/Git/bin"
             DOC "git command line client")
mark_as_advanced(GIT_EXECUTABLE)

if(GIT_EXECUTABLE)
  execute_process(COMMAND ${GIT_EXECUTABLE} --version
                  WORKING_DIRECTORY "${CMAKE_BINARY_DIR}"
                  OUTPUT_VARIABLE git_version
                  ERROR_QUIET
                  OUTPUT_STRIP_TRAILING_WHITESPACE)
  if (git_version MATCHES "^git version [0-9]")
    string(REPLACE "git version " "" GIT_VERSION_STRING "${git_version}")
  endif()
  unset(git_version)
endif(GIT_EXECUTABLE)

# handle the QUIETLY and REQUIRED arguments and set GIT_FOUND to TRUE if
# all listed variables are TRUE
INCLUDE(FindPackageHandleStandardArgs)
find_package_handle_standard_args(GIT
                                  REQUIRED_VARS GIT_EXECUTABLE
                                  VERSION_VAR GIT_VERSION_STRING)

IF(NOT GIT_FOUND)
    # No git available
    RETURN()
ENDIF()


#! @brief Extract information of a git working copy at a given location.
#!
#! @param _dir Where the git tree is.
#! @param prefix A prefix for defined variables.
#! @return <prefix>_WC_FOUND - true in case a working copy was fond in _dir
#! @return <prefix>_WC_REVISION_HASH - Current SHA1 hash
#! @return <prefix>_WC_REVISION - Current SHA1 hash
#! @return <prefix>_WC_REVISION_NAME - Name associated with <var-prefix>_WC_REVISION_HASH
#! @return <prefix>_WC_URL - output of command `git config --get remote.origin.url'
#! @return <prefix>_WC_ROOT - Same value as working copy URL
#! @return <prefix>_WC_GITSVN - Set to true if it's a git-svn repository:
#! @return <prefix>_WC_INFO - output of command `git svn info' (only git-svn repository)
#! @return <prefix>_WC_URL - url of the associated SVN repository (only git-svn repository)
#! @return <prefix>_WC_ROOT - root url of the associated SVN repository (only git-svn repository)
#! @return <prefix>_WC_REVISION - current SVN revision number (only git-svn repository)
#! @return <prefix>_WC_LAST_CHANGED_AUTHOR - author of last commit (only git-svn repository)
#! @return <prefix>_WC_LAST_CHANGED_DATE - date of last commit (only git-svn repository)
#! @return <prefix>_WC_LAST_CHANGED_REV - revision of last commit (only git-svn repository)
#! @return <prefix>_WC_LAST_CHANGED_LOG - last log of base revision (only git-svn repository)
FUNCTION(GIT_WC_INFO _dir prefix)
    MESSAGE(STATUS "Command GIT_WC_INFO '${_dir}' '${prefix}'")

    IF(NOT EXISTS "${_dir}")
        MESSAGE(STATUS "GIT_WC_INFO: directory '${_dir}' does not exist.")
        RETURN()
    ENDIF()

    SET(GIT_WC_INFO_COMMAND "${GIT_EXECUTABLE}" rev-list -n 1 HEAD)
    EXECUTE_PROCESS(COMMAND ${GIT_WC_INFO_COMMAND}
                    WORKING_DIRECTORY "${_dir}"
                    RESULT_VARIABLE GIT_RESULT
                    ERROR_VARIABLE GIT_ERROR
                    OUTPUT_VARIABLE WC_REVISION_HASH
                    OUTPUT_STRIP_TRAILING_WHITESPACE)
    SET(WC_REVISION ${WC_REVISION_HASH})
    IF(NOT ${GIT_RESULT} EQUAL 0)
        MESSAGE(STATUS "Command '" ${GIT_WC_INFO_COMMAND} "' in directory ${_dir} failed (${GIT_RESULT}) with output:\n${GIT_ERROR}")
        SET("${prefix}_WC_FOUND" false PARENT_SCOPE)
        RETURN()
    ENDIF()

    SET(GIT_WC_INFO_COMMAND "${GIT_EXECUTABLE}" name-rev "${WC_REVISION_HASH}")
    EXECUTE_PROCESS(COMMAND ${GIT_WC_INFO_COMMAND}
                    WORKING_DIRECTORY "${_dir}"
                    RESULT_VARIABLE GIT_RESULT
                    ERROR_VARIABLE GIT_ERROR
                    OUTPUT_VARIABLE WC_REVISION_NAME
                    OUTPUT_STRIP_TRAILING_WHITESPACE)
    IF(NOT ${GIT_RESULT} EQUAL 0)
        MESSAGE(STATUS "Command '" ${GIT_WC_INFO_COMMAND} "' in directory ${_dir} failed (${GIT_RESULT}) with output:\n${GIT_ERROR}")
    ENDIF()

    SET(GIT_WC_INFO_COMMAND "${GIT_EXECUTABLE}" config --get "remote.origin.url")
    EXECUTE_PROCESS(COMMAND ${GIT_WC_INFO_COMMAND}
                    WORKING_DIRECTORY "${_dir}"
                    RESULT_VARIABLE GIT_RESULT
                    ERROR_VARIABLE GIT_ERROR
                    OUTPUT_VARIABLE WC_URL
                    OUTPUT_STRIP_TRAILING_WHITESPACE)
    IF(NOT ${GIT_RESULT} EQUAL 0)
        MESSAGE(STATUS "Command '" ${GIT_WC_INFO_COMMAND} "' in directory ${_dir} failed (${GIT_RESULT}) with output:\n${GIT_ERROR}")
    ENDIF()

    SET(WC_ROOT "${WC_URL}")
    SET(WC_GITSVN false)

    # Try to get the branch
    SET(GIT_WC_INFO_COMMAND "${GIT_EXECUTABLE}" branch --no-color)
    EXECUTE_PROCESS(COMMAND ${GIT_WC_INFO_COMMAND}
                    WORKING_DIRECTORY "${_dir}"
                    RESULT_VARIABLE GIT_RESULT
                    OUTPUT_VARIABLE WC_FULL_BRANCH
                    ERROR_VARIABLE GIT_ERROR
                    OUTPUT_STRIP_TRAILING_WHITESPACE)
    IF(NOT ${GIT_RESULT} EQUAL 0)
        MESSAGE(STATUS "Command '" ${GIT_WC_INFO_COMMAND} "' in directory ${_dir} failed (${GIT_RESULT}) with output:\n${GIT_ERROR}")
        SET("${prefix}_WC_FOUND" false PARENT_SCOPE)
        RETURN()
    ENDIF()

    STRING(REGEX MATCH "^\\* *([^ ]*)$" WC_BRANCH "${WC_FULL_BRANCH}")

    # In case git-svn is used, attempt to extract svn info
    SET(GIT_WC_INFO_COMMAND ${GIT_EXECUTABLE} svn info)
    EXECUTE_PROCESS(COMMAND ${GIT_WC_INFO_COMMAND}
                    WORKING_DIRECTORY "${_dir}"
                    TIMEOUT 3
                    ERROR_VARIABLE GIT_ERROR
                    OUTPUT_VARIABLE WC_INFO
                    RESULT_VARIABLE GIT_RESULT
                    OUTPUT_STRIP_TRAILING_WHITESPACE)
    IF(NOT ${GIT_RESULT} EQUAL 0)
        MESSAGE(STATUS "Command '" ${GIT_WC_INFO_COMMAND} "' in directory ${_dir} failed (${GIT_RESULT}) with output:\n${GIT_ERROR}")
    ENDIF()

    IF(${GIT_RESULT} EQUAL 0)
        SET(WC_GITSVN true)
        STRING(REGEX REPLACE "^(.*\n)?URL: ([^\n]+).*" "\\2" WC_URL "${WC_INFO}")
        STRING(REGEX REPLACE "^(.*\n)?Revision: ([^\n]+).*" "\\2" WC_REVISION "${WC_INFO}")
        STRING(REGEX REPLACE "^(.*\n)?Repository Root: ([^\n]+).*" "\\2" WC_ROOT "${WC_INFO}")
        STRING(REGEX REPLACE "^(.*\n)?Last Changed Author: ([^\n]+).*" "\\2" WC_LAST_CHANGED_AUTHOR "${WC_INFO}")
        STRING(REGEX REPLACE "^(.*\n)?Last Changed Rev: ([^\n]+).*" "\\2" WC_LAST_CHANGED_REV "${WC_INFO}")
        STRING(REGEX REPLACE "^(.*\n)?Last Changed Date: ([^\n]+).*" "\\2" WC_LAST_CHANGED_DATE "${WC_INFO}")
    ENDIF()

    SET("${prefix}_WC_FOUND"               true                        PARENT_SCOPE)
    SET("${prefix}_WC_BRANCH"              "${WC_BRANCH}"              PARENT_SCOPE)
    SET("${prefix}_WC_REVISION_HASH"      	"${WC_REVISION_HASH}"		PARENT_SCOPE)
    SET("${prefix}_WC_REVISION"            "${WC_REVISION}"            PARENT_SCOPE)
    SET("${prefix}_WC_REVISION_NAME"       "${WC_REVISION_NAME}" 		PARENT_SCOPE)
    SET("${prefix}_WC_URL"                 "${WC_URL}"                 PARENT_SCOPE)
    SET("${prefix}_WC_ROOT"                "${WC_ROOT}"                PARENT_SCOPE)
    SET("${prefix}_WC_GITSVN"              "${WC_GITSVN}"              PARENT_SCOPE)
    SET("${prefix}_WC_INFO"                "${WC_INFO}"                PARENT_SCOPE)
    SET("${prefix}_WC_LAST_CHANGED_AUTHOR" "${WC_LAST_CHANGED_AUTHOR}" PARENT_SCOPE)
    SET("${prefix}_WC_LAST_CHANGED_DATE" 	"${WC_LAST_CHANGED_DATE}" 	PARENT_SCOPE)
    SET("${prefix}_WC_LAST_CHANGED_REV" 	"${WC_LAST_CHANGED_REV}" 	PARENT_SCOPE)
    SET("${prefix}_WC_LAST_CHANGED_LOG" 	"${WC_LAST_CHANGED_LOG}" 	PARENT_SCOPE)

ENDFUNCTION(GIT_WC_INFO)


#! @brief Create a working copy of a remote git repository.
#!
#! Create a working copy. If the working copy already exists, try to update (rebase) to current master.
#!
#! @param _dir Where the git repository shall be created in.
#! @param _url The url of the remote repository to track.
#! @param _wc_name The directory name for the working copy. This is relativ to _dir
#! @param _branch A Branch to work on.
#! @param prefix A prefix for defined variables.
#! @return <prefix>_WC_FOUND - true in case a working copy was created in _dir
#! @return <prefix>_WC_ROOT_DIR - root directory of the working copy
FUNCTION(GIT_WC_SETUP _dir _wc_name _url _branch prefix)

    MESSAGE(STATUS "Command GIT_WC_SETUP '${_dir}' '${_wc_name}' '${_url}' '${_branch}' '${prefix}'")

    IF(EXISTS "${_dir}/${_wc_name}/.git")
        # Git directory aleady exists
        MESSAGE(STATUS "Repository directory '${_dir}/${_wc_name}' found.")
        GIT_WC_INFO("${_dir}/${_wc_name}" "${prefix}")
        IF("${prefix}_WC_FOUND")
            MESSAGE(STATUS "Repository found in '${_dir}/${_wc_name}' for '${${prefix}_WC_URL}'.")
            # this is really a git repository
            IF("${${prefix}_WC_URL}" STREQUAL "${_url}")
                # This is a copy of the same remote repository
                MESSAGE(STATUS "Working copy '${_dir}/${_wc_name}' for '${_url}' arleady exists. Reusing working copy.")
            ELSE()
                SET("${prefix}_WC_FOUND" false)
            ENDIF()
        ENDIF()
    ENDIF()

    SET(GIT_RESULT 0)

    IF(NOT "${prefix}_WC_FOUND" AND EXISTS "${_dir}/${_wc_name}")
        # Be shure there is an empty directory to setup the repository
        SET(GIT_WC_SETUP_COMMAND "${CMAKE_COMMAND}" -E remove_directory "${_dir}/${_wc_name}")
        EXECUTE_PROCESS(COMMAND ${GIT_WC_SETUP_COMMAND}
                         RESULT_VARIABLE   GIT_RESULT
                         ERROR_VARIABLE    GIT_ERROR
                         OUTPUT_STRIP_TRAILING_WHITESPACE )
    ENDIF()

    IF(NOT "${prefix}_WC_FOUND" AND "${GIT_RESULT}" EQUAL 0)
        # Clone the remote repository
        MESSAGE(STATUS "No working copy '${_dir}/${_wc_name}' for '${_url}' found. Creating working copy.")

        SET(GIT_WC_SETUP_COMMAND "${GIT_EXECUTABLE}" clone "${_url}" "${_wc_name}")
        EXECUTE_PROCESS(COMMAND ${GIT_WC_SETUP_COMMAND}
                         WORKING_DIRECTORY "${_dir}"
                         RESULT_VARIABLE   GIT_RESULT
                         OUTPUT_VARIABLE   GIT_ERROR
                         ERROR_VARIABLE    GIT_ERROR
                         OUTPUT_STRIP_TRAILING_WHITESPACE )
        SET("${prefix}_WC_BRANCH" "master")
    ENDIF()

    IF(NOT "${_branch}" STREQUAL "${${prefix}_WC_BRANCH}" AND "${GIT_RESULT}" EQUAL 0)
        # Try to create the branch (we do not care if it is already available)
        SET(GIT_WC_SETUP_COMMAND "${GIT_EXECUTABLE}" branch "${_branch}")
        EXECUTE_PROCESS(COMMAND ${GIT_WC_SETUP_COMMAND}
                        WORKING_DIRECTORY "${_dir}/${_wc_name}"
                        RESULT_VARIABLE   GIT_RESULT
                        OUTPUT_VARIABLE   GIT_ERROR
                        ERROR_VARIABLE    GIT_ERROR
                        OUTPUT_STRIP_TRAILING_WHITESPACE )
        IF(NOT "${GIT_RESULT}" EQUAL 0)
            MESSAGE(STATUS "Command '${GIT_WC_SETUP_COMMAND}' in directory ${_dir}/${_wc_name} failed (${GIT_RESULT}) with output:\n${GIT_ERROR}")
        ENDIF()

        MESSAGE(STATUS "Switching to branch '${_branch}' in directory '${_dir}/${_wc_name}'.")
        # Switch to the requested branch
        SET(GIT_WC_SETUP_COMMAND "${GIT_EXECUTABLE}" checkout "${_branch}")
        EXECUTE_PROCESS(COMMAND ${GIT_WC_SETUP_COMMAND}
                        WORKING_DIRECTORY "${_dir}/${_wc_name}"
                        RESULT_VARIABLE   GIT_RESULT
                        OUTPUT_VARIABLE   GIT_ERROR
                        ERROR_VARIABLE    GIT_ERROR
                        OUTPUT_STRIP_TRAILING_WHITESPACE )

    ENDIF()

    IF(NOT "${_branch}" STREQUAL "master" AND "${GIT_RESULT}" EQUAL 0)
        # Try to update the branch to actual master
        MESSAGE(STATUS "Rebasing branch '${_branch}' in directory '${_dir}/${_wc_name}' to '${_branch}'.")
        # Rebasing the requested branch
        SET(GIT_WC_SETUP_COMMAND "${GIT_EXECUTABLE}" rebase "${_branch}")
        EXECUTE_PROCESS(COMMAND ${GIT_WC_SETUP_COMMAND}
                        WORKING_DIRECTORY "${_dir}/${_wc_name}"
                        RESULT_VARIABLE   GIT_RESULT
                        OUTPUT_VARIABLE   GIT_ERROR
                        ERROR_VARIABLE    GIT_ERROR
                        OUTPUT_STRIP_TRAILING_WHITESPACE )
        IF(NOT "${GIT_RESULT}" EQUAL 0)
            MESSAGE(STATUS "Command '${GIT_WC_SETUP_COMMAND}' in directory ${_dir}/${_wc_name} failed (${GIT_RESULT}) with output:\n${GIT_ERROR}")
            # Revert rebase operation
            MESSAGE(STATUS "Abort rebasing branch '${_branch}' in directory '${_dir}/${_wc_name}'.")
            SET(GIT_WC_SETUP_COMMAND "${GIT_EXECUTABLE}" rebase --abort)
            EXECUTE_PROCESS(COMMAND ${GIT_WC_SETUP_COMMAND}
                            WORKING_DIRECTORY "${_dir}/${_wc_name}"
                            RESULT_VARIABLE   GIT_RESULT
                            OUTPUT_VARIABLE   GIT_ERROR
                            ERROR_VARIABLE    GIT_ERROR
                            OUTPUT_STRIP_TRAILING_WHITESPACE )
        ENDIF()

    ENDIF()

    IF(NOT "${GIT_RESULT}" EQUAL 0)
        MESSAGE(STATUS "Command '${GIT_WC_SETUP_COMMAND}' in directory ${_dir}/${_wc_name} failed (${GIT_RESULT}) with output:\n${GIT_ERROR}")
    ENDIF()

    SET("${prefix}_WC_FOUND"       true                    PARENT_SCOPE)
    SET("${prefix}_WC_ROOT_DIR" 	"${_dir}/${_wc_name}" 	PARENT_SCOPE)

ENDFUNCTION(GIT_WC_SETUP)


#! @brief Setup a mirror git repository.
#!
#! @param GIT_DIR <directory> Directory the git repository shall be created in.
#! @param URL <url> The url of the remote repository to track.
#! @param PREFIX <prefix> Prefix to use for return variables. Defaults to function name.
#! @return <prefix>_READY true in case the shared git repository is available.
FUNCTION(GIT_MIRROR_SETUP)
    MESSAGE(STATUS "GIT_MIRROR_SETUP called: ${ARGN}.")

    #-------------------- parse function arguments -------------------

    SET(prefix GIT_MIRROR_SETUP)
    SET(options)
    SET(one_value_args GIT_DIR URL)
    SET(multi_value_args)

    FUNCTION_PARSE_ARGUMENTS("${prefix}" "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN} )

    #------------------- finished parsing arguments --------------------


    # - Get the repository path and name
    GET_FILENAME_COMPONENT(${prefix}_REPO_TOP_DIR "${${prefix}_GIT_DIR}" PATH)
    GET_FILENAME_COMPONENT(${prefix}_REPO_NAME "${${prefix}_GIT_DIR}" NAME)
    
    # - Try to find out whether repository working copy (WC) is already available
    SET(${prefix}_WC_FOUND false)
    
    IF(EXISTS "${${prefix}_GIT_DIR}/.git")
        # Git directory aleady exists
        MESSAGE(STATUS "Command 'GIT_MIRROR_SETUP" ${ARGN} "' failed: Git repository '${${prefix}_GIT_DIR}' is not a bare repository.")
        SET("${prefix}_READY" false PARENT_SCOPE)
        RETURN()
    ENDIF()
    IF(EXISTS "${${prefix}_GIT_DIR}/HEAD")
        # Git directory aleady exists
        MESSAGE(STATUS "Repository directory '${${prefix}_GIT_DIR}' found.")
        GIT_WC_INFO("${${prefix}_GIT_DIR}" "${prefix}")
        IF("${prefix}_WC_FOUND")
            MESSAGE(STATUS "Repository found in '${${prefix}_GIT_DIR}' for '${${prefix}_WC_URL}'.")
            # this is really a git repository
            IF("${${prefix}_WC_URL}" STREQUAL "${${prefix}_URL}")
                # This is a copy of the same remote repository
                MESSAGE(STATUS "Shared working copy '${${prefix}_GIT_DIR}' for '${${prefix}_WC_URL}' arleady exists. Reusing working copy.")
            ELSE()
                MESSAGE(STATUS "Command 'GIT_MIRROR_SETUP" ${ARGN} "' failed: Git repository '${${prefix}_GIT_DIR}' does not refer to '${${prefix}_WC_URL}'.")
                SET("${prefix}_READY" false PARENT_SCOPE)
                RETURN()
            ENDIF()
        ENDIF()    
    ENDIF()

    IF(NOT "${prefix}_WC_FOUND" AND EXISTS "${${prefix}_GIT_DIR}")
        # Be shure there is an empty directory to setup the repository
        SET(${prefix}_COMMAND "${CMAKE_COMMAND}" -E remove_directory "${${prefix}_GIT_DIR}")
        EXECUTE_PROCESS(COMMAND ${${prefix}_COMMAND}
                         RESULT_VARIABLE   ${prefix}_RESULT
                         ERROR_VARIABLE    ${prefix}_ERROR
                         OUTPUT_STRIP_TRAILING_WHITESPACE )
    ENDIF()
    
    IF(NOT "${prefix}_WC_FOUND")
        # Clone the remote repository
        MESSAGE(STATUS "No shared working copy '${${prefix}_GIT_DIR}' for '${${prefix}_URL}' found. Creating shared working copy.")
        
        # Clone into a mirror repository
        SET(${prefix}_COMMAND "${GIT_EXECUTABLE}" "clone" "--mirror" "${${prefix}_URL}" "${${prefix}_REPO_NAME}")
        SET(${prefix}_WORKING_DIR "${${prefix}_REPO_TOP_DIR}")
        EXECUTE_PROCESS(COMMAND ${${prefix}_COMMAND}
                         WORKING_DIRECTORY "${prefix}_WORKING_DIR"
                         RESULT_VARIABLE   ${prefix}_RESULT
                         OUTPUT_VARIABLE   ${prefix}_OUTPUT
                         ERROR_VARIABLE    ${prefix}_ERROR
                         OUTPUT_STRIP_TRAILING_WHITESPACE )
        IF(NOT ${${prefix}_RESULT} EQUAL 0)
            MESSAGE(STATUS "Command '" ${${prefix}_COMMAND} "' in directory ${${prefix}_WORKING_DIR} failed (${${prefix}_ERROR}). Result ${${prefix}_RESULT} with output:\n${${prefix}_ERROR}")
            SET("${prefix}_READY" false PARENT_SCOPE)
            RETURN()
        ENDIF()
    ELSE()
        # -- Make shure it is up to date
        SET(${prefix}_COMMAND "${GIT_EXECUTABLE}" "remote" "update")
        SET(${prefix}_WORKING_DIR "${${prefix}_GIT_DIR}")
        EXECUTE_PROCESS(COMMAND ${${prefix}_COMMAND}
                        WORKING_DIRECTORY "${${prefix}_WORKING_DIR}"
                        RESULT_VARIABLE ${prefix}_RESULT
                        ERROR_VARIABLE ${prefix}_MASTER_ERROR
                        OUTPUT_VARIABLE ${prefix}_OUTPUT
                        OUTPUT_STRIP_TRAILING_WHITESPACE)
        IF(NOT ${${prefix}_RESULT} EQUAL 0)
            # MESSAGE(STATUS "Command '" ${KERNEL_SETUP_MASTER_COMMAND} "' in directory ${KERNEL_SETUP_MASTER_WORKING_DIR} failed (${KERNEL_SETUP_MASTER_RESULT}) with output:\n${KERNEL_SETUP_MASTER_ERROR}")
            # This not an error. May be just the timeout elapsed due to a missing internet connection
        ENDIF()        
    ENDIF()

    SET(${prefix}_READY true PARENT_SCOPE)

ENDFUNCTION(GIT_MIRROR_SETUP)


#! @brief Setup a clone git repository
#!
#! @param GIT_DIR <directory> Directory where the cloned repository shall be in.
#! @param MASTER_DIR <directory> Directory where the original git repository is in.
#! @param PREFIX <prefix> Prefix to use for return variables. Defaults to function name.
#! @param BRANCH <branch> Branch to track in clone. Defaults to master.
#! @return <prefix>_READY true in case the cloned repository is available.
FUNCTION(GIT_CLONE_SETUP)
    MESSAGE(STATUS "GIT_CLONE_SETUP called: ${ARGN}.")

    #-------------------- parse function arguments -------------------

    SET(prefix GIT_CLONE_SETUP)
    SET(options)
    SET(one_value_args GIT_DIR MASTER_DIR BRANCH)
    SET(multi_value_args)

    FUNCTION_PARSE_ARGUMENTS("${prefix}" "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN} )

    #------------------- finished parsing arguments --------------------

    GET_FILENAME_COMPONENT(${prefix}_TOP_DIR ${${prefix}_GIT_DIR} PATH)
    GET_FILENAME_COMPONENT(${prefix}_WC ${${prefix}_GIT_DIR} NAME)
    
    IF("${${prefix}_BRANCH}" STREQUAL "")
        SET(${prefix}_BRANCH "master")
    ENDIF()

   IF(EXISTS "${${prefix}_GIT_DIR}")
        # Git directory aleady exists
        MESSAGE(STATUS "Repository directory '${${prefix}_GIT_DIR}' found.")
        GIT_WC_INFO("${${prefix}_GIT_DIR}" "${prefix}")
        IF("${prefix}_WC_FOUND")
            MESSAGE(STATUS "Repository found in '${${prefix}_GIT_DIR}' for '${${_prefix}_WC_URL}'.")
            # this is really a git repository
            IF("${${prefix}_WC_URL}" STREQUAL "${${prefix}_MASTER_DIR}")
                # This is a copy of the same remote repository
                MESSAGE(STATUS "Working copy '${${prefix}_GIT_DIR}' for '${${prefix}_MASTER_DIR}' arleady exists. Reusing working copy.")
            ELSE()
                SET("${prefix}_WC_FOUND" false)
            ENDIF()
        ENDIF()
    ENDIF()

    IF(NOT "${prefix}_WC_FOUND")
        MESSAGE(STATUS "Clone directory not available or corrupt. Creating new \"${${prefix}_GIT_DIR}\".")

        # clone working copy not available or automatic crash recovery.
        SET(${prefix}_COMMAND "${CMAKE_COMMAND}" "-E" "remove_directory" "${${prefix}_WC}")
        SET(${prefix}_WORKING_DIR "${${prefix}_TOP_DIR}")
        EXECUTE_PROCESS(COMMAND ${${prefix}_COMMAND}
                        WORKING_DIRECTORY "${${prefix}_WORKING_DIR}"
                        RESULT_VARIABLE ${prefix}_RESULT
                        ERROR_VARIABLE ${prefix}_ERROR
                        OUTPUT_VARIABLE ${prefix}_OUTPUT
                        OUTPUT_STRIP_TRAILING_WHITESPACE)
        IF(NOT ${${prefix}_RESULT} EQUAL 0)
            MESSAGE(STATUS "Command '" ${${prefix}_COMMAND} "' in directory ${${prefix}_WORKING_DIR} failed (${${prefix}_RESULT}) with output:\n${${prefix}_ERROR}")
            # This not an error. May be directory was not available.
        ENDIF()

        SET(${prefix}_COMMAND "${GIT_EXECUTABLE}" clone --shared "${${prefix}_MASTER_DIR}" "${${prefix}_WC}")
        EXECUTE_PROCESS(COMMAND ${${prefix}_COMMAND}
                        WORKING_DIRECTORY "${${prefix}_WORKING_DIR}"
                        RESULT_VARIABLE ${prefix}_RESULT
                        ERROR_VARIABLE ${prefix}_ERROR
                        OUTPUT_VARIABLE ${prefix}_OUTPUT
                        OUTPUT_STRIP_TRAILING_WHITESPACE)
        IF(NOT ${${prefix}_RESULT} EQUAL 0)
            MESSAGE(STATUS "Command '" ${${prefix}_COMMAND} "' in directory ${${prefix}_WORKING_DIR} failed (${${prefix}_RESULT}) with output:\n${${prefix}_ERROR}")
            SET("${prefix}_READY" false PARENT_SCOPE)
            RETURN()
        ENDIF()
    ENDIF()


    # -- Do some cleanup on current working branch of clone repository.

    # Abort any patching operation from before in the current working branch.
    SET(${prefix}_COMMAND "${GIT_EXECUTABLE}" "am" "--abort")
    SET(${prefix}_WORKING_DIR "${${prefix}_TOP_DIR}/${${prefix}_WC}")
    EXECUTE_PROCESS(COMMAND ${${prefix}_COMMAND}
                    WORKING_DIRECTORY "${${prefix}_WORKING_DIR}"
                    RESULT_VARIABLE ${prefix}_RESULT
                    ERROR_VARIABLE ${prefix}_ERROR
                    OUTPUT_VARIABLE ${prefix}_OUTPUT
                    OUTPUT_STRIP_TRAILING_WHITESPACE)
    IF(NOT ${${prefix}_RESULT} EQUAL 0)
        MESSAGE(STATUS "Command '" ${${prefix}_COMMAND} "' in directory ${${prefix}_WORKING_DIR} failed (${${prefix}_RESULT}) with output:\n${${prefix}_ERROR}")
        #SET("${prefix}_READY" false PARENT_SCOPE)
        #RETURN()
    ENDIF()

    # Add everything for empty cleanup commit.
    SET(${prefix}_COMMAND "${GIT_EXECUTABLE}" "add" "--all")
    EXECUTE_PROCESS(COMMAND ${${prefix}_COMMAND}
                    WORKING_DIRECTORY "${${prefix}_WORKING_DIR}"
                    RESULT_VARIABLE ${prefix}_RESULT
                    ERROR_VARIABLE ${prefix}_ERROR
                    OUTPUT_VARIABLE ${prefix}_OUTPUT
                    OUTPUT_STRIP_TRAILING_WHITESPACE)
    IF(NOT ${${prefix}_RESULT} EQUAL 0)
        MESSAGE(STATUS "Command '" ${${prefix}_COMMAND} "' in directory ${${prefix}_WORKING_DIR} failed (${${prefix}_RESULT}) with output:\n${${prefix}_ERROR}")
        SET("${prefix}_READY" false PARENT_SCOPE)
        RETURN()
    ENDIF()

    # Empty cleanup commit.
    SET(${prefix}_COMMAND "${GIT_EXECUTABLE}" "commit" "--allow-empty" "-a" "-m" "empty cleanup commit")
    EXECUTE_PROCESS(COMMAND ${${prefix}_COMMAND}
                    WORKING_DIRECTORY "${${prefix}_WORKING_DIR}"
                    RESULT_VARIABLE ${prefix}_RESULT
                    ERROR_VARIABLE ${prefix}_ERROR
                    OUTPUT_VARIABLE ${prefix}_OUTPUT
                    OUTPUT_STRIP_TRAILING_WHITESPACE)
    IF(NOT ${${prefix}_RESULT} EQUAL 0)
        MESSAGE(STATUS "Command '" ${${prefix}_COMMAND} "' in directory ${${prefix}_WORKING_DIR} failed (${${prefix}_RESULT}) with output:\n${${prefix}_ERROR}")
        SET("${prefix}_READY" false PARENT_SCOPE)
        RETURN()
    ENDIF()

    # Reset to head.
    SET(${prefix}_COMMAND "${GIT_EXECUTABLE}" "reset" "--hard" "HEAD")
    EXECUTE_PROCESS(COMMAND ${${prefix}_COMMAND}
                    WORKING_DIRECTORY "${${prefix}_WORKING_DIR}"
                    RESULT_VARIABLE ${prefix}_RESULT
                    ERROR_VARIABLE ${prefix}_ERROR
                    OUTPUT_VARIABLE ${prefix}_OUTPUT
                    OUTPUT_STRIP_TRAILING_WHITESPACE)
    IF(NOT ${${prefix}_RESULT} EQUAL 0)
        MESSAGE(STATUS "Command '" ${${prefix}_COMMAND} "' in directory ${${prefix}_WORKING_DIR} failed (${${prefix}_RESULT}) with output:\n${${prefix}_ERROR}")
        SET("${prefix}_READY" false PARENT_SCOPE)
        RETURN()
    ENDIF()


    # -- Make clone repository up to date (switches to master branch).

    # Set clone working copy to tracking branch.
    SET(${prefix}_COMMAND "${GIT_EXECUTABLE}" "checkout" "${${prefix}_BRANCH}" "-f")
    EXECUTE_PROCESS(COMMAND ${${prefix}_COMMAND}
                    WORKING_DIRECTORY "${${prefix}_WORKING_DIR}"
                    RESULT_VARIABLE ${prefix}_RESULT
                    ERROR_VARIABLE ${prefix}_ERROR
                    OUTPUT_VARIABLE ${prefix}_OUTPUT
                    OUTPUT_STRIP_TRAILING_WHITESPACE)
    IF(NOT ${${prefix}_RESULT} EQUAL 0)
        MESSAGE(STATUS "Command '" ${${prefix}_COMMAND} "' in directory ${${prefix}_WORKING_DIR} failed (${${prefix}_RESULT}) with output:\n${${prefix}_ERROR}")
        SET("${prefix}_READY" false PARENT_SCOPE)
        RETURN()
    ENDIF()

    # Get any updates from origin master.
    SET(${prefix}_COMMAND "${GIT_EXECUTABLE}" "pull" "${${prefix}_MASTER_DIR}" "--tags")
    EXECUTE_PROCESS(COMMAND ${${prefix}_COMMAND}
                    WORKING_DIRECTORY "${${prefix}_WORKING_DIR}"
                    RESULT_VARIABLE ${prefix}_RESULT
                    ERROR_VARIABLE ${prefix}_ERROR
                    OUTPUT_VARIABLE ${prefix}_OUTPUT
                    OUTPUT_STRIP_TRAILING_WHITESPACE)
    IF(NOT ${${prefix}_RESULT} EQUAL 0)
        MESSAGE(STATUS "Command '" ${${prefix}_COMMAND} "' in directory ${${prefix}_WORKING_DIR} failed (${${prefix}_RESULT}) with output:\n${${prefix}_ERROR}")
        # May fail due to just fetching tags and no updates.
        # SET("${prefix}_READY" false PARENT_SCOPE)
        # RETURN()
    ENDIF()

    SET("${prefix}_READY" true PARENT_SCOPE)

ENDFUNCTION(GIT_CLONE_SETUP)


#! @brief Setup branch in git repository (e.g. for patching...)
#!
#! @param GIT_DIR <directory> Directory of git repository where the branch shall be created in.
#! @param TAG <tag> The tag the branch shall sit on (e.g. v3.9).
#! @param BRANCH <branch> Branch. Will be combined with tag to form actual branch name "<tag>-<branch>".
#! @param EMPTY Branch shall be empty. If the branch is available, it will be deleted an recreated. All changes will be lost!!!
#! @param PREFIX <prefix> Prefix to use for return variables. Defaults to function name.
#! @return <prefix>_READY true in case the branch is available.
FUNCTION(GIT_BRANCH)
    MESSAGE(STATUS "GIT_BRANCH called: ${ARGN}.")

    #-------------------- parse function arguments -------------------

    SET(prefix GIT_BRANCH)
    SET(options EMPTY)
    SET(one_value_args GIT_DIR TAG BRANCH)
    SET(multi_value_args)

    FUNCTION_PARSE_ARGUMENTS("${prefix}" "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN} )

    #------------------- finished parsing arguments --------------------

    # -- Check for kernel tag (e.g 3.9) to be available in clone working copy.
    SET(${prefix}_COMMAND "${GIT_EXECUTABLE}" "tag")
    SET(${prefix}_WORKING_DIR "${${prefix}_GIT_DIR}")
    EXECUTE_PROCESS(COMMAND ${${prefix}_COMMAND}
                    WORKING_DIRECTORY "${${prefix}_WORKING_DIR}"
                    RESULT_VARIABLE ${prefix}_RESULT
                    ERROR_VARIABLE ${prefix}_ERROR
                    OUTPUT_VARIABLE ${prefix}_OUTPUT
                    OUTPUT_STRIP_TRAILING_WHITESPACE)
    IF(NOT ${${prefix}_RESULT} EQUAL 0)
        MESSAGE(STATUS "Command '" ${${prefix}_COMMAND} "' in directory ${${prefix}_WORKING_DIR} failed (${${prefix}_RESULT}) with output:\n${${prefix}_ERROR}")
        SET("${_prefix}_READY" false PARENT_SCOPE)
        RETURN()
    ELSE()
        MESSAGE(STATUS "Command '" ${${prefix}_COMMAND} "' in directory ${${prefix}_WORKING_DIR} succeeded (${${prefix}_RESULT}) with output:\n${${prefix}_OUTPUT}")
    ENDIF()
    STRING(REPLACE "\n" ";" ${prefix}_TAGS "${${prefix}_OUTPUT}")
    MESSAGE(STATUS "Tag: ${${prefix}_TAG}, Tags: ${${prefix}_TAGS}")
    LIST(FIND ${prefix}_TAGS "${${prefix}_TAG}" ${prefix}_RESULT)
    IF(${${prefix}_RESULT} EQUAL -1)
        MESSAGE(STATUS "Command '" ${${prefix}_COMMAND} "' in directory ${${prefix}_WORKING_DIR}: Tag \"${${prefix}_TAG}\" not available")
        # Maybe TAG is a branch
        SET(${prefix}_COMMAND "${GIT_EXECUTABLE}" "branch" "--list" "${${prefix}_TAG}")
        EXECUTE_PROCESS(COMMAND ${${prefix}_COMMAND}
                        WORKING_DIRECTORY "${${prefix}_WORKING_DIR}"
                        RESULT_VARIABLE ${prefix}_RESULT
                        ERROR_VARIABLE ${prefix}_ERROR
                        OUTPUT_VARIABLE ${prefix}_OUTPUT
                        OUTPUT_STRIP_TRAILING_WHITESPACE)
        STRING(REPLACE " " "" ${prefix}_OUTPUT "${${prefix}_OUTPUT}")
        STRING(REPLACE "*" "" ${prefix}_OUTPUT "${${prefix}_OUTPUT}")
        STRING(REPLACE "\n" ";" ${prefix}_BRANCHES "${${prefix}_OUTPUT}")
        MESSAGE(STATUS "TAG Branch: ${${prefix}_TAG}, Branches: ${${prefix}_BRANCHES}")
        LIST(FIND ${prefix}_BRANCHES "${${prefix}_TAG}" ${prefix}_RESULT)
        IF(${${prefix}_RESULT} EQUAL -1)
            MESSAGE(STATUS "Command '" ${${prefix}_COMMAND} "' in directory ${${prefix}_WORKING_DIR}: TAG Branch \"${${prefix}_TAG}\" not available")
            SET("${_prefix}_READY" false PARENT_SCOPE)
            RETURN()
        ENDIF()
    ENDIF()

    # -- Check for branch already available.
    SET(${prefix}_COMMAND "${GIT_EXECUTABLE}" "branch" "--list" "${${prefix}_TAG}-${${prefix}_BRANCH}")
    EXECUTE_PROCESS(COMMAND ${${prefix}_COMMAND}
                    WORKING_DIRECTORY "${${prefix}_WORKING_DIR}"
                    RESULT_VARIABLE ${prefix}_RESULT
                    ERROR_VARIABLE ${prefix}_ERROR
                    OUTPUT_VARIABLE ${prefix}_OUTPUT
                    OUTPUT_STRIP_TRAILING_WHITESPACE)
    STRING(REPLACE " " "" ${prefix}_OUTPUT "${${prefix}_OUTPUT}")
    STRING(REPLACE "*" "" ${prefix}_OUTPUT "${${prefix}_OUTPUT}")
    STRING(REPLACE "\n" ";" ${prefix}_BRANCHES "${${prefix}_OUTPUT}")
    #MESSAGE(STATUS "Branch: ${${prefix}_BRANCH}, Branches: ${${prefix}_BRANCHES}")
    LIST(FIND ${prefix}_BRANCHES "${${prefix}_TAG}-${${prefix}_BRANCH}" ${prefix}_RESULT)

    # -- Create/ checkout branch
    IF(${${prefix}_RESULT} EQUAL -1)
        # branch not available. Checkout master tag and build branch on top of it.
        MESSAGE(STATUS "Branch \"${${prefix}_BRANCH}\" not available. Generating it")
        SET(${prefix}_COMMAND "${GIT_EXECUTABLE}" "checkout" "${${prefix}_TAG}" "-b" "${${prefix}_TAG}-${${prefix}_BRANCH}")
    ELSEIF(${${prefix}_EMPTY})
        # branch available, but we have to provide an empty one.
        # Delete it
        MESSAGE(STATUS "Branch \"v${${prefix}_TAG}-${${prefix}_BRANCH}\" available. Deleting and recreating it.")
        SET(${prefix}_COMMAND "${GIT_EXECUTABLE}" "branch" "-D" "${${prefix}_TAG}-${${prefix}_BRANCH}")
        EXECUTE_PROCESS(COMMAND ${${prefix}_COMMAND}
                        WORKING_DIRECTORY "${${prefix}_WORKING_DIR}"
                        RESULT_VARIABLE ${prefix}_RESULT
                        ERROR_VARIABLE ${prefix}_ERROR
                        OUTPUT_VARIABLE ${prefix}_OUTPUT
                        OUTPUT_STRIP_TRAILING_WHITESPACE)
        IF(NOT ${${prefix}_RESULT} EQUAL 0)
            MESSAGE(STATUS "Command '" ${${prefix}_COMMAND} "' in directory ${${prefix}_WORKING_DIR} failed (${${prefix}_RESULT}) with output:\n${${prefix}_ERROR}")
            SET("${_prefix}_READY" false PARENT_SCOPE)
            RETURN()
        ENDIF()
        # Recreate branch
        SET(${prefix}_COMMAND "${GIT_EXECUTABLE}" "checkout" "${${prefix}_TAG}" "-b" "${${prefix}_TAG}-${${prefix}_BRANCH}")
    ELSE()
        # branch available.
        MESSAGE(STATUS "Branch \"${${prefix}_BRANCH}\" available. Reusing it.")
        SET(${prefix}_COMMAND "${GIT_EXECUTABLE}" "checkout" "${${prefix}_TAG}-${${prefix}_BRANCH}")
    ENDIF()
    EXECUTE_PROCESS(COMMAND ${${prefix}_COMMAND}
                    WORKING_DIRECTORY "${${prefix}_WORKING_DIR}"
                    RESULT_VARIABLE ${prefix}_RESULT
                    ERROR_VARIABLE ${prefix}_ERROR
                    OUTPUT_VARIABLE ${prefix}_OUTPUT
                    OUTPUT_STRIP_TRAILING_WHITESPACE)
    IF(NOT ${${prefix}_RESULT} EQUAL 0)
        MESSAGE(STATUS "Command '" ${${prefix}_COMMAND} "' in directory ${${prefix}_WORKING_DIR} failed (${${prefix}_RESULT}) with output:\n${${prefix}_ERROR}")
        SET("${_prefix}_READY" false PARENT_SCOPE)
        RETURN()
    ENDIF()

    SET("${prefix}_READY" true PARENT_SCOPE)

ENDFUNCTION(GIT_BRANCH)


#! @brief Reset branch to branch of origin.
#!
#! @param GIT_DIR <directory> Directory the git repository is in.
#! @param BRANCH <branch> The branch of the origin repository to track.
#! @param PREFIX <prefix> Prefix to use for return variables. Defaults to function name.
#! @return <prefix>_READY true in case the branch is now reset to origin/<branch>.
FUNCTION(GIT_BRANCH_RESET_TO_ORIGIN)
    MESSAGE(STATUS "GIT_BRANCH_RESET_TO_ORIGIN called: ${ARGN}.")

    #-------------------- parse function arguments -------------------

    set(DEFAULT_ARGS)
    set(prefix "GIT_BRANCH_RESET_TO_ORIGIN")
    set(arg_names "GIT_DIR;BRANCH")
    set(option_names)
    
    # Override default prefix if requested
    LIST(FIND ARGN "PREFIX" is_arg_name)
    IF(is_arg_name GREATER -1)
        MATH(EXPR is_arg_value "${is_arg_name} + 1")
        LIST(GET ARGN ${is_arg_value} prefix)
        LIST(REMOVE_AT ARGN ${is_arg_name} ${is_arg_value})
    ENDIF(is_arg_name GREATER -1)

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

    # -- Move branch to origin/<branch>
    SET(${prefix}_COMMAND "${GIT_EXECUTABLE}" "update-ref" "refs/heads/${${prefix}_BRANCH}" "origin/${${prefix}_BRANCH}")
    SET(${prefix}_WORKING_DIR "${${prefix}_GIT_DIR}")
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
    SET(${prefix}_WORKING_DIR "${${prefix}_GIT_DIR}")
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

ENDFUNCTION(GIT_BRANCH_RESET_TO_ORIGIN)


#! @brief Patch a git repository with a list of patches
#!
#! @param GIT_DIR <directory> Directory of the git repository.
#! @param PATCHES <list of patches> List of patches to be applied.
#! @param COMMIT_MSG <msg> Message for git commit of applied patches.
#! @param PREFIX <prefix> Prefix to use for return variables. Defaults to function name.
#! @return <prefix>_READY true in case the repository was patched.
FUNCTION(GIT_PATCH)
    MESSAGE(STATUS "GIT_PATCH called: ${ARGN}.")

    #-------------------- parse function arguments -------------------
    
    SET(prefix GIT_PATCH)
    SET(options)
    SET(one_value_args GIT_DIR COMMIT_MSG)
    SET(multi_value_args PATCHES)

    FUNCTION_PARSE_ARGUMENTS("${prefix}" "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN} )

    #------------------- finished parsing arguments --------------------

    
    SET(${prefix}_WORKING_DIR "${${prefix}_GIT_DIR}")
    
    # Check patch commit already available.
    SET(${prefix}_PATCHSET_COMMITS)
    SET(${prefix}_COMMAND "${GIT_EXECUTABLE}" "log" "--grep" "${${prefix}_COMMIT_MSG}")
    EXECUTE_PROCESS(COMMAND ${${prefix}_COMMAND}
                    WORKING_DIRECTORY "${${prefix}_WORKING_DIR}"
                    RESULT_VARIABLE ${prefix}_RESULT
                    ERROR_VARIABLE ${prefix}_ERROR
                    OUTPUT_VARIABLE ${prefix}_OUTPUT
                    OUTPUT_STRIP_TRAILING_WHITESPACE)
    MESSAGE(STATUS "Command '" ${${prefix}_COMMAND} "' in directory ${${prefix}_WORKING_DIR} returns (${${prefix}_RESULT}) with output:\n${${prefix}_ERROR}")
    STRING(REGEX MATCHALL "${${prefix}_COMMIT_MSG}[^ \t\r\n]*" ${prefix}_PATCHSET_COMMITS "${${prefix}_OUTPUT}")
    LIST(REMOVE_DUPLICATES ${prefix}_PATCHSET_COMMITS) # LIST(FIND ...) does not work on multiple duplicates.
    MESSAGE(STATUS "${prefix}_PATCHSET_COMMITS: '${${prefix}_PATCHSET_COMMITS}'")
    LIST(FIND ${prefix}_PATCHSET_COMMITS "${${prefix}_COMMIT_MSG}" ${prefix}_PATCHSET_APPLIED)
    IF(NOT (${${prefix}_PATCHSET_APPLIED} EQUAL -1))
        MESSAGE(STATUS "Patchset '${${prefix}_COMMIT_MSG}' already applied.")
        SET(${prefix}_READY true PARENT_SCOPE)
        RETURN()
    ENDIF()
    
    # -- Apply patches
    FOREACH(PATCH ${${prefix}_PATCHES})
        # Apply single patch of patches
        SET(${prefix}_COMMAND "${GIT_EXECUTABLE}" "am" "-3" "-q" "${PATCH}")
        EXECUTE_PROCESS(COMMAND ${${prefix}_COMMAND}
                        WORKING_DIRECTORY "${${prefix}_WORKING_DIR}"
                        RESULT_VARIABLE ${prefix}_RESULT
                        ERROR_VARIABLE ${prefix}_ERROR
                        OUTPUT_VARIABLE ${prefix}_OUTPUT
                        OUTPUT_STRIP_TRAILING_WHITESPACE)
        IF(NOT ${${prefix}_RESULT} EQUAL 0)
            MESSAGE(STATUS "Command '" ${${prefix}_COMMAND} "' in directory ${${prefix}_WORKING_DIR} failed (${${prefix}_RESULT}) with output:\n${${prefix}_ERROR}")
            SET(${prefix}_READY false PARENT_SCOPE)
            RETURN()
        ENDIF()
        MESSAGE(STATUS "Patch \"${PATCH}\" applied!")
    ENDFOREACH()

    # Commit patches
    SET(GIT_PATCH_COMMAND "${GIT_EXECUTABLE}" "commit" "--allow-empty" "-a" "-m" "${GIT_PATCH_COMMIT_MSG}")
    EXECUTE_PROCESS(COMMAND ${GIT_PATCH_COMMAND}
                    WORKING_DIRECTORY "${GIT_PATCH_WORKING_DIR}"
                    RESULT_VARIABLE GIT_PATCH_RESULT
                    ERROR_VARIABLE GIT_PATCH_ERROR
                    OUTPUT_VARIABLE GIT_PATCH_OUTPUT
                    OUTPUT_STRIP_TRAILING_WHITESPACE)
    IF(NOT ${GIT_PATCH_RESULT} EQUAL 0)
        MESSAGE(STATUS "Command '" ${GIT_PATCH_COMMAND} "' in directory ${GIT_PATCH_WORKING_DIR} failed (${GIT_PATCH_RESULT}) with output:\n${GIT_PATCH_ERROR}")
        SET(${prefix}_READY false PARENT_SCOPE)
        RETURN()
    ENDIF()

    SET(${prefix}_READY true PARENT_SCOPE)

ENDFUNCTION(GIT_PATCH)



#! @brief Patch git repository with a list of patches from patch directories
#!
#! Patchset directories are expected to be named xxxx-<patchset name>-patchset. 
#! The commit for a patchset will be named <header>-<patchset_name>.
#!
#! The patchsets will be applied as given by the PATCHSETS list. No sorting will be done.
#!
#! @param GIT_DIR <directory> Directory where the kernel is in.
#! @param COMMIT_MGS_HEADER <text> Header for all commit messages. Will be combined
#!                          with the patch set directory name to build up the commit message for a patch set.
#! @param PATCHSETS <list of directories> List of directories that contain patches to be applied.
#! @return GIT_PATCH_SET_READY true in case the git repository was patched.
FUNCTION(GIT_PATCH_SET)
    MESSAGE(STATUS "GIT_PATCH_SET called: ${ARGN}.")

    #-------------------- parse function arguments -------------------
    
    SET(prefix GIT_PATCH_SET)
    SET(options)
    SET(one_value_args GIT_DIR COMMIT_MSG_HEADER)
    SET(multi_value_args PATCHSETS)

    FUNCTION_PARSE_ARGUMENTS("${prefix}" "${options}" "${one_value_args}" "${multi_value_args}" ${ARGN} )

    #------------------- finished parsing arguments --------------------

    SET(${prefix}_WORKING_DIR "${${prefix}_GIT_DIR}")

    # -- Apply patchsets
    FOREACH(PATCHSET_DIR ${${prefix}_PATCHSETS})
        # Patchset name is directory name (without leading number(0001-) and trailing -patchset)
        GET_FILENAME_COMPONENT(${prefix}_PATCHSET "${PATCHSET_DIR}" NAME)
        STRING(REGEX REPLACE "[ -]*patchset$" "" ${prefix}_PATCHSET "${${prefix}_PATCHSET}")
        STRING(REGEX REPLACE "^[0-9]+[ -]*" "" ${prefix}_PATCHSET "${${prefix}_PATCHSET}")
        SET(${prefix}_PATCHSET_COMMIT_MSG "${${prefix}_COMMIT_MGS_HEADER}-${${prefix}_PATCHSET}")
        FILE(GLOB ${prefix}_PATCHES "${PATCHSET_DIR}/*.patch")
        LIST(SORT ${prefix}_PATCHES)
        #  Apply patches
        SET(${prefix}_COMMAND PATCHES "${${prefix}_PATCHES}"
                              GIT_DIR "${${prefix}_GIT_DIR}"
                              COMMIT_MSG "${${prefix}_PATCHSET_COMMIT_MSG}")
        GIT_PATCH(${${prefix}_COMMAND})
        IF(NOT GIT_PATCH_READY)
            MESSAGE(STATUS "GIT_PATCH '" ${${prefix}_COMMAND} "' failed (${GIT_PATCH_READY})!")
            SET(${prefix}_READY false PARENT_SCOPE)
            RETURN()
        ENDIF()
    ENDFOREACH()

    SET(${prefix}_READY true PARENT_SCOPE)

ENDFUNCTION(GIT_PATCH_SET)

#! @} sil2linuxmp-cmake

