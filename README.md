letsencrypt-mythic-dns01
========================

These are hook scripts for the [letsencrypt.sh client](https://github.com/lukas2511/letsencrypt.sh)
for verifying Let's Encrypt SSL certificates using 
[DNS validation](https://letsencrypt.github.io/acme-spec/#rfc.section.7.4) with the [Mythic Beasts](https://www.mythic-beasts.com) DNS API.

Usage
-----

To use these scripts you will need to set a DNS API password for your domains
using the [Mythic Beasts control panel](https://ctrlpanel.mythic-beasts.com)

The create a file called dnsapi.config.txt containing your domain name and
password.  You can add multiple domains, one per line:

````
example.net myS3cretPassword
example.com myOtherS3cretPassword
````

You can then provide this script to the -k option to letsencrypt.sh:

````
letsencrypt.sh -c -t dns-01 -k ./letsencrypt-mythic-dns01.sh
````

The script will look in the current directory for the dnsapi.config.txt file.

Perl and Shell versions of this hook are provided.  The Perl version has the minor advantage that your DNS API password is not exposed on the command line invocation of curl.






