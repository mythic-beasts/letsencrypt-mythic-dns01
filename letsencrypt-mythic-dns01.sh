#!/bin/sh

#
# Simple hook script for letsencrypt.sh[1] for using Mythic Beasts DNS API
#
# [1] https://github.com/lukas2511/letsencrypt.sh

CONFIG=dnsapi.config.txt

if [ "$1" = "deploy_challenge" ]; then
    echo " ++ setting DNS for $2 to $4"
    while read DNSDOMAIN DNSAPIPASSWORD; do
        case $2 in
        *$DNSDOMAIN)
            RECORD=$(echo "_acme-challenge.$2" | sed -e "s/\\.$DNSDOMAIN\$//")
            echo -n "$DNSAPIPASSWORD" |
                curl --data-urlencode "domain=$DNSDOMAIN" --data-urlencode "password@-" --data-urlencode "command=REPLACE $RECORD 300 TXT $4" https://dnsapi.mythic-beasts.com/
            echo " ++ sleeping 60 seconds for change to take effect..."
            sleep 60
            break
            ;;
        esac
    done < $CONFIG
else
    echo "hook said..."
    echo "$1 $2 $3 $4"
fi
