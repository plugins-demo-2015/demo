#!/bin/bash

vagrant up ami --provider=aws
instanceid=$(vagrant awsinfo -m ami -p | jq '.instance_id')
amiid=$(aws ec2 create-image --instance-id $instanceid --name docker-plugins-demo | jq '.ImageId')
echo "AMI image has been created"
echo $amiid