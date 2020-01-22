#!/usr/bin/perl

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
			 uri    => "/farms/<$K{FARM}>/zones/<$K{ZONES}>/resources/$Define::UriParamTag",
			 method => 'PUT',
			 uri_param => [
						   {
							 name => "resource ID",
							 desc => "the IP address of the source which will be modified",
						   },
			 ],
			 enterprise => 1,
		},
		$V{ DELETE } => {
			  uri => "/farms/<$K{FARM}>/zones/<$K{ZONES}>/resources/$Define::UriParamTag",
			  method    => 'DELETE',
			  uri_param => [
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
