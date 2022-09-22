#!/bin/bash

#------------------------------------------------------------
# Default function to general use
# Do nothing. Just define functions.
# Load with ". ./lib.sh"
#------------------------------------------------------------


#--------------------------------------------------------
# comment: Retries a command on failure.
#
# sintax:
# retry number_attempts command
#
# Example:
# retry 5 ls -ltr foo
#
# Reference: http://fahdshariff.blogspot.com/2014/02/retrying-commands-in-shell-scripts.html
#
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

echo "[INFO] Test that kubectl can correctly communication with the Kubernetes API"
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
#
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
#
# sintax:
# checkVariable name value
#
# return: 0 is correct or code error
#
# Example:
# checkVariable "variable1" "value1"
#
function checkVariable() {

local variable_name="$1";
local value="$2";
local debug="${DEBUG}"

if [ -z $value ] ; then 
    echo "[ERROR] The variable $variable_name is empty."
    # The function usage must create in script main
    usage
    exit 3
else
    if [ "$debug" == true ]; then
        echo "[DEBUG] ${variable_name}: ${value}"
    fi
fi
}

#--------------------------------------------------------
# comment: Print error messages in red
#
# Reference: https://nick3499.medium.com/bash-echo-text-color-background-color-e8d8c41d5a91
#
# sintax:
# printRedMessage message
#
# Example:
# printRedMessage "Error Example"
#
function printRedMessage() {

local message="$1";

echo -e "\e[1;41m$message\e[0m"
}


#----------------------------------------------------
# comment: Converts lowercase letters to uppercase
# syntax: AUX=$(toupper $STRING)
# return: $AUX containing the uppercase string
#
function toupper(){

tr '[a-z]' '[A-Z]' <<< $*
}


#----------------------------------------------------
# comment: Converts uppercase letters to lowercase
# syntax: AUX=$(tolower $STRING)
# return: $AUX containing the lower case string
#
function tolower(){

echo $* | tr '[A-Z]' '[a-z]'
}

#------------------------------------------------------------
# comment: Execute the command and show in output (use for debug of commands)
# sintax:
#   debug COMMAND
# requirement: create variable _DEBUG_COMMAND.
#    Use the value 'on' for enable this funcion.
#    Use the value 'off' for disable this function
# Reference: https://www.cyberciti.biz/tips/debugging-shell-script.html
#
# how_to:
#
# Example 1:
# debug echo "File is $filename"
#
# Example 2:
# debug set -x
# Cmd1
# Cmd2
# debug set +x
#
function debug(){
    [ "$_DEBUG_COMMAND" == "on" ] && "$@"
}


#--------------------------------------------------------
# comment: Get current context in Kubernetes cluster
# sintax:
#   k8sGetCurrentContext
# return: k8s_context
function k8sGetCurrentContext() {

local k8s_context

k8s_context=$(kubectl config current-context)

echo "$k8s_context"
}


#--------------------------------------------------------
# comment: Unset current context in Kubernetes cluster
# sintax:
#   k8sUnsetCurrentContext
function k8sUnsetCurrentContext() {

local context

context=$(k8sGetCurrentContext)

echo "[INFO] Unset Kubernetes context: $context ..."

kubectl config unset current-context
}


#--------------------------------------------------------
# comment: Test access to Kubernetes cluster
# sintax:
#   testAccessKubernetes
# return: 0 is correct or code error
#
# Reference: https://github.com/judexzhu/Jenkins-Pipeline-CI-CD-with-Helm-on-Kubernetes/blob/master/Jenkinsfile
function testAccessKubernetes() {

local cluster_name
local result_code

echo "[INFO] Testing access a Kubernetes cluster..."
kubectl cluster-info > /dev/null 2>&1
result_code=$?

if [ "$result_code" -eq 0 ] ; then
    cluster_name=$(k8sGetCurrentContext)
    echo "[OK] CLUSTER_NAME=$cluster_name"
else
    echo "[ERROR] Failed to access a Kubernetes cluster. Make sure to connect to a cluster before running the script."
    exit 1
fi

return 0
}


#--------------------------------------------------------
# comment: Check Kubernetes Version
# sintax:
#   checkK8sVersion "${KUBERNETES_VERSION_SUPPORTED[@]}"
# return: 0 is correct or 1 is incorrect
#
function checkK8sVersion() {

local versions_supported=("$@")
local debug="${DEBUG}"

echo "[INFO] Check Kubernetes version..."
cluster_version=$(kubectl version --short 2> /dev/null | grep Server | cut -d":" -f2 | cut -d " " -f2)

if [ "$debug" == true ]; then
    echo "[DEBUG] KUBERNETES_VERSION_SUPPORTED: ${versions_supported[*]}"
fi

for substring in "${versions_supported[@]}"; do
    if [[ "$cluster_version" == *"${substring}"* ]]; then
        echo "[OK] Kubernetes version $cluster_version is supported!"
        return 0
    else
        if [ "$debug" == true ]; then
            echo
            echo "[WARNING] Kubernetes version $cluster_version is not compatible with '$substring'! Use Kubernetes ${versions_supported[*]}"
            echo
        fi
    fi
done

echo
echo "[ERROR] Kubernetes version $cluster_version is not supported! Use Kubernetes ${versions_supported[*]}"
echo
exit 7
}


#--------------------------------------------------------
# comment: Create name space if not exist
# sintax:
#   createNameSpace NAMESPACE
# return: 0 is correct or code error
#
# Reference: https://github.com/eldada/jenkins-pipeline-kubernetes/blob/master/Jenkinsfile
function createNameSpace() {

local namespace="$1";

ns_aux=$(kubectl get namespace $namespace --no-headers -o custom-columns=":metadata.name" 2> /dev/null)

if [ -z "${ns_aux}" ]; then
    echo
    kubectl create ns "$namespace"
    ns_aux2=$(kubectl get namespace $namespace --no-headers -o custom-columns=":metadata.name" 2> /dev/null)

    if [ -z "${ns_aux2}" ]; then
        echo
        echo "[ERROR] Problem to create namespace '$namespace'."
        exit 7
    fi
else
    echo "[INFO] Namespace '$namespace' exists."
fi

local result_code=$?

return $result_code
}

