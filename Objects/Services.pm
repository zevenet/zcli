#!/usr/bin/perl

use strict;
use warnings;

require "./Define.pm";

# verbs
my %V = %Define::Actions;

# keys
my %K = %Define::Keys;

package Objects;

our $Services = {
				  'system-services-dns' => {
											 $V{ GET } => {
															uri    => "/system/dns",
															method => 'GET',
											 },
											 $V{ SET } => {
															uri    => "/system/dns",
															method => 'POST',
											 },
				  },
				  'system-services-snmp' => {
											  $V{ GET } => {
															 uri    => "/system/snmp",
															 method => 'GET',
											  },
											  $V{ SET } => {
															 uri    => "/system/snmp",
															 method => 'POST',
											  },
				  },
				  'system-services-ntp' => {
											 $V{ GET } => {
															uri    => "/system/ntp",
															method => 'GET',
											 },
											 $V{ SET } => {
															uri    => "/system/ntp",
															method => 'POST',
											 },
				  },
				  'system-services-ssh' => {
											 $V{ GET } => {
															uri    => "/system/ssh",
															method => 'GET',
											 },
											 $V{ SET } => {
															uri    => "/system/ssh",
															method => 'POST',
											 },
				  },
				  'system-services-http' => {
											  $V{ GET } => {
															 uri    => "/system/http",
															 method => 'GET',
											  },
											  $V{ SET } => {
															 uri    => "/system/http",
															 method => 'POST',
											  },
				  },
				  'system-services-proxy' => {
											   $V{ GET } => {
															  uri    => "/system/proxy",
															  method => 'GET',
											   },
											   $V{ SET } => {
															  uri    => "/system/proxy",
															  method => 'POST',
											   },
				  },
};

1;