## create AMI

This will use the Vagrant AWS plugin to provision a blank, new Ubuntu instance and get everything installed on it ready to produce an AMI.

You need 2 vagrant plugins for this to work:

```
$ vagrant plugin install vagrant-aws
$ vagrant plugin install vagrant-awsinfo
```

You also need [jq](http://stedolan.github.io/jq/download/) installed.

Before running the script - you need to create a `.aws_secrets` file that will be used to configure EC2.

You need a keypair in the US East 1 region (N.Virginia) for this to work - login to the AWS console and create a keypair.

Here is an example of the `.aws_secrets` file:

```yaml
access_key_id: KEY_ID_HERE
secret_access_key: SECRET_KEY_HERE
keypair_name: kai-demo
keypair_path: /Users/kai/.ssh/kai-demo.pem
instance_name_prefix: kai
```

You also need the [aws cli](http://docs.aws.amazon.com/cli/latest/userguide/installing.html) installed and configured with your access credentials (the same as the ones above) - you can `aws configure` to do this.

IMPORTANT - when you configure aws, you must set the region to the same as the keypair in .aws_secrets

Once this is setup - do this:

```
$ make build
```

which does:

```
$ bash build.sh
```

This will vagrant up - get the box provisioned and then spit out an AMI from it.

Once the ImageId has been printed - the image will still be pending - use the AWS console to see its current status
