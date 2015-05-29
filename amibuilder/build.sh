#!/bin/bash
unixsecs=$(date +%s)
vagrant up ami --provider=aws
instanceid=$(vagrant awsinfo -m ami -p | jq -r '.instance_id')
amiid=$(aws ec2 create-image --instance-id $instanceid --name docker-plugins-demo-$unixsecs | jq -r '.ImageId')
echo "AMI image has been created"
echo $amiid