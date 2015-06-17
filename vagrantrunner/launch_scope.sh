#!/bin/sh -x
for m in master runner
do vagrant ssh $m -c 'sudo /vagrant/bin/scope launch 172.16.70.250 172.16.70.251'
done
