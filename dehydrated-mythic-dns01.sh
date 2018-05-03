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
    for i in $(seq $MAXTRIES); do
        for s in $SERVERS; do
            if ! dig $DIGOPT @$s $key txt | grep -q -e $val; then
               sleep $SLEEP
               continue 2
            fi
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

action=$1
shift

case $action in
    deploy_challenge)
        args=''
        while [ "$1" ]; do args="$args$1 $3\n"; shift 3; done
        echo -n "$args" | while read domain token; do
            echo " ++ setting DNS for $domain"
            call_api REPLACE _acme-challenge.$domain $token
        done
        echo -n "$args" | while read domain token; do
            echo " ++ waiting DNS for $domain"
            wait_for_dns _acme-challenge.$domain $token
        done
        ;;
    clean_challenge)
        args=''
        while [ "$1" ]; do args="$args$1 $3\n"; shift 3; done
        echo -n "$args" | while read domain token; do
            echo " ++ cleaning DNS for $domain"
            call_api DELETE _acme-challenge.$domain $token
        done
        ;;
esac
