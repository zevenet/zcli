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
										  uri        => "/interfaces/bonding/<$K{IFACE}>",
										  method     => 'GET',
										  enterprise => 1,
						   },
						   $V{ CREATE } => {
											 uri        => "/interfaces/bonding",
											 method     => 'POST',
											 enterprise => 1,
						   },
						   $V{ SET } => {
										  uri        => "/interfaces/bonding/<$K{IFACE}>",
										  method     => 'PUT',
										  enterprise => 1,
						   },
						   $V{ UNSET } => {
											uri        => "/interfaces/bonding/<$K{IFACE}>",
											method     => 'DELETE',
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
	'network-bonding-slave' => {
		$V{ ADD } => {
			uri                 => "/interfaces/bonding/<$K{IFACE}>/slaves",
			method              => 'POST',
			enterprise          => 1,
			params_autocomplete => {
									 name => ['interfaces', 'nic'],
			},

		},
		$V{ REMOVE } => {
					 uri => "/interfaces/bonding/<$K{IFACE}>/slaves/$Define::Uri_param_tag",
					 param_uri => [
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
