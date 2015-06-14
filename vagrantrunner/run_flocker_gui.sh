#!/bin/bash
cd unofficial-flocker-tools
export CERTS=$PWD
export CONTROL_SERVICE=172.16.70.250
export USERNAME=flockerdemo
docker run --name experimental-volumes-gui \
    -d -p 80:80 \
    -e CONTROL_SERVICE=$CONTROL_SERVICE \
    -e USERNAME=user \
    -e CERTS_PATH=/ \
    -v $CERTS/$USERNAME.key:/user.key \
    -v $CERTS/$USERNAME.crt:/user.crt \
    -v $CERTS/cluster.crt:/cluster.crt \
    clusterhq/experimental-volumes-gui
sleep 5
if which boot2docker >/dev/null; then
    open "http://$(boot2docker ip)/client/#/nodes/list"
else
    echo "Open http://localhost/client/#/nodes/list in a browser."
fi
