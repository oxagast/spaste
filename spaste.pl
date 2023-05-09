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
# v0.3 drastically improved performance by fixing threading and using blocking and a 
# return to bump out of loop


use strict;
use warnings;
use IO::Handle;
use Fcntl ("F_GETFL", "F_SETFL", "O_NONBLOCK");
use Socket;
use IO::Socket::SSL;
use threads;
chdir "/var/www/spaste.oxasploits.com/";
STDOUT->autoflush();
my $logfile = "/var/log/spaste.log";                  # log
my $proot   = "/var/www/spaste.oxasploits.com/p/";    # paste root if not default
my $host    = "spaste.oxasploits.com";                # change to your server
my $srvname = "https://" . $host;
my $port    = "8888";
my $cer = "/etc/letsencrypt/live/" . $host . "/cert.pem";       # use your cert
my $key = "/etc/letsencrypt/live/" . $host . "/privkey.pem";    # use your privkey
my $sock = IO::Socket::IP->new(
                               Listen    => SOMAXCONN,
                               LocalPort => $port,
                               Blocking  => 1,
                               ReuseAddr => 1
) or die $!;
umask(022);
my $WITH_THREADS = 1;                                           # the switch!!

while (1) {
  eval {
    my $cl = $sock->accept();                                   # threaded accept
    if ($cl) {
      my $th = threads->create(\&client, $cl);
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
  my $flags = fcntl($cl, F_GETFL, 0) or die $!;
  fcntl($cl, F_SETFL, $flags | O_NONBLOCK) or die $!;
  print STDERR $cl->peerhost . "/" . $cl->peerport . "\n";
  print LOG $cl->peerhost . "/" . $cl->peerport . "\n";
  while (1) {
    my $ret = "";
    $ret = $cl->read(my $recv, 50000);    # get the data
    if (defined($ret) && length($recv) > 0) {
      my $rndid = "";
      while ($uniq != 1) {
        $rndid = genuniq();
        if (-e "$proot$rndid") {
        }
        else {
          writef($rndid, $recv, $cl, $logfile);
          $cl->close();                   # close last sock and move on
          return 0;                       # return so we don't get stuck in the loop
        }
      }
    }
  }
  close(LOG);
}


sub writef() {
  my ($rndid, $recv, $cl, $logfile) = @_;
  open(LOG, '>>', $logfile) or die $!;
  print LOG "$rndid : storing at $proot/p/$rndid\n";
  print "$rndid : storing at $proot/p/$rndid\n";
  print LOG "$rndid : serving at $srvname/p/$rndid\n";
  print "$rndid : serving at $srvname/p/$rndid\n";
  my $filename = $proot . $rndid;
  open(P, '>', $filename) or die $!;
  print P $recv;
  close(P);
  print $cl "$srvname/p/$rndid" . "\n";
  close(LOG);
  return 1;
}


sub genuniq {
  my $pasid;    # for unique paste identifier
  my @set = ('A' .. 'Z', 'a' .. 'z', 0 .. 9);
  my $num = $#set;
  $pasid .= $set[rand($num)] for 1 .. 8;
  return $pasid;    # push it back
}
