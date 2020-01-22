#!/usr/bin/perl
###############################################################################
#
#    Zevenet Software License
#    This file is part of the Zevenet Load Balancer software package.
#
#    Copyright (C) 2014-today ZEVENET SL, Sevilla (Spain)
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as
#    published by the Free Software Foundation, either version 3 of the
#    License, or any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
###############################################################################

use strict;
use warnings;

use ZCLI::Define;

use ZCLI::Objects::Nic;
use ZCLI::Objects::Virtual;
use ZCLI::Objects::Vlan;
use ZCLI::Objects::Bonding;
use ZCLI::Objects::Floating;
use ZCLI::Objects::Alias;
use ZCLI::Objects::Routing;

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
$Objects::Interfaces =
  &Hash::Merge::merge( $Objects::Interfaces, $Objects::Routing );

1;
