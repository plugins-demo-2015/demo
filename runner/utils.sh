#!/bin/sh

# return the private or public IP of a named node
function get-node-ip() {
  local node="$1"; shift;
  local field="$1"; shift;
  vagrant awsinfo -m $node -p | jq -r ".$field"
}

function get_aws_value() {
  local field="$1";
  cat $DIR/../.aws_secrets | grep $field | awk '{print $2}'
}