#!/usr/bin/perl

use strict;
use warnings;

require "./Define.pm";

require "./Objects/Blacklist.pm";
require "./Objects/Dos.pm";
require "./Objects/Waf.pm";
require "./Objects/Rbl.pm";

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
