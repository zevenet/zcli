#!/usr/bin/perl

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

	'ipds-blacklist-sources' => {
		$V{ LIST } => {
						uri        => "/ipds/blacklists/<$K{BL}>/sources",
						method     => 'GET',
						enterprise => 1,
		},
		$V{ CREATE } => {
						  uri        => "/ipds/blacklists/<$K{BL}>/sources",
						  method     => 'POST',
						  enterprise => 1,
		},
		$V{ SET } => {
			 uri       => "/ipds/blacklists/<$K{BL}>/sources/$Define::UriParamTag",
			 method    => 'PUT',
			 param_uri => [
						   {
							 name => "source ID",
							 desc => "the IP address of the source which will be modified",
						   },
			 ],
			 enterprise => 1,
		},
		$V{ DELETE } => {
			  uri       => "/ipds/blacklists/<$K{BL}>/sources/$Define::UriParamTag",
			  method    => 'DELETE',
			  param_uri => [
							{
							  name => "source ID",
							  desc => "the IP address of the source which will be removed",
							},
			  ],
			  enterprise => 1,
		},
	},
};

1;

