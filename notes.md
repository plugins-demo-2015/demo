#### to install swarm on OSX

```bash
$ brew install go
$ export GOPATH=~/go
$ export PATH=$PATH:~/go/bin
$ go get github.com/tools/godep
$ mkdir -p $GOPATH/src/github.com/docker/
$ cd $GOPATH/src/github.com/docker/
$ git clone https://github.com/docker/swarm
$ cd swarm
$ godep go install .
```