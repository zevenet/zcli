#!/usr/bin/perl

use strict;
use warnings;

use ZCLI::Define;

# verbs
my %V = %Define::Actions;

# keys
my %K = %Define::Keys;

package Objects;

our $Routing = {
	'network-routing-rules' => {
		$V{ LIST } => {
						uri        => "/routing/rules",
						method     => 'GET',
						enterprise => 1,
		},
		$V{ CREATE } => {
						  uri        => "/routing/rules",
						  method     => 'POST',
						  enterprise => 1,
		},
		$V{ SET } => {
					  uri       => "/routing/rules/$Define::UriParamTag",
					  method    => 'PUT',
					  param_uri => [
							  {
								name => "rule",
								desc => "the rule id of the rule that is going to be modified",
							  },
					  ],
					  enterprise => 1,
		},
		$V{ DELETE } => {
			 uri       => "/routing/rules/$Define::UriParamTag",
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
	'network-routing-tables' => {
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
		$V{ CREATE } => {
						  uri        => "/routing/tables/<$K{ROUTING_TABLE}>/routes",
						  method     => 'POST',
						  enterprise => 1,
		},
		$V{ SET } => {
			   uri    => "/routing/tables/<$K{ROUTING_TABLE}>/routes/$Define::UriParamTag",
			   method => 'PUT',
			   param_uri => [
							{
							  name => "id",
							  desc => "the route id of the route that is going to be modified",
							},
			   ],
			   enterprise => 1,
		},
		$V{ DELETE } => {
			   uri    => "/routing/tables/<$K{ROUTING_TABLE}>/routes/$Define::UriParamTag",
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
	'network-routing-tables-unmanaged' => {
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
			uri    => "/routing/tables/<$K{ROUTING_TABLE}>/unmanaged/$Define::UriParamTag",
			method => 'DELETE',
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
