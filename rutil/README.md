<!-- TOC -->

- [About](#about)
- [Demostration](#demostration)
- [Installation](#installation)
  - [Using Docker](#using-docker)
  - [Compiling with go](#compiling-with-go)
- [Usage](#usage)
  - [Examples](#examples)
  - [Dump](#dump)
  - [Pipe](#pipe)
  - [Restore](#restore)
  - [Query](#query)

<!-- TOC -->

# About

``rutil`` is a small command line utility that lets you selectively dump, restore and query a redis database, peek into stored data and pretty print json contents.

> Attention!!! This code is a fork of project [``rutil``](https://github.com/pampa/rutil)
> We will try to contact the initial developers of the project and open a PR. Parallel to this, improvements were made to the code to be compiled with [Go](https://golang.org/) 1.15 and a Docker image was created to facilitate distribution and use.

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
docker build -t rutil .
```

List the Docker images:

```bash
docker images
```

Run a container:

```bash
docker run --rm --name rutil rutil --help
```

## Compiling with go

Install Go following the instructions in [this tutorial](../tutorials/install_go.md).

Compile ``rutil`` with Go:

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
   --help, -h              show help
   --version, -v           print the version
```

## Examples

## Dump

```bash
rutil dump [command options] [arguments...]

--keys, -k "*"  keys pattern (passed to redis 'keys' command)
--match, -m     regexp filter for key names
--invert, -v    invert match regexp
--auto, -a      make up a file name for the dump - redisYYYYMMDDHHMMSS.rdmp
```

## Pipe

```bash
rutil pipe [command options] [arguments...]

--keys, -k "*"  keys pattern (passed to redis 'keys' command)
--match, -m     regexp filter for key names
--invert, -v    invert match regexp
```

## Restore

```bash
rutil restore [command options] [arguments...]

--dry-run, -r   pretend to restore
--flushdb, -f   flush the database before restoring
--delete, -d    delete key before restoring
--ignore, -g    ignore BUSYKEY restore errors
```

## Query

```bash
rutil query [command options] [arguments...]

--keys, -k                           keys pattern (passed to redis 'keys' command)
--match, -m                          regexp filter for key names
--invert, -v                         invert match regexp
--delete                             delete keys
--print, -p                          print key values
--field, -f [-f option --f option]   hash fields to print (default all)
--json, -j                           attempt to parse and pretty print strings as json
```