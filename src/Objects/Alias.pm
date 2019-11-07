#!/usr/bin/perl

use strict;
use warnings;

require "./Define.pm";

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
											 },
											 $V{ SET } => {
													 uri => "/aliases/backends/<$K{ALIAS}>",
													 method => 'PUT',
											 },
											 $V{ DELETE } => {
													 uri => "/aliases/backends/<$K{ALIAS}>",
													 method => 'DELETE',
											 },
			   },
			   'network-aliases-interfaces' => {
										   $V{ LIST } => {
														   uri    => "/aliases/interfaces",
														   method => 'GET',
										   },
										   $V{ SET } => {
												   uri => "/aliases/interfaces/<$K{ALIAS}>",
												   method => 'PUT',
										   },
										   $V{ DELETE } => {
												   uri => "/aliases/interfaces/<$K{ALIAS}>",
												   method => 'DELETE',
										   },
			   },
};

1;
