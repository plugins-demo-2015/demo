#!/bin/bash

set -xe

DNS='10.23.11.10'

weave expose
ip route add $DNS dev weave

TARGET_HOST=$(dig +short hello.weave.local @${DNS})

proxyid=$(docker run -d \
    --name demoproxy \
    --net=host \
    -p 80:80 \
    clusterhq/experimental-volumes-gui \
    python -c "from twisted.python import log; from twisted.internet import reactor; from twisted.web import proxy, server; import sys; log.startLogging(sys.stdout); site = server.Site(proxy.ReverseProxyResource('$TARGET_HOST', 80, '')); reactor.listenTCP(80, site); reactor.run()")
