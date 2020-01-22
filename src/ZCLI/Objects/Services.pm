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

our $Services = {
				  'system-services-dns' => {
											 $V{ GET } => {
															uri    => "/system/dns",
															method => 'GET',
											 },
											 $V{ SET } => {
															uri    => "/system/dns",
															method => 'POST',
											 },
				  },
				  'system-services-snmp' => {
											  $V{ GET } => {
															 uri    => "/system/snmp",
															 method => 'GET',
											  },
											  $V{ SET } => {
															 uri    => "/system/snmp",
															 method => 'POST',
											  },
				  },
				  'system-services-ntp' => {
											 $V{ GET } => {
															uri    => "/system/ntp",
															method => 'GET',
											 },
											 $V{ SET } => {
															uri    => "/system/ntp",
															method => 'POST',
											 },
				  },
				  'system-services-ssh' => {
											 $V{ GET } => {
															uri        => "/system/ssh",
															method     => 'GET',
															enterprise => 1,
											 },
											 $V{ SET } => {
															uri        => "/system/ssh",
															method     => 'POST',
															enterprise => 1,
											 },
				  },
				  'system-services-http' => {
											  $V{ GET } => {
															 uri        => "/system/http",
															 method     => 'GET',
															 enterprise => 1,
											  },
											  $V{ SET } => {
															 uri        => "/system/http",
															 method     => 'POST',
															 enterprise => 1,
											  },
				  },
				  'system-services-proxy' => {
											   $V{ GET } => {
															  uri        => "/system/proxy",
															  method     => 'GET',
															  enterprise => 1,
											   },
											   $V{ SET } => {
															  uri        => "/system/proxy",
															  method     => 'POST',
															  enterprise => 1,
											   },
				  },
};

1;
