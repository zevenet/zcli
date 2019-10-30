#!/usr/bin/perl

use strict;
use warnings;

require "./Define.pm";

# verbs
my %V = %Define::Actions;

# keys
my %K = %Define::Keys;

package Objects;

our $Statistics = {
					'statistics-system' => {
											 $V{ GET } => {
															uri    => "/stats",
															method => 'GET',
											 },
					},
					'statistics-network' => {
										  $V{ GET } => {
												  uri => "/stats/system/network/interfaces",
												  method => 'GET',
										  },
					},
					'statistics-network-connections' => {
										  $V{ GET } => {
												  uri => "/stats/system/connections",
												  method => 'GET',
										  },
					},
					'statistics-farms' => {
											$V{ LIST } => {
															uri    => "/stats/farms",
															method => 'GET',
											},
											$V{ GET } => {
													  uri => "/stats/farms/$K{FARM}",
													  method => 'GET',
											},
					},
};

1;
