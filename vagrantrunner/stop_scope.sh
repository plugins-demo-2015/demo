#!/bin/sh -x
for m in master runner
do vagrant ssh $m -c 'sudo /usr/bin/scope stop'
done
