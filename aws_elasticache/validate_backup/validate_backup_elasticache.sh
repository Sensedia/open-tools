#!/bin/bash

#---------------------------------------------------------------------------------------
# Sensedia
# Author: André Déo - andre.deo@sensedia.com
# Date: April 2021
#---------------------------------------------------------------------------------------

#---------------------------------------------------------------------------------------
# This script is responsible for:
# - Validating that is possible to recreate the Elasticache cluster from the snapshot.
# - Validate the percentage of keys equal from the snapshot to the current moment.
# 
# The script creates everything needed to perform these tasks and in the end
#   destroys everything that has been created for this.
# 
#---------------------------------------------------------------------------------------

#---------------------------------------------------------------------------------------
# Functions
#---------------------------------------------------------------------------------------

#---------------------------------------------------------------------------------------
# Function Debug
#---------------------------------------------------------------------------------------
# comment: Execute the command and show in output (use for debug of commands)
# sintax:
#   debug COMMAND
# requirement: create variable _DEBUG_COMMAND.
#    Use the value 'on' for enable this funcion.
#    Use the value 'off' for disable this function
# reference: https://www.cyberciti.biz/tips/debugging-shell-script.html
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
#---------------------------------------------------------------------------------------
function debug(){
    [ "$_DEBUG_COMMAND" == "on" ] && "$@"
}

#---------------------------------------------------------------------------------------
# Main Variables
#---------------------------------------------------------------------------------------
PROFILE=$PROFILE
REGION=$REGION
_DEBUG_COMMAND=$_DEBUG_COMMAND

#---------------------------------------------------------------------------------------
# Local Temp Files
#---------------------------------------------------------------------------------------
debug set -x
# Generating a list of cluster names (customerids)
aws elasticache describe-cache-clusters --profile $PROFILE --region $REGION | jq -r '.CacheClusters[].CacheClusterId' > customerids || exit

# Removing extra node identifications, like 0001-001, 0001-002, 0002-001, 0003-001 and 0003-002
# Reference: https://stackoverflow.com/questions/19482123/extract-part-of-a-string-using-bash-cut-split/19482947
for var in `cat customerids`; do echo "${var%-*-*}" >> customerids_temp ; done

# Making the list of cluster names (customerids) unique
uniq customerids_temp > customerids
debug set +x

#---------------------------------------------------------------------------------------
# General Variables
#---------------------------------------------------------------------------------------
LINES=$(wc -l < customerids)
CUSTOMERID=$(head -`echo $((1 + $RANDOM % $LINES))` customerids | tail -1 || exit)
BACKUP_TIME=$BACKUP_TIME
MY_S3_BUCKET=$MY_S3_BUCKET
REPLICATION_GROUP_ID=$REPLICATION_GROUP_ID
REPLICA_DESCRIPTION="Backup Validation Restore"
NUM_NODES=3
CACHE_SIZE=$CACHE_SIZE
REDIS_VERSION=$REDIS_VERSION
SECURITY_GROUP=$(aws elasticache describe-cache-clusters --cache-cluster-id "${CUSTOMERID}-0001-001" --profile $PROFILE --region $REGION | jq -r '.CacheClusters[].SecurityGroups[].SecurityGroupId' || exit)
BACKUPID=backup-${CUSTOMERID}-$(date +%F || exit)-${BACKUP_TIME}
SLOT_01=$SLOT_01
SLOT_02=$SLOT_02
SLOT_03=$SLOT_03
ZONE_01=${ZONE_01}
ZONE_02=${ZONE_02}
MINIMAL_KEYS_PERCENTAGE=$MINIMAL_KEYS_PERCENTAGE

#---------------------------------------------------------------------------------------
# MAIN
#---------------------------------------------------------------------------------------

# Empty the S3 Bucket
# For some reason, for example, interruption of the script, the bucket may content lost files
aws s3 rm s3://$MY_S3_BUCKET --recursive --profile $PROFILE --region $REGION || exit 

# Copy snapshot files to S3 Bucket
echo "[INFO] Copying snapshot automatic.${CUSTOMERID}-`date +%F`-${BACKUP_TIME} to Bucket S3 $MY_S3_BUCKET"
debug set -x
aws elasticache copy-snapshot \
--source-snapshot-name automatic.${CUSTOMERID}-`date +%F`-${BACKUP_TIME} \
--target-snapshot-name $CUSTOMERID \
--target-bucket $MY_S3_BUCKET \
--profile $PROFILE --region $REGION || exit
debug set +x

# Waiting the file copy
sleep 30
echo "[INFO] Copy finished"

# Create a Elastichache Cluster using S3 Bucket files
debug set -x
aws elasticache create-replication-group \
--replication-group-id $REPLICATION_GROUP_ID \
--replication-group-description "$REPLICA_DESCRIPTION" \
--num-node-groups $NUM_NODES \
--node-group-configuration \
"ReplicaCount=1,Slots=$SLOT_01,PrimaryAvailabilityZone=$ZONA_01,ReplicaAvailabilityZones=$ZONA_02" \
"ReplicaCount=1,Slots=$SLOT_02,PrimaryAvailabilityZone=$ZONA_02,ReplicaAvailabilityZones=$ZONA_01" \
"ReplicaCount=1,Slots=$SLOT_03,PrimaryAvailabilityZone=$ZONA_02,ReplicaAvailabilityZones=$ZONA_01" \
--cache-node-type $CACHE_SIZE \
--cache-parameter-group eg-prod-${CUSTOMERID}-production \
--engine redis \
--engine-version $REDIS_VERSION \
--security-group-ids $SECURITY_GROUP \
--cache-subnet-group-name eg-prod-${CUSTOMERID}-production \
--snapshot-arns arn:aws:s3:::$MY_S3_BUCKET/${CUSTOMERID}-0001.rdb \
--snapshot-arns arn:aws:s3:::$MY_S3_BUCKET/${CUSTOMERID}-0002.rdb \
--snapshot-arns arn:aws:s3:::$MY_S3_BUCKET/${CUSTOMERID}-0003.rdb \
--profile $PROFILE --region $REGION || exit

# Waiting the creating cluster process
while [ $(aws elasticache describe-cache-clusters --cache-cluster-id $REPLICATION_GROUP_ID-0001-001 --profile $PROFILE --region $REGION 2> /dev/null | jq -r '.CacheClusters[].CacheClusterStatus') = creating 2> /dev/null ]

do
  echo "[INFO] Creating cluster $REPLICATION_GROUP_ID ... Wait..."
  sleep 60
done
debug set +x
echo "[INFO] Cluster created"

# Take a Snapshot from Actual State of Cluster
debug set -x
aws elasticache create-snapshot --snapshot-name $BACKUPID --replication-group-id $CUSTOMERID --profile $PROFILE --region $REGION || exit

sleep 5

# Waiting the snapshot process
while [ $(aws elasticache describe-snapshots --profile $PROFILE --region $REGION --replication-group-id $CUSTOMERID --snapshot-name $BACKUPID | jq -r '.Snapshots[].SnapshotStatus') = creating 2> /dev/null ]
do
  echo "[INFO] Making snapshot $BACKUPID ... Wait..."
  sleep 60
done
debug set +x

echo "[INFO] Snapshot done"

sleep 5
echo " "
echo "[INFO] Copying snapshot $BACKUPID to Bucket S3 $MY_S3_BUCKET"
debug set -x
aws elasticache copy-snapshot \
--source-snapshot-name $BACKUPID \
--target-snapshot-name $BACKUPID \
--target-bucket $MY_S3_BUCKET \
--profile $PROFILE --region $REGION || exit
debug set +x
echo "[INFO] Copy finished"
echo " "

# Download the files from S3 Bucket to local machine
echo "[INFO] Copying .rdb files"

# Waiting the file copy
sleep 30

debug set -x
for (( f=1; f<=3; f++ ))
do
  aws s3 cp s3://$MY_S3_BUCKET/${BACKUPID}-000$f.rdb . --profile $PROFILE --region $REGION
  aws s3 cp s3://$MY_S3_BUCKET/${CUSTOMERID}-000$f.rdb . --profile $PROFILE --region $REGION
  rdb -c diff ${BACKUPID}-000$f.rdb  | sort >> dump_backup.txt
  rdb -c diff ${CUSTOMERID}-000$f.rdb  | sort >> dump_customer.txt
done

sort dump_backup.txt -o dump_backup.txt
sort dump_customer.txt -o dump_customer.txt
debug set +x

echo "[INFO] Copy finished"
echo " "

# Current keys quantity
debug set -x
KEYS_CUSTOMER=$(wc -l dump_customer.txt | cut -d " " -f1)

# Number of equal lines in the two files
KEYS_EQUALS=$(grep -F -x -f dump_customer.txt dump_backup.txt | wc -l)

# Percentage of equal keys
KEYS_PERCENTAGE=$(echo "scale=2;$KEYS_EQUALS/$KEYS_CUSTOMER*100" | bc)

echo -e "****************************************************\n             Percentage of equal keys:\n             $KEYS_PERCENTAGE %\n****************************************************"

# Generate a temporary file, jenkins will use this information in e-mail notification
echo $KEYS_PERCENTAGE > /tmp/keys_percentage

debug set +x

sleep 5

echo " "
echo "[INFO] Removing everthing ..."

# Deleting Cluster 
debug set -x
aws elasticache delete-replication-group --replication-group-id "$REPLICATION_GROUP_ID" --profile $PROFILE --region $REGION || exit

# Waiting the cluster destruction process
while [ $(aws elasticache describe-cache-clusters --cache-cluster-id $REPLICATION_GROUP_ID-0001-001 --profile $PROFILE --region $REGION 2> /dev/null | jq -r '.CacheClusters[].CacheClusterStatus' = deleting 2> /dev/null) ]
 do
  echo "[INFO] Deleting cluster $REPLICATION_GROUP_ID ... Wait..."
  sleep 60
done
debug set +x
echo "[INFO] Cluster deleted"
echo " "

# Deleting the files from S3 Bucket and Locally
echo "[INFO] Deleting .rdb files"
debug set -x
for (( f=1; f<=3; f++ ))
  do
    aws s3 rm s3://$MY_S3_BUCKET/${CUSTOMERID}-000$f.rdb --profile $PROFILE --region $REGION
    aws s3 rm s3://$MY_S3_BUCKET/${BACKUPID}-000$f.rdb --profile $PROFILE --region $REGION
    rm -rf ${CUSTOMERID}-000$f.rdb
    rm -rf ${BACKUPID}-000$f.rdb
  done
debug set +x

# Deleting Snapshot file
echo " "
echo "[INFO] Deleting snapshot file"
debug set -x
aws elasticache delete-snapshot --snapshot-name $BACKUPID --profile $PROFILE --region $REGION || exit
debug set +x

# Remove Local Temp Files
echo "[INFO] Remove local temp files"
rm -rf customerids dump_customer.txt dump_backup.txt 

debug set -x
# Validate the percentage of equal keys
if (( $(echo "$KEYS_PERCENTAGE < $MINIMAL_KEYS_PERCENTAGE" | bc -l) ))
then
  echo -e "****************************************************\n[ERROR] Number of equal keys is less than $MINIMAL_KEYS_PERCENTAGE %\n****************************************************"
  exit 1
fi
debug set +x

echo " "
echo "[INFO] Process ended"
