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

use strict;
use warnings;
use IO::Handle;
use Fcntl ( "F_GETFL", "F_SETFL", "O_NONBLOCK" );
use Socket;
use IO::Socket::SSL;
use threads;
chdir "/var/www/spaste/";
STDOUT->autoflush();
my $logfile = "/var/log/spaste.log"; # log
my $proot   = "/var/www/html/";     # paste root if not default
my $host    = "spaste.online";      # change to your server
my $srvname = "https://" . $host;
my $port    = "8888";
my $cer  = "/etc/letsencrypt/live/" . $host . "/cert.pem";    # use your cert
my $key  = "/etc/letsencrypt/live/" . $host . "/privkey.pem"; # use your privkey
my $sock = IO::Socket::IP->new(
    Listen    => SOMAXCONN,
    LocalPort => $port,
    Blocking  => 0,
    ReuseAddr => 1
) or die $!;
my $WITH_THREADS = 0;                                         # the switch!!

while (1) {
    eval {
        my $cl = $sock->accept();                             # threaded accept
        if ($cl) {
            my $th = threads->create( \&client, $cl );
            $th->detach();
        }
    };    # eval
    if ($@) {
        print STDERR "ex: $@\n";
        exit(1);
    }
}    # forever

sub client    # worker
{
    my $cl = shift;
    open(LOG, '>>', $logfile) or die $!;
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
    print LOG $cl->peerhost . "/" . $cl->peerport . "\n";

    while (1) {
        my $ret = "";

        # for (my $i = 0; $i < 100; $i ++)
        $ret = $cl->read( my $recv, 50000 );

        # faults here if with threads!
        my $uniq = 0;
        if ( defined($ret) && length($recv) > 0 ) {
            my $rndid = "";
            while ( $uniq != 1 ) {
                $rndid = genuniq();
                if ( -e "$proot$rndid" ) {
                    $uniq = 0;
                }
                else {
                    $uniq = 1;
                }
                if ( $uniq == 1 ) {
                    writef( $rndid, $recv, $cl, $logfile );
                }
            }
            $cl->close();

        }
    }
    close(LOG);
}

sub writef() {
    my ( $rndid, $recv, $cl, $logfile ) = @_;
    open(LOG, '>>', $logfile) or die $!;
    print LOG "$rndid : storing at $proot$rndid\n";
    print "$rndid : storing at $proot$rndid\n";
    print LOG "$rndid : serving at $srvname/$rndid\n";
    print "$rndid : serving at $srvname/$rndid\n";
    my $filename = $proot . $rndid;
    open( P, '>', $filename ) or die $!;
    print P $recv;
    close(P);
    print $cl "$srvname/$rndid" . "\n";
    close(LOG);

    return 1;
}

sub genuniq {
    my $pasid;    # for unique paste identifier
    my @set = ( 'A' .. 'Z', 'a' .. 'z', 0 .. 9 );
    my $num = $#set;

    $pasid .= $set[ rand($num) ] for 1 .. 8;
    return $pasid;    # push it back
}
