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

our $Blacklist = {
	'ipds-blacklist' => {
						  $V{ LIST } => {
										  uri        => "/ipds/blacklists",
										  method     => 'GET',
										  enterprise => 1,
						  },
						  $V{ GET } => {
										 uri        => "/ipds/blacklists/<$K{BL}>",
										 method     => 'GET',
										 enterprise => 1,
						  },
						  $V{ CREATE } => {
											uri        => "/ipds/blacklists",
											method     => 'POST',
											enterprise => 1,
						  },
						  $V{ SET } => {
										 uri        => "/ipds/blacklists/<$K{BL}>",
										 method     => 'PUT',
										 enterprise => 1,
						  },
						  $V{ DELETE } => {
											uri        => "/ipds/blacklists/<$K{BL}>",
											method     => 'DELETE',
											enterprise => 1,
						  },
						  $V{ START } => {
										   uri    => "/ipds/blacklists/<$K{BL}>/actions",
										   method => 'POST',
										   params => {
													   'action' => 'start',
										   },
										   enterprise => 1,
						  },
						  $V{ STOP } => {
										  uri    => "/ipds/blacklists/<$K{BL}>/actions",
										  method => 'POST',
										  params => {
													  'action' => 'stop',
										  },
										  enterprise => 1,
						  },
						  $V{ UPDATE } => {
											uri    => "/ipds/blacklists/<$K{BL}>/actions",
											method => 'POST',
											params => {
														'action' => 'update',
											},
											enterprise => 1,
						  },
	},

	'ipds-blacklist-source' => {
		$V{ LIST } => {
						uri        => "/ipds/blacklists/<$K{BL}>/sources",
						method     => 'GET',
						enterprise => 1,
		},
		$V{ ADD } => {
					   uri        => "/ipds/blacklists/<$K{BL}>/sources",
					   method     => 'POST',
					   enterprise => 1,
		},
		$V{ SET } => {
			 uri       => "/ipds/blacklists/<$K{BL}>/sources/$Define::Uri_param_tag",
			 method    => 'PUT',
			 param_uri => [
						   {
							 name => "source_ID",
							 desc => "the IP address of the source which will be modified",
						   },
			 ],
			 enterprise => 1,
		},
		$V{ REMOVE } => {
			  uri       => "/ipds/blacklists/<$K{BL}>/sources/$Define::Uri_param_tag",
			  method    => 'DELETE',
			  param_uri => [
							{
							  name => "source_ID",
							  desc => "the IP address of the source which will be removed",
							},
			  ],
			  enterprise => 1,
		},
	},
};

1;

