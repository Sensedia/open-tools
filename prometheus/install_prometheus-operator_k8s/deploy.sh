#!/bin/bash

#------------------------
# Sensedia
# Authors: Victor Ribeiro and Aecio Pires
# Date: 13 jan 2020
#
# Objective: Install or upgrade Prometheus Operator in clusters Kubernetes
#
#--------------------- REQUISITES --------------------#

#------------------------
# Local Functions


#--------------------------------------------------------
# comment: Print usage help
# usage: usage
#
function usage() {

echo "Script to install or upgrade Prometheus Operator in clusters Kubernetes"
echo "Usage:"
echo " "
echo "$0 <install|upgrade> <aws|gcp> <testing|staging|production> <cluster_name>"
}


#--------------------------------------------------------
# comment: Install a helm release of prometheus-operator
# usage: install_prometheus_operator
#
function install_prometheus_operator() {

# Disable create resource CRD
# https://github.com/helm/charts/issues/19452

    helm secrets install $APP_NAME \
    $HELM_REPO_NAME/$HELM_CHART_NAME \
    --version $CHART_VERSION \
    --namespace $NAMESPACE \
    $DEBUG_DEPLOY \
    $SKIP_CRD \
    -f $DEFAULT_VALUES \
    -f $CLOUD_VALUES \
    -f $CLUSTER_VALUES
}

#--------------------------------------------------------
# comment: Upgrade a helm release of prometheus-operator
# usage: upgrade_prometheus_operator
#
function upgrade_prometheus_operator() {

    helm secrets upgrade $APP_NAME \
    $HELM_REPO_NAME/$HELM_CHART_NAME \
    --version $CHART_VERSION \
    --namespace $NAMESPACE \
    $DEBUG_DEPLOY \
    $SKIP_CRD \
    -f $DEFAULT_VALUES \
    -f $CLOUD_VALUES \
    -f $CLUSTER_VALUES
}

#--------------------------------------------------------


#------------------------
# Variables
HELM_DIR='./helm_vars'
KUBE_DIR='./kube-manifests'
COMMAND=$1
CLOUD=$2
ENVIRONMENT=$3
CLUSTER=$4
NAMESPACE='monitoring'
SEND_VICTORIAMETRICS=true
# Uncomment next line to disable debug mode during deploy
#DEBUG_DEPLOY=''
# Uncomment next line to enable debug mode during deploy
DEBUG_DEPLOY='--debug'
# Uncomment next line to disable install crd
#SKIP_CRD='--skip-crds'
# Uncomment next line to enable install crd
SKIP_CRD=''

#--- Version new of chart
#    https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack
HELM_REPO_NAME='prometheus-community'
HELM_REPO_URL='https://prometheus-community.github.io/helm-charts'
HELM_CHART_NAME='kube-prometheus-stack'
CHART_VERSION='40.1.0'

APP_NAME='monitor'
NAMESPACE='monitoring'
# Use true to add helm repo always, use false to don't install helm repo
ADD_HELM_REPO=true

# File with config values
DEFAULT_VALUES="$HELM_DIR/values.yaml"
CLOUD_VALUES="$HELM_DIR/${CLOUD,,}/values.yaml"
CLUSTER_VALUES="$HELM_DIR/${CLOUD,,}/${ENVIRONMENT,,}/${CLUSTER,,}.yaml"

PROGPATHNAME=$BASH_SOURCE
PROGFILENAME=$(basename $PROGPATHNAME)
PROGDIRNAME=$(dirname $PROGPATHNAME)
LIB_FILE="${PROGDIRNAME}/lib.sh"
DEBUG=true
_DEBUG_COMMAND="on"
#------------------------


# Load script with our libs and defaults functions
[ -x $PROGDIRNAME/lib.sh ] && . $PROGDIRNAME/lib.sh 

# Testing if variable is empty
checkVariable COMMAND "$COMMAND"
checkVariable CLOUD "$CLOUD"
checkVariable ENVIRONMENT "$ENVIRONMENT"
checkVariable CLUSTER "$CLUSTER"

# Testing if commands existis
checkCommand git kubectl helm sops

# Check if cloud provider is supported
case ${CLOUD,,} in
    aws|gcp)
    ;;
    *)
        echo "[ERROR] Wrong value for cloud argument."
        usage
        exit 3
    ;;
esac


# Check if environment is supported
case ${ENVIRONMENT,,} in
    testing|staging|production)
    ;;
    *)
        echo "[ERROR] Wrong value for environment argument."
        usage
        exit 3
    ;;
esac

# Testing if files existis
existfiles $DEFAULT_VALUES $CLOUD_VALUES $CLUSTER_VALUES

if $ADD_HELM_REPO ; then
    echo "[INFO] Add Helm repo '$HELM_REPO_NAME'"
    helm repo add $HELM_REPO_NAME $HELM_REPO_URL
fi

helm repo update

echo "[INFO] Testing access a kubernetes cluster."
if ``kubectl cluster-info > /dev/null 2>&1``; then
    CONTEXT_NAME=$(kubectl config current-context)
else
    echo "[ERROR] Failed to access a Kubernetes cluster. Make sure to connect to a cluster before running the script."
    usage
fi

SHORT_CLUSTER_NAME=$(echo $CONTEXT_NAME | grep -o $CLUSTER)
SHORT_CLUSTER_VALUES=$(basename $CLUSTER_VALUES | cut -d'.' -f1)

if [ "$DEBUG" == true ]; then
    echo "[DEBUG] INIT -------------"
    echo "[DEBUG] CONTEXT_NAME         => $CONTEXT_NAME"
    echo "[DEBUG] CLUSTER              => $CLUSTER"
    echo "[DEBUG] NAMESPACE            => $NAMESPACE"
    echo "[DEBUG] CLUSTER_VALUES       => $CLUSTER_VALUES"
    echo "[DEBUG] SHORT_CLUSTER_VALUES => $SHORT_CLUSTER_VALUES"
    echo "[DEBUG] Helm plugins installed..."
    helm plugin list
    echo "[DEBUG] END"
fi

# Check if user is logged in correct cluster
if [ "$SHORT_CLUSTER_NAME" != "$SHORT_CLUSTER_VALUES" ]; then
    MESSAGE="[ERROR] Connect in correct cluster: \"$SHORT_CLUSTER_VALUES\""
    printRedMessage "$MESSAGE"
    exit 1
fi

# Create namespace if not exists
createNameSpace "$NAMESPACE"

# Execute command to deploy or upgrade helm release of prometheus-operator
case ${COMMAND,,} in
    install)
        kubectl create ns $NAMESPACE

        install_prometheus_operator
        ;;
    upgrade)
        upgrade_prometheus_operator
        ;;
    *)
        echo "[ERROR] Wrong command."
        usage
        exit 3
    ;;
esac
