FROM alpine:3.12
# Base image
# https://hub.docker.com/_/alpine
# Source:https://www.sandtable.com/reduce-docker-image-sizes-using-alpine/

# Informations about image
LABEL maintainer="Sensedia SA" \
      author="Cloud Architect Team" \
      email="suporte@sensedia.com" \
      description="Docker image to validate AWS Elasticache backup" \
      licence="copyright"

# Define software versions
ENV AWSCLI_VERSION="1.18.126" \
    RDB_VERSION="0.1.15" \
    IAM_AUTHENTICATOR_VERSION="1.16.8"

# Install basic packages
RUN apk add --no-cache python3 curl jq bash vim net-tools \
    && apk add --no-cache py3-pip bind-tools moreutils

# Install AWS-CLI and AWS-Authenticaton
RUN pip3 install --no-cache-dir --upgrade pip \
    && pip3 --no-cache-dir install awscli==${AWSCLI_VERSION} \
    && rm -rf /var/cache/apk/* \
    && curl -sk -L https://amazon-eks.s3-us-west-2.amazonaws.com/${IAM_AUTHENTICATOR_VERSION}/2020-04-16/bin/linux/amd64/aws-iam-authenticator -o /usr/local/bin/aws-iam-authenticator \
    && chmod +x /usr/local/bin/aws-iam-authenticator \
    && aws --version \
    && aws-iam-authenticator version

# Variables specific to rdbtools
ENV RDB_URL=https://github.com/sripathikrishnan/redis-rdb-tools/archive/refs/tags/rdbtools-0.1.15.tar.gz \
    RDB_TAR_DIR=rdb-${RDB_VERSION}

# Install rdbtools
RUN wget ${RDB_URL} -O /tmp/${RDB_TAR_DIR}.tar.gz \
    && tar -C /tmp -xvzf /tmp/${RDB_TAR_DIR}.tar.gz \
    && cd /tmp/redis-rdb-tools-rdbtools-${RDB_VERSION} \
    && python3 setup.py install \
    && rm -rf /tmp/${RDB_TAR_DIR}.tar.gz \
    && rm -rf /tmp/redis-rdb-tools-rdbtools-${RDB_VERSION}

# Clear cache of packages in Alpine Linux
# Source: https://wiki.alpinelinux.org/wiki/Local_APK_cache
# https://wiki.alpinelinux.org/wiki/Alpine_Linux_package_management
RUN rm -rf /var/cache/apk/* \
    && rm -rf /tmp/*

# Create scripts directory
RUN mkdir /scripts

# Create .aws directory in root
RUN mkdir /root/.aws

# Copy validate_backup_elasticache.sh to /scripts
COPY validate_backup_elasticache.sh /scripts

# Copy credentials to /root/.aws
COPY credentials /root/.aws

# Entrypoint
CMD ["/bin/bash", "-c", "/scripts/validate_backup_elasticache.sh"]