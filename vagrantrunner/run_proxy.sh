#!/usr/bin/bash

TARGET_HOSTNAME='hello.weave.local'

docker network create -d weave proxynet

proxyid=$(docker run -d \
    -p 80:80 \
    clusterhq/experimental-volumes-gui \
    python -c "from twisted.internet import reactor; from twisted.web import proxy, server; site = server.Site(proxy.ReverseProxyResource('$TARGET_HOSTNAME', 80, '')); reactor.listenTCP(80, site); reactor.run()")

docker network service create proxyservice proxynet
docker network service join $proxyid proxyservice proxynet

#docker run -d \
#    --name haproxy \
#    -v $PWD/haproxy/haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg:ro \
#    haproxy:1.5