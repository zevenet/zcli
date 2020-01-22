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

# macros
my %V   = %Define::Actions;
my $FIN = $Define::FIN;

my $zcli_dir     = $Global::config_dir;
my $zcli_history = $Global::history_path;

# Init!

system ( "mkdir -p $zcli_dir" ) if ( !-d $zcli_dir );

my $opt = &parseOptions( \@ARGV );

&printHelp() if ( $opt->{ 'help' } );

# add local lb if it exists
my $localhost = &hostInfo( $opt->{ 'host' } );
if ( &check_is_lb() )
{
	if ( !defined $localhost )
	{
		&printSuccess( "Type the zapi key for the current load balancer", 0 );
		&setHost( "localhost", 1 );
	}

	# refresh ip and port. Maybe they were modified
	else
	{
		&refreshLocalHost();
	}
}

$Env::HOST = &hostInfo( $opt->{ 'host' } );
if ( !$Env::HOST )
{
	if ( $opt->{ 'silence' } )
	{
		&printError( "The silence mode needs a host profile" );
		exit 1;
	}
}

if ( !$Env::HOST )
{
	&printSuccess(
				 "Not found the host info, try to configure the default host profile" );
	$Env::HOST = &setHost();
}

# update the Zevenet version if it does not exit
if ( !exists $Env::HOST->{ edition } )
{
	my $edition = &getHostEdition( $Env::HOST );
	&updateHostEdition( $Env::HOST->{ NAME }, $edition ) if ( defined $edition );
}

# Use interactive
my $err = &create_zcli();
exit $err;
