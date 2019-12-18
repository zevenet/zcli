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

my %V   = %Define::Actions;
my $FIN = $Define::FIN;

my $zcli_dir     = $Global::config_dir;
my $zcli_history = $Global::history_path;

### definition of functions

sub create_zcli
{
	&reload_cmd_struct();

	$Env::ZCLI = new Term::ShellUI( commands     => $Env::ZCLI_CMD_ST,
									history_file => $zcli_history, );
	print "Zevenet Client Line Interface\n";
	&reload_prompt();
	$Env::ZCLI->load_history();

	# $Env::ZCLI->add_eof_exit_hook($self->save_history()); # ????
	$Env::ZCLI->run();
}

sub reload_prompt
{
	my $err  = shift // 0;
	my $conn = $Env::CONNECTIVITY;
	my $host = $Env::HOST->{ NAME } // "";

	my $gray     = "\033[01;90m";
	my $red      = "\033[01;31m";
	my $green    = "\033[01;32m";
	my $no_color = "\033[0m";

	my $color      = ( $err )   ? $red  : $green;
	my $conn_color = ( !$conn ) ? $gray : "";

	my $tag = "zcli($conn_color$host$color)";
	$Env::ZCLI->prompt( "$color$tag$no_color: " );
}

sub gen_cmd_struct
{
	my $st;

	# features of the lb
	if ( $Env::CONNECTIVITY )
	{
		foreach my $cmd ( keys %{ $Objects::Zcli } )
		{
			$st->{ $cmd } = &gen_obj( $cmd );
		}
	}

	# add static functions
	$st->{ 'help' }->{ cmds }->{ $V{ LIST } }->{ desc } = "Print the ZCLI help";
	$st->{ 'help' }->{ cmds }->{ $V{ LIST } }->{ proc } =
	  sub { &printHelp(); &reload_prompt( 0 ); };
	$st->{ 'help' }->{ cmds }->{ $V{ LIST } }->{ maxargs } = 0;

	$st->{ 'history' }->{ cmds }->{ $V{ LIST } }->{ desc } =
	  "Print the list of commands executed";
	$st->{ 'history' }->{ cmds }->{ $V{ LIST } }->{ method } =
	  sub { shift->history_call(); };
	$st->{ 'history' }->{ cmds }->{ $V{ LIST } }->{ maxargs } = 0;

	$st->{ 'zcli' }->{ cmds }->{ $V{ RELOAD } }->{ desc } =
	  "Force a ZCLI reload to refresh the ID objects";
	$st->{ 'zcli' }->{ cmds }->{ $V{ RELOAD } }->{ proc } =
	  sub { &reload_cmd_struct(); };
	$st->{ 'zcli' }->{ cmds }->{ $V{ RELOAD } }->{ maxargs } = 0;
	$st->{ 'zcli' }->{ cmds }->{ $V{ QUIT } }->{ dec } = "Escape from the ZCLI";
	$st->{ 'zcli' }->{ cmds }->{ $V{ QUIT } }->{ method } =
	  sub { shift->exit_requested( 1 ); };
	$st->{ 'zcli' }->{ cmds }->{ $V{ QUIT } }->{ exclude_from_history } = 1;
	$st->{ 'zcli' }->{ cmds }->{ $V{ QUIT } }->{ maxargs }              = 0;

	my $host_st;
	my @host_list = &listHost();
	$host_st->{ $V{ LIST } }->{ proc }      = sub { say $_ for ( &listHost ) };
	$host_st->{ $V{ LIST } }->{ maxargs }   = 1;
	$host_st->{ $V{ CREATE } }->{ proc }    = \&setHost;
	$host_st->{ $V{ CREATE } }->{ maxargs } = 1;
	$host_st->{ $V{ SET } } = {
		args    => [sub { \@host_list }],
		maxargs => 1,
		proc    => sub {
			my $new_host = &setHost( $_[0], 0 );
			my $err = ( defined $new_host ) ? 0 : 1;
			if ( !$err )
			{
				# reload the host configuration
				$Env::HOST = $new_host if ( $Env::HOST->{ NAME } eq $new_host->{ NAME } );
			}
			$Env::CONNECTIVITY = &check_connectivity( $Env::HOST );
			&reload_prompt( $err );
		},
	};
	$host_st->{ $V{ DELETE } } = {
		proc => sub {
			if ( $Env::HOST->{ name } eq @_[0] )
			{
				say "The '$Env::HOST->{NAME}' host is being used";
			}
			else
			{
				&delHost( @_ );
			}
		},
		args    => [sub { \@host_list }],
		maxargs => 1,
	};
	$host_st->{ $V{ APPLY } } = {
		proc => sub {
			$Env::HOST = hostInfo( @_ );
			my $err = ( defined $Env::HOST ) ? 0 : 1;
			&reload_prompt( $err );
			&reload_cmd_struct();
		},
		args    => [sub { \@host_list }],
		maxargs => 1,
	};
	$st->{ hosts }->{ desc } =
	  "apply an action about which is the destination load balancer";
	$st->{ hosts }->{ cmds } = $host_st;

	return $st;
}

sub gen_obj
{
	my $obj = shift;
	my $def;

	foreach my $action ( keys %{ $Objects::Zcli->{ $obj } } )
	{
		my @ids_def = &getIds( $Objects::Zcli->{ $obj }->{ $action }->{ uri } );
		$Objects::Zcli->{ $obj }->{ $action }->{ ids } = \@ids_def;
		$def->{ cmds }->{ $action } =
		  &add_ids( $obj, $action, $Objects::Zcli->{ $obj }->{ $action }->{ uri },
					$Env::HOST_IDS_TREE );
	}

	return $def;
}

# recursive
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

		$def->{ desc } = &create_description( $Objects::Zcli, $obj, $action );

		if ( !@values )
		{
			my $msg = "This object '$id_list[-1]' is not using the feature '$key'\n";
			$def->{ proc } = sub {
				print ( "$msg" );
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
					print "The id '$key' could not be replaced";
					my $FIN = $Define::FIN;
				}

				my @id_join = $def->{ cmds }->{ $id } =
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
	my $ids_def = $Objects::Zcli->{ $obj }->{ $act }->{ ids };
	my $def;
	my $call;

	# add description
	$def->{ desc } = $def->{ desc } =
	  &create_description( $Objects::Zcli, $obj, $act );

	my @in_args = ();
	if ( exists $Objects::Zcli->{ $obj }->{ $act }->{ 'uri_param' } )
	{
		foreach my $p ( @{ $Objects::Zcli->{ $obj }->{ $act }->{ 'uri_param' } } )
		{
			push @in_args, "<$p->{name}>";
		}
		$def->{ args }    = \@in_args;
		$def->{ maxargs } = scalar @in_args;
	}

	# check if the call is expecting a file name to upload or download
	if (    exists $Objects::Zcli->{ $obj }->{ $act }->{ 'download_file' }
		 or exists $Objects::Zcli->{ $obj }->{ $act }->{ 'upload_file' } )
	{
		push @in_args, sub { shift->complete_files( @_ ); };
		$def->{ args }    = \@in_args;
		$def->{ maxargs } = scalar @in_args;
	}

	elsif ( $Objects::Zcli->{ $obj }->{ $act }->{ method } =~ /POST|PUT/ )
	{
		# comprobar si objeto ya tiene cargado los posibles parametros.
		#  ???? pueden faltar parametros de uri
		$def->{ args } = sub {
			&complete_body_params( @_, $Objects::Zcli->{ $obj }->{ $act },
								   $obj, $act, $ids );
		};
	}

	$def->{ proc } = sub {
		my $resp;
		eval {

			$Env::CMD_STRING = "";    # clean string

			my @args = ( $Objects::Zcli->{ $obj }->{ $act }, $obj, $act, @{ $ids }, @_ );

			say "args";
			print Dumper \@args;

			my $input = &parseInput( @args );

			say "parsed";
			print Dumper $input;

			my $request =
			  &checkInput( $Objects::Zcli, $input, $Env::HOST, $Env::HOST_IDS_TREE );

			say "request";
			print Dumper $request;

			$resp = &zapi( $request, $Env::HOST );
			&printOutput( $resp );
			$Env::ZCLI->save_history();

			# reload structs
			&reload_cmd_struct();
		};
		say $@ if $@;
		my $err = ( $@ or $resp->{ err } ) ? 1 : 0;
		&reload_prompt( $err );

		# ???? $self->exit_requested($opt->{silence});
		#~ POSIX::_exit( $resp->{err} );
	};

	return $def;
}

sub complete_body_params
{
	my ( undef, $input, $obj_def, $obj, $act, $ids ) = @_;

	my $clean_tag = "''";
	my $out;

	# Get the last parameter struct
	my $p_obj = $Env::CMD_PARAMS_DEF;

	# command that is being executing
	my $cmd_string = "$obj $act";

	# list of used arguments
	my @params_used = @{ $input->{ args } };

	# get the previous completed parameter that was used
	my $previus_param = $params_used[$input->{ argno } - 1];
	$previus_param =~ s/^-//;

	# get list or refreshing the parameters list
	if ( $Env::CMD_STRING eq '' or $Env::CMD_STRING ne $cmd_string )
	{
		$Env::ZCLI->completemsg( "  ## Refreshing params\n" ) if ( $Global::DEBUG );
		$p_obj = &listParams( $obj_def, $obj, $act, $ids, $Env::HOST );

		# refresh values
		$Env::CMD_STRING     = $cmd_string;
		$Env::CMD_PARAMS_DEF = $p_obj;
	}

	# manage the 'value' of the parameter
	if ( exists $p_obj->{ $previus_param } )
	{
		my $p_def = $p_obj->{ $previus_param };

		# list the possible values
		if ( exists $p_def->{ possible_values } )
		{
			$out = $p_def->{ possible_values };
			push @{ $out }, "<$clean_tag>" if ( exists $p_def->{ blank } );
		}
		else
		{
			$out =
			  ( exists $p_def->{ blank } )
			  ? "<$previus_param|$clean_tag>"
			  : "<$previus_param>";
		}
	}

	# manage the 'key' of the parameter
	else
	{
		# remove the parameters already exists
		my @params = ();
		foreach my $p ( keys %{ $p_obj } )
		{
			# not show the parameters that are predefined
			next if ( exists $Objects::Zcli->{ $obj }->{ $act }->{ params }->{ $p } );

			push @params, "-$p" if ( !grep ( /^-$p$/, @params_used ) );
		}

		# all parameters has been used
		if ( !@params )
		{
			@params = ();
			$Env::ZCLI->completemsg( "  ## This command does not expect more parameters\n" )
			  if ( $Global::DEBUG );
		}

		$out = \@params;
	}

	return $out;
}

sub reload_cmd_struct
{
	$Env::CONNECTIVITY = &check_connectivity( $Env::HOST );
	if ( $Env::CONNECTIVITY )
	{
		$Env::HOST_IDS_TREE = &getLBIdsTree( $Env::HOST );
	}
	$Env::ZCLI_CMD_ST = &gen_cmd_struct();

	$Env::ZCLI->commands( $Env::ZCLI_CMD_ST ) if ( defined $Env::ZCLI );
}

sub create_description
{
	my $object_st = shift;
	my $obj       = shift;
	my $act       = shift;

	return "$obj" if not defined $act;

	my $def = $object_st->{ $obj }->{ $act };

	# action object @ids @uri_param @file @params
	my $msg    = "$obj $act";
	my $params = 1;

	my @ids = &getIds( $def->{ uri } );
	if ( @ids )
	{
		$msg .= " <$_>" for @ids;
	}
	if ( exists $def->{ uri_param } )
	{
		$msg .= " <$_->{name}>" for @{ $def->{ uri_param } };
	}
	if ( exists $def->{ upload_file } )
	{
		$msg .= " <file_path>";
		$params = 0;
	}
	if ( exists $def->{ download_file } )
	{
		$msg .= " <file_path>";
		$params = 0;
	}
	if (     $def->{ method } =~ /^POST|PUT$/
		 and not exists $def->{ params }
		 and $params )
	{
		$msg .= " [-param_name param_value ...]";
	}

	return $msg;
}

1;
