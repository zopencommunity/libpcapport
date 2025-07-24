#!/bin/bash

# Script to generate the diff files/patches from libpcap repo to be committed to the libpcapport repo
# Steps
# 1. Apply all the patches and generate libpcap repo using zopen build command
# 2. Commit the files modified by applying patches. Dev/bug fix changes should be done on top of this commit
# 3. Once changes are ready, create new commit(s)
# 4. Use this script to generate patch for files modified in step 3

echo_error()
{
    echo "ERROR: $1"
}

run_checks()
{
    if [ ! -d ${LIBPCAP_DIR} ]
    then
        echo_error "${LIBPCAP_DIR} does not exist"
        exit
    fi

    if [ ! -d ${LIBPCAP_PORT_DIR} ]
    then
        echo_error "${LIBPCAP_PORT_DIR} does not exist"
        exit
    fi

    if [[ -z ${BASE_COMMIT} || -z ${PATCHED_COMMIT} || -z ${CURRENT_COMMIT} ]]
    then
        echo_error "BASE_COMMIT, PATCHED_COMMIT and CURRENT_COMMIT needed but not set"
        exit
    fi
}

# Generate patches for the first time after running zopen generate
gen_patches_first_time()
{
    MODIFIED_FILES=$(git diff-tree --no-commit-id --name-only ${BASE_COMMIT} ${CURRENT_COMMIT} -r)
    
    echo "Modified files:" 
    echo "{MODIFIED_FILES}"
    
    for file in ${MODIFIED_FILES}
    do
        echo "Generating diff for ${file}"
    
        #Save the patch files to libpcapport/patches/
        PATCH_FILE=${LIBPCAP_PORT_DIR}/patches/${file}.patch
        PATCH_FILE_DIR=$(dirname ${PATCH_FILE})
    
        if [ ! -d ${PATCH_FILE_DIR} ]
        then
            echo "${PATCH_FILE_DIR} does not exist, creating one"
    	    mkdir -p ${PATCH_FILE_DIR}
        fi
    
        if [ -f ${PATCH_FILE} ]
        then
            echo "WARNING: ${PATCH_FILE} already exist, contents will be overwritten"
        fi
    
        #Generate patch file
        git diff ${BASE_COMMIT} -- ${file} > ${PATCH_FILE}
    
        #Add the file to the staging area
        cd ${LIBPCAP_PORT_DIR} ; git add ${PATCH_FILE} ; cd - 
    done
}

gen_patches()
{
    MODIFIED_FILES=$(git diff-tree --no-commit-id --name-only ${PATCHED_COMMIT} ${CURRENT_COMMIT} -r)
    
    echo "Modified files:" 
    echo "{MODIFIED_FILES}"
    
    for file in ${MODIFIED_FILES}
    do
        echo "Generating diff for ${file}"
    
        #Save the patch files to libpcapport/patches/
        PATCH_FILE=${LIBPCAP_PORT_DIR}/patches/${file}.patch
        PATCH_FILE_DIR=$(dirname ${PATCH_FILE})
    
        if [ ! -d ${PATCH_FILE_DIR} ]
        then
            echo "${PATCH_FILE_DIR} does not exist, creating one"
    	    mkdir -p ${PATCH_FILE_DIR}
        fi
    
        if [ -f ${PATCH_FILE} ]
        then
            echo "WARNING: ${PATCH_FILE} already exist, contents will be overwritten"
        fi
    
        #Generate patch file
        git diff ${BASE_COMMIT} -- ${file} > ${PATCH_FILE}
    
        #Add the file to the staging area
        cd ${LIBPCAP_PORT_DIR} ; git add ${PATCH_FILE} ; cd - 
    done


}

LIBPCAP_DIR=${LIBPCAP_DIR}                          # Path to libpcap repo
LIBPCAP_PORT_DIR=${LIBPCAP_PORT_DIR}                # Path to libpcapport repo
BASE_COMMIT=8a7a9cc527fd1d6d8664315d3bed47c4259479cc      # libpcap gets cloned with this latest commit
PATCHED_COMMIT=6ef2e294b086ab3592f080a9ff7f3fcf8bbfecfa   # Run zopen build to apply all the patches in libpcapport
CURRENT_COMMIT=5981282d96c4ed9b000a91a838f63e4c73836c11   # Commit with further dev changes

## main() STARTS HERE ##
echo "LIBPCAP_DIR      ${LIBPCAP_DIR}"
echo "LIBPCAP_PORT_DIR ${LIBPCAP_PORT_DIR}"
echo "BASE_COMMIT         ${BASE_COMMIT}"
echo "PATCHED_COMMIT      ${PATCHED_COMMIT}"
echo "CURRENT_COMMIT      ${CURRENT_COMMIT}"

run_checks

pushd ${LIBPCAP_DIR}

# Generate patches for the first time after running zopen generate
#gen_patches_first_time

# Generate patches later
gen_patches

popd
