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

use strict;
use Data::Dumper;
use feature "say";
use POSIX qw(_exit);

# https://metacpan.org/pod/Term::ShellUI
use Term::ShellUI;

use ZCLI::Define;
use ZCLI::Lib;
use ZCLI::Objects;
use ZCLI::Interactive;

# Init!

system ( "mkdir -p $Global::Config_dir" ) if ( !-d $Global::Config_dir );

my $opt = &parseOptions( \@ARGV );

&printHelp() if ( $opt->{ 'help' } );

# add local lb if it exists
my $local_profile = &getProfile( $opt->{ 'profile' } );
if ( &isLoadBalancer() )
{
	if ( !defined $local_profile )
	{
		&printSuccess( "Type the zapi key for the current load balancer", 0 );
		&setProfile( "local_profile", 1 );
	}

	# refresh ip and port. Maybe they were modified
	else
	{
		&updateProfileLocal();
	}
}

$Env::Profile = &getProfile( $opt->{ 'profile' } );
if ( !$Env::Profile )
{
	if ( $opt->{ 'silence' } )
	{
		&printError( "It is necessary to select a 'profile' to use the silence mode" );
		exit 1;
	}
}

if ( !$Env::Profile )
{
	&printSuccess(
			   "No profile found, try to configure the default load balancer profile" );
	$Env::Profile = &setProfile();
}

# update the Zevenet version if it does not exit
if ( !exists $Env::Profile->{ edition } )
{
	my $edition = &getProfileEdition( $Env::Profile );
	&getProfileEdition( $Env::Profile->{ name }, $edition ) if ( defined $edition );
}

# Use interactive
my $err = &createZcli();
exit $err;
