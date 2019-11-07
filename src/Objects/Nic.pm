#!/usr/bin/perl

use strict;
use warnings;

require "./Define.pm";

# verbs
my %V = %Define::Actions;

# keys
my %K = %Define::Keys;

package Objects;

our $Nic = {
			 'network-nic' => {
								$V{ LIST } => {
												uri    => "/interfaces/nic",
												method => 'GET',
								},
								$V{ GET } => {
											   uri    => "/interfaces/nic/<$K{IFACE}>",
											   method => 'GET',
								},
								$V{ SET } => {
											   uri    => "/interfaces/nic/<$K{IFACE}>",
											   method => 'PUT',
								},
								$V{ UNSET } => {
												 uri    => "/interfaces/nic/<$K{IFACE}>",
												 method => 'DELETE',
								},
								$V{ START } => {
											   uri => "/interfaces/nic/<$K{IFACE}>/actions",
											   method => 'POST',
											   params => {
														   'action' => 'up',
											   },
								},
								$V{ STOP } => {
											   uri => "/interfaces/nic/<$K{IFACE}>/actions",
											   method => 'POST',
											   params => {
														   'action' => 'down',
											   },
								},
			 },
};

1;
