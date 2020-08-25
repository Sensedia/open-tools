#!/bin/bash

#------------------------
# Authors: Aecio Pires
# Date: 24 ago 2020
#
# Objective: Migrate Docker images between GCR repositories
#
#--------------------- REQUISITES --------------------#
#  1) Install packages: docker gcloud
#
#------------------------


#------------------------
# Local Functions

#--------------------------------------------------------
# comment: Print usage help.
# sintax: usage
#
function usage() {

echo "Script to migrate Docker images between GCR repositories."
echo "Usage:"
echo " "
echo "$0 GCR_ORIGIN GCR_DESTINY"
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
    if ! type "$command" > /dev/null 2>&1; then 
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

if [ -z "$value" ] ; then 
    echo "[ERROR] The variable $variable_name is empty."
    # The function usage must create in script main
    usage
    return 1
fi

}


#------------------------
# Variables

DEBUG=false
PROGPATHNAME=$0
PROGFILENAME=$(basename $PROGPATHNAME)
PROGDIRNAME=$(dirname $PROGPATHNAME)

GCR_ORIGIN=$1
GCR_DESTINY=$2

GCLOUD='/usr/bin/gcloud'
#GCLOUD_SILENCE=' '
GCLOUD_SILENCE='--quiet'
#------------------------

# Testing if variable is empty
checkVariable GCR_ORIGIN "$GCR_ORIGIN"
checkVariable GCR_DESTINY "$GCR_DESTINY"

# Testing if commands existis
checkCommand $GCLOUD docker

$GCLOUD auth configure-docker gcr.io ;
if [ "$?" -ne "0" ]; then
    echo "[ERROR] Unable to authenticate to GCR."
    exit 6
fi

DOCKER_IMAGE_LIST=$($GCLOUD container images list --repository "$GCR_ORIGIN" | grep -v NAME)
if $DEBUG ; then
    echo "[DEBUG] IMAGE-LIST-INIT -------------"
    echo "Images:"
    echo "$DOCKER_IMAGE_LIST"
    echo "[DEBUG] IMAGE-LIST-END"
fi

for docker_image in $DOCKER_IMAGE_LIST; do
    TAG_LIST=$($GCLOUD container images list-tags "$docker_image" | awk -F' ' '{ print $2  }' | grep -v ":" | grep -v TAGS | awk -F',' '{ print $1 " " $2 }');
    if $DEBUG ; then
            echo
            echo
            echo "#----------------------------------------------"
            echo "[DEBUG] TAG-LIST-INIT"
            echo "Image: $docker_image"
            echo "Tag list:"
            echo "$TAG_LIST"
            echo "Command list tag: $GCLOUD container images list-tags $docker_image | awk -F' ' '{ print \$2  }' | grep -v \":\" | grep -v TAGS | awk -F',' '{ print \$1 \" \" \$2 }'"
            echo "[DEBUG] TAG-LIST-END"
            echo
            echo
    fi

    for tag in $TAG_LIST; do
        LAST_NAME_DOCKER_IMAGE=$(echo "$docker_image" | awk -F'/' '{ print $3  }')
        if $DEBUG ; then
            echo "[DEBUG] TAG-INIT"
            echo "===========> Tag: $tag "
            echo "Command send image: $GCLOUD container images add-tag $GCR_ORIGIN/$LAST_NAME_DOCKER_IMAGE:$tag $GCR_DESTINY/$LAST_NAME_DOCKER_IMAGE:$tag"
            echo "[DEBUG] TAG-END"
        fi
        $GCLOUD container images add-tag "$GCR_ORIGIN"/"$LAST_NAME_DOCKER_IMAGE":"$tag" "$GCR_DESTINY"/"$LAST_NAME_DOCKER_IMAGE":"$tag" "$GCLOUD_SILENCE"
    done
done
