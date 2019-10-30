#!/usr/bin/perl

use strict;
use warnings;

require "./Define.pm";

# verbs
my %V = %Define::Actions;

# keys
my %K = %Define::Keys;

package Objects;

our $Certificates = {
	'certificates' => {
		$V{ LIST } => {
						uri    => "/certificates",
						method => 'GET',
		},
		$V{ DOWNLOAD } => {
			uri    => "/certificates/<$K{CERT}>",
			method => 'GET',

			# ADD HEADERS
			# ADD DESTINE FILE
			# ????
		},
		$V{ GET } => {
					   uri    => "/certificates/<$K{CERT}>/info",
					   method => 'GET',
		},
		$V{ DELETE } => {
						  uri    => "/certificates/<$K{CERT}>",
						  method => 'DELETE',
		},
		$V{ CREATE } => {
			uri    => "/certificates",
			method => 'POST',

			# ADD HEADERS
			# ADD SOURCE FILE
			# ????
		},
		$V{ UPLOAD } => {
						  uri    => "/certificates/<$K{CERT}>",
						  method => 'POST',
		},
	},
	'certificates-ciphers' => {
								$V{ LIST } => {
												uri    => "/ciphers",
												method => 'GET',
								},
	},
};

1;
