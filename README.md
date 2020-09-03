dehydrated-mythic-dns01
=======================

These are hook scripts for the [dehydrated client](https://github.com/lukas2511/dehydrated)
for verifying Let's Encrypt SSL certificates using 
[DNS validation](https://letsencrypt.github.io/acme-spec/#rfc.section.7.4) with the [Mythic Beasts](https://www.mythic-beasts.com) DNS API.

Note that this hook currently uses the older [DNS API v1](https://www.mythic-beasts.com/support/api/dns).  Support for the [DNS API v2](https://www.mythic-beasts.com/support/api/dnsv2) is planned.

A [step-by-step guide](https://www.mythic-beasts.com/support/domains/letsencrypt_dns_01) to using this script can be found on the [Mythic Beasts](https://www.mythic-beasts.com/) website.

The script was originally written by [David Earl](https://github.com/davidearl).

Usage
-----

To use these scripts you will need to set a DNS API password for your domains
using the [Mythic Beasts control panel](https://ctrlpanel.mythic-beasts.com)

Then create the file `/etc/dehydrated/dnsapi.config.txt` containing your domain
name and password. You can add multiple domains, one per line:

````
example.net myS3cretPassword
example.com myOtherS3cretPassword
````

To tell `dehydrated` to use the hook script, provide its path via the `-k`
option. You will also need `-t dns-01` to use DNS-01 validation:

````Shell
dehydrated -c -t dns-01 -k .../path/to/dehydrated-mythic-dns01.sh
````

Or you can set the `HOOK` and `CHALLENGETYPE` configuration variables, by
creating the file `/etc/dehydrated/conf.d/hook.sh` with this content:

````
HOOK=.../path/to/dehydrated-mythic-dns01.sh
CHALLENGETYPE=dns-01
````

If you need to combine this hook with others, take a look at
[dehydrated-code-rack](https://github.com/mythic-beasts/dehydrated-code-rack).
Link to the scripts something like this:

````Shell
for d in common clean-challenge deploy-challenge; do
    mkdir -p /etc/dehydrated/hooks/$d
    ln -s $d/mythic-dns01 /etc/dehydrated/hooks/$d
done
````
