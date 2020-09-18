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

our $Debug = {
	'farm-service' => {
						$V{ ADD } => {
									   uri    => "/farms/<$K{FARM}>/services",
									   method => 'POST',
						},
						$V{ SET } => {
									   uri    => "/farms/<$K{FARM}>/services/<$K{SRV}>",
									   method => 'PUT',
						},
	},
	'farm' => {
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

	'system-backup' => {
						 $V{ DOWNLOAD } => {
											 uri           => "/system/backup/<$K{BACKUP}>",
											 method        => 'GET',
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
	}
};

1;
