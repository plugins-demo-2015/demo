## docker-plugins-demo

A demo of the Flocker and Weave Docker plugins.

## Vagrant Quickstart

To spin up the cluster using Vagrant you must first install the [flocker-cli](https://docs.clusterhq.com/en/0.9.0/using/installing/index.html#installing-flocker-cli) on your host machine.

You will also need Vagrant and Virtualbox installed.

Then:

```bash
$ make -C vagrantrunner
```

This will use pre-packed boxes that has everything installed - start 3 VMs and then install the Flocker and Weave plugins.

Once the boxes have started - we create the weave network on each of the nodes
and start the swarm master:

```bash
$ cd vagrantrunner
$ bash create_network.sh
$ bash swarm_manage.sh
```

Then in another shell, we SSH into the master:

```bash
$ cd vagrantrunner
$ vagrant ssh master
```

Then we start the HTTP load balancer that opens up the open to the outside world:

```bash
master$ sudo su -
master# cd /vagrant
master# bash run_proxy.sh
```

Then we check that swarm is working and that the plugins are running, then bring up the app using `docker-compose`:

```bash
master# export DOCKER_HOST=localhost:2378
master# docker ps -a
master# cd /vagrant/app
master# docker-compose up
```

Now we can load the app in a browser:

```
http://172.16.70.250/
```

Click around and add some Docker logos onto the screen.

## AWS Quickstart

To spin up the cluster using AWS - again you must first install the [flocker-cli](https://docs.clusterhq.com/en/0.9.0/using/installing/index.html#installing-flocker-cli) on your host machine.

You need 2 vagrant plugins for this to work:

```
$ vagrant plugin install vagrant-aws
$ vagrant plugin install vagrant-awsinfo
```

You also need [jq](http://stedolan.github.io/jq/download/) installed.

Before running the script - you need to create a `.aws_secrets` file in the root of this repo that will be used to configure EC2.
You can base this on the `.aws_secrets.example` file:

```yaml
access_key_id: KEY_ID_HERE
secret_access_key: SECRET_KEY_HERE
region: us-east-1
zone: us-east-1c
keypair_name: kai-demo
keypair_path: /Users/kai/.ssh/kai-demo.pem
instance_name_prefix: kai
builderami: ami-3cf8b154
runnerami: ami-290fe942
instance_type: c3.xlarge
```

IMPORTANT - you need to create a keypair in the region you intend to run the instances (.e.g US East 1)

The `builderami` field needs to be an Ubuntu 14.04 box that is from the same region as the keypair

This keypair needs downloading and when you edit `.aws_secrets` - set the keypair_name and keypair_path accordingly.

You also need the [aws cli](http://docs.aws.amazon.com/cli/latest/userguide/installing.html) installed and configured with your access credentials (the same as the ones above) - you can `aws configure` to do this.

When you run `aws configure` - ensure that the region is the same as the one in which you created the keypair.

Then you can:

```bash
$ vagrant -C runner
```

And it will use the `runnerami` that has been configured in the `.aws_secrets` file

## Compile and build

The stack uses a custom compiled version of docker and weave plugin.

It will then install weave and Flocker onto Vagrant and AWS base boxes to save spin up time.

The AWS and Vagrant runners will then use the base boxes to start the cluster.

The sequence of events is as follows:

 * `make -C compiler` to compile docker and the weave plugin
 * `make -C vagrantbuilder` to use the compiled binaries to build a vagrant box
 * `make -C amibuilder` to use the compiled binaries to build an AMI
 * upload the Vagrant box and edit `vagrantrunner/Vagrantfile` to point at it
 * make the AMI public and edit `runnerami` in `.aws_secrets` to point at it
 * `make -C vagrantrunner` to spin up the cluster in Vagrant
 * `make -C runner` to spin up the cluster in AWS
 * `cd vagrantrunner && vagrant ssh master` to use the Vagrant cluster
 * `cd runner && vagrant ssh master` to use the AWS cluster 

### Compiler

This generates new docker binaries and weave images from the merge of all the latest code:

```
$ make -C compiler
```

It will then copy the results of the build into the `vagrantbuilder/compiled/files` and `amibuilder/compiled/files` folder ready for the 2 builders to use.

### Amibuilder

This uses vagrant-aws to install dependencies and inject the binaries created by the compiler.  It then creates a new AMI from the instance.

First - [install and configure](amibuilder)

```
$ make -C amibuilder
```

This will vagrant up - get the box provisioned and then spit out an AMI from it.

Once the ImageId has been printed - the image will still be pending - use the AWS console to see its current status.

When the Image is ready - edit the permissions to public so anyone can use it.

When the AMI has been generated - replace the `runnerami` field in the `.aws_secrets` file to be the generated AMI id.

This means the runner will use the AMI we just built.

### Vagrant builder

This will create a Vagrant.box file ready for the Vagrant runner - it will spit out a `vagrantbuilder/vagrantXXX.box` file when finished.

```
$ make -C vagrantbuilder
```

Once the box has been created - upload it to a public cloud and paste the url into the `config.vm.box_url` section of the `vagrantrunner/Vagrantfile` file.

### Runner

Install flocker-cli`

This uses vagrant-aws to spin up 3 nodes for the actual demo - one of the 3 nodes is designated `master` (i.e. it runs the Flocker control service)

```
$ make -C runner
```

Once the 3 nodes have spun up - it will then download [unofficial-flocker-tools](https://github.com/clusterhq/unofficial-flocker-tools) and use the [flocker-cli](https://docs.clusterhq.com/en/0.9.0/using/installing/index.html#installing-flocker-cli) to create and upload TLS certificates for the cluster.

Once the cluster has started - you can use the unofficial tools to list nodes and create volumes:

```bash
$ cd runner/unofficial-flocker-tools
$ ./flocker-volumes.py list-nodes
$ ./flocker-volumes.py --help
```

### Vagrant runner

This will spin up 3 nodes using the Vagrantbox - it will then download [unofficial-flocker-tools](https://github.com/clusterhq/unofficial-flocker-tools) and use the [flocker-cli](https://docs.clusterhq.com/en/0.9.0/using/installing/index.html#installing-flocker-cli) to create and upload TLS certificates for the cluster.

```
$ make -C vagrantrunner
```

Once the cluster has started - you can use the unofficial tools to list nodes and create volumes:

```bash
$ cd vagrantrunner/unofficial-flocker-tools
$ ./flocker-volumes.py list-nodes
$ ./flocker-volumes.py --help
```
