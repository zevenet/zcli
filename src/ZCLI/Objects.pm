#!/usr/bin/perl

use strict;
use warnings;
use Hash::Merge;

package Objects;

use ZCLI::Objects::Farms;
use ZCLI::Objects::Interfaces;
use ZCLI::Objects::Certificates;
use ZCLI::Objects::Farmguardian;
use ZCLI::Objects::Statistics;
use ZCLI::Objects::Ipds;
use ZCLI::Objects::System;
use ZCLI::Objects::Rbac;

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
