#!/usr/bin/perl

use strict;
use warnings;

use ZCLI::Define;

# verbs
my %V = %Define::Actions;

# keys
my %K = %Define::Keys;

package Objects;

our $Alias = {
			   'network-aliases-backends' => {
											 $V{ LIST } => {
															 uri    => "/aliases/backends",
															 method => 'GET',
															 enterprise => 1,
											 },
											 $V{ SET } => {
													 uri => "/aliases/backends/<$K{ALIAS}>",
													 method     => 'PUT',
													 enterprise => 1,
											 },
											 $V{ DELETE } => {
													 uri => "/aliases/backends/<$K{ALIAS}>",
													 method     => 'DELETE',
													 enterprise => 1,
											 },
			   },
			   'network-aliases-interfaces' => {
										   $V{ LIST } => {
														   uri    => "/aliases/interfaces",
														   method => 'GET',
														   enterprise => 1,
										   },
										   $V{ SET } => {
												   uri => "/aliases/interfaces/<$K{ALIAS}>",
												   method     => 'PUT',
												   enterprise => 1,
										   },
										   $V{ DELETE } => {
												   uri => "/aliases/interfaces/<$K{ALIAS}>",
												   method     => 'DELETE',
												   enterprise => 1,
										   },
			   },
};

1;
