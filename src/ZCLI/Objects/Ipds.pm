#!/usr/bin/perl

use strict;
use warnings;

use ZCLI::Define;

use ZCLI::Objects::Blacklist;
use ZCLI::Objects::Dos;
use ZCLI::Objects::Waf;
use ZCLI::Objects::Rbl;

# verbs
my %V = %Define::Actions;

# keys
my %K = %Define::Keys;

package Objects;

our $Ipds = {
			  'ipds' => {
						  $V{ LIST } => {
										  uri    => "/ipds",
										  method => 'GET',
						  },
			  },
			  'ipds-package' => {
								  $V{ GET } => {
												 uri    => "/ipds/package",
												 method => 'GET',
								  },
								  $V{ UPGRADE } => {
													 uri    => "/ipds/package",
													 method => 'POST',
													 params => {
																 'action' => 'upgrade',
													 },
								  },
			  },
};

$Objects::Ipds = &Hash::Merge::merge( $Objects::Ipds, $Objects::Blacklist );
$Objects::Ipds = &Hash::Merge::merge( $Objects::Ipds, $Objects::Dos );
$Objects::Ipds = &Hash::Merge::merge( $Objects::Ipds, $Objects::Rbl );
$Objects::Ipds = &Hash::Merge::merge( $Objects::Ipds, $Objects::Waf );

1;
