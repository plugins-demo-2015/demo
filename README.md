## Compiler

This generates new docker binaries and weave images from the merge of all the latest code:

```
$ make -C compiler
```

## Amibuilder

This uses vagrant-aws to install dependencies and inject the binaries created by the compiler.  It then creates a new AMI from the instance.

First - [install and configure](amibuilder)

```
$ make -C amibuilder
```

## Runner

This uses vagrant-aws to spin up 3 nodes for the actual demo - one of the 3 nodes is designated `master` (i.e. it runs the Flocker control service)

```
$ make -C runner
```
