#!/usr/bin/perl

use strict;
use feature "say";
use LWP::UserAgent;
use JSON;

use Storable qw(dclone);

use ZCLI::Define;
use ZCLI::Objects;

my $DEBUG = $Define::DEBUG;
my $FIN   = $Define::FIN;

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
Function: dev

	Function to print debug messages.

Parametes:
	String - String to print. Use 'Dumper($ref)' to print the value of a reference
	Tag - Short message to wrap the message
	lvl - The minimum log level to print the message

Returns:
	none - .

=cut

sub printHelp
{
	my $executed = shift
	  // 0;    # 1 when the help is printed for command line invocation

	print "\n";
	print
	  "ZCLI can be executed with the following options (the options are available at the moment of the invocation):\n";
	say "	-help: it prints this ZCLI help.";
	say
	  "	-host <name>: it selects the 'name' as destination load balancer of the command.";
	say "	-silence, -s: it executes the action without the human interaction.";

	print "\n";
	print "A ZCLI command uses the following arguments:\n";
	print "<object> <action> <id> <id2>... -param1 value [-param2 value]\n";
	print
	  "    'object' is the load balancer module over the command is going to be executed\n";
	print
	  "    'action' is the verb is going to be used. Each object has itself actions\n";
	print
	  "    'id' specify a object name inside of a module. For example a farm name, an interface name or blacklist name.\n";
	print
	  "         To execute some commands, it is necessary use more than one 'ids', to refer several objects that take part in the command.\n";
	print
	  "    'param value' some command need parameters. Theese parameters are indicated using the hyphen symbol '-' following with the param name, a black space and the param value.\n";
	print "\n";

	print
	  "ZCLI has an autocomplete feature. Pressing double <tab> to list the possible options for the current command\n";
	print
	  "If the autocomplete does not list more options, press <intro> to get further information\n";
	print "\n";

	print
	  "ZCLI is created using ZAPI (Zevenet API), so, to get descrition about the parameters, you can check the official documentation: \n";
	print "https://www.zevenet.com/zapidocv4.0/\n";
	print "\n";

	print "\n";
	print "Examples:\n";
	print "farms set gslbfarm -vport 53 -vip 10.0.0.20\n";
	print
	  "  This command is setting the virtual port 53 and the virtual IP 10.0.0.20 in a farm named gslbfarm\n";
	print "\n";
	print "network-virtual create -name eth0:srv -ip 192.168.100.32\n";
	print
	  "  This command is creating a virtual interface called eth0:srv that is using the IP 192.168.100.32\n";
	print "\n";

# 	print "$0 [-opt1 <val1> [..]] object order <id> -param1 value [-param2 value]";
# añadir:
# -js, js output, borrar todos los mensajes que no sean el json de respuesta
# -h,  host, cambia el host destinatario de la peticion. Añadir opcion para mandar a varios hosts a la vez
}

## Objects definitions

## Parse args

# pedir parametros de la uri
# preguntar por los objetos
# preguntar por los posibles valores
sub parseInput
{
	my $def  = shift;
	my @args = @_;

	my $input = {
				  object        => shift @args,
				  action        => shift @args,
				  id            => [],
				  uri_param     => [],
				  download_file => undef,
				  upload_file   => undef,
				  params        => undef,
	};

	for ( @{ $def->{ ids } } )
	{
		my $id = shift @args;
		push @{ $input->{ id } }, $id;
	}

	# adding uri parameters
	if ( exists $def->{ uri_param } )
	{
		my $uri = $def->{ uri };
		foreach my $p ( @{ $def->{ uri_param } } )
		{
			my $val = shift @args;
			my $tag = $Define::UriParamTag;
			if ( $uri =~ s/$tag/$val/ )
			{
				push @{ $input->{ uri_param } }, $val;
			}
			else
			{
				print "This command expects $p->{name}, $p->{desc}";
				die $FIN;
			}
		}
	}

	# check if the call is expecting a file name to upload or download
	$input->{ download_file } = shift @args if ( exists $def->{ 'download_file' } );
	$input->{ upload_file }   = shift @args if ( exists $def->{ 'upload_file' } );

	# json params
	my $param_flag = 0;
	my $index      = 0;
	for ( my $ind = 0 ; $ind <= $#args ; $ind++ )
	{
		# The value ';' is used to finish the current zcli command
		if ( $args[$ind] eq ';' )
		{
			next;
		}
		elsif ( $args[$ind] =~ s/^\-// )
		{
			$param_flag = 1;
			my $key = $args[$ind];
			my $val = $args[$ind + 1];
			$ind++;

			$input->{ params }->{ $key } = $val;
		}
		elsif ( $param_flag )
		{
			print
			  "Error parsing the parameters. The parameters have to have the following format:\n";
			print "   -param1-name param1-value -param2-name param2-value";
			die $FIN;
		}
	}

	&dev( Dumper( $input ), 'input parsed', 2 );

	return $input;
}

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
			elsif ( $opt eq '-host' and $args->[0] !~ /^-/ )
			{
				$opt_st->{ 'host' } = shift @{ $args };
			}
			else
			{
				say "The '$o' option is not recognized.";
				say "";
				&printHelp( 1 );
				exit 1;
			}
		}
	}

	return $opt_st;
}

## Validate args

sub checkInput
{
	my $obj   = shift;
	my $input = shift;
	my $host  = shift;
	my $def;
	my %call;

	# getting OBJECT
	$def = $obj->{ $input->{ object } };
	if ( !defined $def )
	{
		my @keys = keys %{ $obj };
		my $join = join ( ', ', @keys );
		if ( $input->{ object } )
		{
			print "The object '$input->{object}' is not valid";
		}
		else
		{
			print "No object was selected";
		}
		print ", please, try with: \n\t> ";
		print $join;
		print "\n";
		die $FIN;
	}

	# getting ACTION
	my $act_def = $def;
	$def = $def->{ $input->{ action } };
	if ( !defined $def )
	{
		my @keys = keys %{ $act_def };
		my $join = join ( ', ', @keys );
		if ( $input->{ action } )
		{
			print "The action '$input->{action}' is not valid";
		}
		else
		{
			print "No action was selected";
		}
		print ", please, try with: \n\t> ";
		print $join;
		print "\n";
		die $FIN;
	}

	# getting IDs
	{
		%call = %{ $def };

		my @ids = @{ $input->{ id } };

		foreach my $id ( @ids )
		{
			unless ( $call{ uri } =~ s/\<[\w -]+\>/$id/ )
			{
				print "The id '$id' was not expected\n";
				die $FIN;
			}
		}

		# error si falta algun id por sustituir
		if ( $call{ uri } =~ /\<([\w -]+)\>/ )
		{
			print "The id '$1' was not set";
			die $FIN;
		}
	}

	# getting uri parameters
	if ( exists $def->{ uri_param } )
	{
		my $tag = $Define::UriParamTag;
		foreach my $p ( @{ $input->{ uri_param } } )
		{
			unless ( $call{ uri } =~ s/$tag/$p/ )
			{
				print "Error replacing the param '$p'";
				die $FIN;
			}
		}
	}

	# getting upload file
	if ( exists $call{ upload_file } )
	{
		if ( !defined $input->{ upload_file } )
		{
			print "The file name to upload is not set";
			die $FIN;
		}
		if ( !-e $input->{ upload_file } )
		{
			print "The file '$input->{upload_file}' does not exist";
			die $FIN;
		}
		$call{ upload_file } = $input->{ upload_file };
	}

	# getting download file
	if ( exists $call{ download_file } )
	{
		if ( !defined $input->{ download_file } )
		{
			print "The file name to save the download is not set";
			die $FIN;
		}
		if ( -e $input->{ download_file } )
		{
			print "The file '$input->{download_file}' already exist, select another name";
			die $FIN;
		}
		$call{ download_file } = $input->{ download_file };
	}

	# get PARAMS
	if ( ( $call{ method } eq 'POST' or $call{ method } eq 'PUT' )
		 and !exists $call{ download_file }
		 or $call{ upload_file } )
	{
		say "?????? montando params";

		if ( exists $def->{ params } )
		{
			$call{ params } = $def->{ params };
		}

		else
		{
			$call{ params } = $input->{ params };
		}
	}

	&dev( Dumper( \%call ), "request sumary", 2 );

	return \%call;
}

sub checkUriParams
{
	my $uri_param = shift;
	my @params    = @_;
	my @p_out;
	if ( defined $uri_param )
	{
		foreach my $p ( @{ $uri_param } )
		{
			my $val = shift @params;
			my $tag = $Define::UriParamTag;
			unless ( $uri_param =~ s/$tag/$val/ )
			{
				push @p_out, undef;
				print "This command expects $p->{name}, $p->{desc}\n";
			}
		}
	}
	return @p_out;
}

=begin nd
Function: getLBIdsTree

	Gets and modify te load balancer IDs tree to adapt it to ZCLI.

Parametes:
	Host - It is a reference to a host object that contains the information about connecting with the load balancer

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
	if ( $resp->{ 'json' }->{ 'params' } )
	{
		$tree = $resp->{ 'json' }->{ 'params' };
		$tree->{ 'monitoring' }->{ 'fg' } = $tree->{ 'farmguardians' };
	}

	return $tree;
}

sub getIdValues
{
	my $tree     = shift;    # arbol de keys, va comprobandose recursivamente
	my $keys_arr = shift;    # claves que estoy buscando

	my %hash_recursive = %{ $tree };
	my $href           = \%hash_recursive;

	# look for the key
	foreach my $id ( @{ $keys_arr } )
	{
		return undef if !exists $href->{ $id };
		$href = $href->{ $id };
	}

	my @values = keys %{ $href };
	return \@values;
}

## ZAPI requests

=begin nd
Function: getUserAgent

	Initializate the HTTP client used to do action using the ZAPI

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

sub zapi
{
	my $arg  = shift;
	my $host = shift;

	&dev( Dumper( $arg ), 'req', 2 );

	# This is a workaround to manage l4 and datalink services.
	$arg->{ uri } =~ s|/services/_/|/|m;

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

	# tratamiento para descargar certs, backups...
	if ( exists $arg->{ 'download_file' } )
	{
		open ( my $download_fh, '>', $arg->{ 'download_file' } );
		{
			print $download_fh $response->content();
		}
		close $download_fh;

		$msg = "The file was properly saved in the file '$arg->{ 'download_file' }'.";
	}

	# tratamiento texto
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

	Get an URI and look for the parameters which expects.

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
	If the definition of the call has some predefined parameter, it is removed before doing de call.

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
				blank : 1
			}
		}

=cut

sub listParams
{
	my ( $obj_def, $obj, $act, $ids, $host ) = @_;

	my @args = ( $obj, $act, @{ $ids } );

	# remove predefined values
	my $predef_params = $Objects::Zcli->{ $obj }->{ $act }->{ params };
	delete $Objects::Zcli->{ $obj }->{ $act }->{ params };

	my $in_parsed = &parseInput( $Objects::Zcli->{ $obj }->{ $act }, @args );
	my $request =
	  &checkInput( $Objects::Zcli, $in_parsed, $host, $Env::HOST_IDS_TREE );

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
	$Objects::Zcli->{ $obj }->{ $act }->{ params } = $predef_params;

	$Env::CMD_PARAMS_DEF = {};
	foreach my $p ( @{ $params_ref } )
	{
		$Env::CMD_PARAMS_DEF->{ $p->{ name } }->{ possible_values } =
		  $p->{ possible_values }
		  if ( exists $p->{ possible_values } );

		my $blank = ( !( exists $p->{ regex } and exists $p->{ format } ) ) ? 1 : 0;
		$blank = 1
		  if (
			   $blank
			   and ( !exists $p->{ non_blank }
					 or ( exists $p->{ non_blank } and $p->{ non_blank } eq 'false' ) )
		  );
		$Env::CMD_PARAMS_DEF->{ $p->{ name } }->{ blank } = 1 if ( $blank );
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
		print "Info: $resp->{json}->{description}\n";
		delete $resp->{ json }->{ description };
	}

	if ( $resp->{ err } )
	{
		print "Error!! ";
		print "$resp->{msg}";
		print "\n";
	}
	else
	{
		if ( exists $resp->{ msg } and defined $resp->{ msg } )
		{
			print "$resp->{ msg }\n";
		}

		if ( exists $resp->{ txt } )
		{
			print "$resp->{txt}";
			print "\n";
		}

		if ( %{ $resp->{ json } } )
		{
			my $json_enc = "";
			eval {
				$json_enc = JSON::to_json( $resp->{ json }, { utf8 => 1, pretty => 1 } );
			};
			print "$json_enc" if ( $json_enc );
		}
	}
	print "\n";
}

## host

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
				say "A host name is required";
			}
			else
			{
				say "The '$hostname' host does not exist";
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
			print "Load balancer host name: ";
			$valid_flag = 1;
			$hostname   = <STDIN>;
			chomp $hostname;
			$cfg->{ NAME } = $hostname;
			if ( $hostname !~ /\S+/ )
			{
				$valid_flag = 0;
				say "Invalid name. It expects a string with the load balancer host name";
			}
			elsif ( exists $Config->{ $hostname } )
			{
				$valid_flag = 0;
				say "Invalid name. The '$hostname' host already exist";
			}
		} while ( !$valid_flag );
	}

	# get IP
	if ( $hostname ne $localname )
	{
		do
		{
			print "Load balancer management IP: ";
			print "[$set_msg: $cfg->{HOST}] " if not $new_flag;
			$valid_flag = 1;
			my $val = <STDIN>;
			chomp $val;
			$cfg->{ HOST } = $val unless ( $val eq "" and not $new_flag );
			unless ( $cfg->{ HOST } =~ /$ip_regex/ )
			{
				$valid_flag = 0;
				say "Invalid IP for load balancer. It expects an IP v4 or v6";
			}
		} while ( !$valid_flag );
	}

	# get port
	if ( $hostname ne $localname )
	{
		do
		{
			print "Load balancer management port: ";
			print "[$set_msg: $cfg->{PORT}] " if not $new_flag;
			$valid_flag = 1;
			my $val = <STDIN>;
			chomp $val;
			$cfg->{ PORT } = $val unless ( $val eq "" and not $new_flag );
			unless ( $cfg->{ PORT } > 0 and $cfg->{ PORT } <= 65535 )
			{
				$valid_flag = 0;
				say "Invalid PORT for load balancer. It expects a port between 1 and 65535";
			}
		} while ( !$valid_flag );
	}

	# get zapi key
	do
	{
		print "Load balancer zapi key: ";
		print "[$set_msg: $cfg->{ZAPI_KEY}] " if not $new_flag;
		$valid_flag = 1;
		my $val = <STDIN>;
		chomp $val;
		$cfg->{ ZAPI_KEY } = $val unless ( $val eq "" and not $new_flag );
		unless ( $cfg->{ ZAPI_KEY } =~ /\S+/ )
		{
			$valid_flag = 0;
			say "Invalid zapi key. It expects a string with the zapi key";
		}
	} while ( !$valid_flag );

	# get zapi version
	#	do
	#	{
	#		print "Load balancer zapi version: ";
	#		$valid_flag = 1;
	#		$cfg->{ ZAPI_VERSION } = <STDIN>;
	#		chomp $cfg->{ ZAPI_VERSION };
	#		unless ( $cfg->{ ZAPI_VERSION } =~ /^(4.0)$/ )
	#		{
	#			$valid_flag = 0;
	#			say
	#			  "Invalid zapi version. It expects once of the following versions: 4.0.";
	#		}
	#	} while ( !$valid_flag );
	$cfg->{ ZAPI_VERSION } = "4.0";

	$Config->{ $hostname } = $cfg;

	# set the default
	if ( !defined $Config->{ _ }->{ default_host } )
	{
		$Config->{ _ }->{ default_host } = $hostname;
		say "Saved as default profile";
	}
	elsif ( $Config->{ _ }->{ default_host } ne $hostname )
	{
		print "Do you wish set this host as the default one? [yes|no=default]: ";
		my $confirmation = <STDIN>;
		chomp $confirmation;
		if ( $confirmation =~ /^(y|yes)$/i )
		{
			$Config->{ _ }->{ default_host } = $hostname;
			say "Saved as default profile";
		}
	}
	say "";

	$Config->write( $hostfile );
	return $Config->{ $hostname };
}

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
			say "The '$name' host was unregistered from zcli";
		}
	}

	say "The '$name' host was not found" if $err;

	return $err;
}

sub listHost
{
	my $host_name = shift;
	my $hostfile  = $Global::hosts_path;

	use Config::Tiny;
	my $Config = Config::Tiny->read( $hostfile );

	return grep ( !/^_$/, keys %{ $Config } );
}

=begin nd
Function: hostInfo

	It returns an object with information about the host

Parametes:
	Host name - It is the name used to identify the host

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
		say "The '$host->{NAME}' host ($host->{HOST}:$host->{PORT}) cannot be reached.";
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
	  'dpkg -l |grep -E "\szevenet\s" | sed -E "s/ +/ /g" | cut -d " " -f3 2>/dev/null';
	my $version = `$cmd`;

	return ( !$version or $version < $Define::REQUIRED_ZEVEVENET_VERSION ) ? 0 : 1;
}

1;
