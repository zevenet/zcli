#!/usr/bin/perl
###############################################################################
#
#    ZEVENET Software License
#    This file is part of the ZEVENET Load Balancer software package.
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
