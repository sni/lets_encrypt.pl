#!/usr/bin/env perl
#
# Usage: ./lets_encrypt.pl <domain>[,alias] <htdocs folder> [test]
#
# Url: https://github.com/sni/lets_encrypt.pl
#

use warnings;
use strict;
use Crypt::LE;
use Crypt::OpenSSL::PKCS10;

my $domain   = $ARGV[0];
my $htdocs   = $ARGV[1] or die("usage: $0 <domain>[,alias] <htdocs folder> [test]");
my $testmode = $ARGV[2];

(-w $htdocs && -d $htdocs) || die("cannot write to $htdocs: $!");

my $le = Crypt::LE->new(
    live    => (defined $testmode ? 0 : 1),
    debug   => 0,
);

# load and generate account key
my $basefile = (split(/,/mx,$domain))[0];
if(-f 'account.key') {
    $le->load_account_key('account.key');
} else {
    $le->generate_account_key();
    _write('account.key', $le->account_key());
    print "account.key written\n";
}

# generate request
$le->generate_csr($domain);
$le->csr() or die("failed to generate csr ".$le->error_details());
_write($basefile.'.csr', $le->csr());

$le->register();
$le->accept_tos();
$le->request_challenge();
$le->accept_challenge(\&_process_challenge);
$le->verify_challenge();
$le->request_certificate();
my $cert   = $le->certificate() or die("failed: ".$le->error_details());
$le->request_issuer_certificate();
my $issuer = $le->issuer()      or die("failed: ".$le->error_details());
`rm -rf $basefile.csr '$htdocs/.well-known'`;
_write($basefile.'.key', $le->csr_key());
printf("%s.key written%s\n", $basefile, (defined $testmode ? ' (non-production keys)' : ''));
_write($basefile.'.crt', $cert."\n".$issuer);
printf("%s.crt written%s\n", $basefile, (defined $testmode ? ' (non-production keys)' : ''));
exit;

############################################################################
sub _process_challenge {
    my($challenge) = @_;
    mkdir($htdocs.'/.well-known');
    mkdir($htdocs.'/.well-known/acme-challenge');
    _write($htdocs.'/.well-known/acme-challenge/'.$challenge->{token}, $challenge->{token}.'.'.$challenge->{fingerprint});
    return 1;
}

sub _write {
    my($file, $data) = @_;
    open(my $fh, '>', $file) or die("cannot write to $file: $!");
    print $fh $data;
    close($fh);
    return 1;
}
