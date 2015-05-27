## compile docker / weave

This will compile the docker and weave binaries that are used by the AMI:

```
$ make compile
```

which does:

```
$ bash bootstrap.sh
$ bash build.sh
$ vagrant suspend builder
```