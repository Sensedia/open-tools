# Validate AWS Elasticache Backup

<!-- TOC -->

- [Validate AWS Elasticache Backup](#validate-aws-elasticache-backup)
- [About](#about)
- [Requirement](#requirement)
- [Running](#running)
- [Parameters Explanation](#parameters-explanation)
- [Addictional Instructions](#addictional-instructions)

<!-- TOC -->

# About

Alpine Image with some tools:

- awscli
- aws-iam-authenticator
- rdb
- and some basic packages:
  - python3, py3-pip, curl, jq, bash, vim, net-tools, bind-tools and moreutils

# Requirement
 - AWS Elasticache Cluster
 - Follow the AWS Documentation's instruction to create an Amazon Bucket S3 and grant permission to AWS ElastiCache access this bucket:
    - https://docs.aws.amazon.com/AmazonElastiCache/latest/red-ug/backups-exporting.html#backups-exporting-procedures
- For AWS Elasticache enable Automatic Backup and choose a Backup Retention Period and a Backup Window:
  - https://docs.aws.amazon.com/AmazonElastiCache/latest/red-ug/backups-automatic.html

# Running
docker run -it --rm -e "AWS_ACCESS_KEY_ID=\<your_aws_access_key_id>" -e "AWS_SECRET_ACCESS_KEY=\<your_aws_secret_key>"" -e "AWS_DEFAULT_REGION=\<region>" -e "_DEBUG_COMMAND=<on|off>" -e "BACKUP_TIME=\<time>" -e "MY_S3_BUCKET=\<bucket_name>" -e "CACHE_SIZE=\<cache_size>" -e "REDIS_VERSION=\<redis_version>" -e "ZONE_01='<zone_01>'" -e "ZONE_02='<zone_02>'" -e "REPLICATION_GROUP_ID=\<replication_group_id>" -e "SLOT_01=\<slot_01>" -e "SLOT_02=\<slot_02>" -e "SLOT_03=\<slot_03>" -e "MINIMAL_KEYS_PERCENTAGE=\<keys_percentage>" --name sensedia sensedia/validate_backup_elasticache:1.0

```diff
- Change each of the above parameters according to your environment before running docker run command
```

# Parameters Explanation
AWS_ACCESS_KEY_ID - Your AWS Acess Key ID

AWS_SECRET_ACCESS_KEY - Your AWS Secret Key

AWS_DEFAULT_REGION - The region of your AWS Elasticache Cluster

_DEBUG_COMMAND - Enable (on) or Disable (off) debug output

BACKUP_TIME - Initial time of your Backup Window Configuration (see [Requirement](#requirement))

MY_S3_BUCKET - Your S3 Bucket Name (see [Requirement](#requirement))

CACHE_SIZE - The Node type, for example: "cache.m5.large"

REDIS_VERSION - Version of you AWS Elasticache Cluster (Engine Version Compatibility)

ZONE_01 and ZONE_02 - AWS Availability Zones, for example: "us-east-1a" and "us-east-1c"

REPLICATION_GROUP_ID - Identification of cluster, for examplo: restore-backup-redis

SLOT_01, SLOT_02 and SLOT_03 - Slots/Keyspaces of Shards, for example: 0-5461, 5462-10922 and 10923-16383

MINIMAL_KEYS_PERCENTAGE - Which is the minimal acceptable for equals keys since last snapshot and actual state


# Addictional Instructions
If you have a different number of:
 - Nodes (3)
 - Regions (2)
 - Slots (3)

```diff
- You'll need to change the script
```
