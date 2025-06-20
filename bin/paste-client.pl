#!/usr/bin/perl

#
#   __ _  _  __   ___  __  ____ ____
#  /  ( \/ )/ _\ / __)/ _\/ ___(_  _)
# (  O )  (/    ( (_ /    \___ \ )(
#  \__(_/\_\_/\_/\___\_/\_(____/(__)
#
# By oxagast, thanks to termbin.org creators for the idea.
#
# Babe! Let me lick your butthole!
#
# usage: cat /etc/passwd | perl paste-client.pl

use strict;
use warnings;
use IO::Socket::SSL;
use Getopt::Long;

my %options;
GetOptions(
           'server=s' => \$options{server},
           'port=i'   => \$options{port},
           'help'     => \$options{help}
);
if ($options{help}) {
  print STDERR "Usage: echo abc | $0 --server oxasploits.com --port 8888\n";
  exit 1;
}
STDIN->blocking(0);
my @data = <STDIN>;
if (@data) {
  my $host = 'spaste.oxasploits.com';
  my $port = 8888;
  if ($options{server}) {
    $host = $options{server};
  }
  if ($options{port}) {
    $port = $options{port};
  }
  my $sock = IO::Socket::SSL->new(
                                  PeerAddr            => "$host:$port",
                                  Proto               => 'tcp',
                                  SSL_verify_mode     => SSL_VERIFY_PEER,
                                  SSL_verifycn_name   => $host,
                                  SSL_hostname        => $host,
                                  SLL_verifycn_scheme => 'http',
                                  Timeout             => '8'
  ) or die "Error: 0x03 Creation of socket: $!";
  print $sock @data;
  print $sock "\n";
  while (my $res = <$sock>) {
    if ($res =~ m|https://.*/p/.*|) {
      print $res;
      $sock->close();
      exit 0;
    }
    else {
      if ($res =~ m/^0x/) {
        print STDERR "Error: $res\n";
      }
      else {
      print STDERR "Error: 0x01 Maybe not an spaste server?\n";
      }

      $sock->close();
      exit 1;
    }
  }
  exit 0;
}
else {
  print STDERR "Error: 0x04 You should add your paste data to stdin.\n";
  print STDERR "Usage:\n  echo abc | $0 --server oxasploits.com --port 8888\n";
  exit 1;
}
