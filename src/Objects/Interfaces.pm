#!/usr/bin/perl

use strict;
use warnings;

require "./Define.pm";

require "./Objects/Nic.pm";
require "./Objects/Virtual.pm";
require "./Objects/Vlan.pm";
require "./Objects/Bonding.pm";
require "./Objects/Floating.pm";
require "./Objects/Alias.pm";

# verbs
my %V = %Define::Actions;

# keys
my %K = %Define::Keys;

package Objects;

our $Interfaces = {
					'network' => {
								   $V{ LIST } => {
												   uri    => "/interfaces",
												   method => 'GET',
								   },
					},
					'network-default-gateway-ipv4' => {
										  $V{ GET } => {
												  uri => "/interfaces/default-gateway/ipv4",
												  method => 'GET',
										  },
										  $V{ SET } => {
												  uri => "/interfaces/default-gateway/ipv4",
												  method => 'PUT',
										  },
										  $V{ DELETE } => {
												  uri => "/interfaces/default-gateway/ipv4",
												  method => 'DELETE',
										  },
					},
					'network-default-gateway-ipv6' => {
										  $V{ GET } => {
												  uri => "/interfaces/default-gateway/ipv6",
												  method => 'GET',
										  },
										  $V{ SET } => {
												  uri => "/interfaces/default-gateway/ipv6",
												  method => 'PUT',
										  },
										  $V{ DELETE } => {
												  uri => "/interfaces/default-gateway/ipv6",
												  method => 'DELETE',
										  },
					},
};

$Objects::Interfaces =
  &Hash::Merge::merge( $Objects::Interfaces, $Objects::Nic );
$Objects::Interfaces =
  &Hash::Merge::merge( $Objects::Interfaces, $Objects::Virtual );
$Objects::Interfaces =
  &Hash::Merge::merge( $Objects::Interfaces, $Objects::Vlan );
$Objects::Interfaces =
  &Hash::Merge::merge( $Objects::Interfaces, $Objects::Bonding );
$Objects::Interfaces =
  &Hash::Merge::merge( $Objects::Interfaces, $Objects::Floating );
$Objects::Interfaces =
  &Hash::Merge::merge( $Objects::Interfaces, $Objects::Alias );

1;
