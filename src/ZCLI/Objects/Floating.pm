#!/usr/bin/perl

use strict;
use warnings;

use ZCLI::Define;

# verbs
my %V = %Define::Actions;

# keys
my %K = %Define::Keys;

package Objects;

our $Floating = {
				  'network-floating' => {
										  $V{ LIST } => {
														  uri    => "/interfaces/floating",
														  method => 'GET',
														  enterprise => 1,
										  },
										  $V{ GET } => {
												  uri => "/interfaces/floating/<$K{IFACE}>",
												  method     => 'GET',
												  enterprise => 1,
										  },
										  $V{ SET } => {
												  uri => "/interfaces/floating/<$K{IFACE}>",
												  method     => 'PUT',
												  enterprise => 1,
										  },
										  $V{ DELETE } => {
												  uri => "/interfaces/floating/<$K{IFACE}>",
												  method     => 'DELETE',
												  enterprise => 1,
										  },
				  },
};

1;
