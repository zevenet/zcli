#!/usr/bin/perl

use strict;
use warnings;

require "./Define.pm";

# verbs
my %V = %Define::Actions;

# keys
my %K = %Define::Keys;

package Objects;

our $Farmguardian = {
	'farmguardian' => {
		$V{ LIST } => {
						uri    => "/monitoring/fg",
						method => 'GET',
		},
		$V{ GET } => {
					   uri    => "/monitoring/fg/<$K{FG}>",
					   method => 'GET',
		},
		$V{ CREATE } => {
						  uri    => "/monitoring/fg",
						  method => 'POST',
		},

		# ??? add copy

		$V{ SET } => {
					   uri    => "/monitoring/fg/<$K{FG}>",
					   method => 'PUT',
		},
		$V{ DELETE } => {
						  uri    => "/monitoring/fg/<$K{FG}>",
						  method => 'DELETE',
		},
	},
};

1;