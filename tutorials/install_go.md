<!-- TOC -->

- [Install Go](#install-go)

<!-- TOC -->

# Install Go

Run the following commands to install Go.

```bash
VERSION=1.15

mkdir -p $HOME/go/bin

curl https://dl.google.com/go/go$VERSION.linux-amd64.tar.gz -o /tmp/go.tar.gz

sudo tar -C /usr/local -xzf /tmp/go.tar.gz

rm /tmp/go.tar.gz

export GOPATH=$HOME/go
export PATH=$PATH:/usr/local/go/bin:$GOPATH/bin

go version
```

More information: https://golang.org/doc/