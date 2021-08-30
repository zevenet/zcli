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

our $Farms = {
	'farm' => {
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
								  uri                 => "/farms",
								  method              => 'POST',
								  params_autocomplete => {
														   copy_from => ['farms'],
								  },
				},
	},

	'farm-service' => {
						$V{ GET } => {
									   uri    => "/farms/<$K{FARM}>/services/<$K{SRV}>",
									   method => 'GET',
						},
						$V{ ADD } => {
									   uri    => "/farms/<$K{FARM}>/services",
									   method => 'POST',
						},
						$V{ SET } => {
									   uri    => "/farms/<$K{FARM}>/services/<$K{SRV}>",
									   method => 'PUT',
						},
						$V{ REMOVE } => {
										  uri    => "/farms/<$K{FARM}>/services/<$K{SRV}>",
										  method => 'DELETE',
						},
						$V{ MOVE } => {
									  uri => "/farms/<$K{FARM}>/services/<$K{SRV}>/actions",
									  method     => 'POST',
									  enterprise => 1,
						},
	},

	'farm-service-replacerequestheader' => {
						  $V{ ADD } => {
										 uri => "/farms/<$K{FARM}>/services/<$K{SRV}>/replacerequestheader",
										 method              => 'POST',
						  },
						  $V{ REMOVE } => {
								  uri => "/farms/<$K{FARM}>/services/<$K{SRV}>/replacerequestheader/$Define::Uri_param_tag",
					 			  param_uri => [
								  	{
										 name => "index",
										 desc => "It is the index of the directive to remove",
								  	}
								  ],
								  method => 'DELETE',
						  },
	},

	'farm-service-replaceresponseheader' => {
						  $V{ ADD } => {
										 uri => "/farms/<$K{FARM}>/services/<$K{SRV}>/replaceresponseheader",
										 method              => 'POST',
						  },
						  $V{ REMOVE } => {
								  uri => "/farms/<$K{FARM}>/services/<$K{SRV}>/replaceresponseheader/$Define::Uri_param_tag",
					 			  param_uri => [
								  	{
										 name => "index",
										 desc => "It is the index of the directive to remove",
								  	}
								  ],
								  method => 'DELETE',
						  },
	},

	'farm-service-addrequestheader' => {
						  $V{ ADD } => {
										 uri => "/farms/<$K{FARM}>/services/<$K{SRV}>/addrequestheader",
										 method              => 'POST',
						  },
						  $V{ REMOVE } => {
								  uri => "/farms/<$K{FARM}>/services/<$K{SRV}>/addrequestheader/$Define::Uri_param_tag",
					 			  param_uri => [
								  	{
										 name => "index",
										 desc => "It is the index of the directive to remove",
								  	}
								  ],
								  method => 'DELETE',
						  },
	},

	'farm-service-addresponseheader' => {
						  $V{ ADD } => {
										 uri => "/farms/<$K{FARM}>/services/<$K{SRV}>/addresponseheader",
										 method              => 'POST',
										 
						  },
						  $V{ REMOVE } => {
								  uri => "/farms/<$K{FARM}>/services/<$K{SRV}>/addresponseheader/$Define::Uri_param_tag",
					 			  param_uri => [
								  	{
										 name => "index",
										 desc => "It is the index of the directive to remove",
								  	}
								  ],
								  method => 'DELETE',
						  },
	},

	'farm-service-removerequestheader' => {
						  $V{ ADD } => {
										 uri => "/farms/<$K{FARM}>/services/<$K{SRV}>/removerequestheader",
										 method              => 'POST',
										 
						  },
						  $V{ REMOVE } => {
								  uri => "/farms/<$K{FARM}>/services/<$K{SRV}>/removerequestheader/$Define::Uri_param_tag",
					              param_uri => [
								  	{
										 name => "index",
										 desc => "It is the index of the directive to remove",
								  	}
								  ],
								  method => 'DELETE',
						  },
	},

	'farm-service-removeresponseheader' => {
						  $V{ ADD } => {
										 uri => "/farms/<$K{FARM}>/services/<$K{SRV}>/removeresponseheader",
										 method              => 'POST',
						  },
						  $V{ REMOVE } => {
								  uri => "/farms/<$K{FARM}>/services/<$K{SRV}>/removeresponseheader/$Define::Uri_param_tag",
					              param_uri => [
								  	{
										 name => "index",
										 desc => "It is the index of the directive to remove",
								  	}
								  ],
								  method => 'DELETE',
						  },
	},

	'farm-service-rewriteurl' => {
						  $V{ ADD } => {
										 uri => "/farms/<$K{FARM}>/services/<$K{SRV}>/rewriteurl",
										 method              => 'POST',
										 
						  },
						  $V{ REMOVE } => {
								  uri => "/farms/<$K{FARM}>/services/<$K{SRV}>/rewriteurl/$Define::Uri_param_tag",
					              param_uri => [
								  	{
										 name => "index",
										 desc => "It is the index of the directive to remove",
								  	}
								  ],
								  method => 'DELETE',
						  },
	},

	'farm-service-backend' => {
		$V{ ADD } => {
					   uri    => "/farms/<$K{FARM}>/services/<$K{SRV}>/backends",
					   method => 'POST',
		},
		$V{ SET } => {
					   uri    => "/farms/<$K{FARM}>/services/<$K{SRV}>/backends/<$K{BK}>",
					   method => 'PUT',
		},
		$V{ REMOVE } => {
						  uri => "/farms/<$K{FARM}>/services/<$K{SRV}>/backends/<$K{BK}>",
						  method => 'DELETE',
		},
		$V{ MAINTENANCE } => {
				uri => "/farms/<$K{FARM}>/services/<$K{SRV}>/backends/<$K{BK}>/maintenance",
				method => 'PUT',
				params => {
							action => 'maintenance',
				},
				params_opt => {
								mode => ['drain', 'cut'],
				},
		},
		$V{ NON_MAINTENANCE } => {
				uri => "/farms/<$K{FARM}>/services/<$K{SRV}>/backends/<$K{BK}>/maintenance",
				method => 'PUT',
				params => {
							action => 'up',
				}
		},
	},

	'farm-session' => {
						$V{ ADD } => {
									   uri        => "/farms/<$K{FARM}>/sessions",
									   method     => 'POST',
									   enterprise => 1,
						},
						$V{ REMOVE } => {
								 uri => "/farms/<$K{FARM}>/sessions/$Define::Uri_param_tag",
								 param_uri => [
											   {
												 name => "session",
												 desc => "session to delete",
											   },
								 ],
								 method     => 'DELETE',
								 enterprise => 1,
						},
						$V{ LIST } => {
										uri        => "/farms/<$K{FARM}>/sessions",
										method     => 'GET',
										enterprise => 1,
						},
	},

		'farm-service-session' => {
			$V{ ADD } => {
				uri        => "/farms/<$K{FARM}>/services/<$K{SRV}>/sessions",
				method     => 'POST',
				enterprise => 1,
			},
			$V{ REMOVE } => {
				uri => "/farms/<$K{FARM}>/services/<$K{SRV}>/sessions/$Define::Uri_param_tag",
				param_uri => [
					{
						name => "session",
						desc => "session to delete",
					},
				],
				method     => 'DELETE',
				enterprise => 1,
			},
			$V{ LIST } => {
				uri        => "/farms/<$K{FARM}>/services/<$K{SRV}>/sessions",
				method     => 'GET',
				enterprise => 1,
			},
	},

	'farm-service-farmguardian' => {
						  $V{ ADD } => {
										 uri => "/farms/<$K{FARM}>/services/<$K{SRV}>/fg",
										 method              => 'POST',
										 params_autocomplete => {
																  name => ['farmguardians'],
										 },
						  },
						  $V{ REMOVE } => {
								  uri => "/farms/<$K{FARM}>/services/<$K{SRV}>/fg/<$K{FG}>",
								  method => 'DELETE',
						  },
	},

	'farm-zone' => {
					 $V{ ADD } => {
									uri        => "/farms/<$K{FARM}>/zones",
									method     => 'POST',
									enterprise => 1,
					 },
					 $V{ SET } => {
									uri        => "/farms/<$K{FARM}>/zones/<$K{ZONES}>",
									method     => 'PUT',
									enterprise => 1,
					 },
					 $V{ REMOVE } => {
									   uri        => "/farms/<$K{FARM}>/zones/<$K{ZONES}>",
									   method     => 'DELETE',
									   enterprise => 1,
					 },
	},

	'farm-zone-resource' => {
		$V{ LIST } => {
						uri        => "/farms/<$K{FARM}>/zones/<$K{ZONES}>/resources",
						method     => 'GET',
						enterprise => 1,
		},
		$V{ ADD } => {
					   uri        => "/farms/<$K{FARM}>/zones/<$K{ZONES}>/resources",
					   method     => 'POST',
					   enterprise => 1,
		},
		$V{ SET } => {
			 uri => "/farms/<$K{FARM}>/zones/<$K{ZONES}>/resources/$Define::Uri_param_tag",
			 method    => 'PUT',
			 param_uri => [
						   {
							 name => "resource_ID",
							 desc => "the IP address of the source which will be modified",
						   },
			 ],
			 enterprise => 1,
		},
		$V{ REMOVE } => {
			  uri => "/farms/<$K{FARM}>/zones/<$K{ZONES}>/resources/$Define::Uri_param_tag",
			  method    => 'DELETE',
			  param_uri => [
							{
							  name => "resource_ID",
							  desc => "the IP address of the source which will be removed",
							},
			  ],
			  enterprise => 1,
		},
	},

	'farm-certificate' => {
						 $V{ ADD } => {
										uri    => "/farms/<$K{FARM}>/certificates",
										method => 'POST',
										params_autocomplete => {
																 file => ['certificates'],
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

	'farm-add-request-header' => {
			  $V{ ADD } => {
							 uri        => "/farms/<$K{FARM}>/addheader",
							 method     => 'POST',
							 enterprise => 1,
			  },
			  $V{ REMOVE } => {
					  uri       => "/farms/<$K{FARM}>/addheader/$Define::Uri_param_tag",
					  param_uri => [
									{
									  name => "index",
									  desc => "It is the index of the directive to remove",
									},
					  ],
					  method     => 'DELETE',
					  enterprise => 1,
			  },
	},

	'farm-remove-request-header' => {
			  $V{ ADD } => {
							 uri        => "/farms/<$K{FARM}>/headremove",
							 method     => 'POST',
							 enterprise => 1,
			  },
			  $V{ REMOVE } => {
					  uri       => "/farms/<$K{FARM}>/headremove/$Define::Uri_param_tag",
					  param_uri => [
									{
									  name => "index",
									  desc => "It is the index of the directive to remove",
									},
					  ],
					  method     => 'DELETE',
					  enterprise => 1,
			  },
	},

	'farm-add-response-header' => {
			  $V{ ADD } => {
							 uri        => "/farms/<$K{FARM}>/addresponseheader",
							 method     => 'POST',
							 enterprise => 1,
			  },
			  $V{ REMOVE } => {
					  uri => "/farms/<$K{FARM}>/addresponseheader/$Define::Uri_param_tag",
					  param_uri => [
									{
									  name => "index",
									  desc => "It is the index of the directive to remove",
									},
					  ],
					  method     => 'DELETE',
					  enterprise => 1,
			  },
	},

	'farm-remove-response-header' => {
			 $V{ ADD } => {
							uri        => "/farms/<$K{FARM}>/removeresponseheader",
							method     => 'POST',
							enterprise => 1,
			 },
			 $V{ REMOVE } => {
					 uri => "/farms/<$K{FARM}>/removeresponseheader/$Define::Uri_param_tag",
					 param_uri => [
								   {
									 name => "index",
									 desc => "It is the index of the directive to remove",
								   },
					 ],
					 method     => 'DELETE',
					 enterprise => 1,
			 },
	},

	'farm-replace-request-header' => {
			 $V{ ADD } => {
							uri        => "/farms/<$K{FARM}>/replacerequestheader",
							method     => 'POST',
							enterprise => 1,
			 },
			 $V{ REMOVE } => {
					 uri => "/farms/<$K{FARM}>/replacerequestheader/$Define::Uri_param_tag",
					 param_uri => [
								   {
									 name => "index",
									 desc => "It is the index of the directive to remove",
								   },
					 ],
					 method     => 'DELETE',
					 enterprise => 1,
			 },
	},

	'farm-replace-response-header' => {
			 $V{ ADD } => {
							uri        => "/farms/<$K{FARM}>/replaceresponseheader",
							method     => 'POST',
							enterprise => 1,
			 },
			 $V{ REMOVE } => {
					 uri => "/farms/<$K{FARM}>/replaceresponseheader/$Define::Uri_param_tag",
					 param_uri => [
								   {
									 name => "index",
									 desc => "It is the index of the directive to remove",
								   },
					 ],
					 method     => 'DELETE',
					 enterprise => 1,
			 },
	},

	'farm-waf' => {
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

	'farm-blacklist' => {
						  $V{ ADD } => {
										 uri        => "/farms/<$K{FARM}>/ipds/blacklists",
										 method     => 'POST',
										 enterprise => 1,
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

	'farm-dos' => {
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

	'farm-rbl' => {
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
