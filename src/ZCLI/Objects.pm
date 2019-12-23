#!/usr/bin/perl

use strict;
use warnings;
use Hash::Merge;
use ZCLI::Define;

package Objects;

use ZCLI::Objects::Farms;
use ZCLI::Objects::Interfaces;
use ZCLI::Objects::Certificates;
use ZCLI::Objects::Farmguardian;
use ZCLI::Objects::Statistics;
use ZCLI::Objects::Ipds;
use ZCLI::Objects::System;
use ZCLI::Objects::Rbac;

our $Zcli = {};

if ( $Global::DEBUG > 1 )
{
	require ZCLI::Objects::Debug;
	$Objects::Zcli = &Hash::Merge::merge( $Objects::Zcli, $Objects::Debug );
}
else
{
	$Objects::Zcli = &Hash::Merge::merge( $Objects::Zcli, $Objects::Farms );
	$Objects::Zcli = &Hash::Merge::merge( $Objects::Zcli, $Objects::Interfaces );
	$Objects::Zcli = &Hash::Merge::merge( $Objects::Zcli, $Objects::Certificates );
	$Objects::Zcli = &Hash::Merge::merge( $Objects::Zcli, $Objects::Farmguardian );
	$Objects::Zcli = &Hash::Merge::merge( $Objects::Zcli, $Objects::Statistics );
	$Objects::Zcli = &Hash::Merge::merge( $Objects::Zcli, $Objects::Ipds );
	$Objects::Zcli = &Hash::Merge::merge( $Objects::Zcli, $Objects::System );
	$Objects::Zcli = &Hash::Merge::merge( $Objects::Zcli, $Objects::Rbac );
}

1;

