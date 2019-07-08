#!/usr/bin/perl

use strict;
use feature "say";
#~ use warnings;
use POSIX qw(_exit);

require "./lib.pm";
require "./objects.pm";

&printHelp() if ($ARGV[0] eq '-h');

my $options = &parseOptions(@ARGV);

my $host = &hostInfo() or do
{
	say "Not found the host info, try to configure the default host profile";
	&setHost();
	&hostInfo();
};

my $objects = $Objects::zcli_objects;

my $input = &parseInput(@ARGV);

my $request = &checkInput($objects, $input, $host);

my $resp = &zapi($request, $host);

&printOutput($resp);
POSIX::_exit( $resp->{err} );
