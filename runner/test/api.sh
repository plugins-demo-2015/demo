#!/bin/bash

# a test of creating and moving a volume using the HTTP API
set -e

KEY_FILE=/etc/flocker/plugin.key
CERT_FILE=/etc/flocker/plugin.crt
CA_FILE=/etc/flocker/cluster.crt
CONTROL_SERVICE=54.204.134.124 # 10.229.91.29
RUNNER_1=54.163.111.97 # 10.71.204.72
RUNNER_2=54.158.107.49 # 10.142.8.207

# where to initially create the volume
START_NODE=928beef5-e33e-48ba-b5c3-e653c73649a8
# where to move it to
END_NODE=f273c8c9-7cc6-44a9-af9d-f1524d6077f7

list-nodes() {
    # a very basic test that creates a volume using the HTTP API
    # and then moves it
    echo "Check list nodes works"
    curl \
        --cacert /etc/flocker/cluster.crt \
        --cert /etc/flocker/plugin.crt \
        --key /etc/flocker/plugin.key \
        https://54.204.134.124:4523/v1/state/nodes
}

list-volumes() {
    # a very basic test that creates a volume using the HTTP API
    # and then moves it
    echo "Check list nodes works"
    curl \
        --cacert /etc/flocker/cluster.crt \
        --cert /etc/flocker/plugin.crt \
        --key /etc/flocker/plugin.key \
        https://54.204.134.124:4523/v1/state/datasets
}

create-volume() {
    local volumename=$1
    if [[ -z "$volumename" ]]; then
        echo "Please supply a volumename"
        exit 1
    fi
    echo "Create a new volume"
    curl \
        --cacert /etc/flocker/cluster.crt \
        --cert /etc/flocker/plugin.crt \
        --key /etc/flocker/plugin.key \
        -XPOST \
        --header "Content-type: application/json" \
        -d "{\"primary\":\"$START_NODE\",\"maximum_size\": 107374182400, \"metadata\": {\"name\": \"$volumename\"}}" \
        https://54.204.134.124:4523/v1/configuration/datasets
}

move-volume() {
    local volumeid=$1
    if [[ -z "$volumeid" ]]; then
        echo "Please supply a volumeid"
        exit 1
    fi
    echo "Move a volume"
    curl \
        --cacert /etc/flocker/cluster.crt \
        --cert /etc/flocker/plugin.crt \
        --key /etc/flocker/plugin.key \
        -XPOST \
        --header "Content-type: application/json" \
        -d "{\"primary\":\"$END_NODE\"}" \
        https://54.204.134.124:4523/v1/configuration/datasets/$volumeid
}

usage() {
cat <<EOF
Usage:
./test.sh list-nodes
./test.sh list-volumes
./test.sh create-volume <volumename>
./test.sh move-volume <volumename>
./test.sh help
EOF
    exit 1
}

main() {
    case "$1" in
    list-nodes)         shift; list-nodes $@;;
    list-volumes)       shift; list-volumes $@;;
    create-volume)      shift; create-volume $@;;
    move-volume)        shift; move-volume $@;;
    *)                  usage $@;;
    esac
}

main "$@"