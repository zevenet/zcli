#!/usr/bin/perl

use strict;
use Data::Dumper;
use feature "say";
use POSIX qw(_exit);

require "./Define.pm";
require "./lib.pm";
require "./Objects.pm";

my $zcli_history = '.zcli-history';

&printHelp() if ( $ARGV[0] eq '-h' );

my $options = &parseOptions( @ARGV );

my $host = &hostInfo() or do
{
	say "Not found the host info, try to configure the default host profile";
	&setHost();
	&hostInfo();
};

my $objects = $Objects::zcli_objects;

our $id_tree = &getLBIdsTree( $host );
&dev( Dumper( $id_tree ), "treee", 3 );

our $cmd_st = &gen_cmd_struct();

&dev( Dumper( $cmd_st ), "dump", 3 );

# https://metacpan.org/pod/Term::ShellUI
use Term::ShellUI;
my $term = new Term::ShellUI( commands     => $cmd_st,
							  history_file => $zcli_history, );
print "Zevenet Client Line Interface\n";
$term->prompt( "zcli($host->{name}):" );
$term->load_history();
$term->run();




sub gen_cmd_struct
{
	my $st;

	foreach my $cmd ( keys %{ $objects } )
	{
		$st->{ $cmd } = &gen_obj( $cmd );
	}

	$st->{ help }->{ proc } = \&printHelp;

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

	$def->{ proc } = sub {
		eval {
			my @args = ( $obj, $act, @{ $ids }, @_ );

			$term->save_history();

			my $input = &parseInput( @args );

			my $request = &checkInput( $objects, $input, $host, $id_tree );
			my $resp    = &zapi( $request, $host );
			&printOutput( $resp );

			# reload structs
			#~ $main::id_tree = &getLBIdsTree( $host );
			$main::cmd_st  = &gen_cmd_struct();
			$term->commands( $main::cmd_st );
		};
		say $@ if $@;

		#~ POSIX::_exit( $resp->{err} );
	};

	return $def;
}

