## compile docker / weave

This will compile the docker and weave binaries that are used by the AMI:

```
$ make compile
```

which does:

```
$ ./bootstrap.sh
$ ./build.sh
$ vagrant suspend builder
```

## create AMI

This will use the Vagrant AWS plugin to provision a blank, new Ubuntu instance and get everything installed on it ready to produce an AMI.

```
$ make ami
```

which does:

```
$ ./ami.sh
```