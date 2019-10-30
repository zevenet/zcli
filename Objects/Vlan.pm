#!/usr/bin/perl

use strict;
use warnings;

require "./Define.pm";

# verbs
my %V = %Define::Actions;

# keys
my %K = %Define::Keys;

package Objects;

our $Vlan = {
			  'network-vlan' => {
								  $V{ LIST } => {
												  uri    => "/interfaces/vlan",
												  method => 'GET',
								  },
								  $V{ GET } => {
												 uri    => "/interfaces/vlan/<$K{IFACE}>",
												 method => 'GET',
								  },
								  $V{ CREATE } => {
													uri    => "/interfaces/vlan",
													method => 'POST',
								  },
								  $V{ SET } => {
												 uri    => "/interfaces/vlan/<$K{IFACE}>",
												 method => 'PUT',
								  },
								  $V{ DELETE } => {
													uri => "/interfaces/vlan/<$K{IFACE}>",
													method => 'DELETE',
								  },
								  $V{ START } => {
											  uri => "/interfaces/vlan/<$K{IFACE}>/actions",
											  method => 'POST',
											  params => {
														  'action' => 'up',
											  },
								  },
								  $V{ STOP } => {
											  uri => "/interfaces/vlan/<$K{IFACE}>/actions",
											  method => 'POST',
											  params => {
														  'action' => 'down',
											  },
								  },
			  },
};

1;
