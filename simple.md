# flocker + weave simple plugins demo

for dockercon keynote

example: https://www.youtube.com/watch?v=XJdDjEZcfuo

# setup

```
$ vagrant --version # need 1.7.2
$ flocker-ca --version # need 1.0.0
$ # on OSX: brew tap ClusterHQ/tap && brew update && brew install flocker-1.0.0
$ # other platforms: https://docs.clusterhq.com/en/1.0.0/using/installing/index.html#installing-flocker-cli
$ cd ~
$ mkdir demo2
$ cd demo2
$ git clone git@github.com:clusterhq/docker-plugins-demo
$ cd docker-plugins-demo
$ make -C vagrantrunner
```

# weave

on both nodes:

```
$ sudo docker network create -d weave demonet
```

on node1 (in new window):

```
$ sudo docker run --rm -ti --net=demonet --name=server --hostname=server.weave.local --dns=10.23.11.10 gliderlabs/alpine nc -p 4000 -lk -e echo HELLO
```

on node2 (in new window):

```
$ sudo docker run --rm -ti --net=demonet --name=client --hostname=client.weave.local --dns=10.23.11.10 gliderlabs/alpine nc server.weave.local 4000
```


# flocker

on node1:

```
$ sudo docker run -v demo:/data --volume-driver=flocker gliderlabs/alpine sh -c "echo hello > /data/world"
```

on node2:

```
$ sudo docker run -v demo:/data --volume-driver=flocker gliderlabs/alpine cat /data/world
```
