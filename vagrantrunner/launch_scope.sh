#!/bin/sh -x
for m in master runner-1 runner-2
do vagrant ssh $m -c 'sudo /vagrant/bin/scope launch 172.16.70.250 172.16.70.251 172.16.70.252'
done
