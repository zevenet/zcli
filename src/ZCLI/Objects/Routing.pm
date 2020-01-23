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

our $Routing = {
	'network-routing-rule' => {
		$V{ LIST } => {
						uri        => "/routing/rules",
						method     => 'GET',
						enterprise => 1,
		},
		$V{ ADD } => {
					   uri        => "/routing/rules",
					   method     => 'POST',
					   enterprise => 1,
		},
		$V{ SET } => {
					  uri       => "/routing/rules/$Define::Uri_param_tag",
					  method    => 'PUT',
					  param_uri => [
							  {
								name => "rule",
								desc => "the rule id of the rule that is going to be modified",
							  },
					  ],
					  enterprise => 1,
		},
		$V{ REMOVE } => {
			 uri       => "/routing/rules/$Define::Uri_param_tag",
			 method    => 'DELETE',
			 param_uri => [
						   {
							 name => "rule",
							 desc => "the rule id of the rule that is going to be deleted",
						   },
			 ],
			 enterprise => 1,
		},
	},
	'network-routing-table' => {
		$V{ LIST } => {
						uri        => "/routing/tables",
						method     => 'GET',
						enterprise => 1,
		},
		$V{ GET } => {
					   uri        => "/routing/tables/<$K{ROUTING_TABLE}>",
					   method     => 'GET',
					   enterprise => 1,
		},
		$V{ ADD } => {
					   uri        => "/routing/tables/<$K{ROUTING_TABLE}>/routes",
					   method     => 'POST',
					   enterprise => 1,
		},
		$V{ SET } => {
			 uri    => "/routing/tables/<$K{ROUTING_TABLE}>/routes/$Define::Uri_param_tag",
			 method => 'PUT',
			 param_uri => [
						   {
							 name => "id",
							 desc => "the route id of the route that is going to be modified",
						   },
			 ],
			 enterprise => 1,
		},
		$V{ REMOVE } => {
			 uri    => "/routing/tables/<$K{ROUTING_TABLE}>/routes/$Define::Uri_param_tag",
			 method => 'DELETE',
			 param_uri => [
						   {
							 name => "id",
							 desc => "the route id of the route that is going to be modified",
						   },
			 ],
			 enterprise => 1,
		},
	},
	'network-routing-table-unmanaged' => {
		$V{ LIST } => {
						uri        => "/routing/tables",
						method     => 'GET',
						enterprise => 1,
		},
		$V{ ADD } => {
					   uri        => "/routing/tables/<$K{ROUTING_TABLE}>/unmanaged",
					   method     => 'POST',
					   enterprise => 1,
		},
		$V{ REMOVE } => {
			uri => "/routing/tables/<$K{ROUTING_TABLE}>/unmanaged/$Define::Uri_param_tag",
			method    => 'DELETE',
			param_uri => [
					  {
						name => "interface",
						desc => "the interface name that is going to be managed for the table",
					  },
			],
			enterprise => 1,
		},
	},
};

1;
