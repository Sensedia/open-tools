#!/bin/bash

#------------------------
# Authors: Aecio Pires
# Date: 13 jan 2020
#
# Objective: Update git repositories local
#
#--------------------- REQUISITES --------------------#
#  1) Install packages: git
#
#------------------------


#------------------------
# Local Functions

#--------------------------------------------------------
# comment: Print usage help.
# sintax: usage
#
function usage() {

echo "Script to update git repositories local."
echo "Usage:"
echo " "
echo "$0 DIR_GIT_BASE"
exit 3
}

#--------------------------------------------------------
# comment: Check if existis command
# sintax:
# checkCommand command1 command2 command3
#
# return: 0 is correct or code error
#
# Example:
# checkCommand git kubectl helm
function checkCommand() {

local commands="$@"

for command in $commands ; do
    if ! type $command > /dev/null 2>&1; then 
        echo "[ERROR] Command '$command' not found."
        exit 4
    fi
done

}

#--------------------------------------------------------
# comment: Check if a variable is empty
# sintax:
# checkVariable name value
#
# return: 0 is correct or code error
#
# Example:
# checkVariable "variable1" "value1"
function checkVariable() {

local variable_name="$1"; 
local value="$2"; 

if [ -z $value ] ; then 
    echo "[ERROR] The variable $variable_name is empty."
    # The function usage must create in script main
    usage
    return 1
fi

}


#------------------------
# Variables

DEBUG=true
PROGPATHNAME=$0
PROGFILENAME=$(basename $PROGPATHNAME)
PROGDIRNAME=$(dirname $PROGPATHNAME)

DIR_GIT_BASE=$1
#------------------------

# Testing if variable is empty
checkVariable DIR_GIT_BASE "$DIR_GIT_BASE"

# Testing if commands existis
checkCommand git find


if [ -d "$DIR_GIT_BASE" ]; then
    cd "$DIR_GIT_BASE" >/dev/null 2>&1 ;
    LIST_DIR_GIT_REPOSITORIES=$(find . -maxdepth 1 -mindepth 1 -type d)
    for dir in $LIST_DIR_GIT_REPOSITORIES; do
        if [ -d $dir/.git ] ; then
            cd $dir >/dev/null 2>&1 ;
            BRANCH_NAME=$(git symbolic-ref HEAD | cut -d/ -f3-)
            echo "[INFO]BEGIN ---------------------------"
            echo "[INFO] Updating dir: '$dir' in branch '$BRANCH_NAME'.
            If necessary, enter with login/password."
            echo "..."
            git pull
            echo "."
            echo "."
            echo "."
            cd - >/dev/null 2>&1 ;
        else
            echo "[ERROR] Dir '$dir' isn't git local repository."
        fi
    done
else
    echo "[ERROR] Dir '$DIR_GIT_BASE' is not exists."
    exit 1
fi
