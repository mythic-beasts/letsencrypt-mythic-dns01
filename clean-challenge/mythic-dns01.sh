#!/usr/bin/env bash

# Copyright (C) 2018 Mythic Beasts Ltd

. "$(dirname "$0")"/../common/mythic-dns01-common.sh

echo -n "$ARGS" | while read domain filename token; do
    echo " ++ cleaning DNS for $domain"
    call_api DELETE _acme-challenge.$domain $token
done
