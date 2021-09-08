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

our $Notifications = {
					 'system-notifications-alert-backend' => {
							 $V{ GET } => {
											uri => "/system/notifications/alerts/backends",
											method     => 'GET',
											enterprise => 1,
							 },
							 $V{ SET } => {
											uri => "/system/notifications/alerts/backends",
											method     => 'POST',
											enterprise => 1,
							 },
							 $V{ START } => {
									 uri => "/system/notifications/alerts/backends/actions",
									 method => 'POST',
									 params => {
												 action => 'enable',
									 },
									 enterprise => 1,
							 },
							 $V{ STOP } => {
									 uri => "/system/notifications/alerts/backends/actions",
									 method => 'POST',
									 params => {
												 action => 'disable',
									 },
									 enterprise => 1,
							 },
					 },
					 'system-notifications-alert-cluster' => {
							  $V{ GET } => {
											 uri => "/system/notifications/alerts/cluster",
											 method     => 'GET',
											 enterprise => 1,
							  },
							  $V{ SET } => {
											 uri => "/system/notifications/alerts/cluster",
											 method     => 'POST',
											 enterprise => 1,
							  },
							  $V{ START } => {
									  uri => "/system/notifications/alerts/cluster/actions",
									  method => 'POST',
									  params => {
												  action => 'enable',
									  },
									  enterprise => 1,
							  },
							  $V{ STOP } => {
									  uri => "/system/notifications/alerts/cluster/actions",
									  method => 'POST',
									  params => {
												  action => 'disable',
									  },
									  enterprise => 1,
							  },
					 },
					 'system-notifications-alert-license' => {
							  $V{ GET } => {
											 uri => "/system/notifications/alerts/license",
											 method     => 'GET',
											 enterprise => 1,
							  },
							  $V{ START } => {
									  uri => "/system/notifications/alerts/license/actions",
									  method => 'POST',
									  params => {
												  action => 'enable',
									  },
									  enterprise => 1,
							  },
							  $V{ STOP } => {
									  uri => "/system/notifications/alerts/license/actions",
									  method => 'POST',
									  params => {
												  action => 'disable',
									  },
									  enterprise => 1,
							  },
					 },
					 'system-notifications-alert-interface' => {
							  $V{ GET } => {
											 uri => "/system/notifications/alerts/interface",
											 method     => 'GET',
											 enterprise => 1,
							  },
							  $V{ SET } => {
											 uri => "/system/notifications/alerts/interface",
											 method     => 'POST',
											 enterprise => 1,
							  },
							  $V{ START } => {
									  uri => "/system/notifications/alerts/interface/actions",
									  method => 'POST',
									  params => {
												  action => 'enable',
									  },
									  enterprise => 1,
							  },
							  $V{ STOP } => {
									  uri => "/system/notifications/alerts/interface/actions",
									  method => 'POST',
									  params => {
												  action => 'disable',
									  },
									  enterprise => 1,
							  },
					 },
					 'system-notifications-alert-certificate' => {
							  $V{ GET } => {
											 uri => "/system/notifications/alerts/certificate",
											 method     => 'GET',
											 enterprise => 1,
							  },
							  $V{ START } => {
									  uri => "/system/notifications/alerts/certificate/actions",
									  method => 'POST',
									  params => {
												  action => 'enable',
									  },
									  enterprise => 1,
							  },
							  $V{ STOP } => {
									  uri => "/system/notifications/alerts/certificate/actions",
									  method => 'POST',
									  params => {
												  action => 'disable',
									  },
									  enterprise => 1,
							  },
					 },
					 'system-notifications-alert-package' => {
							  $V{ GET } => {
											 uri => "/system/notifications/alerts/package",
											 method     => 'GET',
											 enterprise => 1,
							  },
							  $V{ START } => {
									  uri => "/system/notifications/alerts/certificate/actions",
									  method => 'POST',
									  params => {
												  action => 'enable',
									  },
									  enterprise => 1,
							  },
							  $V{ STOP } => {
									  uri => "/system/notifications/alerts/certificate/actions",
									  method => 'POST',
									  params => {
												  action => 'disable',
									  },
									  enterprise => 1,
							  },
					 },
					 'system-notifications-method-email' => {
							   $V{ GET } => {
											  uri => "/system/notifications/methods/email",
											  method     => 'GET',
											  enterprise => 1,
							   },
							   $V{ SET } => {
											  uri => "/system/notifications/methods/email",
											  method     => 'POST',
											  enterprise => 1,
							   },
							   $V{ TEST } => {
											   uri => "/system/notifications/methods/email",
											   method     => 'POST',
											   enterprise => 1,
							   },
							   $V{ STOP } => {
									   uri => "/system/notifications/methods/email/actions",
									   method => 'POST',
									   params => {
												   action => 'test',
									   },
									   enterprise => 1,
							   },
					 },
};

1;

