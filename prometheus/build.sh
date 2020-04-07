#!/usr/bin/env bash

# This script uses arg $1 (name of *.jsonnet file to use) to generate the manifests/*.yaml files.

set -e
set -x
# only exit with zero if all commands of the pipeline exit successfully
set -o pipefail

# Make sure to start with a clean 'manifests' dir
rm -rf manifests
mkdir -p manifests/setup

# TODO: Adapt to HA setup (multiple masters)
master_ip="['$(kubectl get nodes -l node-role.kubernetes.io/master -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')']"

jsonnet --ext-code master_ip=$master_ip -J vendor -m manifests "${1-prometheus.jsonnet}" \
    | xargs -I{} sh -c 'cat {} | gojsontoyaml > {}.yaml; rm -f {}' -- {}
    # ^^^ is optional, but we would like to generate yaml, not json

