#!/usr/bin/perl

use strict;
use warnings;

require "./Define.pm";

# verbs
my %V = %Define::Actions;

# keys
my %K = %Define::Keys;

package Objects;

our $Blacklist = {
	'ipds-blacklist' => {
		$V{ LIST } => {
						uri    => "/ipds/blacklists",
						method => 'GET',
		},
		$V{ GET } => {
					   uri    => "/ipds/blacklists/<$K{BL}>",
					   method => 'GET',
		},
		$V{ CREATE } => {
						  uri    => "/ipds/blacklists",
						  method => 'POST',
		},
		$V{ SET } => {
					   uri    => "/ipds/blacklists/<$K{BL}>",
					   method => 'PUT',
		},
		$V{ DELETE } => {
						  uri    => "/ipds/blacklists/<$K{BL}>",
						  method => 'DELETE',
		},
		$V{ START } => {
						 uri    => "/ipds/blacklists/<$K{BL}>/actions",
						 method => 'POST',
						 params => {
									 'action' => 'start',
						 },
		},
		$V{ STOP } => {
						uri    => "/ipds/blacklists/<$K{BL}>/actions",
						method => 'POST',
						params => {
									'action' => 'stop',
						},
		},
		$V{ UPDATE } => {
						uri    => "/ipds/blacklists/<$K{BL}>/actions",
						method => 'POST',
						params => {
									'action' => 'update',
						},
		},

		# ADD SOURCES ??????
	},
};

1;
