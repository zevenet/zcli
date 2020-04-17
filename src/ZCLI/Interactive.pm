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
use Storable qw(dclone);

# https://metacpan.org/pod/Term::ShellUI
use Term::ShellUI;

use lib '..';
use ZCLI::Define;
use ZCLI::Lib;
use ZCLI::Objects;

my %V = %Define::Actions;

my $zcli_dir = $Global::Config_dir;

my $skip_reload = 0;

# overwriting methods
{
	no warnings 'redefine';

	# It is overwritten to print using the error output
	*Term::ShellUI::error = sub {
		&printError( "$_[1]" );
	};

	# skip reload when the input is a blank line
	*Term::ShellUI::blank_line = sub {
		$skip_reload = 1;
		undef;    # the command used is the last execution of this function
	};
}

### definition of functions

=begin nd
Function: createZcli

	It creates a Term object that implements the ZCLI.
	The object will be available from the variable '$Env::ZCLI'.

Parametes:
	none - .

Returns:
	Error code - It returns the error code of the last command execution, 0 on success or another value on failure

=cut

sub createZcli
{
	# Execute and exit
	my @args = ();
	if ( $Env::Silence )
	{
		&devMsg( "execute and exit", undef, 1 );
		@args = @ARGV;
	}

	# code of ShellUI->run modified
	# $Env::Zcli->run(@args); this function is not completed
	my $incmd = join " ", @args;

	$Env::Zcli = new Term::ShellUI(
									commands     => $Env::Zcli_cmd_st,
									history_file => $Global::History_path,
									keep_quotes  => 1,
									token_chars  => '',
	);

	my $logo = "
  ___________ _      _____
 |___  / ____| |    |_   _|
    / / |    | |      | |
   / /| |    | |      | |
  / /_| |____| |____ _| |_
 /_____\\_____|______|_____|
";

	$logo = "${Color::Logo}$logo${Color::Clean}" if ( $Env::Color );

	my $welcome = "$logo

Welcome to the Zevenet Command Line Interface.

The extendend information can be displayed using the 'help' command.";

	&printSuccess( $welcome );

	$Env::Zcli->load_history();
	$Env::Zcli->getset( 'done', 0 );

	my $err = 0;
	while ( !$Env::Zcli->{ done } )
	{
		if ( !$skip_reload )
		{
			&reloadCmdStruct();
			&reloadPrompt( $err );
		}
		else
		{
			$skip_reload = 0;
		}

		$err = $Env::Zcli->process_a_cmd( $incmd );
		$err = 1 if not defined $err;
		$Env::Zcli->save_history();

		last if $Env::Silence;
		last if $incmd;          # only loop if we're prompting for commands
	}

	return $err;
}

=begin nd
Function: reloadPrompt

	It reloads the prompt line of the ZCLI. The color will change between green (the last command was successful) or
	red (the last command finishes with failure).

	The profile name will be printed as gray if ZCLI has not connectivity with the load balancer.

Parametes:
	Error code - It is used to select the prompt color. It expects 0 on success or another value on failure.

Returns:
	none - .

=cut

sub reloadPrompt
{
	my $err     = shift                   // 0;
	my $profile = $Env::Profile->{ name } // "";

	if ( !$Env::Color )
	{
		my $err_tag = ( $err ) ? 'x' : 'o';
		$Env::Zcli->prompt( "[$err_tag] zcli($profile): " );
	}
	else
	{
		my $conn = $Env::Connectivity;

		my $color      = ( $err )   ? $Color::Error      : $Color::Success;
		my $conn_color = ( !$conn ) ? $Color::Disconnect : "";
		$color      = $Color::Init . $color . $Color::End;
		$conn_color = $Color::Init . $conn_color . $Color::End;

		my $tag = "zcli($conn_color$profile$color)";
		$Env::Zcli->prompt( "${Color::Reset}$color$tag${Color::Reset}: " );
	}
}

=begin nd
Function: reloadCmdStruct

	It reloads the struct used for ZCLI with the definition of the possible commands

Parametes:
	none - .

Returns:
	none - .

=cut

sub reloadCmdStruct
{
	$Env::Connectivity = &checkConnectivity( $Env::Profile );
	if ( $Env::Connectivity )
	{
		$Env::Profile_ids_tree = &getLBIdsTree( $Env::Profile );
		if ( !defined $Env::Profile_ids_tree )
		{
			$Env::Connectivity = 0;
		}
	}
	$Env::Zcli_cmd_st = &createZcliCmd( $Env::Profile_ids_tree );

	$Env::Zcli->commands( $Env::Zcli_cmd_st ) if ( defined $Env::Zcli );
}

=begin nd
Function: createZcliCmd

	It creates a struct with a tree with the possible values and its expected arguments.
	There are two kind of commands:
		* Commands to the load balancer: they only are available when ZCLI has connectivity with the load balancer.
		* Commands to the ZCLI: they apply action over the ZCLI app. For example: help, history, zcli, profile

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

sub createZcliCmd
{
	my $ids_tree = shift;
	my $st;

	# features of the lb
	if ( $Env::Connectivity )
	{
		foreach my $cmd ( keys %{ $Objects::Zcli } )
		{
			my $obj = &createCmdObject( $cmd, $ids_tree );
			if ( defined $obj )
			{
				$st->{ $cmd } = $obj;
			}
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

	$st->{ profile } = &createCmdObjectProfile();

	return $st;
}

=begin nd
Function: createCmdObjectProfile

	It creates a struct with profile command object

Parametes:
	none - .

Returns:
	Hash ref - object to expand the profile command

=cut

sub createCmdObjectProfile
{
	my $profile_st;
	my @profile_list = &listProfiles();
	$profile_st->{ $V{ LIST } }->{ proc } = sub {
		for ( &listProfiles )
		{
			my $st   = $_;
			my $desc = &getProfile( $_ )->{ description };
			$st .= "  -  $desc";
			printSuccess( $st, 0 );
		}

	};
	$profile_st->{ $V{ LIST } }->{ maxargs } = 1;
	$profile_st->{ $V{ LIST } }->{ desc }    = "It lists the ZCLI saved profiles";

	$profile_st->{ $V{ CREATE } }->{ proc } = sub {
		my $out = &setProfile;
		( !defined $out );
	};
	$profile_st->{ $V{ CREATE } }->{ maxargs } = 1;
	$profile_st->{ $V{ CREATE } }->{ desc } =
	  "It executes the profile creation assistant";

	$profile_st->{ $V{ SET } } = {
		args    => [sub { \@profile_list }],
		maxargs => 1,
		proc    => sub {
			my $new_profile = &setProfile( $_[0], 0 );
			my $err         = ( defined $new_profile ) ? 0 : 1;
			if ( !$err )
			{
				# reload the profile configuration
				$Env::Profile = $new_profile
				  if ( $Env::Profile->{ name } eq $new_profile->{ name } );
				$err = 0;
			}

			( $err );
		},
		desc =>
		  "It modifies the parameters of a profile to connect with the load balancer",
	};

	$profile_st->{ $V{ DELETE } } = {
		proc => sub {
			if ( $Env::Profile->{ name } eq $_[0] )
			{
				&printError( "The '$Env::Profile->{name}' profile is being used" );
			}
			else
			{
				&delProfile( @_ );
			}
		},
		args    => [sub { \@profile_list }],
		maxargs => 1,
		desc    => "It removes a load balancer profile from ZCLI",
	};

	$profile_st->{ $V{ APPLY } } = {
		proc => sub {
			my $prof = $_[0];
			if ( grep ( /^$prof$/, @profile_list ) )
			{
				$Env::Profile = &getProfile( @_ );
				( defined $Env::Profile ) ? 0 : 1;
			}
			else
			{
				&printError( "The '$prof' profile was not found" );
			}
		},
		args    => [sub { \@profile_list }],
		maxargs => 1,
		desc    => "It changes the current profile",
	};

	my $cmd = {};
	$cmd->{ desc } =
	  "It applies an action about which is the destination load balancer";
	$cmd->{ cmds } = $profile_st;

	return $cmd;
}

=begin nd
Function: createCmdObject

	It creates the command tree of an object. Modify the Object::Zcli adding it the required IDs.
	This function uses add_ids to implement the IDs autocompletation.

Parametes:
	object - Object name is being implemented
	Ids tree - It is the struct with the tree of IDsS

Returns:
	Hash string - It returns the command struct used for Term for all actions of an 'object'

=cut

sub createCmdObject
{
	my $obj_name = shift;
	my $id_tree  = shift;

	# copy the Zcli object.
	# $Objects::Zcli swill be used as template and it won't be modified
	# the object_struct will be expanded.
	my $object_struct;
	foreach my $action ( keys %{ $Objects::Zcli->{ $obj_name } } )
	{
		my $cmd;
		my $obj_def = dclone( $Objects::Zcli->{ $obj_name }->{ $action } );

		# skip EE features when the load balancer is of type CE
		next
		  if ( $Env::Profile->{ edition } eq 'CE' and exists $obj_def->{ enterprise } );

		my @ids_def = &getIds( $obj_def->{ uri } );

		# complete the definition
		$obj_def->{ ids }    = \@ids_def;
		$obj_def->{ object } = $obj_name;
		$obj_def->{ action } = $action;

		# create the Term struct
		$cmd->{ desc } = &getCmdDescription( $obj_def );
		$cmd->{ proc } = sub { &geCmdProccessCallback( $obj_def, @_ ); };
		$cmd->{ args } = sub { &getCmdArgsCallBack( @_, $obj_def, $id_tree ); };

		$object_struct->{ cmds }->{ $action } = $cmd;
	}

	return $object_struct;
}

=begin nd
Function: getCmdDescription

	It creates a message with the expected format for the command.

Parametes:
	object struct - It is a hash ref with the required argments for the command

Returns:
	String - It returns the message with the expected parameters

=cut

sub getCmdDescription
{
	my $def = shift;
	my $obj = $def->{ object };
	my $act = $def->{ action };

	return "$obj" if not defined $act;

	# action object @ids @param_uri @file @params
	my $msg    = "$obj $act";
	my $params = 1;

	my @ids = &getIds( $def->{ uri } );
	if ( @ids )
	{
		$msg .= " <$_>" for @ids;
	}
	if ( exists $def->{ param_uri } )
	{
		$msg .= " <$_->{name}>" for @{ $def->{ param_uri } };
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
	if ( exists $def->{ params } and !exists $def->{ params_opt } )
	{
		$params = 0;
	}
	if ( $def->{ method } =~ /^(POST|PUT)$/ and $params )
	{
		$msg .= " $Define::Description_param";
	}

	return $msg;
}

=begin nd
Function: getMissingArgument

	It returns the first mandatory argument that is missing in the command

Parametes:
	Description - It is the command description. It is a string with the command syntaxsis.
	Input argmument - It is the list of arguments used in the command.

Returns:
	String - It returns the argument name that is missing with the same name that it appears in the description. It returns undef if the argument name cannot be found.

=cut

sub getMissingArgument
{
	my ( $desc, $input_args ) = @_;

	my $it = 0;
	foreach my $p ( split ( ' ', $desc ) )
	{
		if ( !defined $input_args->[$it] )
		{
			return undef if ( $p eq '[params' );
			return $p;
		}
		$it++;
	}

	return undef;
}

=begin nd
Function: getCmdArgsNum

	It calculates the number of expected arguments for a command.
	This function is only valid for GET and DELETE methods

Parametes:
	object struct - It is a hash ref with the required argments for the command

Returns:
	Integer - number of expeted arguments

=cut

sub getCmdArgsNum
{
	my $def = shift;

	my $num =
	  ( exists $def->{ upload_file } or exists $def->{ download_file } ) ? 1 : 0;
	$num += 2;                                 # the object and the action
	$num += scalar &getIds( $def->{ uri } );
	$num += scalar @{ $def->{ param_uri } } if ( exists $def->{ param_uri } );

	# a filter was added
	$num += 2 if ( @Env::OutputFilter );

	return $num;
}

=begin nd
Function: geCmdProccessCallback

	It executes the ZAPI request. First, parsing the arguments from the command line, next execute the request and then print the output.

Parametes:
	object struct - It is a hash ref with the required argments for the command

Returns:
	none - .

=cut

sub geCmdProccessCallback
{
	my $obj_def = shift;

	my $resp;
	my $err        = 0;
	my @input_args = ( $obj_def->{ object }, $obj_def->{ action }, @_ );
	eval {
		$Env::Cmd_string = "";    # clean string

		my ( $input_parsed, $next_arg, $success ) =
		  &parseInput( $obj_def, 0, @input_args );

		# if there isn't a path to download the file, it is used the same name
		if ( !$success and ( $next_arg eq 'download_file' ) )
		{
			$input_parsed->{ download_file } =
			  &getDefaultDownloadFile( $obj_def, $input_args[-1] );
			$success = 1;
		}

		unless ( $success )
		{
			&devMsg( "The parameter list is not complete" );

			if ( $next_arg eq 'output_filter' )
			{
				&printError(
					"The output filter is empty. It expects a parameter list to filter, i.e. 'name,status'."
				);
				die $Global::Fin;
			}

			&refreshParameters( $obj_def, $input_parsed, $Env::Profile );

			my $desc      = &getCmdDescription( $obj_def );
			my $missing_p = &getMissingArgument( $desc, \@input_args );

			if ( !defined $missing_p )
			{
				&printError( "Some parameters are missing. The expected syntax is:" );
			}
			else
			{
				&printError(
					"Some parameters are missing, it failed getting $missing_p. The expected syntax is:"
				);
			}

			if ( defined $Env::Cmd_params_def )
			{
				my $params = "";
				foreach my $p ( keys %{ $Env::Cmd_params_def } )
				{
					if ( exists $Env::Cmd_params_def->{ $p }->{ required } )
					{
						$params = "<-$p value> $params";
					}
					else
					{
						$params .= "[-$p value] ";
					}
				}
				my $pattern = quotemeta ( $Define::Description_param );
				$desc =~ s/$pattern/$params/;
			}
			&printError( "	[zcli] $desc" );
			die $Global::Fin;
		}

		# do not allow sending extra arguments using GET or DELETE methods
		if ( $obj_def->{ method } =~ /^(?:GET|DELETE)$/
			 and ( scalar ( @input_args ) > &getCmdArgsNum( $obj_def ) ) )
		{
			my $desc = &getCmdDescription( $obj_def );
			&printError(
						 " There are extra arguments in the command, the expected syntax is:" );
			&printError( "	[zcli] $desc" );
			die $Global::Fin;
		}

		my $request =
		  &createZapiRequest( $obj_def, $input_parsed, $Env::Profile,
							  $Env::Profile_ids_tree );

		&devMsg( "Do zapi request..." );
		$resp = &zapi( $request, $Env::Profile );
		$err  = $resp->{ err };

		&printOutput( $resp );

	};
	&printError( $@ ) if $@;

	#~ $err = ( $@ or $err ) ? 1 : 0 if ($Env::Silence);
	$err = ( $@ or $err ) ? 1 : 0;

	( $err );
}

=begin nd
Function: getCmdArgsCallBack

	It manages how to autocomplete the current input argument depend on his type.

	[ids list] [ids_params list] [file_upload|download] [param_body list] [output_filter]

Parametes:
	none - .
	Input arguments - It is a hash with the input arguments parsed.
	Object def - It is the command definition.
	ID tree - It is the load balancer ID tree.

Returns:
	Depend on the argument type, this function returns ones of the following values:
	- ids list, it looks for the possible values in the load balancer IDs tree and it returns an array ref.
	- ids params list, it returns a string with the name of the argument expected.
	- file, it retuns the output of the 'complete_files' function.
	- param body, it returns the output of the function 'completeArgsBodyParams'.
	- output_filter, it returns a string with input format.
	- empty array ref, this command does not expect more arguments.

=cut

sub getCmdArgsCallBack
{
	my ( undef, $input, $obj_def, $id_tree ) = @_;
	my $possible_values = [];

	# 'args' is the list of arguments used
	# 'argno' is the number of arguments used

	# list of used arguments
	my @args_used = @{ $input->{ args } };

	# get the previous completed parameter that was used
	my $arg_previus = $args_used[$input->{ argno } - 1];

	my ( $args_parsed, $next_arg, undef ) =
	  &parseInput( $obj_def, 1,
				   $obj_def->{ object },
				   $obj_def->{ action }, @args_used );

	&devMsg( "getting '$next_arg'" );

	if ( $next_arg eq 'id' )
	{
		&devMsg( "Getting the id list " . scalar @{ $args_parsed->{ id } } );
		$possible_values = &getIdNext( $obj_def, $id_tree, $args_parsed->{ id } );
	}
	elsif ( $next_arg eq 'param_uri' )
	{
		my $uri_index = scalar @{ $args_parsed->{ param_uri } };
		$possible_values = "<$obj_def->{param_uri}->[$uri_index]->{name}>";
	}
	elsif ( $next_arg =~ /file/ )
	{
		$possible_values = shift->complete_files( $input );
	}
	elsif ( $next_arg eq 'param_body' )
	{
		$possible_values =
		  &completeArgsBodyParams( $obj_def,     $args_parsed, \@args_used,
								   $arg_previus, $id_tree );
	}
	elsif ( $next_arg eq 'output_filter' )
	{
		if ( $arg_previus ne $Define::Options{ FILTER } )
		{
			$possible_values = [$Define::Options{ FILTER }];
		}
		else
		{
			$possible_values = "<item1[,item2]>";
		}
	}

	# fin
	else
	{
		$possible_values = [];
	}

	return $possible_values;
}

=begin nd
Function: validateIds

	It matchs the command input IDs with the load balancer IDs to look for if there
	was any error.

Parametes:
	Object def - It is the command definition.
	Input arguments - It is a hash with the input arguments parsed.
	ID tree - It is the load balancer ID tree.

Returns:
	String - It returns an error message. It there was an error and it already was printed, this function returns "". It retuns undef if there isn't an error.

=cut

sub validateIds
{
	my ( $obj_def, $args_parsed, $id_tree ) = @_;

	my $msg;

	return $msg if !exists $obj_def->{ ids };

	if ( @{ $obj_def->{ ids } } > @{ $args_parsed->{ id } } )
	{
		$msg = "The argument '$obj_def->{id}' is missing";
	}
	elsif ( @{ $obj_def->{ ids } } < @{ $args_parsed->{ id } } )
	{
		$msg = "The argument '$args_parsed->{id}' is not expected";
	}
	else
	{
		my @id_list = ();
		my $ind     = 0;
		my $possible_values;
		foreach my $id ( @{ $args_parsed->{ id } } )
		{
			$possible_values = &getIdNext( $obj_def, $id_tree, \@id_list );
			if ( !@{ $possible_values } )
			{
				&dev();
				return "";
			}
			return "The $obj_def->{ids}->[$ind] '$id' is not found"
			  unless ( grep ( /^$id$/, @{ $possible_values } ) );
			push @id_list, $id;
			$ind++;
		}
	}

	return $msg;
}

=begin nd
Function: completeArgsBodyParams

	It parses the command input arguments that apply to the HTTP body parameters.
	It updates the object with the list of expected parameter list (using refreshParameters).
	It returns the list of following parameters depend on the previous input parameters
	of the command.

Parametes:
	Object def - It is the command definition.
	Input arguments parsed - It is a hash with the input arguments parsed by type.
	Input arguments list - It is a list with all the input arguements
	Previous argument - It is the last complete argument, it is not the current one that is autocompleting.
	ID tree - It is the load balancer ID tree.

Returns:
	String or Array ref - If the current input argument is a key (-param) it retuns an array reference with the list of expected ZAPI parameters.
						If the current input argument is a value, it retuns the list of possible values that the ZAPI responds in the field 'possible_values' or an string repeating the parameter name

=cut

sub completeArgsBodyParams
{
	my ( $obj_def, $args_parsed, $args_used, $arg_previus, $id_tree ) = @_;
	my $out;

	my $msg = &validateIds( $obj_def, $args_parsed, $id_tree );
	if ( defined $msg )
	{
		&printCompleteMsg( $msg ) if ( $msg ne '' );
		return [];
	}

	&refreshParameters( $obj_def, $args_parsed, $Env::Profile );

	# get the previous completed parameter that was used
	my $previus_param = $arg_previus;
	$previus_param =~ s/^-//;

	my $p_obj = $Env::Cmd_params_def;

	# manage the 'value' of the parameter
	if ( exists $p_obj->{ $previus_param } )
	{
		&devMsg( "getting the value for the key '$previus_param'" );
		my $p_def = $p_obj->{ $previus_param };

		# list the possible values
		if ( exists $p_def->{ possible_values } )
		{
			$out = $p_def->{ possible_values };
		}

		# try to autocomplete
		elsif ( exists $obj_def->{ params_autocomplete }->{ $previus_param } )
		{
			# get list of possible values from the id tree
			my $id_ref = $id_tree;
			foreach my $it ( @{ $obj_def->{ params_autocomplete }->{ $previus_param } } )
			{
				$id_ref = $id_ref->{ $it };
			}
			my @list = keys %{ $id_ref };
			$out = \@list;
		}
		else
		{
			$out = "<$previus_param>";
		}
	}

	# manage the 'key' of the parameter
	else
	{
		&devMsg( "getting key" );

		# remove the parameters already exists
		my @params = ();
		foreach my $p ( keys %{ $p_obj } )
		{
			# not show the parameters that are predefined
			next if ( exists $obj_def->{ params }->{ $p } );

			# not show parameters that expects arrays or hashes values
			next if ( exists $Env::Cmd_params_def->{ $p }->{ ref } );

			push @params, "-$p" if ( !grep ( /^-$p$/, @{ $args_used } ) );
		}

		# all parameters has been used
		if ( !@params )
		{
			@params = ();
			&printCompleteMsg( "This command does not expect more parameters" );
		}

		$out = \@params;
	}

	return $out;
}

=begin nd
Function: getIdNext

	It expands the URI request using the input arguments and the IDs tree to
	look for the list of possible values that the load balancer accepts for the
	following uri ID.
	It will print a autocomplete message if the list of possible values is empty..

Parametes:
	Object def - It is the command definition.
	ID tree - It is the load balancer ID tree.
	ID Arguments list - It is the list of IDs arguments used in the command

Returns:
	Array ref - It is the list of possibles values for a key.

=cut

sub getIdNext
{
	my $obj_def = shift;
	my $id_tree = shift;
	my $args    = shift;    # input arguments

	my $url = $obj_def->{ uri };    # copy data from def

	# replace the obtained ids untill getting the next arg key
	$url = &replaceUrl( $url, $args );

	# getting next args
	if ( $url =~ /([^\<]+)\<([\w -]+)\>/ )
	{
		my $sub_url = $1;           # Getting the url keys to be used in the IDs tree

		my @keys_list = split ( '/', $sub_url );

		# Remove the first item, because url begins with the character '/'
		shift @keys_list;

		my @values   = ();
		my $nav_tree = $id_tree;
		my $key_flag = 0;
		my $prev_key = "";
		foreach my $k ( @keys_list )
		{
			$key_flag = !$key_flag;
			$prev_key = $k if ( $key_flag );

			# check previous ids exist
			if ( !defined $nav_tree->{ $k } )
			{
				if ( $key_flag )
				{
					&printCompleteMsg( "The are not any '$k' available" );
				}
				else
				{
					&printCompleteMsg( "The $prev_key '$k' does not exist" );
				}
				return [];
			}

			$nav_tree = $nav_tree->{ $k };
			@values   = keys %{ $nav_tree };
		}

		return \@values;
	}

	return [];
}

1;
