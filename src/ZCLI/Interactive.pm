#!/usr/bin/perl

use strict;
use Data::Dumper;
use feature "say";
use POSIX qw(_exit);
use Storable qw(dclone);

# https://metacpan.org/pod/Term::ShellUI
use Term::ShellUI;

use ZCLI::Define;
use ZCLI::Lib;
use ZCLI::Objects;

my %V   = %Define::Actions;
my $FIN = $Global::FIN;

my $zcli_dir     = $Global::config_dir;
my $zcli_history = $Global::history_path;

# overwriting methods

# It is overwritten to print using the error output
*Term::ShellUI::error = sub {
	&printError( "$_[1]" );
};

# skip reload when the input is a blank line
my $skip_reload = 0;
*Term::ShellUI::blank_line = sub {
	$skip_reload = 1;
};

### definition of functions

=begin nd
Function: create_zcli

	It creates a Term object that implements the ZCLI. 
	The object will be available from the variable '$Env::ZCLI'.

Parametes:
	none - .

Returns:
	Error code - It returns the error code of the last command execution, 0 on success or another value on failure

=cut

sub create_zcli
{
	# Execute and exit
	my @args = ();
	if ( $Env::SILENCE )
	{
		&dev( "execute and exit", undef, 1 );
		@args = @ARGV;
	}

	# code of ShellUI->run modified
	# $Env::ZCLI->run(@args); this function is not completed
	my $incmd = join " ", @args;

	$Env::ZCLI = new Term::ShellUI(
									commands     => $Env::ZCLI_CMD_ST,
									history_file => $zcli_history,
									keep_quotes  => 1,
									token_chars  => '',
	);

	&printSuccess( "Zevenet Client Line Interface" );
	$Env::ZCLI->load_history();
	$Env::ZCLI->getset( 'done', 0 );

	my $err = 0;
	while ( !$Env::ZCLI->{ done } )
	{
		if ( !$skip_reload )
		{
			&reload_cmd_struct();
			&reload_prompt( $err );
		}
		else
		{
			$skip_reload = 0;
		}

		$err = $Env::ZCLI->process_a_cmd( $incmd );
		$err = 1 if not defined $err;
		$Env::ZCLI->save_history();

		last if $Env::SILENCE;
		last if $incmd;          # only loop if we're prompting for commands
	}

	return $err;
}

=begin nd
Function: reload_prompt

	It reloads the prompt line of the ZCLI. The color will change between green (the last command was successful) or 
	red (the last command finishes with failure).

	The host name will be printed as gray if ZCLI has not connectivity with the load balancer.

Parametes:
	Error code - It is used to select the prompt color. It expects 0 on success or another value on failure.

Returns:
	none - .

=cut

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
	$Env::ZCLI->prompt( "$no_color$color$tag$no_color: " );
}

=begin nd
Function: reload_cmd_struct

	It reloads the struct used for ZCLI with the definition of the possible commands

Parametes:
	none - .

Returns:
	none - .

=cut

sub reload_cmd_struct
{
	$Env::CONNECTIVITY = &check_connectivity( $Env::HOST );
	if ( $Env::CONNECTIVITY )
	{
		$Env::HOST_IDS_TREE = &getLBIdsTree( $Env::HOST );
		if ( !defined $Env::HOST_IDS_TREE )
		{
			$Env::CONNECTIVITY = 0;
		}
	}
	$Env::ZCLI_CMD_ST = &gen_cmd_struct( $Env::HOST_IDS_TREE );

	$Env::ZCLI->commands( $Env::ZCLI_CMD_ST ) if ( defined $Env::ZCLI );
}

=begin nd
Function: gen_cmd_struct

	It creates a struct with a tree with the possible values and its expected arguments.
	There are two kind of commands:
		* Commands to the load balancer: they only are available when ZCLI has connectivity with the load balancer.
		* Commands to the ZCLI: they apply action over the ZCLI app. For example: help, history, zcli, hosts

Parametes:
	Ids tree - It is the struct with the tree of IDsS

Returns:
	Hash ref - It is a struct with the following format:
		{
			'$object' : {				# name of the object
				cmds: {					
					'$action' : {		# action to apply
						desc : "",		# description for the command
						proc : sub {}.	# Reference to the function that process the command. The last condition of the proc function has to returns 0 on success
						args : sub {}.	# Reference to the function that autocompletes them
						maxargs : \d	# Maximun number of arguments expected. This parameter does not appear always.
					}
				},
			},
		}


=cut

sub gen_cmd_struct
{
	my $ids_tree = shift;
	my $st;

	# features of the lb
	if ( $Env::CONNECTIVITY )
	{
		foreach my $cmd ( keys %{ $Objects::Zcli } )
		{
			$st->{ $cmd } = &gen_obj( $cmd, $ids_tree );
		}
	}

	# add static functions
	$st->{ 'help' }->{ desc }    = "Print the ZCLI help";
	$st->{ 'help' }->{ proc }    = sub { &printHelp(); };
	$st->{ 'help' }->{ maxargs } = 0;

	$st->{ 'history' }->{ desc } = "Print the list of commands executed";
	$st->{ 'history' }->{ method } =
	  sub { shift->history_call(); };
	$st->{ 'history' }->{ maxargs } = 0;

	$st->{ $V{ RELOAD } }->{ desc } =
	  "Force a ZCLI reload to refresh the ID objects";
	$st->{ $V{ RELOAD } }->{ proc } =
	  sub { ( 0 ) };
	$st->{ $V{ RELOAD } }->{ maxargs } = 0;
	$st->{ $V{ QUIT } }->{ dec }       = "Escape from the ZCLI";
	$st->{ $V{ QUIT } }->{ method } =
	  sub { shift->exit_requested( 1 ); };
	$st->{ $V{ QUIT } }->{ exclude_from_history } = 1;
	$st->{ $V{ QUIT } }->{ maxargs }              = 0;

	my $host_st;
	my @host_list = &listHost();
	$host_st->{ $V{ LIST } }->{ proc } =
	  sub { printSuccess( $_, 0 ) for ( &listHost ) };
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
				$err       = 0;
			}

			( $err );
		},
	};
	$host_st->{ $V{ DELETE } } = {
		proc => sub {
			if ( $Env::HOST->{ name } eq $_[0] )
			{
				&printError( "The '$Env::HOST->{NAME}' host is being used" );
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
			( defined $Env::HOST ) ? 0 : 1;
		},
		args    => [sub { \@host_list }],
		maxargs => 1,
	};
	$st->{ hosts }->{ desc } =
	  "apply an action about which is the destination load balancer";
	$st->{ hosts }->{ cmds } = $host_st;

	return $st;
}

=begin nd
Function: gen_obj

	It creates the command tree of an object. Modify the Object::Zcli adding it the required IDs.
	This function uses add_ids to implement the IDs autocompletation.

Parametes:
	object - Object name is being implemented
	Ids tree - It is the struct with the tree of IDsS

Returns:
	Hash string - It returns the command struct used for Term for all actions of an 'object'

=cut

sub gen_obj
{
	my $obj_name = shift;
	my $id_tree  = shift;

	# copy the Zcli object.
	# $Objects::Zcli will be used as template and it won't be modified
	# the object_struct will be expanded.
	my $object_struct = dclone( $Objects::Zcli );

	foreach my $action ( keys %{ $object_struct->{ $obj_name } } )
	{
		my $cmd;
		my $obj_def = $object_struct->{ $obj_name }->{ $action };
		my @ids_def = &getIds( $obj_def->{ uri } );

		# complete the definition
		$obj_def->{ ids }    = \@ids_def;
		$obj_def->{ object } = $obj_name;
		$obj_def->{ action } = $action;

		# create the Term struct
		$cmd->{ desc } = &desc_cb( $obj_def );
		$cmd->{ proc } = sub { &proc_cb( $obj_def, @_ ); };
		$cmd->{ args } = sub { &args_cb( @_, $obj_def, $id_tree ); };

		$object_struct->{ cmds }->{ $action } = $cmd;
	}

	return $object_struct;
}

=begin nd
Function: desc_cb

	It creates a message with the expected format for the command.

Parametes:
	object struct - It is a hash ref with the required argments for the command

Returns:
	String - It returns the message with the expected parameters

=cut

sub desc_cb
{
	my $def = shift;
	my $obj = $def->{ object };
	my $act = $def->{ action };

	return "$obj" if not defined $act;

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
	if (     $def->{ method } =~ /^(POST|PUT)$/
		 and not exists $def->{ params }
		 and $params )
	{
		$msg .= " $Define::Description_param";
	}

	return $msg;
}

sub getMissingParam
{
	my ( $desc, $input_args ) = @_;

	my $it = 0;
	foreach my $p ( split ( ' ', $desc ) )
	{
		return $p if !defined $input_args->[$it];
		$it++;
	}

	return undef;
}

=begin nd
Function: get_args_num

	It calculates the number of expected arguments for a command. 
	This function is only valid for GET methods

Parametes:
	object struct - It is a hash ref with the required argments for the command

Returns:
	Integer - number of expeted arguments

=cut

sub get_args_num
{
	my $def = shift;

	my $num =
	  ( exists $def->{ upload_file } or exists $def->{ download_file } ) ? 1 : 0;
	$num += 2;                                 # the object and the action
	$num += scalar &getIds( $def->{ uri } );
	$num += scalar @{ $def->{ uri_param } } if ( exists $def->{ uri_param } );

	return $num;
}

=begin nd
Function: proc_cb

	It executes the ZAPI request. First, parsing the arguments from the command line, next execute the request and then print the output.

Parametes:
	object struct - It is a hash ref with the required argments for the command

Returns:
	none - .

=cut

sub proc_cb
{
	my $obj_def = shift;

	my $resp;
	my $err;
	my @input_args = ( $obj_def->{ object }, $obj_def->{ action }, @_ );
	eval {
		$Env::CMD_STRING = "";    # clean string

		my ( $input_parsed, $next_arg, $success ) =
		  &parseInput( $obj_def, 0, @input_args );

		# if there isn't a path to download the file, it is used the same name
		if ( !$success and ( $next_arg eq 'download_file' ) )
		{
			$input_parsed->{ download_file } = $input_args[-1];
			$success = 1;
		}

		unless ( $success )
		{
			my $desc      = &desc_cb( $obj_def );
			my $missing_p = &getMissingParam( $desc, \@input_args );

			#		if (!defined $missing_p )
			{
				&printError( "Some parameters are missing. The expected syntax is:" );
			}

#		else
#		{
#			&printError ("Some parameters are missing, it failed getting '$missing_p'. The expected syntax is:" );
#		}

			# force reload if params does not exist
			&listParams( $obj_def, $input_parsed, $Env::HOST )
			  if ( !defined $Env::CMD_PARAMS_DEF );

			if ( defined $Env::CMD_PARAMS_DEF )
			{
				my $params = "";
				foreach my $p ( keys %{ $Env::CMD_PARAMS_DEF } )
				{
					if ( exists $Env::CMD_PARAMS_DEF->{ $p }->{ required } )
					{
						$params = "<-$p $p> $params";
					}
					else
					{
						$params .= "[-$p $p] ";
					}
				}
				my $pattern = quotemeta ( $Define::Description_param );
				$desc =~ s/$pattern/$params/;
			}
			&printError( "	[zcli] $desc" );
			die $FIN;
		}

		# do not allow sending extra arguments using GET methods
		if ( $obj_def->{ method } eq 'GET'
			 and ( scalar ( @input_args ) > &get_args_num( $obj_def ) ) )
		{
			my $desc = &desc_cb( $obj_def );
			&printError(
						 " There are extra arguments in the command, the expected syntax is:" );
			&printError( "	[zcli] $desc" );
			die $FIN;
		}

		my $request =
		  &createZapiRequest( $obj_def, $input_parsed, $Env::HOST,
							  $Env::HOST_IDS_TREE );

		$resp = &zapi( $request, $Env::HOST );
		$err  = $resp->{ err };

		&printOutput( $resp );

	};
	&printError( $@ ) if $@;
	$err = ( $@ or $err ) ? 1 : 0;

	( $err );
}

# [ids list] [ids_params list] [file_upload|download] [body_params list]
sub args_cb
{
	my ( undef, $input, $obj_def, $id_tree ) = @_;
	my $possible_values = [];

	# 'args' is the list of arguments used
	# 'argno' is the number of arguments used

	# list of used arguments
	my @args_used = @{ $input->{ args } };

	# get the previous completed parameter that was used
	my $arg_previus = $args_used[$input->{ argno } - 1];

	my ( $args_parsed, $next_arg ) =
	  &parseInput( $obj_def, 1,
				   $obj_def->{ object },
				   $obj_def->{ action }, @args_used );

	$Env::ZCLI->completemsg( "  ## getting '$next_arg'\n" ) if ( $Global::DEBUG );

	if ( $next_arg eq 'id' )
	{
		$possible_values = &get_next_id( $obj_def, $id_tree, $args_parsed->{ id } );
	}
	elsif ( $next_arg eq 'uri_params' )
	{
		my $uri_index = scalar @{ $args_parsed->{ uri_param } };
		$possible_values = "<$obj_def->{uri_param}->[$uri_index]->{name}>";
	}
	elsif ( $next_arg =~ /file/ )
	{
		$possible_values = shift->complete_files( $input );
	}

	elsif ( $next_arg eq 'body_params' )
	{
		$possible_values =
		  &complete_body_params( $obj_def, $args_parsed, \@args_used, $arg_previus );
	}

	# fin
	else
	{
		$possible_values = [];
	}

	return $possible_values;
}

sub complete_body_params
{
	my ( $obj_def, $args_parsed, $args_used, $arg_previus ) = @_;
	my $out;

	# command that is being executing
	my $cmd_string = "$obj_def->{object} $obj_def->{action}";

	# get the previous completed parameter that was used
	my $previus_param = $arg_previus;
	$previus_param =~ s/^-//;

	# get list or refreshing the parameters list
	if ( $Env::CMD_STRING eq '' or $Env::CMD_STRING ne $cmd_string )
	{
		$Env::ZCLI->completemsg( "  ## Refreshing params\n" ) if ( $Global::DEBUG );
		&listParams( $obj_def, $args_parsed, $Env::HOST );

		# refresh values
		$Env::CMD_STRING = $cmd_string;
	}
	my $p_obj = $Env::CMD_PARAMS_DEF;

	$Env::ZCLI->completemsg( "  ## prev: $p_obj->{ $previus_param }\n" )
	  if ( $Global::DEBUG );

	# manage the 'value' of the parameter
	if ( exists $p_obj->{ $previus_param } )
	{
		$Env::ZCLI->completemsg( "  ## getting value\n" ) if ( $Global::DEBUG );
		my $p_def = $p_obj->{ $previus_param };

		# list the possible values
		if ( exists $p_def->{ possible_values } )
		{
			$out = $p_def->{ possible_values };
		}
		else
		{
			$out = "<$previus_param>";
		}
	}

	# manage the 'key' of the parameter
	else
	{
		$Env::ZCLI->completemsg( "  ## getting key\n" ) if ( $Global::DEBUG );

		# remove the parameters already exists
		my @params = ();
		foreach my $p ( keys %{ $p_obj } )
		{
			# not show the parameters that are predefined
			next if ( exists $obj_def->{ params }->{ $p } );

			push @params, "-$p" if ( !grep ( /^-$p$/, @{ $args_used } ) );
		}

		# all parameters has been used
		if ( !@params )
		{
			@params = ();
			$Env::ZCLI->completemsg(
									 "  ## This command does not expect more parameters\n" );

			#if ( $Global::DEBUG );
		}

		$out = \@params;
	}

	return $out;
}

sub get_next_id
{
	my $obj_def = shift;
	my $id_tree = shift;
	my $args    = shift;    # input arguments

	my @possible_values = ();
	my $url             = $obj_def->{ uri };    # copy data from def

	# replace the obtained ids untill getting the next arg key
	$url = &replaceUrl( $url, $args );

	# getting next args
	if ( $url =~ /([^\<]+)\<([\w -]+)\>/ )
	{
		my $sub_url = $1;    # Getting the url keys to be used in the IDs tree
		my $key     = $2;

		my @keys_list = split ( '/', $sub_url );
		shift
		  @keys_list; # Remove the first item, because url begins with the character '/'

		my $nav_tree = $id_tree;
		foreach my $k ( @keys_list )
		{
			$nav_tree = $nav_tree->{ $k };
		}

		my @values = keys %{ $nav_tree };
		if ( !@values )
		{
			# my $msg = "This object is not using the feature '$key'\n";
			# $Env::ZCLI->completemsg( "  ## $msg\n" ) if ( $Global::DEBUG );
			$Env::ZCLI->completemsg( "  ## There is no any '$key'\n" );
		}

		return \@values;
	}

	return [];
}

1;
