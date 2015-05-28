## Compiler

This generates new docker binaries and weave images from the merge of all the latest code:

```
$ cd compiler && make compile
```

## Amibuilder

This uses vagrant-aws to install dependencies and inject the binaries created by the compiler.  It then creates a new AMI from the instance.

First - [install and configure](amibuilder)

```
$ cd amibuilder && make build
```

## Runner

This uses vagrant-aws to spin up 3 nodes for the actual demo - one of the 3 nodes is designated `master` (i.e. it runs the Flocker control service)

```
$ cd runner && make run
```
