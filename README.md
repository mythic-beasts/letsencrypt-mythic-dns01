letsencrypt-mythic-dns01
========================

These are hook scripts for the [dehydrated client](https://github.com/lukas2511/dehydrated)
for verifying Let's Encrypt SSL certificates using 
[DNS validation](https://letsencrypt.github.io/acme-spec/#rfc.section.7.4) with the [Mythic Beasts](https://www.mythic-beasts.com) DNS API.

A [step-by-step guide](https://www.mythic-beasts.com/support/domains/letsencrypt_dns_01) to using this script can be found on the [Mythic Beasts](https://www.mythic-beasts.com/) website.

The bash version of this script was originally written by [David Earl](https://github.com/davidearl).

Usage
-----

To use these scripts you will need to set a DNS API password for your domains
using the [Mythic Beasts control panel](https://ctrlpanel.mythic-beasts.com)

Then create a file called ``dnsapi.config.txt`` containing your domain name and
password.  You can add multiple domains, one per line:

````
example.net myS3cretPassword
example.com myOtherS3cretPassword
````

You can then provide this script to the ``-k`` option to ``letsencrypt.sh``:

````
letsencrypt.sh -c -t dns-01 -k ./letsencrypt-mythic-dns01.sh
````

The script will look in the current directory for the ``dnsapi.config.txt``
file.

Perl and Shell versions of this hook are provided.

