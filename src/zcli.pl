#!/usr/bin/perl

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

# overriding error method
#*{ Term::ShellUI::error } = sub {
*Term::ShellUI::error = sub {
	say "$_[1]";
	&reload_prompt( 1 );
};

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
		print "Type the zapi key for the current load balancer\n";
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
	if ( exists $opt->{ 'host' } )
	{
		say "Not found the '$opt->{host}' host, selecting the default host";
		$Env::HOST = &hostInfo( $opt->{ 'host' } );
	}

	if ( $opt->{ 'silence' } )
	{
		say "The silence mode needs a host profile";
		exit 1;
	}
}

if ( !$Env::HOST )
{
	say "Not found the host info, try to configure the default host profile";
	$Env::HOST = &setHost();
}

# Launching only a cmd
if ( $opt->{ 'silence' } )
{
	my $resp;
	eval {
		my $obj = $_[0];
		my $act = $_[1];

		my $input = &parseInput( $Objects::Zcli->{ $obj }->{ $act }, @ARGV );
		my $request =
		  &checkInput( $Objects::Zcli, $input, $Env::HOST, $Env::HOST_IDS_TREE );
		$resp = &zapi( $request, $Env::HOST );
		&printOutput( $resp );
	};
	say $@ if $@;
	my $err = ( $@ or $resp->{ err } ) ? 1 : 0;
	POSIX::_exit( $err );
}

# Use interactive
&create_zcli();
