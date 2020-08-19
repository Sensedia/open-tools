<!-- TOC -->

- [About](#about)
- [Demostration](#demostration)
- [Installation](#installation)
  - [Using Docker](#using-docker)
  - [Compiling with go](#compiling-with-go)
- [Usage](#usage)
  - [Examples](#examples)
  - [Command ``dump``](#command-dump)
    - [Cluster](#cluster)
    - [Node](#node)
  - [Pipe](#pipe)
  - [Restore](#restore)
    - [Cluster](#cluster-1)
    - [Node](#node-1)
  - [Query](#query)
    - [Cluster](#cluster-2)
    - [Node](#node-2)

<!-- TOC -->

# About

``rutil`` is a small command line utility that lets you selectively dump, restore and query a redis database, peek into stored data and pretty print json contents.

> Attention!!! This code is a fork of project [``rutil``](https://github.com/pampa/rutil)
> We try to contact the initial developers: https://github.com/pampa/rutil/issues/6. Parallel to this, improvements were made to the code to be compiled with [Go](https://golang.org/) 1.15 and a Docker image was created to facilitate distribution and use.

Credits for:

* [@pampa](https://github.com/pampa)
* [@slavaGanzin](https://github.com/slavaGanzin)

Thanks [@otavioprado](otavioprado) for making improvements to the code to be compiled with Go 1.15 and creating the Dockerfile for easy distribution and use.

# Demostration

![rutil](https://raw.githubusercontent.com/pampa/rutil/master/demo.gif)

# Installation

Clone this repository with command:

```bash
git clone https://github.com/Sensedia/open-tools

cd open-tools/rutil
```

## Using Docker

Install Docker following the instructions in [this tutorial](../tutorials/install_docker.md).

Generate new image with command:

```bash
make image
```

Or:

```bash
docker build -t rutil:latest .
```

List the Docker images:

```bash
docker images
```

Run a container:

```bash
docker run --rm rutil --help
```

More information about ``docker run`` command: https://docs.docker.com/engine/reference/run/

## Compiling with go

Install Go following the instructions in [this tutorial](../tutorials/install_go.md).

Compile ``rutil`` with Go:

```bash
make build
```

Or:

```bash
go build -o bin/rutil .
```

Run ``rutil``:

```bash
./bin/rutil --help
```

# Usage

```bash
rutil [global options] command [command options] [arguments...]

COMMANDS:
   dump      dump redis database to a file
   pipe      dump a redis database to stdout in a format compatible with | redis-cli --pipe
   restore   restore redis database from a file
   query, q  query keys matching the pattern provided by --keys
   help, h   Shows a list of commands or help for one command

GLOBAL OPTIONS:
   --host value, -s value  redis host (default: "127.0.0.1")
   --auth value, -a value  authentication password
   --port value, -p value  redis port (default: 6379)
   --cluster, -c           redis cluster connection
   --help, -h              show help
   --version, -v           print the version
```

## Examples

## Command ``dump``

```bash
rutil [global options] dump [command options] [arguments...]

GLOBAL OPTIONS:
   --host value, -s value  redis host (default: "127.0.0.1")
   --auth value, -a value  authentication password
   --port value, -p value  redis port (default: 6379)
   --cluster, -c           redis cluster connection
   --help, -h              show help
   --version, -v           print the version

OPTIONS:
   --keys value, -k value   keys pattern (passed to redis 'keys' command) (default: "*")
   --match value, -m value  regexp filter for key names
   --invert, -v             invert match regexp
   --auto, -a               make up a file name for the dump - redisYYYYMMDDHHMMSS.rdmp
```

### Cluster

Make a dump of all keys of Redis cluster:

```bash
./bin/rutil -c --host 192.168.0.1 --port 6379 dump /tmp/dump_all_keys.rdmp
```

A file will be created ``/tmp/dump_all_keys.rdmp``.

Or:

```bash
./bin/rutil -c --host 192.168.0.1 --port 6379 dump -a
```

A file will be created in the current directory with the following pattern: ``redisYYYYMMDDHHMMSS.rdmp``.

Using Docker:

```bash
docker run --rm -v $PWD:/tmp rutil -c --host 192.168.0.1 --port 6379 dump /tmp/file2.rdmp
```

Or:

```bash
docker run --rm -v $PWD:/tmp rutil -c --host 192.168.0.1 --port 6379 dump -a
```

### Node

Make a dump of all keys of Redis node (ommiting ``-c`` option):

```bash
./bin/rutil --host 192.168.0.1 --port 6379 dump /tmp/dump_all_keys.rdmp
```

A file will be created ``/tmp/dump_all_keys.rdmp``.

Or:

```bash
./bin/rutil --host 192.168.0.1 --port 6379 dump -a
```

A file will be created in the current directory with the following pattern: ``redisYYYYMMDDHHMMSS.rdmp``.

Using Docker (ommiting ``-c`` option):

```bash
docker run --rm -v $PWD:/tmp rutil --host 192.168.0.1 --port 6379 dump /tmp/file2.rdmp
```

Or:

```bash
docker run --rm -v $PWD:/tmp rutil --host 192.168.0.1 --port 6379 dump -a
```

## Pipe

```bash
rutil [global options] pipe [command options] [arguments...]

GLOBAL OPTIONS:
   --host value, -s value  redis host (default: "127.0.0.1")
   --auth value, -a value  authentication password
   --port value, -p value  redis port (default: 6379)
   --cluster, -c           redis cluster connection
   --help, -h              show help
   --version, -v           print the version

OPTIONS:
   --keys value, -k value   keys pattern (passed to redis 'keys' command) (default: "*")
   --match value, -m value  regexp filter for key names
   --invert, -v             invert match regexp
```

## Restore

```bash
rutil [global options] estore [command options] [arguments...]

GLOBAL OPTIONS:
   --host value, -s value  redis host (default: "127.0.0.1")
   --auth value, -a value  authentication password
   --port value, -p value  redis port (default: 6379)
   --cluster, -c           redis cluster connection
   --help, -h              show help
   --version, -v           print the version

OPTIONS:
   --dry-run, -r  pretend to restore
   --flushdb, -f  flush the database before restoring
   --delete, -d   delete key before restoring
   --ignore, -g   ignore BUSYKEY restore errors
   --stdin, -i    read dump from STDIN
```

### Cluster

Simulate restore all keys of Redis cluster:

```bash
./bin/rutil --host 192.168.0.1 -c --port 6379 restore --dry-run /tmp/file2.rdmp
```

Or:

```bash
docker run --rm -v $PWD:/tmp rutil -c --host 192.168.0.1 --port 6379 restore --dry-run /tmp/file2.rdmp
```

Restore all keys of Redis cluster:

```bash
./bin/rutil -c --host 192.168.0.1 --port 6379 restore --flushdb /tmp/file2.rdmp
```

Or:

```bash
docker run --rm -v $PWD:/tmp rutil -c --host 192.168.0.1 --port 6379 restore --flushdb /tmp/file2.rdmp
```

### Node

Simulate restore all keys of Redis node (ommiting ``-c`` option):

```bash
./bin/rutil --host 192.168.0.1 --port 6379 restore --dry-run /tmp/file2.rdmp
```

Or:

```bash
docker run --rm -v $PWD:/tmp rutil --host 192.168.0.1 --port 6379 restore --dry-run /tmp/file2.rdmp
```

Restore all keys of Redis node (ommiting ``-c`` option):

```bash
./bin/rutil --host 192.168.0.1 --port 6379 restore --flushdb /tmp/file2.rdmp
```

Or:

```bash
docker run --rm -v $PWD:/tmp rutil --host 192.168.0.1 --port 6379 restore --flushdb /tmp/file2.rdmp
```

## Query

```bash
rutil [global options] query [command options] [arguments...]

GLOBAL OPTIONS:
   --host value, -s value  redis host (default: "127.0.0.1")
   --auth value, -a value  authentication password
   --port value, -p value  redis port (default: 6379)
   --cluster, -c           redis cluster connection
   --help, -h              show help
   --version, -v           print the version

OPTIONS:
   --keys value, -k value   keys pattern (passed to redis 'keys' command)
   --match value, -m value  regexp filter for key names
   --invert, -v             invert match regexp
   --delete                 delete keys
   --print, -p              print key values
   --field value, -f value  hash fields to print (default all)
   --json, -j               attempt to parse and pretty print strings as json
```

### Cluster

List all keys in Redis cluster:

```bash
./bin/rutil -c --host 192.168.0.1 --port 6379 query --keys '*'
```

Or:

```bash
docker run --rm rutil -c --host 192.168.0.1 --port 6379 query --keys '*'
```

Make a query in Redis cluster:

```bash
./bin/rutil -c --host 192.168.0.1 --port 6379 query --keys 'testing:abcde:BOOK*'
```

Or:

```bash
docker run --rm rutil -c --host 192.168.0.1 --port 6379 query --keys 'testing:abcde:BOOK*'
```

Delete a key in Redis cluster:

```bash
./bin/rutil -c --host 192.168.0.1 --port 6379 query --keys 'testing:abcde:BOOK:55' --delete
```

Or:

```bash
docker run --rm rutil -c --host 192.168.0.1 --port 6379 query --keys 'testing:abcde:BOOK:55' --delete
```

Print value of a key in Redis cluster:

```bash
./bin/rutil -c --host 192.168.0.1 --port 6379 query --keys 'testing:abcde:BOOK:55' --print
```

Or:

```bash
docker run --rm rutil -c --host 192.168.0.1 --port 6379 query --keys 'testing:abcde:BOOK:55' --print
```

More information: https://redis.io/commands/keys

### Node

List all keys in Redis node (ommiting ``-c`` option):

```bash
./bin/rutil --host 192.168.0.1 --port 6379 query --keys '*'
```

Or:

```bash
docker run --rm rutil --host 192.168.0.1 --port 6379 query --keys '*'
```

Make a query in Redis node (ommiting ``-c`` option):

```bash
./bin/rutil --host 192.168.0.1 --port 6379 query --keys 'testing:abcde:BOOK*'
```

Or:

```bash
docker run --rm rutil --host 192.168.0.1 --port 6379 query --keys 'testing:abcde:BOOK*'
```

Delete a key in Redis node (ommiting ``-c`` option):

```bash
./bin/rutil --host 192.168.0.1 --port 6379 query --keys 'testing:abcde:BOOK:55' --delete
```

Or:

```bash
docker run --rm rutil --host 192.168.0.1 --port 6379 query --keys 'testing:abcde:BOOK:55' --delete
```

Print value of a key in Redis node (ommiting ``-c`` option):

```bash
./bin/rutil --host 192.168.0.1 --port 6379 query --keys 'testing:abcde:BOOK:55' --print
```

Or:

```bash
docker run --rm rutil --host 192.168.0.1 --port 6379 query --keys 'testing:abcde:BOOK:55' --print
```

More information: https://redis.io/commands/keys
