#!/bin/sh

#
# Simple hook script for dehydrated[1] for using Mythic Beasts DNS API
#
# [1] https://github.com/lukas2511/dehydrated

CONFIG=${MYTHIC_DNS_CONFIG:-/etc/dehydrated/dnsapi.config.txt}

# configure the busy wait loop; max time is $sleep * $maxtries
sleep=2
maxtries=49
servers=3

call_api () {
    ACTION=$1
    while read DNSDOMAIN DNSAPIPASSWORD; do
        case $2 in
        *$DNSDOMAIN)
            FULLRR=_acme-challenge.$2
            RECORD=$(basename $FULLRR .$DNSDOMAIN)
            echo -n "$DNSAPIPASSWORD" |
                curl --data-urlencode "domain=$DNSDOMAIN" --data-urlencode "password@-" --data-urlencode "command=$ACTION $RECORD 30 TXT $4" https://dnsapi.mythic-beasts.com/
            if [ "$ACTION" = REPLACE ]; then
                echo " ++ waiting for DNS record to go live..."
                for i in $(seq $maxtries); do
                    server=ns$(expr $i % $servers).mythic-beasts.com
                    test "$(dig @$server +short $FULLRR txt)" && break
                    sleep $sleep
                done
                if [ "$i" -eq "$maxtries" ]; then
                    echo challenge record not found in DNS >&2
                    exit 1
                fi
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
    echo "$@"
fi
