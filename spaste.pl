#!/usr/bin/perl

#
#   __ _  _  __   ___  __  ____ ____
#  /  ( \/ )/ _\ / __)/ _\/ ___(_  _)
# (  O )  (/    ( (_ /    \___ \ )(
#  \__(_/\_\_/\_/\___\_/\_(____/(__)
#

# I would suggest creating an ssl user and pastebot user for this for security reasons.
# Set the permissions on your valid cert.pm and privkey.pem and on the directory on the
# webserver (i use /var/www/html/paste/)
# useage: ./spaste.pl

#use strict;
use warnings;
use IO::Handle;
use Fcntl ( "F_GETFL", "F_SETFL", "O_NONBLOCK" );
use Socket;
use IO::Socket::SSL;
use threads;
STDOUT->autoflush();
my $srvname = "https://oxagast.org";
my $port    = "8888";
my $cer     = "/etc/letsencrypt/live/oxagast.org/cert.pem";
my $key     = "/etc/letsencrypt/live/oxagast.org/privkey.pem";

#my $sock = IO::Socket::SSL->new (Listen => SOMAXCONN, LocalPort => $port,
# Blocking => 0, Timeout => 0, ReuseAddr => 1, SSL_server => 1,
# SSL_cert_file => $cer, SSL_key_file => $key) or die $@;
my $sock = IO::Socket::IP->new(
    Listen    => SOMAXCONN,
    LocalPort => $port,
    Blocking  => 0,
    ReuseAddr => 1
) or die $!;
my $WITH_THREADS = 0;    # the switch!!

while (1) {
    eval {
        my $cl = $sock->accept();
        if ($cl) {
            my $th = threads->create( \&client, $cl );
            $th->detach();
        }
    };                   # eval
    if ($@) {
        print STDERR "ex: $@\n";
        exit(1);
    }
}    # forever

sub genuniq {
    my $pasid;
    my @set = ( 'A' .. 'Z', 'a' .. 'z', 0 .. 9 );
    my $num = $#set;

    $pasid .= $set[ rand($num) ] for 1 .. 8;
    return $pasid;
}

sub client    # worker
{
    my $cl = shift;

    # upgrade INET socket to SSL
    $cl = IO::Socket::SSL->start_SSL(
        $cl,
        SSL_server    => 1,
        SSL_cert_file => $cer,
        SSL_key_file  => $key
    ) or die $@;

    # unblock
    my $flags = fcntl( $cl, F_GETFL, 0 ) or die $!;
    fcntl( $cl, F_SETFL, $flags | O_NONBLOCK ) or die $!;
    print STDERR $cl->peerhost . "/" . $cl->peerport . "\n";

    while (1) {
        my $ret = "";

        # for (my $i = 0; $i < 100; $i ++)
        $ret = $cl->read( $recv, 50000 );

        # faults here if with threads!

        if ( defined($ret) && length($recv) > 0 ) {
            $rndid = genuniq();
            if ( -e "/var/www/html/paste/$rndid" ) {
                $rndid = genuinq();
                writef( $rndid, $recv, $cl );
            }
            else {
                writef( $rndid, $recv, $cl );
            }
            $cl->close();

        }
    }

}

sub writef() {
    my ( $rndid, $recv, $cl ) = @_;
    print $rndid;
    print " : storing at /var/www/html/paste/$rndid" . "\n";
    my $filename = "/var/www/html/paste/$rndid";
    open( P, '>', $filename ) or die $!;
    print P $recv;
    close(P);
    print $cl "$srvname/paste/$rndid" . "\n";
    return 1;
}

