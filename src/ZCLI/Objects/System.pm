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
use ZCLI::Objects::Services;
use ZCLI::Objects::Notifications;

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
								  uri    => "/system/info",
								  method => 'GET',
				   },
	 },
	 'system-updates' => {
						   $V{ LIST } => {
										   uri        => "/system/packages",
										   method     => 'GET',
										   enterprise => 1,
						   },
	 },
	 'system-user' => {
						$V{ GET } => {
									   uri    => "/system/users",
									   method => 'GET',
						},
						$V{ SET } => {
									   uri    => "/system/users",
									   method => 'POST',
						},
	 },
	 'system-logs' => {
			 $V{ LIST } => {
							 uri    => "/system/logs",
							 method => 'GET',
			 },
			 $V{ GET } => {
					 uri       => "/system/logs/<$K{LOG}>/lines/$Define::Uri_param_tag",
					 method    => 'GET',
					 param_uri => [
								   {
									 name => "lines",
									 desc => "the number of lines of the log file to show",
								   },
					 ],
			 },
			 $V{ DOWNLOAD } => {
								 uri           => "/system/logs/<$K{LOG}>",
								 method        => 'GET',
								 download_file => undef,
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
								   uri          => "/system/backup/$Define::Uri_param_tag",
								   method       => 'PUT',
								   content_type => 'application/gzip',
								   upload_file  => undef,
								   param_uri    => [
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
										  uri        => "/system/cluster",
										  method     => 'GET',
										  enterprise => 1,
						   },
						   $V{ CREATE } => {
											 uri        => "/system/cluster",
											 method     => 'POST',
											 enterprise => 1,
						   },
						   $V{ SET } => {
										  uri        => "/system/cluster",
										  method     => 'PUT',
										  enterprise => 1,
						   },
						   $V{ DELETE } => {
											 uri        => "/system/cluster",
											 method     => 'DELETE',
											 enterprise => 1,
						   },
						   $V{ MAINTENANCE } => {
												  uri    => "/system/cluster/actions",
												  method => 'POST',
												  params => {
															  action => 'maintenance',
															  status => 'enable',
												  },
												  enterprise => 1,
						   },
						   $V{ NON_MAINTENANCE } => {
													  uri    => "/system/cluster/actions",
													  method => 'POST',
													  params => {
																  action => 'maintenance',
																  status => 'disable',
													  },
													  enterprise => 1,
						   },
	 },
	 'system-cluster-nodes' => {
								 $V{ GET } => {
												uri        => "/system/cluster/nodes",
												method     => 'GET',
												enterprise => 1,
								 },
	 },
	 'system-cluster-localhost' => {
									 $V{ GET } => {
												   uri => "/system/cluster/nodes/localhost",
												   method     => 'GET',
												   enterprise => 1,
									 },
	 },
};

$Objects::Ipds = &Hash::Merge::merge( $Objects::Ipds, $Objects::Services );
$Objects::Ipds = &Hash::Merge::merge( $Objects::Ipds, $Objects::Notifications );

1;
