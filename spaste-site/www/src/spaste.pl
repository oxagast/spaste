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
use Fcntl ("F_GETFL", "F_SETFL", "O_NONBLOCK");
use Socket;
use IO::Socket::SSL;
use threads;
STDOUT->autoflush();
STDERR->autoflush();
my $logfile = "/var/log/spaste.log";                  # log
my $proot   = "/var/www/spaste.oxasploits.com/p/";    # paste root if not default
my $host    = "spaste.oxasploits.com";                # change to your server
my $srvname = "https://" . $host;
my $port    = "8888";
my $cer = "/etc/letsencrypt/live/" . $host . "/cert.pem";       # use your cert
my $key = "/etc/letsencrypt/live/" . $host . "/privkey.pem";    # use your privkey
my $ver = "v0.5";
open(STDERR, ">>", $logfile) or die $!;
open(LOG, '>>', $logfile) or die $!;
LOG->autoflush();
my $datet = purdydate();
print LOG "$datet Starting spaste $ver using $host:$port\n";
chdir "/var/www/spaste.oxasploits.com/" or die "$datet $!";
my $sock = IO::Socket::IP->new(
                               Listen    => SOMAXCONN,
                               LocalPort => $port,
                               Blocking  => 1,
                               ReuseAddr => 1
) or die "$datet $!";
umask(022);
my $WITH_THREADS = 1;                                           # the switch!!

while (1) {
  eval {
    my $cl = $sock->accept();                                   # threaded accept
    if ($cl) {
      $datet = purdydate();
      my $th = threads->create(\&client, $cl) or die "$datet $!";
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



sub client    # worker
{
  my $cl = shift;
  # upgrade INET socket to SSL
  $cl = IO::Socket::SSL->start_SSL(
                                   $cl,
                                   SSL_server    => 1,
                                   SSL_cert_file => $cer,
                                   SSL_key_file  => $key
  ) or die "$datet $@";
  # unblock
  my $flags = fcntl($cl, F_GETFL, 0) or die "$datet $cl->peerhost $!";
  fcntl($cl, F_SETFL, $flags | O_NONBLOCK) or die "$datet $cl->peerhost $!";
  while (1) {
    my $ret = "";
    $ret = $cl->read(my $recv, 50000);    # get the data
    if (defined($ret) && length($recv) > 0) {
      my $rndid = "";
      while (1) {
        $rndid = genuniq();
        if (! -e "$proot$rndid") {
          writef($rndid, $recv, $cl, $logfile);
          $cl->close() or die "$datet $cl->peerhost $!";                   # close last sock and move on
          return 0;                       # return so we don't get stuck in the loop
        }
      }
    }
  }
}


sub writef() {
  my ($rndid, $recv, $cl, $logfile) = @_;
  $datet = purdydate();
  print LOG $datet . " " . $cl->peerhost . "/" . $cl->peerport;
  print LOG " $rndid : storing at $proot/p/$rndid\n";
  print "$rndid : storing at $proot/p/$rndid\n";
  $datet = purdydate();
  print LOG $datet . " " . $cl->peerhost . "/" . $cl->peerport;
  print LOG " $rndid : serving at $srvname/p/$rndid\n";
  print "$rndid : serving at $srvname/p/$rndid\n";
  my $filename = $proot . $rndid;
  open(P, '>', $filename) or die "$datet $cl->peerhost $!";;
  print P $recv;
  close(P);
  print $cl "$srvname/p/$rndid" . "\n" or die "$datet $cl->peerhost $!";
  return 1;
}


sub genuniq {
  my $pasid;    # for unique paste identifier
  my @set = ('A' .. 'Z', 'a' .. 'z', 0 .. 9);
  my $num = $#set;
  $pasid .= $set[rand($num)] for 1 .. 8;
  return $pasid;    # push it back
}

sub purdydate {

    my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time);
    my $datetime = sprintf ( "%04d%02d%02d %02d:%02d:%02d",
                                   $year+1900,$mon+1,$mday,$hour,$min,$sec);
    return $datetime;
}