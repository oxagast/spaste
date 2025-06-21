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
#
# Babe! Let me lick your butthole!
#
# useage: ./paste-server.pl --conf spaste.conf

use strict;
use warnings;
use IO::Handle;
use Fcntl ("F_GETFL", "F_SETFL", "O_NONBLOCK");
use Socket;
use IO::Socket::SSL;
use threads;
use Config::Tiny;
use Getopt::Long qw (GetOptions);
$SIG{TERM} = $SIG{INT} = sub { die "Caught a sigterm $!" };
STDOUT->autoflush();
STDERR->autoflush();

if ($#ARGV + 1 ne 2) {
  print "Incorrect number of arguments.\n Useage:\n  $ARGV[0] --conf [file]\n";
  exit $SIG{TERM};
}
my ($logfile, $pasteroot, $host, $srvname, $port, $certfile, $keyfile, $pidfile);
my $cfgf = undef;
GetOptions('conf=s' => \$cfgf);
my $config = Config::Tiny->read($cfgf);
$host      = $config->{Server}{fqdn};
$srvname   = $config->{Server}{baseuri};
$port      = $config->{Server}{listenport};
$certfile  = $config->{SSL}{certfile};
$keyfile   = $config->{SSL}{keyfile};
$pidfile   = $config->{Settings}{pidfile};
$pasteroot = $config->{Server}{pasteroot};
$logfile   = $config->{Settings}{logfile};    # log
my $ver = "v1.1";                             # hell yea, new revision!
                                              # can we have a party
                                              # with lots of hookers?
                                              # bonus points for anal beads

if (-e $pidfile) {
  die
"SPaste is already running or the lockfile didn't get wiped!  If you are sure it is not running, remove $pidfile";
}
open(PIDF, ">", $pidfile) or die $!;
print PIDF $$ . "\n";
close(PIDF);
open(STDERR, ">>", $logfile) or die $!;
open(LOG,    '>>', $logfile) or die $!;
LOG->autoflush();
my $datet = purdydate();
print LOG "$datet Starting spaste $ver using $host:$port\n";
my $siteroot = $pasteroot;
$siteroot =~ s|/p/$||;
chdir "$siteroot" or die "$datet $!";
my $sock = IO::Socket::IP->new(
                               Listen    => SOMAXCONN,
                               LocalPort => $port,
                               Blocking  => 1,
                               ReuseAddr => 1
) or die "$datet $!";
umask(022);
my $WITH_THREADS = 1;    # the switch!!

while (1) {
  eval {
    my $cl = $sock->accept();    # threaded accept
    if ($cl) {
      $datet = purdydate();
      my $th = threads->create(\&server, $cl) or die "$datet $!";
      $th->detach() or print LOG "$datet Thread detach request failed. $!\n";
    }
  };    # eval
  if ($@) {
    print STDERR "ex: $@\n";
    exit(1);
  }
}    # forever
close(LOG);
close(STDERR);


sub server {
  my $cl = shift;

  # upgrade INET socket to SSL
  $cl = IO::Socket::SSL->start_SSL(
                                   $cl,
                                   SSL_server          => 1,
                                   SSL_cert_file       => $certfile,
                                   SSL_key_file        => $keyfile,
                                   SSL_verifycn_name   => $host,
                                   SSL_verifycn_scheme => 'default',
                                   SSL_hostname        => $host
  ) or die "$datet $@";

  # unblock
  my $flags = fcntl($cl, F_GETFL, 0) or die "$datet $cl->peerhost $!";

  #  fcntl($cl, F_SETFL, $flags | O_NONBLOCK) or die "$datet $cl->peerhost $!";  # nonblocking code ended with half docs
  fcntl($cl, F_SETFL, $flags) or die "$datet $cl->peerhost $!";
  my $rndid    = genuniq();
  my $filename = $pasteroot . $rndid;
  $datet = purdydate();
  print LOG $datet . " " . $cl->peerhost . "/" . $cl->peerport;
  print LOG " $rndid : storing at $pasteroot$rndid\n";
  print "$rndid : storing at $pasteroot$rndid\n";
  $datet = purdydate();
  print LOG $datet . " " . $cl->peerhost . "/" . $cl->peerport;
  print LOG " $rndid : serving at $srvname/p/$rndid\n";
  print "$rndid : serving at $srvname/p/$rndid\n";
  open(P, '>', $filename);
  while (my $line = $cl->getline()) {             # i can make getline work like this
    if ($line !~ m/[\x00\x01\x0E-\x16\x7F-\xFF]/) {   # non printable chars
      print P $line;
    }
    else {
      $datet = purdydate();
      print $cl "0x02 Nonprintable chars not supported.";
      print LOG $datet . " " . "Nonprintable chars not supported.";
      unlink($filename);
      return 1;
    }
  print $cl "$srvname/p/$rndid\n";

  }

  close(P);
  $cl->close();  # needs to be closed out way out here to avoid cutting document short
  return 0;
}


sub genuniq {
  my $pasid;        # for unique paste identifier
  my @set = ('A' .. 'Z', 'a' .. 'z', 0 .. 9);
  $pasid .= $set[rand($#set)] for 1 .. 8;
  return $pasid;    # push it back
}


sub purdydate {

  my ($sec, $min, $hour, $mday, $mon, $year, $wday, $yday, $isdst) = localtime(time);
  my $datetime = sprintf("%04d%02d%02d %02d:%02d:%02d",
                         $year + 1900,
                         $mon + 1, $mday, $hour, $min, $sec);
  return $datetime;
}


END {
  if ($cfgf) {
    if (-e $pidfile) {
      unless ($SIG{TERM} || $SIG{INT}) {
        print "Something unusual happened... check $logfile\n";
      }
      print LOG "Removing lockfile...\n";
      unlink($pidfile);
    }
    print LOG "Stopping SPaste process cleanly...\n";
  }
}

