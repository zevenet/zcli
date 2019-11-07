#!/usr/bin/perl

use strict;
use warnings;
use Hash::Merge;

package Objects;

require "./Objects/Farms.pm";
require "./Objects/Interfaces.pm";
require "./Objects/Certificates.pm";
require "./Objects/Farmguardian.pm";
require "./Objects/Statistics.pm";
require "./Objects/Ipds.pm";
require "./Objects/System.pm";
require "./Objects/Rbac.pm";

our $zcli_objects = {};
$Objects::zcli_objects =
  &Hash::Merge::merge( $Objects::zcli_objects, $Objects::Farms );
$Objects::zcli_objects =
  &Hash::Merge::merge( $Objects::zcli_objects, $Objects::Interfaces );
$Objects::zcli_objects =
  &Hash::Merge::merge( $Objects::zcli_objects, $Objects::Certificates );
$Objects::zcli_objects =
  &Hash::Merge::merge( $Objects::zcli_objects, $Objects::Farmguardian );
$Objects::zcli_objects =
  &Hash::Merge::merge( $Objects::zcli_objects, $Objects::Statistics );
$Objects::zcli_objects =
  &Hash::Merge::merge( $Objects::zcli_objects, $Objects::Ipds );
$Objects::zcli_objects =
  &Hash::Merge::merge( $Objects::zcli_objects, $Objects::System );
$Objects::zcli_objects =
  &Hash::Merge::merge( $Objects::zcli_objects, $Objects::Rbac );

1;
