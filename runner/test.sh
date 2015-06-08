#!/bin/sh

# a very basic test that creates a volume using the HTTP API
# and then moves it
curl -s \
    --cacert $PWD/_files/cluster.crt \
    --cert $PWD/_files/user.crt \
    --key $PWD/_files/user.key \
    https://172.16.255.250:4523/v1/state/nodes