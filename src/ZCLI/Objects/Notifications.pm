#!/usr/bin/perl

use strict;
use warnings;

use ZCLI::Define;

# verbs
my %V = %Define::Actions;

# keys
my %K = %Define::Keys;

package Objects;

our $Notifications = {
					 'system-notifications-alerts-backends' => {
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
					 'system-notifications-alerts-cluster' => {
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
					 'system-notifications-methods-email' => {
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

