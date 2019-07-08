#!/usr/bin/perl

use strict;
use warnings;
use Config::Tiny;

# verbs
my %V = &getOrdersDefs();

# keys
my $FARM_KEY='farm name';

package Global;
our $DEBUG=0;


package Objects;

our $zcli_objects =
{
	'farms' => {
		$V{LIST} => {
			uri => "/farms",
			method => 'GET',
		},
		$V{GET} => {
			uri => "/farms/<$FARM_KEY>",
			method => 'GET',
		},
		$V{SET} => {
			uri => "/farms/<$FARM_KEY>",
			method => 'PUT',
		},
		$V{DELETE} => {
			uri => "/farms/<$FARM_KEY>",
			method => 'DELETE',
		},
		$V{START} => {
			uri => "/farms/<$FARM_KEY>/actions",
			method => 'PUT',
			params => {
				'action' => 'start',
			},
		},
		$V{STOP} => {
			uri => "/farms/<$FARM_KEY>/actions",
			method => 'PUT',
			params => {
				'action' => 'stop',
			},
		},
		$V{CREATE} => {
			uri => "/farms",
			method => 'POST',
		},
	},

	#~ 'farms-http' => {

	#~ },

	'interfaces' => {
		$V{LIST} => {
			uri => "/interfaces",
			method => 'GET',
		},
	},

};

1;
