#!/bin/bash

# a test of creating and moving a volume using the HTTP API
set -e

KEY_FILE=/etc/flocker/plugin.key
CERT_FILE=/etc/flocker/plugin.crt
CA_FILE=/etc/flocker/cluster.crt
CONTROL_SERVICE=54.158.167.229 # 10.143.219.242
RUNNER_1=54.145.174.255 # 10.152.24.122
RUNNER_2=54.144.197.228 # 10.111.199.253

# where to initially create the volume
START_NODE=2dfadd04-b0ea-4d4e-ad07-ccf386efc404
# where to move it to
END_NODE=248f8732-7136-4821-8762-e145ca63ecdc

list-nodes() {
    # a very basic test that creates a volume using the HTTP API
    # and then moves it
    curl -s \
        --cacert $CA_FILE \
        --cert $CERT_FILE \
        --key $KEY_FILE \
        https://$CONTROL_SERVICE:4523/v1/state/nodes
}

list-volumes-config() {
    # a very basic test that creates a volume using the HTTP API
    # and then moves it
    curl -s \
        --cacert $CA_FILE \
        --cert $CERT_FILE \
        --key $KEY_FILE \
        https://$CONTROL_SERVICE:4523/v1/configuration/datasets
}

list-volumes() {
    # a very basic test that creates a volume using the HTTP API
    # and then moves it
    curl -s \
        --cacert $CA_FILE \
        --cert $CERT_FILE \
        --key $KEY_FILE \
        https://$CONTROL_SERVICE:4523/v1/state/datasets
}

create-volume() {
    local volumename=$1
    if [[ -z "$volumename" ]]; then
        echo "Please supply a volumename"
        exit 1
    fi
    curl -s \
        --cacert $CA_FILE \
        --cert $CERT_FILE \
        --key $KEY_FILE \
        -XPOST \
        --header "Content-type: application/json" \
        -d "{\"primary\":\"$START_NODE\",\"maximum_size\": 107374182400, \"metadata\": {\"name\": \"$volumename\"}}" \
        https://$CONTROL_SERVICE:4523/v1/configuration/datasets
}

move-volume() {
    local volumeid=$1
    if [[ -z "$volumeid" ]]; then
        echo "Please supply a volumeid"
        exit 1
    fi
    curl -s \
        --cacert $CA_FILE \
        --cert $CERT_FILE \
        --key $KEY_FILE \
        -XPOST \
        --header "Content-type: application/json" \
        -d "{\"primary\":\"$END_NODE\"}" \
        https://$CONTROL_SERVICE:4523/v1/configuration/datasets/$volumeid
}

usage() {
cat <<EOF
Usage:
./test.sh list-nodes
./test.sh list-volumes
./test.sh create-volume <volumename>
./test.sh move-volume <volumeid>
./test.sh help
EOF
    exit 1
}

main() {
    case "$1" in
    list-nodes)         shift; list-nodes $@;;
    list-volumes)       shift; list-volumes $@;;
    list-volumes-config)shift; list-volumes-config $@;;
    create-volume)      shift; create-volume $@;;
    move-volume)        shift; move-volume $@;;
    *)                  usage $@;;
    esac
}

main "$@"