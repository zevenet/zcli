#!/usr/bin/perl

use strict;
use warnings;
use Hash::Merge;

package Objects;

use ZCLI::Objects::Farms;
use ZCLI::Objects::Interfaces;
use ZCLI::Objects::Certificates;
use ZCLI::Objects::Farmguardian;
use ZCLI::Objects::Statistics;
use ZCLI::Objects::Ipds;
use ZCLI::Objects::System;
use ZCLI::Objects::Rbac;

#~ our $Zcli = {};
#~ $Objects::Zcli = &Hash::Merge::merge( $Objects::Zcli, $Objects::Farms );
#~ $Objects::Zcli = &Hash::Merge::merge( $Objects::Zcli, $Objects::Interfaces );
#~ $Objects::Zcli = &Hash::Merge::merge( $Objects::Zcli, $Objects::Certificates );
#~ $Objects::Zcli = &Hash::Merge::merge( $Objects::Zcli, $Objects::Farmguardian );
#~ $Objects::Zcli = &Hash::Merge::merge( $Objects::Zcli, $Objects::Statistics );
#~ $Objects::Zcli = &Hash::Merge::merge( $Objects::Zcli, $Objects::Ipds );
#~ $Objects::Zcli = &Hash::Merge::merge( $Objects::Zcli, $Objects::System );
#~ $Objects::Zcli = &Hash::Merge::merge( $Objects::Zcli, $Objects::Rbac );

1;

#### DEBUG!!
use ZCLI::Define;

# verbs
my %V = %Define::Actions;

# keys
my %K = %Define::Keys;
my $debug = {
	'farms-services' => {
						  $V{ CREATE } => {
											uri    => "/farms/<$K{FARM}>/services",
											method => 'POST',
						  },
						  $V{ SET } => {
										 uri    => "/farms/<$K{FARM}>/services/<$K{SRV}>",
										 method => 'PUT',
						  },
	},
	'farms' => {
				 $V{ STOP } => {
								 uri    => "/farms/<$K{FARM}>/actions",
								 method => 'PUT',
								 params => {
											 'action' => 'stop',
								 },
				 },
	},

	'system-backups' => {
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
	}
};
our $Zcli = $debug;
