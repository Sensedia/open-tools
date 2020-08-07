#!/bin/bash

#------------------------
# Sensedia
# Authors: Aecio Pires
# Date: 04 ago 2020
#
# Objective: List k8s hardware resources (limits and requests)
#
# References:
#
# https://github.com/kubernetes/kubernetes/issues/17512
# https://github.com/amelbakry/kubernetes-scripts
# https://github.com/robscott/kube-capacity
# https://github.com/eht16/kube-cargo-load
# https://github.com/dpetzold/kube-resource-explorer/
#
#--------------------- REQUISITES --------------------#
#  1) Required packages:
#
#  kubectl:
#  https://kubernetes.io/docs/tasks/tools/install-kubectl/
#
# 2) Authenticate access to a kubernetes cluster
#
#------------------------


#---------------------------
# Local Generic Functions
#---------------------------

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
    echo
    # The function usage must create in script main
    usage
fi
}

#--------------------------------------------------------
# comment: Count lines of file
# sintax:
# countLines file
function countLines() {

local file="$1";
local lines=$(wc -l $file | cut -d " " -f1) 

echo $lines
}

#--------------------------------------------------------
# comment: Testing if value is number
# sintax:
# isNumber value
function isNumber() {

local value="$1"; 

if [ ! "$value" == "$(echo $value | tr -dc '[0-9]')" ]; then
    echo "[ERROR] Variable 'NODES_NUMBER' is not number";
    usage
fi

}



#------------------------------------------------------
#------------------------------------------------------
# Local Specific Functions
#------------------------------------------------------
#------------------------------------------------------


#--------------------------------------------------------
# comment: Print usage help
# usage: usage
#
function usage() {

echo
echo "List k8s hardware resources (limits and requests)"
echo
echo "Usage:"
echo
echo "$0 [ACTION]"
echo
echo " Requisite: Make sure to connect to a cluster before running the script."
echo
echo "Actions available:"
echo
echo "---"
echo "$OPTION_ACTION"
echo "---"
exit 3
}

#--------------------------------------------------------
# comment: List top pods number CPU
# usage: topPodsCPU number_pods
#
function topPodsCPU() {

local NUMBER="$1"
NUMBER=$((NUMBER + 1))

$BIN_KUBECTL top pod --all-namespaces --sort-by 'cpu' | head -n $NUMBER

}

#--------------------------------------------------------
# comment: List top pods number memory
# usage: topPodsMemory number_pods
#
function topPodsMemory() {

local NUMBER="$1"
NUMBER=$((NUMBER + 1))

$BIN_KUBECTL top pod --all-namespaces --sort-by 'memory' | head -n $NUMBER

}



#--------------------------------------------------------
# comment: Sort nodes by CPU usage
# usage: topNodesCPU number_nodes
#
function topNodesCPU() {

local NUMBER="$1"
NUMBER=$((NUMBER + 1))
$BIN_KUBECTL top nodes --no-headers=false --sort-by='cpu' | head -n $NUMBER

}



#--------------------------------------------------------
# comment: Sort nodes by memory usage
# usage: topNodesMemory number_nodes
#
function topNodesMemory() {

local NUMBER="$1"
NUMBER=$((NUMBER + 1))

$BIN_KUBECTL top nodes --no-headers=false --sort-by='memory' | head -n $NUMBER

}

#--------------------------------------------------------
# comment: List nodes
# usage: listNodes
#
function listNodes() {

$BIN_KUBECTL get nodes -o wide || usage

}

#--------------------------------------------------------
# comment: List number nodes
# usage: listNumberNodes
#
function listNumberNodes() {

local NODES=$($BIN_KUBECTL get nodes --no-headers=true | wc -l)
echo "[OK] The kubernetes cluster has '$NODES' nodes."

}

#--------------------------------------------------------
# comment: List number pods in all namespaces
# usage: listNumberPods
#
function listNumberPods() {

local PODS=$($BIN_KUBECTL get pods --all-namespaces --no-headers=true | wc -l)
echo "[OK] The kubernetes cluster has '$PODS' pods."

}


#--------------------------------------------------------
# comment: List resources used of nodes by pods
# usage: describeResourcesNodesByPods
#
function describeResourcesNodesByPods() {

local NODES_NAME=$($BIN_KUBECTL get node --no-headers -o custom-columns=NAME:.metadata.name)

for node in $NODES_NAME; do
    echo "Node: $node"
    $BIN_KUBECTL describe node "$node" | sed '1,/Non-terminated Pods/d' || usage
    echo
done

}

#--------------------------------------------------------
# comment: List resources CPU and memory of
# usage: listCPUAndMemoryNodes
#
function listCPUAndMemoryNodes() {

local NODES_NAME=$($BIN_KUBECTL get node --no-headers -o custom-columns=NAME:.metadata.name)
local NODE_COUNT=0
local TOTAL_PERCENT_CPU_REQUEST=0
local TOTAL_PERCENT_MEMORY_REQUEST=0
local TOTAL_PERCENT_CPU_LIMIT=0
local TOTAL_PERCENT_MEMORY_LIMIT=0
local TOTAL_ABSOLUTE_CPU_REQUEST=0
local TOTAL_ABSOLUTE_MEMORY_REQUEST=0
local TOTAL_ABSOLUTE_CPU_LIMIT=0
local TOTAL_ABSOLUTE_MEMORY_LIMIT=0

#$BIN_KUBECTL get nodes --no-headers | awk '{print $1}' | xargs -I {} sh -c " echo {} ; $BIN_KUBECTL describe node {} | grep Allocated -A 5 | grep -ve Event -ve Allocated -ve percent -ve -- ; echo "

for node in $NODES_NAME; do
    local CPU_INFO=$($BIN_KUBECTL describe node $node | grep -A2 -E "Resource" | tail -n1)
    local MEMORY_INFO=$($BIN_KUBECTL describe node $node | grep -A3 -E "Resource" | tail -n1)

    local PERCENT_CPU_REQUEST=$(echo $CPU_INFO | awk -F "[()%]" '{print $2}')
    local ABSOLUTE_CPU_REQUEST=$(echo $CPU_INFO | cut -d'm' -f1 | tr -s ' ' | cut -d' ' -f2)
    local PERCENT_MEMORY_REQUEST=$(echo $MEMORY_INFO | awk -F "[()%]" '{print $2}')
    local ABSOLUTE_MEMORY_REQUEST=$(echo $MEMORY_INFO | cut -d'M' -f1 | tr -s ' ' | cut -d' ' -f2)

    local PERCENT_CPU_LIMIT=$(echo $CPU_INFO | awk -F "[()%]" '{print $5}')
    local ABSOLUTE_CPU_LIMIT=$(echo $CPU_INFO | cut -d'm' -f2 | tr -s ' ' | cut -d' ' -f3)
    local PERCENT_MEMORY_LIMIT=$(echo $MEMORY_INFO | awk -F "[()%]" '{print $5}')
    local ABSOLUTE_MEMORY_LIMIT=$(echo $MEMORY_INFO | cut -d'M' -f2 | tr -s ' ' | cut -d' ' -f3)

    echo "$node"
    echo "requests: ${ABSOLUTE_CPU_REQUEST} (${PERCENT_CPU_REQUEST}%) CPU, ${ABSOLUTE_MEMORY_REQUEST}Mi (${PERCENT_MEMORY_REQUEST}%) memory"
    echo "limits: ${ABSOLUTE_CPU_LIMIT} (${PERCENT_CPU_LIMIT}%) CPU, ${ABSOLUTE_MEMORY_LIMIT}Mi (${PERCENT_MEMORY_LIMIT}%) memory"
    echo

    NODE_COUNT=$((NODE_COUNT + 1))
    TOTAL_PERCENT_CPU_REQUEST=$((TOTAL_PERCENT_CPU_REQUEST + PERCENT_CPU_REQUEST))
    TOTAL_ABSOLUTE_CPU_REQUEST=$((TOTAL_ABSOLUTE_CPU_REQUEST + ABSOLUTE_CPU_REQUEST))
    TOTAL_PERCENT_MEMORY_REQUEST=$((TOTAL_PERCENT_MEMORY_REQUEST + PERCENT_MEMORY_REQUEST))
    TOTAL_ABSOLUTE_MEMORY_REQUEST=$((TOTAL_ABSOLUTE_MEMORY_REQUEST + ABSOLUTE_MEMORY_REQUEST))

    TOTAL_PERCENT_CPU_LIMIT=$((TOTAL_PERCENT_CPU_LIMIT + PERCENT_CPU_LIMIT))
    TOTAL_ABSOLUTE_CPU_LIMIT=$((TOTAL_ABSOLUTE_CPU_LIMIT + ABSOLUTE_CPU_LIMIT))
    TOTAL_PERCENT_MEMORY_LIMIT=$((TOTAL_PERCENT_MEMORY_LIMIT + PERCENT_MEMORY_LIMIT))
    TOTAL_ABSOLUTE_MEMORY_LIMIT=$((TOTAL_ABSOLUTE_MEMORY_LIMIT + ABSOLUTE_MEMORY_LIMIT))
done

local AVG_PERCENT_CPU_REQUEST=$((TOTAL_PERCENT_CPU_REQUEST / NODE_COUNT))
local AVG_ABSOLUTE_CPU_REQUEST=$((TOTAL_ABSOLUTE_CPU_REQUEST / NODE_COUNT))
local AVG_PERCENT_MEMORY_REQUEST=$((TOTAL_PERCENT_MEMORY_REQUEST / NODE_COUNT))
local AVG_ABSOLUTE_MEMORY_REQUEST=$((TOTAL_ABSOLUTE_MEMORY_REQUEST / NODE_COUNT))

local AVG_PERCENT_CPU_LIMIT=$((TOTAL_PERCENT_CPU_LIMIT / NODE_COUNT))
local AVG_ABSOLUTE_CPU_LIMIT=$((TOTAL_ABSOLUTE_CPU_LIMIT / NODE_COUNT))
local AVG_PERCENT_MEMORY_LIMIT=$((TOTAL_PERCENT_MEMORY_LIMIT / NODE_COUNT))
local AVG_ABSOLUTE_MEMORY_LIMIT=$((TOTAL_ABSOLUTE_MEMORY_LIMIT / NODE_COUNT))

echo
echo "In cluster: '$CLUSTER_NAME'"
echo "Nodes: $NODE_COUNT"
echo "Average usage request: ${AVG_ABSOLUTE_CPU_REQUEST} (${AVG_PERCENT_CPU_REQUEST}%) CPU, ${AVG_ABSOLUTE_MEMORY_REQUEST}Mi (${AVG_PERCENT_MEMORY_REQUEST}%) memory."
echo "Average limit: ${AVG_ABSOLUTE_CPU_LIMIT} (${AVG_PERCENT_CPU_LIMIT}%) CPU, ${AVG_ABSOLUTE_MEMORY_LIMIT}Mi (${AVG_PERCENT_MEMORY_LIMIT}%) memory."

}




#------------------------
# Variables
#------------------------

# Variables general of script
PROGPATHNAME=$0
PROGFILENAME=$(basename $PROGPATHNAME)
PROGDIRNAME=$(dirname $PROGPATHNAME)
BIN_KUBECTL="/usr/bin/kubectl"
DEBUG=true
OPTION_ACTION=$(cat $PROGPATHNAME | grep -A5000 "LIST_ACTIONS_DONOT_REMOVE" | grep ")" | grep -v "*" | cut -d")" -f1 | grep -v \$0 | grep -v "(" )

# Variables of input
ACTION=$1
NUMBER_PODS=$2   # Used only top pod by CPU or memory
NUMBER_NODES=$2  # Used only top nodes by CPU or memory

AUX_FILE=$(mktemp)

#------------------------


#------------------------
# Main
#------------------------

# Check arguments
if [ $# -lt 1 ]; then
    usage
fi

# Testing if variable is empty
checkVariable ACTION "$ACTION"

# Testing if command exists
checkCommand $BIN_KUBECTL

echo "[INFO] Testing access a kubernetes cluster."
if ``$BIN_KUBECTL cluster-info > /dev/null 2>&1``; then
    CLUSTER_NAME=$($BIN_KUBECTL config current-context)
    listNumberNodes
    listNumberPods
else
    echo "[ERROR] Failed to access a Kubernetes cluster. Make sure to connect to a cluster before running the script."
    usage
fi

echo "[INFO] List k8s hardware resources of cluster '$CLUSTER_NAME'."

# Deploy according to the action
# [LIST_ACTIONS_DONOT_REMOVE]
case ${ACTION} in
    describeResourcesNodesByPods)
        describeResourcesNodesByPods
    ;;
    listCPUAndMemoryNodes)
        listCPUAndMemoryNodes
    ;;
    listNodes)
        listNodes
    ;;
    topPodsCPU)
        # Testing if variable is empty
        checkVariable NUMBER_PODS "$NUMBER_PODS"

        isNumber "$NUMBER_PODS"

        topPodsCPU "$NUMBER_PODS"
    ;;
    topPodsMemory)
        # Testing if variable is empty
        checkVariable NUMBER_PODS "$NUMBER_PODS"

        # Testing if value is number
        isNumber "$NUMBER_PODS"

        topPodsMemory "$NUMBER_PODS"
    ;;
    topNodesCPU)
        # Testing if variable is empty
        checkVariable NUMBER_PODS "$NUMBER_PODS"

        # Testing if value is number
        isNumber "$NUMBER_PODS"

        topNodesCPU "$NUMBER_NODES"
    ;;
    topNodesMemory)
        # Testing if variable is empty
        checkVariable NUMBER_PODS "$NUMBER_NODES"

        # Testing if value is number
        isNumber "$NUMBER_NODES"

        topNodesMemory "$NUMBER_NODES"
    ;;
    *)
        echo
        echo "[ERROR] Unsupported action yet."
        echo
        usage
    ;;
esac
