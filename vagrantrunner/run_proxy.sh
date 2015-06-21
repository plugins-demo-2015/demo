#!/bin/bash

set -xe

TARGET_HOSTNAME='hello.weave.local'
DNS='10.23.11.10'

proxyid=$(docker run -d \
    --name demoproxy \
    --dns $DNS \
    --net=host \
    -p 80:80 \
    clusterhq/experimental-volumes-gui \
    python -c "from twisted.names.client import createResolver; from twisted.python import log; from twisted.internet import reactor; from twisted.web import proxy, server; import sys; resolver = createResolver(servers=[('$DNS', 53)]); reactor.installResolver(resolver); log.startLogging(sys.stdout); site = server.Site(proxy.ReverseProxyResource('$TARGET_HOSTNAME', 80, '')); reactor.listenTCP(80, site); reactor.run()")
