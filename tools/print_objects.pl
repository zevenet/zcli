#!/usr/bin/perl
###############################################################################
#
#    Zevenet Software License
#    This file is part of the Zevenet Load Balancer software package.
#
#    Copyright (C) 2014-today ZEVENET SL, Sevilla (Spain)
#
#    This program is free software: you can redistribute it and/or modify
#    it under the terms of the GNU Affero General Public License as
#    published by the Free Software Foundation, either version 3 of the
#    License, or any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU Affero General Public License for more details.
#
#    You should have received a copy of the GNU Affero General Public License
#    along with this program.  If not, see <http://www.gnu.org/licenses/>.
#
###############################################################################

# Print the objects with their actions

use strict;
use feature "say";

use lib '../src/';
use ZCLI::Objects;

my $ce = 0;
my $st;
my $line     = 80;
my $max_size = 0;
foreach my $cmd ( keys %{ $Objects::Zcli } )
{
	if ( $ce )
	{
		next if exists $Objects::Zcli->{ $cmd }->{ enterprise };
	}

	$max_size = length ( $cmd ) if ( length ( $cmd ) > $max_size );
	my @act = keys %{ $Objects::Zcli->{ $cmd } };
	$st->{ $cmd } = \@act;
}

&print_objects();

######

# return the word tabulated
sub tab
{
	my $word = $_[0];
	return " $word" . " " x ( $max_size + 2 - length ( $word ) ) . " | ";
}

sub print_objects
{
	print &tab( "Objects" ) . "Actions\n";
	print "-" x $line . "\n";
	foreach my $it ( sort keys %$st )
	{
		print &tab( $it ) . join ( ' ', sort @{ $st->{ $it } } ) . "\n";
	}
}

1;
