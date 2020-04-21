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

our $Statistics = {
					'statistic-system' => {
											$V{ GET } => {
														   uri    => "/stats",
														   method => 'GET',
											},
					},
					'statistic-network' => {
										  $V{ GET } => {
												  uri => "/stats/system/network/interfaces",
												  method => 'GET',
										  },
					},
					'statistic-network-connections' => {
												 $V{ GET } => {
														 uri => "/stats/system/connections",
														 method => 'GET',
												 },
					},
					'statistic-farm' => {
										  $V{ LIST } => {
														  uri    => "/stats/farms",
														  method => 'GET',
										  },
										  $V{ GET } => {
														 uri => "/stats/farms/<$K{FARM}>",
														 method => 'GET',
										  },
					},
};

1;
