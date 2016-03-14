#!/bin/bash

#
# Simple hook script for letsencrypt.sh[1] for using Mythic Beasts DNS API
#
# Note that this script has the flaw that your DNS API password is exposed in
# the curl command line, and so is visible to other users on the machine.
# Please see letsencrypt-mythic-dns01.pl for an alternative.
#
# [1] https://github.com/lukas2511/letsencrypt.sh

CONFIG=dnsapi.config.txt

if [[ "$1" = "deploy_challenge" ]]; then
    echo " ++ setting DNS for $2 to $4"
    while read DNSDOMAIN DNSAPIPASSWORD; do
        if [[ "$2" == *$DNSDOMAIN ]] ; then
            RECORD=$(echo "_acme-challenge.$2" | sed -e "s/\\.$DNSDOMAIN\$//")
            curl --data-urlencode "domain=$DNSDOMAIN" --data-urlencode "password=$DNSAPIPASSWORD" --data-urlencode "command=REPLACE $RECORD 300 TXT $4" "https://dnsapi.mythic-beasts.com/"
            echo " ++ sleeping 60 seconds for change to take effect..."
            sleep 60
            break;
        fi
    done < $CONFIG
else
    echo "hook said..."
    echo "$1 $2 $3 $4"
fi
