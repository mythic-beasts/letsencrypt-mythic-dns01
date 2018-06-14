#!/usr/bin/env bash

# Copyright (c) 2018 Mythic Beasts Ltd

action=$1
shift
args=''
while [ -n "$3" ]; do args="$args$1 $2 $3\n"; shift 3; done
export ARGS="$args"

case $action in
    deploy_challenge)
        "$(dirname "$0")"/deploy-challenge/mythic-dns01
        ;;
    clean_challenge)
        "$(dirname "$0")"/clean-challenge/mythic-dns01
        ;;
esac
