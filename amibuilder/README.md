## create AMI

This will use the Vagrant AWS plugin to provision a blank, new Ubuntu instance and get everything installed on it ready to produce an AMI.

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

Once this is setup - do this:

```
$ make ami
```

which does:

```
$ bash ami.sh
```