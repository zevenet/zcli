#!/usr/bin/perl

use strict;
use warnings;

use ZCLI::Define;

# verbs
my %V = %Define::Actions;

# keys
my %K = %Define::Keys;

package Objects;

our $Debug = {
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
				 $V{ GET } => {
								uri    => "/farms/<$K{FARM}>",
								method => 'GET',
				 }
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

1;
