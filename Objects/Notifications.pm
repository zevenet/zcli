#!/usr/bin/perl

use strict;
use warnings;

require "./Define.pm";

# verbs
my %V = %Define::Actions;

# keys
my %K = %Define::Keys;

package Objects;

our $Notifications = {
					 'system-notifications-alerts-backends' => {
							 $V{ GET } => {
											uri => "/system/notifications/alerts/backends",
											method => 'GET',
							 },
							 $V{ SET } => {
											uri => "/system/notifications/alerts/backends",
											method => 'POST',
							 },
							 $V{ START } => {
									 uri => "/system/notifications/alerts/backends/actions",
									 method => 'POST',
									 params => {
												 action => 'enable',
									 },
							 },
							 $V{ STOP } => {
									 uri => "/system/notifications/alerts/backends/actions",
									 method => 'POST',
									 params => {
												 action => 'disable',
									 },
							 },
					 },
					 'system-notifications-alerts-cluster' => {
							  $V{ GET } => {
											 uri => "/system/notifications/alerts/cluster",
											 method => 'GET',
							  },
							  $V{ SET } => {
											 uri => "/system/notifications/alerts/cluster",
											 method => 'POST',
							  },
							  $V{ START } => {
									  uri => "/system/notifications/alerts/cluster/actions",
									  method => 'POST',
									  params => {
												  action => 'enable',
									  },
							  },
							  $V{ STOP } => {
									  uri => "/system/notifications/alerts/cluster/actions",
									  method => 'POST',
									  params => {
												  action => 'disable',
									  },
							  },
					 },
					 'system-notifications-methods-email' => {
							   $V{ GET } => {
											  uri => "/system/notifications/methods/email",
											  method => 'GET',
							   },
							   $V{ SET } => {
											  uri => "/system/notifications/methods/email",
											  method => 'POST',
							   },
							   $V{ TEST } => {
											   uri => "/system/notifications/methods/email",
											   method => 'POST',
							   },
							   $V{ STOP } => {
									   uri => "/system/notifications/methods/email/actions",
									   method => 'POST',
									   params => {
												   action => 'test',
									   },
							   },
					 },
};

1;

