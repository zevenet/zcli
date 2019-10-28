#!/usr/bin/perl

use strict;
use warnings;

require "./Define.pm";

# verbs
my %V = %Define::Actions;

# keys
my %K = %Define::Keys;

package Objects::Interfaces;
use Data::Dumper;

our $Interfaces = {
	'interfaces' => {
					  $V{ LIST } => {
									  uri    => "/interfaces",
									  method => 'GET',
					  },
	},
};



1;
