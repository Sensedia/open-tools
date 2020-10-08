#!/bin/bash

#------------------------------------------------------------
# Default function to general use
# Do nothing. Just define functions.
# Load with ". ./lib.sh"
#------------------------------------------------------------


#--------------------------------------------------------
# comment: Retries a command on failure.
# sintax:
# retry number_attempts command
#
# Example:
# retry 5 ls -ltr foo
#
# Font: http://fahdshariff.blogspot.com/2014/02/retrying-commands-in-shell-scripts.html
function retry() {

# Creates a read-only local variable of integer type
local -r -i max_attempts="$1"; shift
# Create a read-only local variable
local -r command="$@"
# Create a local variable of integer type 
local -i attempt_num=1
local -i time_seconds=30


until $command; do
    if (( attempt_num == max_attempts )); then
        echo "[ERROR] Attempt $attempt_num failed and there are no more attempts left!"
        return 1
    else
        echo "[WARNING] Attempt $attempt_num failed! Trying again in $time_seconds seconds..."
        sleep $time_seconds
    fi
done

}


#--------------------------------------------------------
# comment: Test that kubectl can correctly communication with the Kubernetes API
# sintax:
# testAccessKubernetes
#
# return: 0 is correct or code error
#
# Example:
# testAccessKubernetes
#
# Font: https://github.com/judexzhu/Jenkins-Pipeline-CI-CD-with-Helm-on-Kubernetes/blob/master/Jenkinsfile
function testAccessKubernetes() {

echo "[INFO] Testing if kubectl command can correctly communication with the Kubernetes API"
kubectl cluster-info
kubectl get nodes

return $?
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



#------------------------------------------------------------
# comment: Check if file existis. 
# syntax: existfiles file [file ...]
#
existfiles(){

# echo --
# echo FILES=$@
OK=YES
for file in "$@" ; do
    if [ ! -f "$file" ] ; then
        echo "[ERROR] File '$file' not found."
        OK=NO
        exit 1
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
    exit 3
fi

}
