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

our $Farms = {
	'farms' => {
				 $V{ LIST } => {
								 uri    => "/farms",
								 method => 'GET',
				 },
				 $V{ GET } => {
								uri    => "/farms/<$K{FARM}>",
								method => 'GET',
				 },
				 $V{ SET } => {
								uri    => "/farms/<$K{FARM}>",
								method => 'PUT',
				 },
				 $V{ DELETE } => {
								   uri    => "/farms/<$K{FARM}>",
								   method => 'DELETE',
				 },
				 $V{ START } => {
								  uri    => "/farms/<$K{FARM}>/actions",
								  method => 'PUT',
								  params => {
											  'action' => 'start',
								  },
				 },
				 $V{ STOP } => {
								 uri    => "/farms/<$K{FARM}>/actions",
								 method => 'PUT',
								 params => {
											 'action' => 'stop',
								 },
				 },
				 $V{ RESTART } => {
									uri    => "/farms/<$K{FARM}>/actions",
									method => 'PUT',
									params => {
												'action' => 'restart',
									},
				 },
				 $V{ CREATE } => {
								   uri    => "/farms",
								   method => 'POST',
				 },
	},

	'farms-services' => {
						  $V{ CREATE } => {
											uri    => "/farms/<$K{FARM}>/services",
											uri    => "/farms/<$K{FARM}>/services",
											method => 'POST',
						  },
						  $V{ SET } => {
										 uri    => "/farms/<$K{FARM}>/services/<$K{SRV}>",
										 method => 'PUT',
						  },
						  $V{ DELETE } => {
											uri => "/farms/<$K{FARM}>/services/<$K{SRV}>",
											method => 'DELETE',
						  },
						  $V{ MOVE } => {
									  uri => "/farms/<$K{FARM}>/services/<$K{SRV}>/actions",
									  method     => 'POST',
									  enterprise => 1,
						  },
	},

	'farms-services-backends' => {
		$V{ CREATE } => {
						  uri    => "/farms/<$K{FARM}>/services/<$K{SRV}>/backends",
						  method => 'POST',
		},
		$V{ SET } => {
					   uri    => "/farms/<$K{FARM}>/services/<$K{SRV}>/backends/<$K{BK}>",
					   method => 'PUT',
		},
		$V{ DELETE } => {
						  uri => "/farms/<$K{FARM}>/services/<$K{SRV}>/backends/<$K{BK}>",
						  method => 'DELETE',
		},
		$V{ MAINTENANCE } => {
				uri => "/farms/<$K{FARM}>/services/<$K{SRV}>/backends/<$K{BK}>/maintenance",
				method => 'PUT',
				params => {
							action => 'maintenance',
							mode   => 'drain',
				}
		},
		$V{ NON_MAINTENANCE } => {
				uri => "/farms/<$K{FARM}>/services/<$K{SRV}>/backends/<$K{BK}>/maintenance",
				method => 'PUT',
				params => {
							action => 'up',
				}
		},
	},

	'farms-services-farmguardian' => {
						  $V{ ADD } => {
										 uri => "/farms/<$K{FARM}>/services/<$K{SRV}>/fg",
										 method              => 'POST',
										 params_autocomplete => {
																  name => ['farmguardian'],
										 },
						  },
						  $V{ REMOVE } => {
								  uri => "/farms/<$K{FARM}>/services/<$K{SRV}>/fg/<$K{FG}>",
								  method => 'DELETE',
						  },
	},

	'farms-zones' => {
					   $V{ CREATE } => {
										 uri        => "/farms/<$K{FARM}>/zones",
										 method     => 'POST',
										 enterprise => 1,
					   },
					   $V{ SET } => {
									  uri        => "/farms/<$K{FARM}>/zones/<$K{ZONES}>",
									  method     => 'PUT',
									  enterprise => 1,
					   },
					   $V{ DELETE } => {
										 uri    => "/farms/<$K{FARM}>/zones/<$K{ZONES}>",
										 method => 'DELETE',
										 enterprise => 1,
					   },
	},

	'farms-zones-resources' => {
		$V{ LIST } => {
						uri        => "/farms/<$K{FARM}>/zones/<$K{ZONES}>/resources",
						method     => 'GET',
						enterprise => 1,
		},
		$V{ CREATE } => {
						  uri        => "/farms/<$K{FARM}>/zones/<$K{ZONES}>/resources",
						  method     => 'POST',
						  enterprise => 1,
		},
		$V{ SET } => {
			 uri => "/farms/<$K{FARM}>/zones/<$K{ZONES}>/resources/$Define::Uri_param_tag",
			 method    => 'PUT',
			 param_uri => [
						   {
							 name => "resource ID",
							 desc => "the IP address of the source which will be modified",
						   },
			 ],
			 enterprise => 1,
		},
		$V{ DELETE } => {
			  uri => "/farms/<$K{FARM}>/zones/<$K{ZONES}>/resources/$Define::Uri_param_tag",
			  method    => 'DELETE',
			  param_uri => [
							{
							  name => "resource ID",
							  desc => "the IP address of the source which will be removed",
							},
			  ],
			  enterprise => 1,
		},
	},

	'farms-certificates' => {
						 $V{ ADD } => {
										uri    => "/farms/<$K{FARM}>/certificates",
										method => 'POST',
										params_autocomplete => {
																 name => ['certificates'],
										},
						 },
						 $V{ MOVE } => {
								 uri => "/farms/<$K{FARM}>/certificates/<$K{CERT}>/actions",
								 method     => 'POST',
								 enterprise => 1,
						 },
						 $V{ REMOVE } => {
										 uri => "/farms/<$K{FARM}>/certificates/<$K{CERT}>",
										 method     => 'DELETE',
										 enterprise => 1,
						 },
	},

	'farms-waf' => {
					 $V{ ADD } => {
									uri                 => "/farms/<$K{FARM}>/ipds/waf",
									method              => 'POST',
									params_autocomplete => {
															 name => ['ipds', 'waf'],
									},
									enterprise => 1,
					 },
					 $V{ REMOVE } => {
									   uri        => "/farms/<$K{FARM}>/ipds/waf/<$K{WAF}>",
									   method     => 'DELETE',
									   enterprise => 1,
					 },
					 $V{ MOVE } => {
									 uri => "/farms/<$K{FARM}>/ipds/waf/<$K{WAF}>/actions",
									 method     => 'POST',
									 enterprise => 1,
					 },
	},

	'farms-blacklists' => {
							$V{ ADD } => {
										   uri    => "/farms/<$K{FARM}>/ipds/blacklists",
										   method => 'POST',
										   enterprise          => 1,
										   params_autocomplete => {
																 name => ['ipds', 'blacklists'],
										   },
							},
							$V{ REMOVE } => {
										uri => "/farms/<$K{FARM}>/ipds/blacklists/<$K{BL}>",
										method     => 'DELETE',
										enterprise => 1,
							},
	},

	'farms-dos' => {
					 $V{ ADD } => {
									uri                 => "/farms/<$K{FARM}>/ipds/dos",
									method              => 'POST',
									params_autocomplete => {
															 name => ['ipds', 'dos'],
									},
									enterprise => 1,
					 },
					 $V{ REMOVE } => {
									   uri        => "/farms/<$K{FARM}>/ipds/dos/<$K{DOS}>",
									   method     => 'DELETE',
									   enterprise => 1,
					 },
	},

	'farms-rbl' => {
					 $V{ ADD } => {
									uri                 => "/farms/<$K{FARM}>/ipds/rbl",
									method              => 'POST',
									params_autocomplete => {
															 name => ['ipds', 'rbl'],
									},
									enterprise => 1,
					 },
					 $V{ REMOVE } => {
									   uri        => "/farms/<$K{FARM}>/ipds/rbl/<$K{RBL}>",
									   method     => 'DELETE',
									   enterprise => 1,
					 },
	},
};

1;
