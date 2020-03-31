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
		&dev( "execute and exit", undef, 1 );
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
	my $welcome = "${Color::Green}$logo${Color::Clean}

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
	my $err     = shift // 0;
	my $conn    = $Env::Connectivity;
	my $profile = $Env::Profile->{ name } // "";

	my $color      = ( $err )   ? $Color::Red  : $Color::Green;
	my $conn_color = ( !$conn ) ? $Color::Gray : "";
	$color      = $Color::Init . $color . $Color::End;
	$conn_color = $Color::Init . $conn_color . $Color::End;

	my $tag = "zcli($conn_color$profile$color)";
	$Env::Zcli->prompt( "${Color::Reset}$color$tag${Color::Reset}: " );

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
	$profile_st->{ $V{ CREATE } }->{ proc }  = sub {
		my $out = &setProfile;
		( !defined $out );
	};
	$profile_st->{ $V{ CREATE } }->{ maxargs } = 1;
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
	};
	$st->{ profile }->{ desc } =
	  "apply an action about which is the destination load balancer";
	$st->{ profile }->{ cmds } = $profile_st;

	return $st;
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
	if ( $def->{ method } =~ /^(POST|PUT)$/ and $params )
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
		if ( !defined $input_args->[$it] )
		{
			return undef if ( $p eq '[-param_1' );
			return $p;
		}
		$it++;
	}

	return undef;
}

=begin nd
Function: getCmdArgsNum

	It calculates the number of expected arguments for a command.
	This function is only valid for GET methods

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
			&dev( "The parameter list is not complete" );

			&refreshParameters( $obj_def, $input_parsed, $Env::Profile );

			my $desc      = &getCmdDescription( $obj_def );
			my $missing_p = &getMissingParam( $desc, \@input_args );

			if ( !defined $missing_p )
			{
				&printError( "Some parameters are missing. The expected syntax is:" );
			}
			else
			{
				&printError(
					"Some parameters are missing, it failed getting '$missing_p'. The expected syntax is:"
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

		# do not allow sending extra arguments using GET methods
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

		&dev( "calling zapi" );
		$resp = &zapi( $request, $Env::Profile );
		$err  = $resp->{ err };

		&printOutput( $resp );

	};
	&printError( $@ ) if $@;

	#~ $err = ( $@ or $err ) ? 1 : 0 if ($Env::Silence);
	$err = ( $@ or $err ) ? 1 : 0;

	( $err );
}

# [ids list] [ids_params list] [file_upload|download] [param_body list]
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

	my ( $args_parsed, $next_arg ) =
	  &parseInput( $obj_def, 1,
				   $obj_def->{ object },
				   $obj_def->{ action }, @args_used );

	$Env::Zcli->completemsg( "  ## getting '$next_arg'\n" ) if ( $Global::Debug );

	if ( $next_arg eq 'id' )
	{
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

	# fin
	else
	{
		$possible_values = [];
	}

	return $possible_values;
}

sub completeArgsBodyParams
{
	my ( $obj_def, $args_parsed, $args_used, $arg_previus, $id_tree ) = @_;
	my $out;

	&refreshParameters( $obj_def, $args_parsed, $Env::Profile );

	# get the previous completed parameter that was used
	my $previus_param = $arg_previus;
	$previus_param =~ s/^-//;

	my $p_obj = $Env::Cmd_params_def;

	$Env::Zcli->completemsg( "  ## prev: $p_obj->{ $previus_param }\n" )
	  if ( $Global::Debug );

	# manage the 'value' of the parameter
	if ( exists $p_obj->{ $previus_param } )
	{
		$Env::Zcli->completemsg( "  ## getting value\n" ) if ( $Global::Debug );
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
		$Env::Zcli->completemsg( "  ## getting key \n" ) if ( $Global::Debug );

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
			$Env::Zcli->completemsg(
									 "  ## This command does not expect more parameters\n" );
		}

		$out = \@params;
	}

	return $out;
}

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
			$Env::Zcli->completemsg( "  ## There is not any '$key'\n" );
		}

		return \@values;
	}

	return [];
}

1;
