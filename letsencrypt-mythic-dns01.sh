#!/bin/sh

#
# Simple hook script for dehydrated[1] for using Mythic Beasts DNS API
#
# [1] https://github.com/lukas2511/dehydrated

CONFIG=${MYTHIC_DNS_CONFIG:-/etc/dehydrated/dnsapi.config.txt}

# configure the busy wait loop; max time is $SLEEP * $MAXTRIES
SLEEP=5
MAXTRIES=60

# all our public authoritative servers
SERVERS="ns1.mythic-beasts.com ns2.mythic-beasts.com ns3.mythic-beasts.com"

# dig options
DIGOPT='+time=1 +tries=1 +short'

wait_for_dns() {
    local key val i s
    key="$1" val="$2"
    echo " ++ waiting for DNS record to go live..."
    for i in $(seq $MAXTRIES); do
        sleep $SLEEP
        for s in $SERVERS; do
            dig $DIGOPT @$s $key txt | grep -q $val || continue 2
        done
        break
    done
    if [ "$i" -eq "$MAXTRIES" ]; then
        echo challenge record not found in DNS >&2
        exit 1
    fi
}

call_api() {
    local action key val dns_domain dns_api_pass rr_part
    action="$1" key="$2" val="$3"
    while read dns_domain dns_api_pass; do
        case $key in
        *$dns_domain)
            rr_part=$(basename $key .$dns_domain)
            echo -n "$dns_api_pass" |
                curl --data-urlencode "domain=$dns_domain" --data-urlencode "password@-" --data-urlencode "command=$action $rr_part 30 TXT $val" https://dnsapi.mythic-beasts.com/
            break
            ;;
        esac
    done < $CONFIG
}

DNS_NAME="_acme-challenge.$2"
case $1 in
    deploy_challenge)
        echo " ++ setting DNS for $2 to $4"
        call_api REPLACE $DNS_NAME $4
        wait_for_dns $DNS_NAME $4
        ;;
    clean_challenge)
        echo " ++ cleaning DNS for $2 with $4"
        call_api DELETE $DNS_NAME $4
        ;;
esac
