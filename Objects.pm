#!/usr/bin/perl

use strict;
use warnings;
use Hash::Merge;

package Objects;

require "./Objects/Farms.pm";
require "./Objects/Interfaces.pm";

our $zcli_objects = {};
$Objects::zcli_objects = &Hash::Merge::merge( $Objects::zcli_objects, $Objects::Farms::Farms );
$Objects::zcli_objects = &Hash::Merge::merge( $Objects::zcli_objects, $Objects::Interfaces::Interfaces );


1;
