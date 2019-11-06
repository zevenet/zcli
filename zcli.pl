#!/usr/bin/perl

use strict;
use Data::Dumper;
use feature "say";
use POSIX qw(_exit);

require "./Define.pm";
require "./lib.pm";
require "./Objects.pm";

my %V = %Define::Actions;
our $id_tree;
our $cmd_st;
our $term;

my $zcli_history = '.zcli-history';

my $opt = &parseOptions( \@ARGV );

&printHelp() if ( $opt->{'help'} );

my $host = &hostInfo($opt->{'host'});
if (!$host)
{
	if (exists $opt->{'host'})
	{
		say "Not found the '$opt->{'host'}' host, selecting the default host";
		my $host = &hostInfo($opt->{'host'});
	}

	if ($opt->{'non-interactive'})
	{
		say "The non-interfactive mode needs a host";
		exit 1;
	}
}

if (!$host)
{
	say "Not found the host info, try to configure the default host profile";
	$host = &setHost();
}


# Preparing Interface
my $objects = $Objects::zcli_objects;

&reload_cmd_struct();


# Launching only a cmd
if ( $opt->{'non-interactive'})
{
	# ?????? tmp
	say "This is not implemented yet";
	exit 1;

	my $resp;
	eval {
		my $input = &parseInput( @ARGV );
		my $request = &checkInput( $objects, $input, $host, $id_tree );
		$resp    = &zapi( $request, $host );
		&printOutput( $resp );
	};
	say $@ if $@;
	POSIX::_exit( $resp->{err} );
}



# https://metacpan.org/pod/Term::ShellUI
use Term::ShellUI;
$term = new Term::ShellUI( commands     => $cmd_st,
							  history_file => $zcli_history, );
print "Zevenet Client Line Interface\n";
$term->prompt( "zcli($host->{name}):" );
$term->load_history();
$term->run();




sub gen_cmd_struct
{
	my $st;

	# features of the lb
	if (defined $main::id_tree)
	{
		foreach my $cmd ( keys %{ $objects } )
		{
			$st->{ $cmd } = &gen_obj( $cmd );
		}
	}

	# add static functions
	$st->{ 'help' }->{ cmds }->{ $V{LIST} }->{ proc } = \&printHelp;

	$st->{ 'zcli' }->{ cmds }->{ $V{RELOAD} }->{ desc } = "Force a ZCLI reload to refresh the ID objects";
	$st->{ 'zcli' }->{ cmds }->{ $V{RELOAD} }->{ proc } = sub { &reload_cmd_struct(); };

	my $host_st;
	my @host_list = &listHost();
	$host_st->{ $V{LIST} }->{ proc } = sub { say $_ for (&listHost) };
	$host_st->{ $V{SET} }->{ proc } = \&setHost;
	$host_st->{ $V{DELETE} } = {
		proc => sub {
			if ($host->{name} eq @_[0])
			{
				say "The '$host->{name}' host is beeing used";
			}
			else
			{
				&delHost(@_);
			}
		},
		args => [sub {\@host_list}],
	};
	$host_st->{ $V{APPLY} } = {
		proc => sub {
			$host=hostInfo(@_);
			$term->prompt( "zcli($host->{name}):" );
			&reload_cmd_struct();
		},
		args => [sub {\@host_list}],
	};
	$st->{ hosts }->{ desc } = "apply an action about which is the destination load balancer";
	$st->{ hosts }->{ cmds } = $host_st;


	return $st;
}

sub gen_obj
{
	my $obj = shift;
	my $def;

	#~ $def->{ desc } = "Apply an action about '$obj' objects";
	foreach my $action ( keys %{ $objects->{ $obj } } )
	{
		my @ids_def = &getIds( $objects->{ $obj }->{ $action }->{ uri } );
		$objects->{ $obj }->{ $action }->{ ids } = \@ids_def;
		$def->{ cmds }->{ $action } =
		  &add_ids( $obj, $action, $objects->{ $obj }->{ $action }->{ uri }, $id_tree );
	}

	return $def;
}

sub add_ids
{
	my $obj         = shift;
	my $action      = shift;
	my $url         = shift;
	my $id_tree     = shift;
	my $id_list_ref = shift // [];
	my @id_list     = @{ $id_list_ref };

	my $def;

	# replaceUrl
	if ( $url =~ /([^\<]+)\<([\w -]+)\>/ )
	{
		my $first_url = $1;    # obtiene hasta la primera key
		my $key       = $2;

		my @keys_list = split ( '/', $first_url );
		shift @keys_list;      # elimina el primer elemento, ya que empieza por /

		my @values;
		my $tree = $id_tree;
		foreach my $k ( @keys_list )
		{
			$tree = $tree->{ $k };
		}
		@values = keys %{ $tree };

		$def->{ desc } = "Getting '$id_list[-1]'\n";    # tmp description

		if ( !@values )
		{
			$def->{ proc } = sub {
				print ( "This object '$id_list[-1]' is not using the feature '$key'\n" );
			};
		}
		else
		{
			foreach my $id ( @values )
			{
				my $sub_url = $url;

				my @id_join = @id_list;
				push @id_join, $id;

				unless ( $sub_url =~ s/\<[\w -]+\>/$id/ )
				{
					die "The id '$key' could not be replaced";
				}

			   # add description. It is used when the command is executed and it is not complete
				my $id_msg  = "";
				my $ids_def = $objects->{ $obj }->{ $action }->{ ids };
				foreach my $i ( @{ $ids_def } )
				{
					$id_msg .= " '$i'";
				}
				$id_msg =~ s/^ //;
				$def->{ desc } = "$action $obj";
				$def->{ desc } .= ", expects the ID(s) $id_msg" if ( $id_msg ne '' );

				my @id_join =
				  $def->{ cmds }->{ $id } =
				  &add_ids( $obj, $action, $sub_url, $id_tree, \@id_join );
			}
		}
	}

	# apply
	else
	{
		$def = &gen_act( $obj, $action, \@id_list );
	}

	return $def;
}

sub gen_act
{
	my $obj     = shift;
	my $act     = shift;
	my $ids     = shift;
	my $ids_def = $objects->{ $obj }->{ $act }->{ ids };
	my $def;
	my $call;

	# add description
	my $id_msg  = "";
	my $ids_def = $objects->{ $obj }->{ $act }->{ ids };
	foreach my $i ( @{ $ids_def } )
	{
		$id_msg .= " '$i'";
	}
	$id_msg =~ s/^ //;
	$def->{ desc } = "$act $obj";
	$def->{ desc } .= ", expects the ID(s) $id_msg" if ( $id_msg ne '' );

	# check if the call is expecting a file name to upload or download
	if (    exists $objects->{ $obj }->{ $act }->{ 'download_file' }
		 or exists $objects->{ $obj }->{ $act }->{ 'upload_file' } )
	{
		$def->{ desc } .= " 'file'";
	}

	$def->{ proc } = sub {
		eval {
			my @args = ( $objects->{ $obj }->{ $act }, $obj, $act, @{ $ids }, @_ );
			my $input = &parseInput( @args );

			my $request = &checkInput( $objects, $input, $host, $id_tree );
			my $resp    = &zapi( $request, $host );
			&printOutput( $resp );
			$term->save_history();

			# reload structs
			&reload_cmd_struct();
		};
		say $@ if $@;

		#~ POSIX::_exit( $resp->{err} );
	};

	return $def;
}

sub reload_cmd_struct
{
	$main::id_tree = &getLBIdsTree( $host );
	if (!defined $main::id_tree)
	{
		say "Error getting the load balancer IDs";
	}
	$main::cmd_st = &gen_cmd_struct();

	$main::term->commands( $main::cmd_st ) if (defined $term);
}
