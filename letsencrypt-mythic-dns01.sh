#!/bin/bash
if [[ "$1" = "deploy_challenge" ]]; then
    echo " ++ setting DNS for $2 to $4"
    while read DNSDOMAIN DNSAPIPASSWORD; do
        if [[ "$2" == *$DNSDOMAIN ]] ; then
            RECORD=$(echo "_acme-challenge.$2" | sed -e "s/\\.$DNSDOMAIN\$//")
            curl -d "domain=$DNSDOMAIN" -d "password=$DNSAPIPASSWORD" -d "command=REPLACE $RECORD 300 TXT $4" "https://dnsapi.mythic-beasts.com/"
            echo sleeping 60 seconds for change to take effect..
            sleep 60
            break;
        fi
    done < ./dnsapi.config.txt
else
    echo "hook said..."
    echo "$1 $2 $3 $4"
fi
