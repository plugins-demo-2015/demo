#!/bin/sh

vagrant up
masterip=$(vagrant awsinfo -m master -p | jq -r '.private_ip')
runner1ip=$(vagrant awsinfo -m runner-1 -p | jq -r '.private_ip')
runner2ip=$(vagrant awsinfo -m runner-2 -p | jq -r '.private_ip')