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
use Hash::Merge;
use ZCLI::Define;

package Objects;

use ZCLI::Objects::Farms;
use ZCLI::Objects::Interfaces;
use ZCLI::Objects::Certificates;
use ZCLI::Objects::Farmguardian;
use ZCLI::Objects::Statistics;
use ZCLI::Objects::Ipds;
use ZCLI::Objects::System;
use ZCLI::Objects::Rbac;

our $Zcli = {};

if ( $Global::DEBUG > 1 )
{
	require ZCLI::Objects::Debug;
	$Objects::Zcli = &Hash::Merge::merge( $Objects::Zcli, $Objects::Debug );
}
else
{
	$Objects::Zcli = &Hash::Merge::merge( $Objects::Zcli, $Objects::Farms );
	$Objects::Zcli = &Hash::Merge::merge( $Objects::Zcli, $Objects::Interfaces );
	$Objects::Zcli = &Hash::Merge::merge( $Objects::Zcli, $Objects::Certificates );
	$Objects::Zcli = &Hash::Merge::merge( $Objects::Zcli, $Objects::Farmguardian );
	$Objects::Zcli = &Hash::Merge::merge( $Objects::Zcli, $Objects::Statistics );
	$Objects::Zcli = &Hash::Merge::merge( $Objects::Zcli, $Objects::Ipds );
	$Objects::Zcli = &Hash::Merge::merge( $Objects::Zcli, $Objects::System );
	$Objects::Zcli = &Hash::Merge::merge( $Objects::Zcli, $Objects::Rbac );
}

1;

