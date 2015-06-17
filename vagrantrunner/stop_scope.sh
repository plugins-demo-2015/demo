#!/bin/sh -x
for m in master runner
do vagrant ssh $m -c 'sudo /vagrant/bin/scope stop'
done
