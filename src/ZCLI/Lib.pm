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
use feature "say";
use LWP::UserAgent;
use JSON;

use Storable qw(dclone);

use lib '..';
use ZCLI::Define;
use ZCLI::Objects;

## Global functions

=begin nd
Function: devMsg

	Function to print debug messages.

	lvl 1. It prints messages and light variables (not array or hashes)
	lvl 2. It prints zapi requests
	lvl 3. It prints structs

Parametes:
	String - String to print. Use 'Dumper($ref)' to print the value of a reference
	Tag - Short message to wrap the message
	lvl - The minimum log level to print the message

Returns:
	none - .

=cut

sub devMsg
{
	my $st  = shift;
	my $tag = shift;
	my $lvl = shift // 1;

	chomp ( $st );

	#~ $st .= "\n###### " if ($st =~ /\n/);

	return if ( $lvl > $Global::Debug );

	my $msg = "# Debug $lvl";
	$msg .= ", $tag" if defined ( $tag );
	$msg .= ": $st";

	&printMsg( "$msg" );

	#~ &printCompleteMsg( $msg );
}

=begin nd
Function: printHelp

	It prints the help

Parametes:
	none - .

Returns:
	none - .

=cut

sub printHelp
{
	my $objs    = join ( ', ', sort keys %{ $Objects::Zcli } );
	my $actions = join ( ', ', sort values ( %Define::Actions ) );

	# tab is 2 spaces
	my $msg = "
SYNTAXIS:
  zcli [options] <object> <action> <id> [parameters]

[args] arguments between characters ‘[]’ are mandatories.
<args> arguments between characters ‘<>’ are optional.


Options:
ZCLI can be executed with the following options:
  --help, -h: show this ZCLI help.
  --version, -v: it prints the ZCLI version.
  --profile, -p <name>: choose the 'name' profile as the destination load balancer of the command.
  --json, -j: the input parameters will be parsed as JSON. The silence flag will be activated automatically if this flag is enabled.
  --no-color, -nc: it disables the color for JSON outputs.
  --debug, -d: it enables the debug level.


ZCLI has an autocomplete feature. Pressing double <tab> to list the possible options for the current command.
If the autocomplete does not list more options, press <intro> to get further information.
The minimum number of expected arguments to execute a command are 2, the ‘object’ and the ‘action’ arguments. The ‘id’ and ‘parameter’ arguments will depend on the object and action.
If zcli is executed followed by argument, then zcli will exit once the action is done.

Objects:
  It selects the Zevenet module where the command is going to do the action.
  ZLI can be executed from command line with the following objects:
  *) help, list the ZCLI help.
  *) profile, manage the load balancer profiles. (See ’profile’ section for further help).
  *) history, list the last commands.
  *) reload, reload the ZCLI without exiting. It is useful to sync information against the load balancer.
  *) quit, exit from the ZCLI.

  The other objects require connectivity with the load balancer and they interact directly with it.
  The list of available objects are:
  $objs


Actions:
  It sets the verb executed for the selected object.
  The available actions are:
  $actions


IDs:
  The IDs identify items for the selected object. The needed IDs for a action can be shown pressing tab or pressing enter once the object and the action have been chosen.


Parameters:
  It sets values of the command.
  The parameters of each command are listed once the previous values (object, action and ids) have been set. This ZCLI tool is based on the ZAPI (Zevenet API), so, the parameter names are the same than the ZAPI, if further information about the availablie parameters for each ID is required, then you can check the ZAPI documentation in the following link: $Define::Zapi_doc_uri

  Parameters are set using a key and value combination. The key name is set using the character '-' previously to the name, followed by the value. An example is: -vip 192.168.100.100 -vport 80, where vip and vport are parameter keys and 192.168.100.100 and 80 are parameter values.

  The parameter '-filter' can be used in the actions 'list' and 'get' in order to filter the output command and get only a list of determinated parameters (see the below examples section).


EXAMPLES:
  # The following command sets the virtual port 53 and the virtual IP 10.0.0.20 in a farm named gslbfarm
  	> zcli farm set gslbfarm -vport 53 -vip 10.0.0.20
  # The following command sets the same action that previously but in JSON format.
  	> zcli -j farms set gslbfarm '{\"vport\":53,\"vip\":\"10.0.0.20\"}'

  # The following command creates a virtual interface named eth0:srv using the IP 192.168.100.32
  	> zcli network-virtual create -name eth0:srv -ip 192.168.100.32
  # The following command sets the same action than previously but in JSON format.
  	> zcli -j network-virtual create '{\"name\":\"eth0:srv\",\"ip\":\"192.168.100.32\"}'

  # The following command shows only the paramters farmname and status in the farm list
  	> zcli farm list -filter farmname,status

PROFILES:
  ZCLI can store several load balancer profiles. Each profile contains information about the load balancer network settings and the connection credentials (user's ZAPI key). This information is saved in the file ‘$Global::Config_dir’, the user home directory.
  In order to manage the load balancer profiles the ZCLI command ‘profile’ can be used.
  In case that zcli command is executed without any profile then the default profile is going to be loaded. If the zcli command is executed with the option ‘--profile’ then the connection will be done to the selected profile.
  ZCLI can be used locally in a load balancer, it automatically set a profile called $Define::Profile_local. It is necessary to set the root ZAPI key to enable full control of the load balancer, RBAC users also can be used for this, in case that the RBAC user doesn't have permissions to execute the action then a permission error will be shown by the zcli command.


PROMPT:
  The ZCLI prompt looks like ‘zcli (profile)’, It will change the color in according to the error code of the executed commands, green color indicates that the last command was successfuly and red color means that last command failed.
  The profile name will change to gray color if ZCLI is not able to connect to the selected load balancer, this could be related to a connectivity issue or ZAPI credential problem.

";

	# print the help paged
	{
		require IO::Pager;
		{
			IO::Pager::open( my $fh ) or warn ( $! );
			print $fh $msg;
		}
	}

	return 0;
}

=begin nd
Function: replaceUrl

	It replaces the url ids in the url of the request definition that contains the tags "<keys>".
	If the number of arguments is minor than the tags, the returned url won't be totally replaced.

Parametes:
	Url - It is an string with the tags "<tag_name>". For example: "/farms/<farmname>/services/<service>/backends"
	Arguments - It is an array reference with a list of sorted values to replace in the original URL.

Returns:
	String - It returns a string with the url replaced

=cut

sub replaceUrl
{
	my $url  = shift;
	my $args = shift;

	my $index = -1;
	foreach my $arg ( @{ $args } )
	{
		$index++;
		unless ( $url =~ s/\<[\w -]+\>/$arg/ )
		{
			&printError( "The id '$index' could not be replaced" );
			die $Global::Fin;
		}
	}

	return $url;
}

## Objects definitions

=begin nd
Function: parseInput

	It receives a ZCLI command line and it parses the arguments creating a hash
	with the obtained information.

	The autocomplete flag is used to parse the input commands in the autocomplete step.
	For this task, the last argument is remove to get again the list of possible values for that item.

	The parse is done always following the same order. The order or the command arguments are:
	zcli [object] [action] [ids list] [ids_params list] [file_upload|download] [param_body lists]

Parametes:
	Object definition - It is a object hash with the parameters that defines a zapi call.
	Autocomplete - It is a flag to parses the arguments in the autocomplete step or when the zapi request is going to be done. The possible values are 1 or 0.
	Arguments - The rest of parameters are the input command arguments, the first one must be the 'object', next the 'action' and following the others arguments (IDS, param_uri, files and param_body).

Returns:
	Array - The first position is a hash with the arguments grouped by type.
			The second position is an string with the key of the following kind of required argument.
			The third position is a flag to return if the command was totally parsed. It the case than the command accepts param_body, the last phase will be the 'param_body'.

=cut

sub parseInput
{
	my $def          = shift;
	my $autocomplete = shift;    # 'autocomplete' = 1, 'check' = 0
	my @args         = @_;

	die "The variable 'autocomplete' in the function 'parseInput' is invalid"
	  if ( $autocomplete != 0 and $autocomplete != 1 );

	my $steps = {
				  uri_id        => 'id',
				  param_uri     => 'param_uri',
				  download_file => 'download_file',
				  upload_file   => 'upload_file',
				  output_filter => 'output_filter',
				  param_body    => 'param_body',
				  end           => 'end',
	};
	my $parsed_completed = 0;

	# remove the last item if it is blank
	pop @args if ( $autocomplete );

	my $input = {
				  object        => shift @args,
				  action        => shift @args,
				  id            => [],
				  param_uri     => [],
				  download_file => undef,
				  upload_file   => undef,
				  output_filter => undef,
				  params        => undef,
	};

	# adding uri ids
	for ( @{ $def->{ ids } } )
	{
		my $id = shift @args;
		if ( defined $id )
		{
			push @{ $input->{ id } }, $id;
		}
		else
		{
			return ( $input, $steps->{ uri_id }, $parsed_completed );
		}
	}

	# adding uri parameters
	if ( exists $def->{ param_uri } )
	{
		my $tag = $Define::Uri_param_tag;
		my $uri = $def->{ uri };
		for ( @{ $def->{ param_uri } } )
		{
			my $val = shift @args;
			if ( defined $val )
			{
				if ( $uri =~ s/$tag/$val/ )
				{
					push @{ $input->{ param_uri } }, $val;
				}
				else
				{
					die $Global::Fin;
				}
			}
			else
			{
				return ( $input, $steps->{ param_uri }, $parsed_completed );
			}
		}
	}

	# check if the call is expecting a file name to upload or download
	if ( exists $def->{ 'download_file' } )
	{
		my $val = shift @args;
		if ( defined $val )
		{
			$input->{ download_file } = $val;
		}
		else
		{
			return ( $input, $steps->{ download_file }, $parsed_completed );
		}
	}
	elsif ( exists $def->{ 'upload_file' } )
	{
		my $val = shift @args;
		if ( defined $val )
		{
			$input->{ upload_file } = $val;
		}
		else
		{
			return ( $input, $steps->{ upload_file }, $parsed_completed );
		}
	}

	my $final_step = $steps->{ end };
	$parsed_completed = 1;

	# output cmd
	@Env::OutputFilter = ();
	if ( $def->{ action } =~ /^(?:$Define::Actions{LIST}|$Define::Actions{GET})$/ )
	{
		$final_step = $steps->{ output_filter };

		my $param = shift @args;
		if ( defined $param and $param ne '' )
		{
			if ( $param eq $Define::Options{ FILTER } )
			{
				$parsed_completed = 0;

				my $str = shift @args;
				if ( !$str or !defined $str )
				{
					&devMsg( "Error parsing filter" );
				}
				else
				{
					@Env::OutputFilter        = split ( ',', $str );
					$input->{ output_filter } = \@Env::OutputFilter;
					$parsed_completed         = 1;
					$final_step               = $steps->{ end };
				}
			}
		}
	}

	if (     !exists $def->{ 'upload_file' }
		 and !exists $def->{ 'download_file' }
		 and $def->{ method } =~ /POST|PUT/ )
	{
		if ( $Env::Input_json )
		{
			my $json_args = join ( '', @args );

			eval { $input->{ params } = JSON::decode_json( $json_args ); };
			if ( $@ )
			{
				&printError( "Error decoding the input JSON" );
				die $Global::Fin;
			}
		}
		else
		{
			$parsed_completed = 0 if ( !defined $def->{ params } );
			$final_step       = $steps->{ param_body };

			# json params
			my $param_flag = 0;
			for ( my $ind = 0 ; $ind <= $#args ; $ind++ )
			{
				if ( $args[$ind] =~ s/^\-// )
				{
					$parsed_completed = 1;
					$param_flag       = 1;
					my $key = $args[$ind];
					my $val = $args[$ind + 1];
					$ind++;

					$input->{ params }->{ $key } = $val;
				}
				else
				{
					$parsed_completed = 0;
					&printCompleteMsg( "The '$args[$ind]' argument is not expected" );
					return ( $input, $final_step, $parsed_completed );
				}
			}

# Parsed is not complete if there aren't parameters in the cmd definition or input arguments
			$parsed_completed = 0
			  if (     !defined $input->{ params }
				   and !( defined $def->{ params } and %{ $def->{ params } } ) );
		}
	}

	&devMsg( Dumper( $input ), 'input parsed', 2 );
	return ( $input, $final_step, $parsed_completed );
}

=begin nd
Function: printCompleteMsg

	It prints useful information aboute the command when the user is pressing 'tab' to autocomplete.

Parametes:
	Message - It is an string with the message to print

Returns:
	none - .

=cut

sub printCompleteMsg
{
	my $msg = shift;
	my $tag = "  ## ";

	if ( defined $Env::Zcli and !$Env::Silence )
	{
		$Env::Zcli->completemsg( "$tag$msg\n" );
	}
}

=begin nd
Function: parseOptions

	It receives the ZCLI command line arguments, parse the options and remove them
	from the list of arguments.
	The options are the arguments that are following the zcli program name and using the tag '-'.

Parametes:
	args - It is an array ref with the list of arguments.

Returns:
	Hash ref - It is a hash with the options parsed. The possible keys are:
		{
			help => 1,
			silence => 1,
			profile => localhost,
			json => 1,
		};

=cut

sub parseOptions
{
	my $args   = $_[0];
	my $opt_st = {};

	# the options are the parameters before object
	while ( @{ $args } )
	{
		if ( $args->[0] !~ /^-/ )
		{
			# Run in silence mode if there are arguments in the execution
			$opt_st->{ silence } = 1;
			last;
		}
		else
		{
			my $opt = shift @{ $args };
			if ( $opt eq '--help' or $opt eq '-h' )
			{
				&printHelp( 0 );
				exit 0;
			}
			elsif ( $opt eq '--version' or $opt eq '-v' )
			{
				&printSuccess( "ZCLI version $Global::Version" );
				exit 0;
			}
			elsif ( $opt eq '--json' or $opt eq '-j' )
			{
				$opt_st->{ 'json' } = 1;
			}
			elsif ( $opt eq '--no-color' or $opt eq '-nc' )
			{
				$opt_st->{ 'nocolor' } = 1;
			}
			elsif ( ( $opt eq '--profile' or $opt eq '-p' ) and $args->[0] !~ /^-/ )
			{
				$opt_st->{ 'profile' } = shift @{ $args };
				my $prof = &getProfile( $opt_st->{ 'profile' } );
				exit 1 if ( !defined $prof );
			}
			elsif ( $opt eq '--debug' or $opt eq '-d' )
			{
				$opt_st->{ 'debug' } = 1;
			}
			elsif ( $opt eq '--debug-2' or $opt eq '-d2' )
			{
				$opt_st->{ 'debug' } = 2;
			}
			else
			{
				&printError( "The '$opt' option is not recognized." );
				&printHelp( 1 );
				exit 1;
			}
		}
	}

	$Global::Debug   = $opt_st->{ 'debug' } if exists $opt_st->{ 'debug' };
	$Env::Silence    = 1                    if exists $opt_st->{ silence };
	$Env::Input_json = 1                    if exists $opt_st->{ json };
	$Env::Color = 0 if exists $opt_st->{ nocolor } or $Env::OS eq 'win';

	if ( %{ $opt_st } )
	{
		&devMsg( Dumper( $opt_st ), "Execution options: " );
	}

	return $opt_st;
}

=begin nd
Function: createZapiRequest

	It creates an zapi request object from a ZCLI definition object.
	First it copies de object and next replaces some values from the input.
	It uses the parameters that were previously parsed

Parametes:
	Object definition - It is an object hash with the parameters that defines a zapi call.
	Argument parsed - It is a hash with the input information parsed and grouped by type.

Returns:
	Hash ref - Is the zcli object updated with the info to do the zapi request.

=cut

sub createZapiRequest
{
	my $def   = shift;
	my $input = shift;

	my %call_obj = %{ $def };
	my $call     = \%call_obj;

	# getting IDs
	$call->{ uri } = &replaceUrl( $def->{ uri }, $input->{ id } );

	# getting uri parameters
	if ( exists $def->{ param_uri } )
	{
		my $tag = $Define::Uri_param_tag;
		foreach my $p ( @{ $input->{ param_uri } } )
		{
			unless ( $call->{ uri } =~ s/$tag/$p/ )
			{
				&printError( "Error replacing the param '$p'" );
				die $Global::Fin;
			}
		}
	}

	# getting upload file
	if ( exists $call->{ upload_file } )
	{
		$call->{ upload_file } = $input->{ upload_file };
	}

	# getting download file
	if ( exists $call->{ download_file } )
	{
		$call->{ download_file } = $input->{ download_file };
	}

	# get PARAMS
	if ( ( $call->{ method } eq 'POST' or $call->{ method } eq 'PUT' )
		 and !exists $call->{ download_file }
		 or $call->{ upload_file } )
	{
		if ( exists $input->{ params } )
		{
			foreach my $p ( keys %{ $input->{ params } } )
			{
				$call->{ params }->{ $p } = $input->{ params }->{ $p };
			}
		}
	}

	&devMsg( Dumper( $call ), "request sumary", 2 );

	return $call;
}

=begin nd
Function: getLBIdsTree

	It gets and modifies the load balancer IDs tree to adapt it to ZCLI. This tree is used to the autocomplete feature of the IDs

Parametes:
	Profile - It is a reference to a profile object that contains the information about connecting with the load balancer.

Returns:
	Hash ref - It is a hash with the IDs tree

=cut

sub getLBIdsTree
{
	my $profile = shift;

	my $request = {
					uri    => "/ids",
					method => 'GET',
	};
	my $resp = &zapi( $request, $profile );

	my $tree;

	if ( defined $resp->{ msg } )
	{
		&printError( $resp->{ msg } );
	}
	if ( $resp->{ code } == 404 )
	{
		&printError(
			"Error connecting to the load balancer.\nZCLI connects with Zevenet versions greater or equal to $Global::Req_ee_zevenet_version for Enterprise Edition or $Global::Req_ce_zevenet_version for Community Edition."
		);
	}
	elsif ( $resp->{ 'json' }->{ 'params' } )
	{
		$tree = $resp->{ 'json' }->{ 'params' };

		$tree->{ 'monitoring' }->{ 'fg' } = $tree->{ 'farmguardians' };
		$tree->{ 'stats' }->{ 'farms' }   = $tree->{ 'farms' };
	}

	&devMsg( Dumper( $tree ), 'ids tree', 2 );

	return $tree;
}

## ZAPI requests

=begin nd
Function: getUserAgent

	Initializate the HTTP client used to do ZAPI requests

Parametes:
	none - .

Returns:
	Hash ref - It is a UserAgent object

=cut

sub getUserAgent
{
	my $ua = LWP::UserAgent->new(
								  agent    => '',
								  ssl_opts => {
												verify_hostname => 0,
												SSL_verify_mode => 0x00
								  }
	);
	return $ua;
}

=begin nd
Function: zapi

	It does a HTTP request to the load balancer ZAPI service.

Parametes:
	Request - It is a hash with the required parameter to create a ZAPI request. The possible keys are:
		uri - It is the HTTP URI for the ZAPI request.
		method - It is the HTTP URI for the ZAPI method (verb).
		content_type - It is the content_type required for the ZAPI request. If 'params' exists content_type will use the 'application/json' value by default.
		params - It is a hash with the parameters used in the POST or PUT method.
		upload_file - It is the path to the file is going to be uploaded.
		download_file - It is the path to the file where save the donwloaded file.
	Profile - It is a hash with information about the load balancer. The possible keys are:
		host - It is the host IP or network hostname.
		port - It is the port of the ZAPI service.
		zapi_version - It is the ZAPI verison used

Returns:
	Hash ref - The output contains the following keys:
		code, it is an integer with the HTTP code that the ZAPI returns.
		msg, it is the message of the JSON response returned by the ZAPI.
		err, it returns 0 if the response contains a 2xx code, else it will return the value 1.
		json, it is a JSON object with the reponse body, this parameter will appear if the response uses the header "content-type: application/json".
		txt, it is an string with the body response, this parameter will appear if the response uses the header "content-type: text/plain".

			{
				'code' => $response->code,
				'json' => $json_dec,
				'msg'  => $msg,
				'err'  => ( $response->code =~ /^2/ ) ? 0 : 1,
			}
	};

=cut

sub zapi
{
	my $arg     = shift;
	my $profile = shift;

	&devMsg( "Do zapi request..." );
	&devMsg( Dumper( $arg ), 'request', 2 );

	# This is a workaround to manage l4 and datalink services.
	$arg->{ uri } =~ s|/services/$Define::L4_service/|/|m;

	# create URL
	my $URL =
	  "https://$profile->{host}:$profile->{port}/zapi/v$profile->{zapi_version}/zapi.cgi$arg->{uri}";
	my $request = HTTP::Request->new( $arg->{ method } => $URL );

	# add zapikey
	my $ZAPI_KEY_HEADER = 'ZAPI-KEY';
	$request->header( $ZAPI_KEY_HEADER => $profile->{ zapi_key } );    # auth: key

	# add body
	if ( $arg->{ method } eq 'POST' or $arg->{ method } eq 'PUT' )
	{
		# add content_type header
		$arg->{ content_type } = $arg->{ content_type } // 'application/json';
		$request->content_type( $arg->{ content_type } );

		# sending data in binary
		if ( $arg->{ content_type } eq 'application/gzip' )
		{
			open ( my $upload_fh, '<', "$arg->{ upload_file }" );
			{
				binmode $upload_fh;
				use MIME::Base64 qw( encode_base64 );
				local $/;
				$request->content( encode_base64( <$upload_fh> ) );
			}
			close $upload_fh;
		}

		# uploading file with another format
		elsif ( exists $arg->{ upload_file } )
		{
			open ( my $upload_fh, '<', "$arg->{ upload_file }" );
			{
				local $/;
				my $upload = <$upload_fh>;
				$request->content( $upload );
			}
			close $upload_fh;
		}
		else
		{
			$arg->{ params } = {} if ( !defined $arg->{ params } );
			$request->content( JSON::encode_json( $arg->{ params } ) );
		}
	}

	my $ua       = &getUserAgent();
	my $response = $ua->request( $request );

	&devMsg( Dumper( $response ), 'response', 2 );

	my $txt;
	my $json_dec;
	my $msg;

	# Getting files (certs, backups...)
	if ( exists $arg->{ 'download_file' } )
	{
		open ( my $download_fh, '>', $arg->{ 'download_file' } );
		{
			print $download_fh $response->content();
		}
		close $download_fh;

		$msg = "The file was properly saved in the file '$arg->{ 'download_file' }'.";
	}

	# Getting text bodies
	elsif ( $response->header( 'content-type' ) =~ 'text/plain' )
	{
		$txt = $response->content();
	}
	else
	{
		eval { $json_dec = JSON::decode_json( $response->content() ); };
		if ( exists $json_dec->{ message } )
		{
			$msg = $json_dec->{ message };
			delete $json_dec->{ message };
		}
	}

	# add message for error 500
	if ( $response->code =~ /^5/ )
	{
		$msg = "There was an error in the load balancer. The command could not finish";
	}
	elsif ( $response->code == 401 )
	{
		$msg = "The authentication failed. Please, review the following settings
	*) The zapi user is enabled: clicking on Zevenet Webgui 'System > User'.
	*) The ZCLI zapikey is valid: using the ZCLI command with the arguments 'profile set $profile->{name}' to modify it.";
	}

	# create a enviorement variable with the body of the last zapi result.
	# if it is a error, put a blank ref.
	my $out = {
				'code' => $response->code,
				'json' => $json_dec,
				'msg'  => $msg,
				'err'  => ( $response->code =~ /^2/ ) ? 0 : 1,
	};

	$out->{ txt } = $txt if defined $txt;

	return $out;
}

=begin nd
Function: getDefaultDownloadFile

	It creates a default file name using the element name that is going to be downloaded

Parametes:
	Def object - the object that defines the zapi request
	object name - It is the name of the object that will be downloaded

Returns:
	String - It returns the file path with its extension.

=cut

sub getDefaultDownloadFile
{
	my $arg  = shift;
	my $file = shift;

	# add extension to backups
	if ( $arg->{ uri } =~ '^/system/backup/' and $file !~ /\.tar\.gz/ )
	{
		$file .= '.tar.gz';
	}

	return $file;
}

=begin nd
Function: getIds

	It receives an URI and it looks for the parameters that expects the URI.

Parametes:
	Uri - It is a string with the URI. An URI contains tag as "<TAG_NAME>" (/interfaces/virtual/<virtual>) that is related to the name of the parameter expected.

Returns:
	Array - It is the list of tags that needed for creating the URI.

=cut

sub getIds
{
	my $uri = shift;

	#~ my @ids = grep (/\<([\w -]+)\>/,$uri);
	my @ids;

	while ( $uri =~ s/\<([\w -]+)\>// )
	{
		push @ids, $1;
	}

	return @ids;
}

=begin nd
Function: listParams

	It does a ZAPI call to get the parameters that that call needs.
	If the definition of the call has some predefined parameter, they are removed before doing de call.

Parametes:
	Command object - It is an struct with the data to create a zcli command
	Arguments - It is an array ref with the input arguments
	Profile - It is a profile object with the information about connecting with the load balancer

Returns:
	Hash array - The response is an object like the following:
		{
			vip : {
				possible_values : [
					11.12.52.2,
					5.22.98.2
				],
			},
			session : {
				possible_values : [
					ip,
					hash_port
				],
			},
			slaves : {
				# the input is an array or hash ref. Do not complete in auto-complete. Input parameters must be json
				ref => 1,
			}
		}

=cut

sub listParams
{
	my ( $obj_def, $args_parsed, $profile ) = @_;

	# remove predefined values
	my $predef_params = $obj_def->{ params };
	delete $obj_def->{ params };

	my $args = {};
	$args->{ id }        = $args_parsed->{ id };
	$args->{ param_uri } = $args_parsed->{ param_uri };

	my $request =
	  &createZapiRequest( $obj_def, $args, $profile, $Env::Profile_ids_tree );

	my $resp = &zapi( $request, $profile );

	$Env::Cmd_params_def = undef;
	$Env::Cmd_params_msg = undef;

	if ( $resp->{ msg } ne $Define::Zapi_param_help_msg and exists $resp->{ msg } )
	{
		$Env::Cmd_params_msg = $resp->{ msg };
		return $Env::Cmd_params_def;
	}

	my $params_ref = $resp->{ json }->{ params };

	# 		Example:
	#		$params_ref =  [
	#			  {
	#				 "format" : "farm_name",
	#				 "name" : "copy_from",
	#				 "options" : [
	#					"non_blank"
	#				 ]
	#			  },
	#			  {
	#				 "name" : "vip",
	#				 "options" : [
	#					"required"
	#				 ],
	#				 "possible_values" : [
	#					"192.168.101.189",
	#					"192.168.100.241"
	#				 ]
	#			  },
	#		 ]

	# set again the predefined parameters
	$obj_def->{ params } = $predef_params if ( defined $predef_params );

	if ( defined $params_ref )
	{
		$Env::Cmd_params_def = {};
		foreach my $p ( @{ $params_ref } )
		{
			$Env::Cmd_params_def->{ $p->{ name } }->{ required } = 1
			  if ( exists $p->{ options } and grep ( /^required$/, @{ $p->{ options } } ) );
			$Env::Cmd_params_def->{ $p->{ name } }->{ exist } = 1;
			$Env::Cmd_params_def->{ $p->{ name } }->{ possible_values } =
			  $p->{ possible_values }
			  if ( exists $p->{ possible_values } );
			$Env::Cmd_params_def->{ $p->{ name } }->{ ref } = 1 if ( exists $p->{ ref } );
		}
	}

	# Add options defined in the cmd object
	if ( defined $obj_def->{ params_opt } )
	{
		foreach my $p ( keys %{ $obj_def->{ params_opt } } )
		{
			$Env::Cmd_params_def->{ $p }->{ possible_values } =
			  $obj_def->{ params_opt }->{ $p };
		}
	}

	return $Env::Cmd_params_def;
}

=begin nd
Function: refreshParameters

	It checks if the input command has changed and lunch a listParams to refresh
	the struct of expecting parameters.

	The new input command is saved in the variable: $Env::Cmd_string

Parametes:
	Command object - It is an struct with the data to create a zcli command
	Arguments - It is an array ref with the input arguments
	Profile - It is a profile object with the information about connecting with the load balancer

Returns:
	none - .

=cut

sub refreshParameters
{
	my ( $obj_def, $args_parsed, $profile ) = @_;

	&devMsg( "Checking refreshing paramters list" );

	# command that is being executed
	my $cmd_string = "$obj_def->{object} $obj_def->{action}";
	$cmd_string .= " $_" for ( @{ $args_parsed->{ id } } );

	# get list or refreshing the parameters list
	if ( $Env::Cmd_string eq '' or $Env::Cmd_string ne $cmd_string )
	{
		&devMsg( "Executing refreshing paramters list" );
		&listParams( $obj_def, $args_parsed, $profile );

		# refresh values
		$Env::Cmd_string = $cmd_string;
	}
}

=begin nd
Function: printOutput

	This function will print the output of the zapi, previously, giving it format.
	The color scheme is defined in the variable %JSON::Color::theme using the colors of Term::ANSIColor:
	https://perldoc.perl.org/Term/ANSIColor.html

Parametes:
	Response - It is a hash ref with the response of the zapi. The keys of the has are:
		$resp->{ json }, it is the json responded by the zapi.
		$resp->{ err }, it is a flag to indicate if the zapi returned an error.
		$resp->{msg}, it is an message, this field can appear if there was an error of if there wasn't.
		$resp->{ txt }, it is the body of the response when the zapi returns a txt message.

Returns:
	none - .

=cut

sub printOutput
{
	my $resp = shift;

	&devMsg( Dumper( $resp ), "responsed json", 3 );

	if ( exists $resp->{ json }->{ description } )
	{
		&printSuccess( "Info: $resp->{json}->{description}" );
		delete $resp->{ json }->{ description };
	}

	if ( $resp->{ err } )
	{
		&printError( "Error! $resp->{msg}" );
		if ( $resp->{ msg } =~ /expects a '(hash|array)' reference as input/ )
		{
			&printError(
				 "This parameter should be set using a JSON as command input (ZCLI option: -j)."
			);
		}
	}
	else
	{
		if ( exists $resp->{ msg } and defined $resp->{ msg } )
		{
			&printSuccess( "$resp->{ msg }" );
		}

		if ( exists $resp->{ txt } )
		{
			&printSuccess( "$resp->{txt}", 0 );
		}

		if ( @Env::OutputFilter )
		{
			$resp->{ json } = &filterHashParams( $resp->{ json }, \@Env::OutputFilter );
		}
		if ( defined $resp->{ json } and %{ $resp->{ json } } )
		{
			delete $resp->{ msg } if exists $resp->{ msg };
			my $json_enc = "";
			if ( !$Env::Color )
			{
				eval {
					require JSON;
					$json_enc = JSON::to_json( $resp->{ json }, { utf8 => 1, pretty => 1 } );
				};
			}
			else
			{
				eval {
					require JSON::Color;
					%JSON::Color::theme = %Color::Json;
					$json_enc = JSON::Color::encode_json( $resp->{ json }, { pretty => 1 } );
				};
				&printError( "There was an error printing the output: $@", 0 ) if ($@);
			}
			&devMsg( $@ ) if ( $@ );

			&printSuccess( "$json_enc", 0 ) if ( $json_enc );
		}
	}
}

=begin nd
Function: filterHashParams

	This funtion filters a hash keeping only the wanted hash keys.
	It will keep the hash struct (arrays ref and nest hashes).

Parametes:
	input hash - It is a hash reference that is going to be filtered.
	keys - It is an array reference with the keys to filter.

Returns:
	Hash ref - It is the input hash only with the wanted keys.

=cut

sub filterHashParams
{
	my $in   = shift;
	my $keys = shift;
	my $out;

	foreach my $k ( keys %{ $in } )
	{
		if ( grep ( /^$k$/, @{ $keys } ) )
		{
			$out->{ $k } = $in->{ $k };
		}
		elsif ( ref $in->{ $k } eq 'HASH' )
		{
			my $var = &filterHashParams( $in->{ $k }, $keys );
			$out->{ $k } = $var if ( defined $var );
		}
		elsif ( ref $in->{ $k } eq 'ARRAY' )
		{
			foreach my $it ( @{ $in->{ $k } } )
			{
				if ( ref $it eq 'HASH' )
				{
					my $var = &filterHashParams( $it, $keys );
					if ( defined $var )
					{
						$out->{ $k } = [] if !exists $out->{ $k };
						push @{ $out->{ $k } }, $var;
					}
				}
			}
		}
	}

	return $out;
}

=begin nd
Function: printMsg

	This function will print a message using the standard output or the error output.

Parametes:
	Message - It is a string with the message to print.
	Error flag - If the flag is 0 the message is printed in the standard output, else it will be printed in the error output.

Returns:
	none - .

=cut

sub printMsg
{
	my $msg = shift;
	my $err = shift // 0;

	chomp ( $msg );
	$msg .= "\n";

	if ( $err )
	{
		print STDERR $msg;
	}
	else
	{
		print STDOUT $msg;
	}
}

=begin nd
Function: printError

	This function is a macro to print error messages

Parametes:
	Message - It is a string with the message to print.
	Error flag - If the flag is 0 the message is printed in the standard output, else it will be printed in the error output.

Returns:
	none - .

=cut

sub printError
{
	my $msg = shift;

	&printMsg( $msg, 1 );
}

=begin nd
Function: printSuccess

	This function is a macro to print successful messages.

	Depend on the ZCLI was executed as silence mode, the information messages and non JSON ZAPI responses won't be printed

Parametes:
	Message - It is a string with the message to print.
	Header - It is a flag that has the value 1 if the message is an information message.

Returns:
	none - .

=cut

sub printSuccess
{
	my $msg    = shift;
	my $header = shift // 1;

	&printMsg( $msg, 0 ) unless ( $header and $Env::Silence );
}

## profile

=begin nd
Function: setProfile

	This function ask the PROFILE configuration to the user. It has two mode of working, one for creating a new profile
	or another to modify it. The profiles are saved in the config file "$ENV{HOME}/.zcli/profiles.ini"

	There is a special profile called 'localhost', this profile is used when ZCLI is executed from the load balancer.
	Localhost only has a input parameter (zapikey), the others ones are taken from the system.

Parametes:
	Profile name - It is the nick of the profile is going to be created or modified. This parameter is empty if it is executed in creation mode.
	new profile - It is a flag that creates a new profile (value 0) or modify a profile that exist (value 0). This flag manage which parameters are mandatory and allow to keep the old value.

Returns:
	Hash ref - It returns the profile struct updated with the new values or undef if there is an error. The keys of the profile struct are:
		zapi_version, it is the ZAPI version used
		name, it is a nick name of the load balancer
		host, it is the IP or nameserver or the load balancer
		port, it is the ZAPI management port
		zapikey, it is the user key used for the ZAPI requests
		edition, it is the Zevenet edition used in the load balancer. The possible values are CE, EE or not exists (if zcli has not connected)
		description, it is a description mesage about the profile. This message is a line.

	Example:
		$cfg = {
				 zapi_version => "4.0",
				 name         => "zevenet-lb-1",
				 host         => "192.168.100.254",
				 port         => 444,
				 zapi_key     => "v2kl3QK658awg34qaQbaewba3wjnzdkfxGbqbwq4",
				 edition      => "EE",
				 description  => "Monitoring user to test lb1",
		}
=cut

sub setProfile
{
	my $name = shift
	  ; # if name exists, the function will modify it, else it will create a new one
	my $new_flag  = shift // 1;
	my $conf_file = $Global::Profiles_path;
	my $cfg;
	my $valid_flag = 1;

	my $set_msg = "Press 'intro' to keep the value";

	# getting conf
	my $Config =
	  ( -e $conf_file ) ? Config::Tiny->read( $conf_file ) : Config::Tiny->new;

	# set values if the profile is localhost
	if ( $name eq $Define::Profile_local )
	{
		# overwrite data. Maybe the http server cfg was changed
		my ( $localip, $localport ) = &getHttpServerConf();

		$cfg = {
			zapi_version => $Define::Default_zapi_version,
			name         => $Define::Profile_local,
			description =>
			  "This profile is the root admin that is used to manage the current load balancer",
			host     => $localip,
			port     => $localport,
			zapi_key => $Config->{ $Define::Profile_local }->{ zapi_key } // '',
			edition  => ( eval { require Zevenet::ELoad; } ) ? 'EE' : 'CE',
		};
	}

	# validating
	elsif ( !$new_flag )
	{
		if ( !exists $Config->{ $name } )
		{
			if ( !defined $name )
			{
				print ( "A profile name is required\n" );
			}
			else
			{
				print ( "The '$name' profile does not exist\n" );
			}
			return undef;
		}
		$cfg = $Config->{ $name };
	}

	## Get parameters
	# get name
	if ( $new_flag and $name ne $Define::Profile_local )
	{
		do
		{
			print ( "Load balancer profile name: " );
			$valid_flag = 1;
			$name       = <STDIN>;
			chomp $name;
			$cfg->{ name } = $name;
			if ( $name !~ /\S+/ )
			{
				$valid_flag = 0;
				&print(
					  "Invalid 'name'. It expects a string with the load balancer profile name\n" );
			}
			elsif ( exists $Config->{ $name } )
			{
				$valid_flag = 0;
				print ( "Invalid name. The '$name' profile already exist\n" );
			}
		} while ( !$valid_flag );
	}

	# get Host
	if ( $name ne $Define::Profile_local )
	{
		do
		{
			print ( "Load balancer management IP or its network name: " );
			print ( "[$set_msg: $cfg->{host}] " ) if not $new_flag;
			$valid_flag = 1;
			my $val = <STDIN>;
			chomp $val;
			$cfg->{ host } = $val unless ( $val eq "" and not $new_flag );
			unless ( $cfg->{ host } =~ /^\S+$/ )
			{
				$valid_flag = 0;
				print ( "Invalid 'host' for load balancer. It an IP or a network name\n" );
			}
		} while ( !$valid_flag );
	}

	# get port
	if ( $name ne $Define::Profile_local )
	{
		do
		{
			print ( "Load balancer management port: " );
			print ( "[$set_msg: $cfg->{port}] " ) if not $new_flag;
			$valid_flag = 1;
			my $val = <STDIN>;
			chomp $val;
			$cfg->{ port } = $val unless ( $val eq "" and not $new_flag );
			unless ( $cfg->{ port } > 0 and $cfg->{ port } <= 65535 )
			{
				$valid_flag = 0;
				print (
					   "Invalid 'port for load balancer. It expects a port between 1 and 65535\n" );
			}
		} while ( !$valid_flag );
	}

	# get zapi key
	do
	{
		print ( "Load balancer zapi key: " );
		print ( "[$set_msg: $cfg->{zapi_key}] " ) if not $new_flag;
		$valid_flag = 1;
		my $val = <STDIN>;
		chomp $val;
		$cfg->{ zapi_key } = $val unless ( $val eq "" and not $new_flag );
		unless ( $cfg->{ zapi_key } =~ /\S+/ )
		{
			$valid_flag = 0;
			print ( "Invalid zapi key. It expects a string with the zapi key\n" );
		}
	} while ( !$valid_flag );

# get zapi version
#	do
#	{
#		print ( "Load balancer zapi version: " );
#		$valid_flag = 1;
#		$cfg->{ zapi_version } = <STDIN>;
#		chomp $cfg->{ zapi_version };
#		unless ( $cfg->{ zapi_version } =~ /^(4.0)$/ )
#		{
#			$valid_flag = 0;
#			print ( "Invalid zapi version. It expects once of the following versions: 4.0\n" );
#		}
#	} while ( !$valid_flag );
	$cfg->{ zapi_version } = $Define::Default_zapi_version;

	# get a description
	if ( $name ne $Define::Profile_local )
	{
		print ( "Do you want to add a description to the profile?: " );
		print ( "[$set_msg: $cfg->{description}] " ) if not $new_flag;
		$valid_flag = 1;
		my $val = <STDIN>;
		chomp $val;
		$cfg->{ description } = $val;
	}

	# Get Edition
	my $edition = &getProfileEdition( $cfg );
	$cfg->{ edition } = $edition if ( defined $edition );

	$Config->{ $name } = $cfg;

	# set the default
	if ( !defined $Config->{ _ }->{ default_profile } )
	{
		$Config->{ _ }->{ default_profile } = $name;
		print ( "Saved as default profile\n" );
	}
	elsif ( $Config->{ _ }->{ default_profile } ne $name )
	{
		print (
			"Do you want to set this load balancer profile as the default one? [yes|no=default]: "
		);
		my $confirmation = <STDIN>;
		chomp $confirmation;
		if ( $confirmation =~ /^(y|yes)$/i )
		{
			$Config->{ _ }->{ default_profile } = $name;
			print ( "Saved as default profile\n" );
		}
	}
	print ( "\n" );

	$Config->write( $conf_file );

	return $Config->{ $name };
}

=begin nd
Function: getProfileEdition

	It does a zapi call to get the zevenet edition

Parametes:
	Profile - It is a struct with profile information.

Returns:
	String - It returns 'EE' if Zevenet is entreprise, 'CE' if it is community or 'undef' if there was an error

=cut

sub getProfileEdition
{
	my $profile = shift;

	my $req = {
				uri    => '/system/info',
				method => 'GET'
	};

	my $resp = &zapi( $req, $profile );

	my $edition = $resp->{ json }->{ params }->{ edition };
	if ( defined $edition )
	{
		$edition = ( $edition eq 'enterprise' ) ? 'EE' : 'CE';
	}

	return $edition;
}

=begin nd
Function: updateProfileEdition

	It saves the Zevenet edition (enterprise or community) in the load balancer profile configuration

Parametes:
	Profile name - It is the profile name used to save the configuration
	Edtiion - It expects 'EE' for enterprise or 'CE' for community

Returns:
	none - .

=cut

sub updateProfileEdition
{
	my $name    = shift;
	my $edition = shift;

	use Config::Tiny;
	my $file = $Global::Profiles_path;

	my $Config = Config::Tiny->read( $file );
	$Config->{ $name }->{ edition } = $edition;

	$Config->write( $file );
}

=begin nd
Function: updateProfileLocal

	This function is used when the ZCLI is used from a load balancer. It overwrites the IP and port where the ZAPI is listening.

Parametes:
	none - .

Returns:
	none - .

=cut

sub updateProfileLocal
{
	my $prof_file = $Global::Profiles_path;
	my $Config =
	  ( -e $prof_file ) ? Config::Tiny->read( $prof_file ) : die $Global::Fin;

	# overwrite data. Maybe the http server cfg was changed
	my ( $localip, $localport ) = &getHttpServerConf();
	$Config->{ $Define::Profile_local }->{ host } = $localip;
	$Config->{ $Define::Profile_local }->{ port } = $localport;

	$Config->write( $prof_file );
}

=begin nd
Function: delProfile

	It removes a profile from the configuration file.

Parametes:
	Profile name - It is the profile nick name that is going to be deleted.

Returns:
	Integer - Error code: 0 on success or another value on failure.

=cut

sub delProfile
{
	my $name = shift;
	my $Config;
	my $file = $Global::Profiles_path;
	my $err  = 1;
	if ( -e $file )
	{
		$Config = Config::Tiny->read( $file );
		if ( exists $Config->{ $name } )
		{
			delete $Config->{ _ }->{ default_profile }
			  if $Config->{ _ }->{ default_profile } eq $name;

			delete $Config->{ $name };
			$Config->write( $file );
			$err = 0;
			&printSuccess( "The '$name' profile was unregistered from zcli", 0 );
		}
	}

	&printError( "The '$name' profile was not found" ) if $err;

	return $err;
}

=begin nd
Function: listProfiles

	It returns a list of the registered profile names.

Parametes:
	none - .

Returns:
	Array - It is a list with the profile names.

=cut

sub listProfiles
{
	my $file = $Global::Profiles_path;

	use Config::Tiny;
	my $Config = Config::Tiny->read( $file );

	return grep ( !/^_$/, keys %{ $Config } );
}

=begin nd
Function: getProfile

	It retrieves the configuration of a profile.

Parametes:
	Profile name - It is the name used to identify the profile.

Returns:
	Hash ref - Struct with the profile info. If the profile does not exist, the function will return undef
		{
			host => 192.168.100.241,
			name => devcano,
			port => 444,
			zapi_key => root,
			zapi_version => 4.0,
			edition => EE,
			description  => "Monitoring user to test lb1",
		}

=cut

sub getProfile
{
	my $profile_name = shift;
	my $conf_file    = $Global::Profiles_path;

	use Config::Tiny;
	my $Config = Config::Tiny->read( $conf_file );

	if ( !defined $profile_name )
	{
		$profile_name = $Config->{ _ }->{ default_profile };
		if ( !defined $profile_name )
		{
			&devMsg( "Warning, there is no default profile set" );
			return undef;
		}
	}
	elsif ( !exists $Config->{ $profile_name } )
	{
		print "The profile selected '$profile_name' does not exist\n";
		return undef;
	}

	return $Config->{ $profile_name };
}

=begin nd
Function: getHttpServerConf

	Looks for in the cherokee configuration file the IP and PORT directives. This is only useful
	if ZCLI is being executing in the load balancer.

Parametes:
	none - .

Returns:
	Array - The array contains two values: 1- the IP for the ZAPI HTTP service, 2- the port for the ZAPI HTTP service

=cut

sub getHttpServerConf
{
	my $port = $Define::LB_http_port;
	my $ip   = $Define::LB_http_ip;

	my $params = 0;    # when 2 params have been found
	open my $fh, "<", $Define::LB_http_cfg;
	while ( my $line = <$fh> )
	{
		if ( $line =~ /^\s*$Define::LB_http_ip_directive/ )
		{
			$params++;
			( undef, $ip ) = split ( "=", $line );
			$ip =~ s/\s//g;
			chomp ( $ip );
		}
		elsif ( $line =~ /^\s*$Define::LB_http_port_directive/ )
		{
			$params++;
			( undef, $port ) = split ( "=", $line );
			$port =~ s/\s//g;
			chomp ( $port );
		}
		last if $params == 2;
	}
	close $fh;

	return ( $ip, $port );
}

=begin nd
Function: checkConnectivity

	It check if the ZCLI has connectivity with the load balancer using the credential of the profile

Parametes:
	Profile struct - Profile struct reference. The profile struct must contains the following keys:
		name - Nick name of the load balancer.
		host - It is the management IP used to connect with the load balancer.
		port - It is the management port used to connect with the load balancer.

Returns:
	Integer - It returns: 1 if ZCLI has connectivity with the load balancer or 0 if it doesn't.

=cut

sub checkConnectivity
{
	my $profile = shift;

	require IO::Socket::INET;

	# test connectivity:
	IO::Socket::INET->new(
						   PeerAddr => $profile->{ host },
						   PeerPort => $profile->{ port },
						   Proto    => 'tcp',
						   Timeout  => $Define::Zapi_timeout
	  )
	  or do
	{
		&printError(
			"The '$profile->{name}' profile ($profile->{host}:$profile->{port}) cannot be reached."
		);
		return 0;
	};

	return 1;
}

=begin nd
Function: isLoadBalancer

	It checks if the host (where is running ZCLI) is a Zevenet load balancer.
	It looks at in the system if the zevenet package is installed.
	The Zevenet version must be upper than 'REQUIRED_ZEVEVENET_VERSION'.

Parametes:
	none - .

Returns:
	Integer - It returns: 1 if the host is a Zevenet load balancer, 0 if it doesn't.

=cut

sub isLoadBalancer
{
	return 0 if ( $Env::OS eq 'win' );

	my $cmd =
	  'dpkg -l 2>/dev/null |grep -E "\szevenet\s" | sed -E "s/ +/ /g" | cut -d " " -f3';
	my $version = `$cmd`;
	my $success = 0;
	if ( $version )
	{
		$cmd = 'dpkg -l 2>/dev/null |grep -E "\szevenet\s"';
		my $edition = `$cmd`;
		if (   ( $edition =~ 'Enterprise' and $version >= $Global::Req_zevenet_version )
			or ( $edition =~ 'Community' and $version >= $Global::Req_zevenet_version ) )
		{
			$success = 1;
		}
	}

	return $success;
}

1;
