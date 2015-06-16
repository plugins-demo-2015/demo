#!/bin/sh -x
for m in master runner
do vagrant ssh $m -c 'sudo docker network create -d weave demonet'
done
