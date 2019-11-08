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
						  method => 'POST',
		},
		$V{ SET } => {
					   uri    => "/farms/<$K{FARM}>/services/<$K{SRV}>",
					   method => 'PUT',
		},
		$V{ DELETE } => {
						  uri    => "/farms/<$K{FARM}>/services/<$K{SRV}>",
						  method => 'DELETE',
		},
		$V{ MOVE } => {
			uri    => "/farms/<$K{FARM}>/services/<$K{SRV}>/actions",
			method => 'POST',
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
						  uri    => "/farms/<$K{FARM}>/services/<$K{SRV}>/backends/<$K{BK}>",
						  method => 'DELETE',
		},
		$V{ MAINTENANCE } => {
						  uri    => "/farms/<$K{FARM}>/services/<$K{SRV}>/backends/<$K{BK}>/maintenance",
						  method => 'PUT',
						  params => {
							  action => 'maintenance',
							  mode => 'drain',
						  }
		},
		$V{ NON_MAINTENANCE } => {
						  uri    => "/farms/<$K{FARM}>/services/<$K{SRV}>/backends/<$K{BK}>/maintenance",
						  method => 'PUT',
						  params => {
							  action => 'up',
						  }
		},
	},

	'farms-services-farmguardian' => {
		$V{ ADD } => {
					   uri    => "/farms/<$K{FARM}>/services/<$K{SRV}>/fg",
					   method => 'POST',
		},
		$V{ REMOVE } => {
						  uri    => "/farms/<$K{FARM}>/services/<$K{SRV}>/fg/<$K{FG}>",
						  method => 'DELETE',
		},
	},

	'farms-zones' => {
					   $V{ CREATE } => {
										 uri    => "/farms/<$K{FARM}>/zones",
										 method => 'POST',
					   },
					   $V{ SET } => {
									  uri    => "/farms/<$K{FARM}>/zones/<$K{ZONES}>",
									  method => 'PUT',
					   },
					   $V{ DELETE } => {
										 uri    => "/farms/<$K{FARM}>/zones/<$K{ZONES}>",
										 method => 'DELETE',
					   },
	},

	'farms-zones-resources' => {
					   $V{ LIST } => {
										 uri    => "/farms/<$K{FARM}>/zones/<$K{ZONES}>/resources",
										 method => 'GET',
					   },
					   $V{ CREATE } => {
									  uri    => "/farms/<$K{FARM}>/zones/<$K{ZONES}>/resources",
									  method => 'POST',
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
					   },
					   $V{ DELETE } => {
										 uri    => "/farms/<$K{FARM}>/zones/<$K{ZONES}>/resources/$Define::UriParamTag",
										 method => 'DELETE',
										 uri_param => [
													   {
														 name => "resource ID",
														 desc => "the IP address of the source which will be removed",
													   },
										 ],
					   },
	},

	'farms-certificates' => {
						 $V{ ADD } => {
										uri    => "/farms/<$K{FARM}>/certificates",
										method => 'POST',
						 },
						 $V{ MOVE } => {
								 uri => "/farms/<$K{FARM}>/certificates/<$K{CERT}>/actions",
								 method => 'POST',
						 },
						 $V{ REMOVE } => {
										 uri => "/farms/<$K{FARM}>/certificates/<$K{CERT}>",
										 method => 'DELETE',
						 },
	},

	'farms-waf' => {
					 $V{ ADD } => {
									uri    => "/farms/<$K{FARM}>/ipds/waf",
									method => 'POST',
					 },
					 $V{ REMOVE } => {
									   uri    => "/farms/<$K{FARM}>/ipds/waf/<$K{WAF}>",
									   method => 'DELETE',
					 },
					 $V{ MOVE } => {
									 uri => "/farms/<$K{FARM}>/ipds/waf/<$K{WAF}>/actions",
									 method => 'POST',
					 },
	},

	'farms-blacklists' => {
							$V{ ADD } => {
										   uri    => "/farms/<$K{FARM}>/ipds/blacklists",
										   method => 'POST',
							},
							$V{ REMOVE } => {
										uri => "/farms/<$K{FARM}>/ipds/blacklists/<$K{BL}>",
										method => 'DELETE',
							},
	},

	'farms-dos' => {
					 $V{ ADD } => {
									uri    => "/farms/<$K{FARM}>/ipds/dos",
									method => 'POST',
					 },
					 $V{ REMOVE } => {
									   uri    => "/farms/<$K{FARM}>/ipds/dos/<$K{DOS}>",
									   method => 'DELETE',
					 },
	},

	'farms-rbl' => {
					 $V{ ADD } => {
									uri    => "/farms/<$K{FARM}>/ipds/rbl",
									method => 'POST',
					 },
					 $V{ REMOVE } => {
									   uri    => "/farms/<$K{FARM}>/ipds/rbl/<$K{RBL}>",
									   method => 'DELETE',
					 },
	},
};

1;
