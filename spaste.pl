#!/usr/bin/perl

#
#   __ _  _  __   ___  __  ____ ____
#  /  ( \/ )/ _\ / __)/ _\/ ___(_  _)
# (  O )  (/    ( (_ /    \___ \ )(
#  \__(_/\_\_/\_/\___\_/\_(____/(__)
#
# By oxagast, thanks to termbin.org creators for the idea.
# I would suggest creating an ssl user and pastebot user for this for security reasons.
# Set the permissions on your valid cert.pm and privkey.pem and on the directory on the
# webserver.
# useage: ./spaste.pl

#use strict;
use warnings;
use IO::Handle;
use Fcntl ( "F_GETFL", "F_SETFL", "O_NONBLOCK" );
use Socket;
use IO::Socket::SSL;
use threads;
STDOUT->autoflush();
my $proot   = "/var/www/html/"; # paste root if not default
my $host    = "spaste.online"; # change to your server
my $srvname = "https://" . $host;
my $port    = "8888";
my $cer     = "/etc/letsencrypt/live/" . $host . "/cert.pem"; # use your cert
my $key     = "/etc/letsencrypt/live/" . $host . "/privkey.pem"; # use your privkey
my $sock = IO::Socket::IP->new(
    Listen    => SOMAXCONN,
    LocalPort => $port,
    Blocking  => 0,
    ReuseAddr => 1
) or die $!;
my $WITH_THREADS = 0;    # the switch!!

while (1) {
    eval {
        my $cl = $sock->accept(); # threaded accept
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
    my $pasid; # for unique paste identifier
    my @set = ( 'A' .. 'Z', 'a' .. 'z', 0 .. 9 );
    my $num = $#set;

    $pasid .= $set[ rand($num) ] for 1 .. 8;
    return $pasid; # push it back
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
            while ( -e "$proot$rndid" ) {
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
    print " : storing at " . $proot . $rndid . "\n";
    my $filename =  $proot . $rndid;
    open( P, '>', $filename ) or die $!;
    print P $recv;
    close(P);
    print $cl "$srvname/$rndid" . "\n";
    return 1;
}

