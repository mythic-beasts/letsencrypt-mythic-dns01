#!/usr/bin/env bash

# Copyright (c) 2018 Mythic Beasts Ltd

group_args() {
    local nl
    nl='
'
    ARGS=''
    while [ "$1" ]; do ARGS="$ARGS$1 $2 $3$nl"; shift 3; done
    export ARGS
}

action=$1
shift

case $action in
    deploy_challenge|clean_challenge)
        group_args
        "$(dirname "$0")"/${action/_/-}/mythic-dns01
        ;;
esac
