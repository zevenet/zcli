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

use ZCLI::Objects::Blacklist;
use ZCLI::Objects::Dos;
use ZCLI::Objects::Waf;
use ZCLI::Objects::Rbl;

# verbs
my %V = %Define::Actions;

# keys
my %K = %Define::Keys;

package Objects;

our $Ipds = {
			  'ipds' => {
						  $V{ LIST } => {
										  uri        => "/ipds",
										  method     => 'GET',
										  enterprise => 1,
						  },
			  },
			  'ipds-package' => {
								  $V{ GET } => {
												 uri        => "/ipds/package",
												 method     => 'GET',
												 enterprise => 1,
								  },
								  $V{ UPGRADE } => {
													 uri    => "/ipds/package/actions",
													 method => 'POST',
													 params_complete => 1,
													 params          => {
																 'action' => 'upgrade',
													 },
													 enterprise => 1,
								  },
			  },
};

$Objects::Ipds = &Hash::Merge::merge( $Objects::Ipds, $Objects::Blacklist );
$Objects::Ipds = &Hash::Merge::merge( $Objects::Ipds, $Objects::Dos );
$Objects::Ipds = &Hash::Merge::merge( $Objects::Ipds, $Objects::Rbl );
$Objects::Ipds = &Hash::Merge::merge( $Objects::Ipds, $Objects::Waf );

1;
