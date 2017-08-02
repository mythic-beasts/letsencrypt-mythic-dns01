#!/bin/sh

#
# Simple hook script for letsencrypt.sh[1] for using Mythic Beasts DNS API
#
# [1] https://github.com/lukas2511/letsencrypt.sh

CONFIG=dnsapi.config.txt
call_api () {
    ACTION=$1
    while read DNSDOMAIN DNSAPIPASSWORD; do
        case $2 in
        *$DNSDOMAIN)
            RECORD=$(echo "_acme-challenge.$2" | sed -e "s/\\.$DNSDOMAIN\$//")
            echo -n "$DNSAPIPASSWORD" |
                curl --data-urlencode "domain=$DNSDOMAIN" --data-urlencode "password@-" --data-urlencode "command=$ACTION $RECORD 30 TXT $4" https://dnsapi.mythic-beasts.com/
            if [ "$ACTION" = "REPLACE" ]; then
                echo " ++ sleeping 60 seconds for change to take effect..."
                sleep 60
            fi
            break
            ;;
        esac
    done < $CONFIG
}
if [ "$1" = "deploy_challenge" ]; then
    echo " ++ setting DNS for $2 to $4"
    call_api REPLACE $2 $3 $4
elif [ "$1" = "clean_challenge" ]; then
    echo " ++ cleaning DNS for $2 with $4"
    call_api DELETE $2 $3 $4
else
    echo "hook said..."
    echo "$1 $2 $3 $4"
fi
