#!/usr/bin/perl

use strict;
use feature "say";
use LWP::UserAgent;
use JSON;

use Storable qw(dclone);

use ZCLI::Define;
use ZCLI::Objects;

my $FIN = $Global::FIN;

## Global functions

=begin nd
Function: dev

	Function to print debug messages.

Parametes:
	String - String to print. Use 'Dumper($ref)' to print the value of a reference
	Tag - Short message to wrap the message
	lvl - The minimum log level to print the message

Returns:
	none - .

=cut

sub dev
{
	my $st  = shift;
	my $tag = shift;
	my $lvl = shift // 1;

	chomp ( $st );

	return if ( $lvl > $Global::DEBUG );

	say "";
	say ">>>> Debug >>>> $tag" if $tag;
	print "$st\n";
	say "<<<<<<<<<<<<<<< $tag" if $tag;
	say "";
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
	my $err = shift // 0;

	my $msg = "
ZCLI can be executed with the following options (the options are available at the moment of the invocation):
	-help: it prints this ZCLI help.
	-host <name>: it selects the 'name' as destination load balancer of the command.
	-silence, -s: it executes the action without the human interaction.
	-json, -j: the parameters will be parsed as JSON. The silence flag will be activated automatically if this flag is enabled

A ZCLI command uses the following arguments:
<object> <action> <id> <id2>... -param1 value [-param2 value]
    'object' is the load balancer module over the command is going to be executed
    'action' is the verb is going to be used. Each object has itself actions
	      'id' specify a object name inside of a module. For example a farm name, an interface name or blacklist name.
	           To execute some commands, it is necessary use more than one 'ids', to refer several objects that take part in the command.
	      'param value' some command need parameters. Theese parameters are indicated using the hyphen symbol '-' following with the param name, a black space and the param value.

ZCLI has an autocomplete feature. Pressing double <tab> to list the possible options for the current command
If the autocomplete does not list more options, press <intro> to get further information

ZCLI is created using ZAPI (Zevenet API), so, to get descrition about the parameters, you can check the official documentation: 
https://www.zevenet.com/zapidocv4.0/

Examples:
farms set gslbfarm -vport 53 -vip 10.0.0.20
farms -j set gslbfarm '{\"vport\":53,\"vip\":\"10.0.0.20\"}'
  	This command is setting the virtual port 53 and the virtual IP 10.0.0.20 in a farm named gslbfarm

network-virtual create -name eth0:srv -ip 192.168.100.32
network-virtual create '{\"name\":\"eth0:srv\",\"ip\":\"192.168.100.32\"}'
	This command is creating a virtual interface called eth0:srv that is using the IP 192.168.100.32
";

	&printMsg( $msg, $err );
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
			die $Define::FIN;
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
	zcli [object] [action] [ids list] [ids_params list] [file_upload|download] [body_params lists]

Parametes:
	Object definition - It is a object hash with the parameters that defines a zapi call.
	Autocomplete - It is a flag to parses the arguments in the autocomplete step or when the zapi request is going to be done. The possible values are 1 or 0.
	Arguments - The rest of parameters are the input command arguments, the first one must be the 'object', next the 'action' and following the others arguments (IDS, uri_params, files and body_params).

Returns:
	Array - The first position is a hash with the arguments grouped by type.
			The second position is an string with the key of the folloing kind of required argument.
			The third position is a flag to return if the command was totally parsed. It the case than the command accepts body_params, the last phase will be the 'body_params'.

=cut

sub parseInput
{
	my $def          = shift;
	my $autocomplete = shift;    # 'autocomplete' = 1, 'check' = 0
	my @args         = @_;

	die "The variable 'autocomplete' in the function 'parseInput is invalid"
	  if ( $autocomplete != 0 and $autocomplete != 1 );

	my $steps = {
				  uri_id        => 'id',
				  uri_param     => 'uri_params',
				  download_file => 'download_file',
				  upload_file   => 'upload_file',
				  body_params   => 'body_params',
				  end           => 'end',
	};
	my $parsed_completed = 0;

	# remove the last item if it is blank
	pop @args if ( $autocomplete );

	my $input = {
				  object        => shift @args,
				  action        => shift @args,
				  id            => [],
				  uri_param     => [],
				  download_file => undef,
				  upload_file   => undef,
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
	if ( exists $def->{ uri_param } )
	{
		my $tag = $Define::UriParamTag;
		my $uri = $def->{ uri };
		foreach my $p ( @{ $def->{ uri_param } } )
		{
			my $val = shift @args;
			if ( defined $val )
			{
				if ( $uri =~ s/$tag/$val/ )
				{
					push @{ $input->{ uri_param } }, $val;
				}
				else
				{
					die $FIN;
				}
			}
			else
			{
				return ( $input, $steps->{ uri_param }, $parsed_completed );
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

	if (     !exists $def->{ 'upload_file' }
		 and !exists $def->{ 'download_file' }
		 and $def->{ method } =~ /POST|PUT/ )
	{
		if ( $Env::INPUT_JSON )
		{
			my $json_args = join ( '', @args );

			eval { $input->{ params } = JSON::decode_json( $json_args ); };
			if ( $@ )
			{
				&printError( "Error decoding the input JSON" );
				die $FIN;
			}

		}
		else
		{
			$parsed_completed = 0 if ( !exists $def->{ params } );

			$final_step = $steps->{ body_params };

			# json params
			my $param_flag = 0;
			my $index      = 0;
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
				elsif ( $param_flag )
				{
					$parsed_completed = 0;
					&printError(
						"Error parsing the parameters. The parameters have to have the following format:"
					);
					&printError( "  $Define::Description_param" );
					return ( $input, $final_step, $parsed_completed );
				}
			}
		}
	}

	&dev( Dumper( $input ), 'input parsed', 2 );
	return ( $input, $final_step, $parsed_completed );
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
			host => localhost,
			json => 1,
		};

=cut

sub parseOptions
{
	my $args   = $_[0];
	my $opt_st = {};

	# get options
	# the options are the parameters before object
	foreach my $o ( @{ $args } )
	{
		if ( $o !~ /^-/ )
		{
			# Run in silence mode if there are arguments in the execution
			$opt_st->{ silence } = 1;
			last;
		}
		else
		{
			my $opt = shift @{ $args };
			if ( $opt eq '-help' )
			{
				$opt_st->{ 'help' } = 1;
			}
			elsif ( $opt eq '-silence' or $opt eq '-s' )
			{
				$opt_st->{ 'silence' } = 1;
			}
			elsif ( $opt eq '-json' or $opt eq '-j' )
			{
				$opt_st->{ 'json' } = 1;
			}
			elsif ( $opt eq '-host' and $args->[0] !~ /^-/ )
			{
				$opt_st->{ 'host' } = shift @{ $args };
			}
			else
			{
				&printError( "The '$o' option is not recognized." );
				&printHelp( 1 );
				exit 1;
			}
		}
	}

	$Env::SILENCE    = 1 if exists $opt_st->{ silence };
	$Env::INPUT_JSON = 1 if exists $opt_st->{ json };

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
	if ( exists $def->{ uri_param } )
	{
		my $tag = $Define::UriParamTag;
		foreach my $p ( @{ $input->{ uri_param } } )
		{
			unless ( $call->{ uri } =~ s/$tag/$p/ )
			{
				&printError( "Error replacing the param '$p'" );
				die $FIN;
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

	&dev( Dumper( $call ), "request sumary", 2 );

	return $call;
}

=begin nd
Function: getLBIdsTree

	It gets and modifies the load balancer IDs tree to adapt it to ZCLI. This tree is used to the autocomplete feature of the IDs

Parametes:
	Host - It is a reference to a host object that contains the information about connecting with the load balancer.

Returns:
	Hash ref - It is a hash with the IDs tree

=cut

sub getLBIdsTree
{
	my $host = shift;

	my $request = {
					uri    => "/ids",
					method => 'GET',
	};
	my $resp = &zapi( $request, $host );

	#~ &dev(Dumper($resp),"id tree", 2);

	my $tree;

	if ( $resp->{ code } == 404 )
	{
		&printError(
			"Error connecting, ZCLI needs a load balancer with the version $Global::REQ_ZEVEVENET_VERSION or higher"
		);
	}
	elsif ( $resp->{ 'json' }->{ 'params' } )
	{
		$tree = $resp->{ 'json' }->{ 'params' };
		$tree->{ 'monitoring' }->{ 'fg' } = $tree->{ 'farmguardians' };
	}

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
	Host - It is a hash with information about the host. The possible keys are:
		HOST - It is the host IP or network hostname.
		PORT - It is the port of the ZAPI service.
		ZAPI_VERSION - It is the ZAPI verison used

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
	my $arg  = shift;
	my $host = shift;

	&dev( Dumper( $arg ), 'req', 2 );

	# This is a workaround to manage l4 and datalink services.
	$arg->{ uri } =~ s|/services/$Define::L4_SERVICE/|/|m;

	# create URL
	my $URL =
	  "https://$host->{HOST}:$host->{PORT}/zapi/v$host->{ZAPI_VERSION}/zapi.cgi$arg->{uri}";
	my $request = HTTP::Request->new( $arg->{ method } => $URL );

	# add zapikey
	my $ZAPI_KEY_HEADER = 'ZAPI-KEY';
	$request->header( $ZAPI_KEY_HEADER => $host->{ ZAPI_KEY } );    # auth: key

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

	#~ &dev( Dumper( $response ), 'HTTP response', 1 );

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
	*) The ZCLI zapikey is valid: using the ZCLI command with the arguments 'hosts set $host->{NAME}' to modify it.";
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
	Request - It is an request object that need the "zapi" function.
	Host - It is a host object with the information about connecting with the load balancer

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
			}
		}

=cut

sub listParams
{
	my ( $obj_def, $args_parsed, $host ) = @_;

	# remove predefined values
	my $predef_params = $obj_def->{ params };
	delete $obj_def->{ params };

	my $request =
	  &createZapiRequest( $obj_def, $args_parsed, $host, $Env::HOST_IDS_TREE );

	my $params_ref = &zapi( $request, $host )->{ json }->{ params };

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

	$Env::CMD_PARAMS_DEF = undef;
	if ( defined $params_ref )
	{
		$Env::CMD_PARAMS_DEF = {};
		foreach my $p ( @{ $params_ref } )
		{
			$Env::CMD_PARAMS_DEF->{ $p->{ name } }->{ required } = 1
			  if ( exists $p->{ options } and grep ( /^required$/, @{ $p->{ options } } ) );
			$Env::CMD_PARAMS_DEF->{ $p->{ name } }->{ exist } = 1;
			$Env::CMD_PARAMS_DEF->{ $p->{ name } }->{ possible_values } =
			  $p->{ possible_values }
			  if ( exists $p->{ possible_values } );
		}
	}

	return $Env::CMD_PARAMS_DEF;
}

=begin nd
Function: printOutput

	This function will print the output of the zapi, previously, giving it format

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

	&dev( Dumper( $resp ), "responsed json", 2 );

	if ( exists $resp->{ json }->{ description } )
	{
		&printSuccess( "Info: $resp->{json}->{description}" );
		delete $resp->{ json }->{ description };
	}

	if ( $resp->{ err } )
	{
		&printError( "Error! $resp->{msg}" );
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

		if ( %{ $resp->{ json } } )
		{
			delete $resp->{ msg } if exists $resp->{ msg };
			my $json_enc = "";
			eval {
				$json_enc = JSON::to_json( $resp->{ json }, { utf8 => 1, pretty => 1 } );
			};
			&printSuccess( "$json_enc", 0 ) if ( $json_enc );
		}
	}
	&printSuccess( "" );    # extra new line
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

	&printMsg( $msg, 0 ) unless ( $header and $Env::SILENCE );
}

## host

=begin nd
Function: setHost

	This function ask the HOST configuration to the user. It has two mode of working, one for creating a new host
	or another to modify it. The hosts are saved in the config file "$ENV{HOME}/.zcli/hosts.ini"

	There is a special host called 'localhost', this host is used when ZCLI is executed from the load balancer.
	Localhost only has a parameter (zapikey).

Parametes:
	host name - It is the nick of the hostname to create or modify. This parameter is empty if it is executed in creation mode.
	new host - It is a flag that creates a new host (value 0) or modify a host that exist (value 0). This flag manage which parameters are mandatory and allow to keep the old value.

Returns:
	Hash ref - It returns the host struct updated with the new values or undef if there is an error. The keys if the host struct are:
		ZAPI_VERSION, it is the ZAPI version used
		NAME, it is a nick name of the load balancer
		HOST, it is the IP or nameserver or the load balancer
		PORT, it is the ZAPI management port
		ZAPIKEY, it is the user key used for the ZAPI requests
		
	Example:
		$cfg = {
				 ZAPI_VERSION => "4.0",
				 NAME         => zevenet-lb-1,
				 HOST         => 192.168.100.254,
				 PORT         => 444,
				 ZAPI_KEY     => v2kl3QK658awg34qaQbaewba3wjnzdkfxGbqbwq4,
		}
=cut

sub setHost
{
	my $hostname = shift
	  ; # if there is HOSTNAME, the function will mofidy, else it will create a new one
	my $new_flag = shift // 1;
	my $hostfile = $Global::hosts_path;
	my $localname =
	  "localhost";    # it is the reserve word to modify the localhost host settings
	my $cfg;
	my $valid_flag = 1;

	my $set_msg = "Press 'intro' to keep the value";
	my $ip_regex =
	  '((^\s*((([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5]))\s*$)|(^\s*((([0-9A-Fa-f]{1,4}:){7}([0-9A-Fa-f]{1,4}|:))|(([0-9A-Fa-f]{1,4}:){6}(:[0-9A-Fa-f]{1,4}|((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){5}(((:[0-9A-Fa-f]{1,4}){1,2})|:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){4}(((:[0-9A-Fa-f]{1,4}){1,3})|((:[0-9A-Fa-f]{1,4})?:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){3}(((:[0-9A-Fa-f]{1,4}){1,4})|((:[0-9A-Fa-f]{1,4}){0,2}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){2}(((:[0-9A-Fa-f]{1,4}){1,5})|((:[0-9A-Fa-f]{1,4}){0,3}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){1}(((:[0-9A-Fa-f]{1,4}){1,6})|((:[0-9A-Fa-f]{1,4}){0,4}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(:(((:[0-9A-Fa-f]{1,4}){1,7})|((:[0-9A-Fa-f]{1,4}){0,5}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:)))(%.+)?\s*$))';

	# getting conf
	my $Config =
	  ( -e $hostfile ) ? Config::Tiny->read( $hostfile ) : Config::Tiny->new;

	# set values if the host is localhost
	if ( $hostname eq $localname )
	{
		# overwrite data. Maybe the http server cfg was changed
		my ( $localip, $localport ) = &getHttpServerConf();

		$cfg = {
				 ZAPI_VERSION => "4.0",
				 NAME         => $localname,
				 HOST         => $localip,
				 PORT         => $localport,
				 ZAPI_KEY     => $Config->{ $localname }->{ ZAPI_KEY } // '',
		};
	}

	# validating
	elsif ( !$new_flag )
	{
		if ( !exists $Config->{ $hostname } )
		{
			if ( !defined $hostname )
			{
				&printError( "A host name is required" );
			}
			else
			{
				&printError( "The '$hostname' host does not exist" );
			}
			return undef;
		}
		$cfg = $Config->{ $hostname };
	}

	## Get parameters
	# get name
	if ( $new_flag and $hostname ne $localname )
	{
		do
		{
			&printMsg( "Load balancer host name: " );
			$valid_flag = 1;
			$hostname   = <STDIN>;
			chomp $hostname;
			$cfg->{ NAME } = $hostname;
			if ( $hostname !~ /\S+/ )
			{
				$valid_flag = 0;
				&printError(
							 "Invalid name. It expects a string with the load balancer host name" );
			}
			elsif ( exists $Config->{ $hostname } )
			{
				$valid_flag = 0;
				&printError( "Invalid name. The '$hostname' host already exist" );
			}
		} while ( !$valid_flag );
	}

	# get IP
	if ( $hostname ne $localname )
	{
		do
		{
			&printMsg( "Load balancer management IP: " );
			&printMsg( "[$set_msg: $cfg->{HOST}] " ) if not $new_flag;
			$valid_flag = 1;
			my $val = <STDIN>;
			chomp $val;
			$cfg->{ HOST } = $val unless ( $val eq "" and not $new_flag );
			unless ( $cfg->{ HOST } =~ /$ip_regex/ )
			{
				$valid_flag = 0;
				&printError( "Invalid IP for load balancer. It expects an IP v4 or v6" );
			}
		} while ( !$valid_flag );
	}

	# get port
	if ( $hostname ne $localname )
	{
		do
		{
			&printMsg( "Load balancer management port: " );
			&printMsg( "[$set_msg: $cfg->{PORT}] " ) if not $new_flag;
			$valid_flag = 1;
			my $val = <STDIN>;
			chomp $val;
			$cfg->{ PORT } = $val unless ( $val eq "" and not $new_flag );
			unless ( $cfg->{ PORT } > 0 and $cfg->{ PORT } <= 65535 )
			{
				$valid_flag = 0;
				&printError(
						  "Invalid PORT for load balancer. It expects a port between 1 and 65535" );
			}
		} while ( !$valid_flag );
	}

	# get zapi key
	do
	{
		&printMsg( "Load balancer zapi key: " );
		&printMsg( "[$set_msg: $cfg->{ZAPI_KEY}] " ) if not $new_flag;
		$valid_flag = 1;
		my $val = <STDIN>;
		chomp $val;
		$cfg->{ ZAPI_KEY } = $val unless ( $val eq "" and not $new_flag );
		unless ( $cfg->{ ZAPI_KEY } =~ /\S+/ )
		{
			$valid_flag = 0;
			&printError( "Invalid zapi key. It expects a string with the zapi key" );
		}
	} while ( !$valid_flag );

# get zapi version
#	do
#	{
#		&printMsg ( "Load balancer zapi version: " );
#		$valid_flag = 1;
#		$cfg->{ ZAPI_VERSION } = <STDIN>;
#		chomp $cfg->{ ZAPI_VERSION };
#		unless ( $cfg->{ ZAPI_VERSION } =~ /^(4.0)$/ )
#		{
#			$valid_flag = 0;
#			&printError ( "Invalid zapi version. It expects once of the following versions: 4.0" );
#		}
#	} while ( !$valid_flag );
	$cfg->{ ZAPI_VERSION } = "4.0";

	$Config->{ $hostname } = $cfg;

	# set the default
	if ( !defined $Config->{ _ }->{ default_host } )
	{
		$Config->{ _ }->{ default_host } = $hostname;
		&printSuccess( "Saved as default profile", 0 );
	}
	elsif ( $Config->{ _ }->{ default_host } ne $hostname )
	{
		&printMsg( "Do you wish set this host as the default one? [yes|no=default]: " );
		my $confirmation = <STDIN>;
		chomp $confirmation;
		if ( $confirmation =~ /^(y|yes)$/i )
		{
			$Config->{ _ }->{ default_host } = $hostname;
			&printSuccess( "Saved as default profile" );
		}
	}
	&printSuccess( "" );

	$Config->write( $hostfile );
	return $Config->{ $hostname };
}

=begin nd
Function: refreshLocalHost

	This function is used when the ZCLI is used from a load balancer. It overwrites the IP and port where the ZAPI is listening.

Parametes:
	none - .

Returns:
	none - .
		
=cut

sub refreshLocalHost
{
	my $localname = "localhost";
	my $hostfile  = $Global::hosts_path;
	my $Config    = ( -e $hostfile ) ? Config::Tiny->read( $hostfile ) : die $FIN;

	# overwrite data. Maybe the http server cfg was changed
	my ( $localip, $localport ) = &getHttpServerConf();
	$Config->{ $localname }->{ HOST } = $localip;
	$Config->{ $localname }->{ PORT } = $localport;

	$Config->write( $hostfile );
}

=begin nd
Function: delHost

	It removes a host from the configuration file.

Parametes:
	host name - It is the host nick name that is going to be deleted.

Returns:
	Integer - Error code: 0 on success or another value on failure.
		
=cut

sub delHost
{
	my $name = shift;
	my $Config;
	my $hostfile = $Global::hosts_path;
	my $err      = 1;
	if ( -e $hostfile )
	{
		$Config = Config::Tiny->read( $hostfile );
		if ( exists $Config->{ $name } )
		{
			delete $Config->{ _ }->{ default_host }
			  if $Config->{ _ }->{ default_host } eq $name;

			delete $Config->{ $name };
			$Config->write( $hostfile );
			$err = 0;
			&printSuccess( "The '$name' host was unregistered from zcli", 0 );
		}
	}

	&printError( "The '$name' host was not found" ) if $err;

	return $err;
}

=begin nd
Function: listHost

	It returns a list of the registered host names.

Parametes:
	none - .

Returns:
	Array - It is a list with the host names.
		
=cut

sub listHost
{
	my $hostfile = $Global::hosts_path;

	use Config::Tiny;
	my $Config = Config::Tiny->read( $hostfile );

	return grep ( !/^_$/, keys %{ $Config } );
}

=begin nd
Function: hostInfo

	It retrieves the configuration of a host.

Parametes:
	Host name - It is the name used to identify the host.

Returns:
	Hash ref - Struct with the host info. If the host does not exist, the function will return undef
		{
			HOST => 192.168.100.241
			NAME => devcano
			PORT => 444
			ZAPI_KEY => root
			ZAPI_VERSION => 4.0
		}

=cut

sub hostInfo
{
	my $host_name = shift;
	my $hostfile  = $Global::hosts_path;

	use Config::Tiny;
	my $Config = Config::Tiny->read( $hostfile );

	if ( !defined $host_name )
	{
		$host_name = $Config->{ _ }->{ default_host };
		if ( !defined $host_name )
		{
			&dev( "Warning, there is no default host set\n" );
			return undef;
		}
	}
	elsif ( !exists $Config->{ $host_name } )
	{
		print "The host selected does not exist\n";
		return undef;
	}

	return $Config->{ $host_name };
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
	my $confhttp = "/usr/local/zevenet/app/cherokee/etc/cherokee/cherokee.conf";

	# read line matching 'server!bind!1!port = 444'
	my $ip_directive   = 'server!bind!1!interface';
	my $port_directive = 'server!bind!1!port';

	my $port = 444;
	my $ip   = "127.0.0.1";

	my $params = 0;    # when 2 params have been found
	open my $fh, "<", "$confhttp";
	while ( my $line = <$fh> )
	{
		if ( $line =~ /^\s*$ip_directive/ )
		{
			$params++;
			my ( undef, $ip ) = split ( "=", $line );
			$ip =~ s/\s//g;
			chomp ( $ip );
		}
		elsif ( $line =~ /^\s*$port_directive/ )
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
Function: check_connectivity

	It checks if the host where is running ZCLI is a Zevenet load balancer.
	It looks at in the system if the zevenet package is installed.
	The Zevenet version must be upper than 'REQUIRED_ZEVEVENET_VERSION'.

Parametes:
	Host - Host reference. The host struct must contains the following keys:
		NAME - Nick name of the load balancer.
		HOST - It is the management IP used to connect with the load balancer.
		PORT - It is the management port used to connect with the load balancer.

Returns:
	Integer - It returns: 1 if ZCLI has connectivity with the load balancer or 0 if it doesn't.

=cut

sub check_connectivity
{
	my $host = shift;

	require IO::Socket::INET;

	# test connectivity:
	my $sock = IO::Socket::INET->new(
									  PeerAddr => $host->{ HOST },
									  PeerPort => $host->{ PORT },
									  Proto    => 'tcp',
									  Timeout  => 8
	  )
	  or do
	{
		&printError(
			  "The '$host->{NAME}' host ($host->{HOST}:$host->{PORT}) cannot be reached." );
		return 0;
	};

	return 1;
}

=begin nd
Function: check_is_lb

	It checks if the host where is running ZCLI is a Zevenet load balancer.
	It looks at in the system if the zevenet package is installed.
	The Zevenet version must be upper than 'REQUIRED_ZEVEVENET_VERSION'.

Parametes:
	none - .

Returns:
	Integer - It returns: 1 if the host is a Zevenet load balancer, 0 if it doesn't.

=cut

sub check_is_lb
{
	my $cmd =
	  'dpkg -l 2>/dev/null |grep -E "\szevenet\s" | sed -E "s/ +/ /g" | cut -d " " -f3';
	my $version = `$cmd`;

	return ( !$version or $version < $Global::REQ_ZEVEVENET_VERSION ) ? 0 : 1;
}

1;
