#!/usr/bin/perl

use strict;
use warnings;

require "./Define.pm";

require "./Objects/Services.pm";
require "./Objects/Notifications.pm";

# verbs
my %V = %Define::Actions;

# keys
my %K = %Define::Keys;

package Objects;

our $System = {
	'license' => {
				   $V{ GET } => {
								  uri    => "/system/license/txt",
								  method => 'GET',
				   },
	},
	'system' => {
				  $V{ GET } => {
								 uri    => "/system",
								 method => 'GET',
				  },
	},
	'system-updates' => {
						  $V{ LIST } => {
										  uri    => "/system/packages",
										  method => 'GET',
						  },
	},
	'system-user' => {
					   $V{ GET } => {
									  uri    => "/system/users",
									  method => 'GET',
					   },
					   $V{ SET } => {
									  uri    => "/system/users",
									  method => 'GET',
					   },
	},
	'system-logs' => {
		$V{ GET } => {
					   uri    => "/system/logs",
					   method => 'GET',
		},
		$V{ SET } => {
			uri       => "/system/logs/$K{LOG}/lines/$Define::UriParamTag",
			method    => 'GET',
			uri_param => [
				{
						name => "lines",
						desc => "the number of lines of the log file to show",
				},
			],
		},
		$V{ DOWNLOAD } => {
							uri    => "/system/logs/$K{LOG}",
							method => 'GET',
		},
	},
	'system-backups' => {
						  $V{ LIST } => {
										  uri    => "/system/backup",
										  method => 'GET',
						  },
						  $V{ CREATE } => {
											uri    => "/system/backup",
											method => 'POST',
						  },
						  $V{ DOWNLOAD } => {
											  uri    => "/system/backup/<$K{BACKUP}>",
											  method => 'GET',
											  download_file => undef,
						  },
						  $V{ UPLOAD } => {
								  uri          => "/system/backup/$Define::UriParamTag",
								  method       => 'PUT',
								  content_type => 'application/gzip',
								  upload_file  => undef,
								  uri_param    => [
										{
											name => "name",
											desc => "the name which the backup will be saved",
										},
								  ],
						  },
						  $V{ DELETE } => {
											uri    => "/system/backup/<$K{BACKUP}>",
											method => 'DELETE',
						  },
						  $V{ APPLY } => {
										   uri    => "/system/backup/<$K{BACKUP}>/actions",
										   method => 'POST',
										   params => {
													   action => 'apply',
										   },
						  },
	},
	'system-supportsave' => {
							  $V{ DOWNLOAD } => {
												  uri           => "/system/supportsave",
												  method        => 'GET',
												  download_file => undef,
							  },
	},
	'system-cluster' => {
						  $V{ GET } => {
										 uri    => "/system/cluster",
										 method => 'GET',
						  },
						  $V{ CREATE } => {
											uri    => "/system/cluster",
											method => 'POST',
						  },
						  $V{ SET } => {
										 uri    => "/system/cluster",
										 method => 'PUT',
						  },
						  $V{ DELETE } => {
											uri    => "/system/cluster",
											method => 'DELETE',
						  },
						  $V{ MAINTENANCE } => {
												 uri    => "/system/cluster/actions",
												 method => 'POST',
												 params => {
															 action => 'maintenance',
															 status => 'enable',
												 }
						  },
						  $V{ NON_MAINTENANCE } => {
													 uri    => "/system/cluster/actions",
													 method => 'POST',
													 params => {
																 action => 'maintenance',
																 status => 'disable',
													 }
						  },
	},
	'system-cluster-nodes' => {
								$V{ GET } => {
											   uri    => "/system/cluster/nodes",
											   method => 'GET',
								},
	},
	'system-cluster-localhost' => {
									$V{ GET } => {
												   uri => "/system/cluster/nodes/localhost",
												   method => 'GET',
									},
	},
};

$Objects::Ipds = &Hash::Merge::merge( $Objects::Ipds, $Objects::Services );
$Objects::Ipds = &Hash::Merge::merge( $Objects::Ipds, $Objects::Notifications );

1;
