#!/usr/bin/perl

use strict;
use warnings;

use ZCLI::Define;

# verbs
my %V = %Define::Actions;

# keys
my %K = %Define::Keys;

package Objects;

our $Bonding = {
	   'network-bonding' => {
							  $V{ LIST } => {
											  uri        => "/interfaces/bonding",
											  method     => 'GET',
											  enterprise => 1,
							  },
							  $V{ GET } => {
											 uri    => "/interfaces/bonding/<$K{IFACE}>",
											 method => 'GET',
											 enterprise => 1,
							  },
							  $V{ CREATE } => {
												uri        => "/interfaces/bonding",
												method     => 'POST',
												enterprise => 1,
							  },
							  $V{ SET } => {
											 uri    => "/interfaces/bonding/<$K{IFACE}>",
											 method => 'PUT',
											 enterprise => 1,
							  },
							  $V{ UNSET } => {
											   uri    => "/interfaces/bonding/<$K{IFACE}>",
											   method => 'DELETE',
											   enterprise => 1,
							  },
							  $V{ DELETE } => {
										   uri => "/interfaces/bonding/<$K{IFACE}>/actions",
										   method => 'POST',
										   params => {
													   'action' => 'destroy',
										   },
										   enterprise => 1,
							  },
							  $V{ START } => {
										   uri => "/interfaces/bonding/<$K{IFACE}>/actions",
										   method => 'POST',
										   params => {
													   'action' => 'up',
										   },
										   enterprise => 1,
							  },
							  $V{ STOP } => {
										   uri => "/interfaces/bonding/<$K{IFACE}>/actions",
										   method => 'POST',
										   params => {
													   'action' => 'down',
										   },
										   enterprise => 1,
							  },
	   },
	   'network-bonding-slaves' => {
			   $V{ ADD } => {
							  uri        => "/interfaces/bonding/<$K{IFACE}>/slaves",
							  method     => 'POST',
							  enterprise => 1,
			   },
			   $V{ REMOVE } => {
					   uri => "/interfaces/bonding/<$K{IFACE}>/slaves/$Define::UriParamTag",
					   uri_param => [
									 {
									   name => "slave",
									   desc => "the slave interface which will be removed",
									 },
					   ],
					   method     => 'DELETE',
					   enterprise => 1,
			   },
	   },
};

1;
