#!/usr/bin/perl

use strict;
use warnings;

require "./Define.pm";

# verbs
my %V = %Define::Actions;

# keys
my %K = %Define::Keys;

package Objects;

our $Bonding = {
	'network-bonding' => {
						   $V{ LIST } => {
										   uri    => "/interfaces/bonding",
										   method => 'GET',
						   },
						   $V{ GET } => {
										  uri    => "/interfaces/bonding/<$K{IFACE}>",
										  method => 'GET',
						   },
						   $V{ CREATE } => {
											 uri    => "/interfaces/bonding",
											 method => 'POST',
						   },
						   $V{ SET } => {
										  uri    => "/interfaces/bonding/<$K{IFACE}>",
										  method => 'PUT',
						   },
						   $V{ UNSET } => {
											uri    => "/interfaces/bonding/<$K{IFACE}>",
											method => 'DELETE',
						   },
						   $V{ DELETE } => {
										   uri => "/interfaces/bonding/<$K{IFACE}>/actions",
										   method => 'POST',
										   params => {
													   'action' => 'destroy',
										   },
						   },
						   $V{ START } => {
										   uri => "/interfaces/bonding/<$K{IFACE}>/actions",
										   method => 'POST',
										   params => {
													   'action' => 'up',
										   },
						   },
						   $V{ STOP } => {
										   uri => "/interfaces/bonding/<$K{IFACE}>/actions",
										   method => 'POST',
										   params => {
													   'action' => 'down',
										   },
						   },
	},
	'network-bonding-slaves' => {
		$V{ ADD } => {
					   uri    => "/interfaces/bonding/<$K{IFACE}>/actions",
					   method => 'POST',
		},
		$V{ REMOVE } => {
			uri => "/interfaces/bonding/<$K{IFACE}>/actions/$Define::UriParamTag",
			uri_param    => [
					{
						name => "slave",
						desc => "the slave interface which will be removed",
					},
			  ],
			method => 'DELETE',
		},
	},
};

1;
