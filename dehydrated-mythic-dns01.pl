#!/usr/bin/perl -w

use LWP::UserAgent;
use File::Slurp;

my $verbose = 1;

my $CONFIG="./dnsapi.config.txt";

sub get_password($) {
    my ($host) = @_;
    foreach (read_file($CONFIG, chomp => 1)) {
        m/^([^ ]+) (.*)$/;
        my ($domain, $password) = ($1, $2);
        if ($host =~ m/^(.+\.)?\Q$domain\E/) {
            return ($domain, $password);
        }
    }
    die "Can't find password for '$host'";
}

my ($action, $domain, $token, $data) = @ARGV;

if ($action eq 'deploy_challenge') {
    print " ++ setting DNS for $domain to $data\n" if $verbose;
    my $host = "_acme-challenge.$domain";
    my ($base_domain, $password) = get_password($host);
    $host =~ s/\.\Q$base_domain\E$//;
    my $ua = new LWP::UserAgent();
    my $res = $ua->post(
        "https://dnsapi.mythic-beasts.com", 
        {
            domain => $base_domain, 
            password => $password, 
            command => "REPLACE $host 300 TXT $data",
        },
    );
    if (!$res->is_success()) {
        die $res->status_line();
    }
    print " ++ waiting 60s for changes to take effect\n" if $verbose;
    sleep(60);
}
else {
    print "Hook called with: $action $domain, $token, $data\n" if $verbose;
}
