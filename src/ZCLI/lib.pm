#!/usr/bin/perl

use strict;
use feature "say";
use LWP::UserAgent;
use JSON;

use ZCLI::Define;
use ZCLI::Objects;

my $zcli_dir = "$ENV{HOME}/.zcli";
my $zcli_history = "$zcli_dir/zcli-history";
my $HOST_FILE = "$zcli_dir/hosts.ini";

my $DEBUG = $Define::DEBUG;
my $FIN = $Define::FIN;

sub getZcliDir
{
	return $zcli_dir;
}


sub getZcliHistoryPath
{
	return $zcli_history;
}

# pedir parametros de la uri
# preguntar por los objetos
# preguntar por los posibles valores
sub parseInput
{
	my $def = shift;
	my @args = @_;

	my $input = {
				  object => shift @args,
				  action => shift @args,
				  id     => [],
				  uri_param   => [],
				  download_file => undef,
				  upload_file => undef,
				  params => undef,
	};

	for (@{$def->{ids}})
	{
		my $id = shift @args;
		push @{ $input->{ id } }, $id;
	}

	# adding uri parameters
	if (exists $def->{uri_param})
	{
		my $uri = $def->{uri};
		foreach my $p (@{$def->{uri_param}})
		{
			my $val = shift @args;
			my $tag = $Define::UriParamTag;
			if ($uri =~ s/$tag/$val/)
			{
				push @{$input->{ uri_param }}, $val;
			}
			else
			{
				print "This command expects $p->{name}, $p->{desc}";
				die $FIN;
			}
		}
	}

	# check if the call is expecting a file name to upload or download
	$input->{download_file} = shift @args if ( exists $def->{ 'download_file' } );
	$input->{upload_file} = shift @args if ( exists $def->{ 'upload_file' } );

	# json params
	my $param_flag = 0;
	my $index      = 0;
	for ( my $ind = 0 ; $ind <= $#args ; $ind++ )
	{
		if ( $args[$ind] =~ s/^\-// )
		{
			$param_flag = 1;
			my $key = $args[$ind];
			my $val = $args[$ind + 1];
			$ind++;

			$input->{ params }->{ $key } = $val;
		}
		elsif ( $param_flag )
		{
			print "Error parsing the parameters. The parameters have to have the following format:\n";
			print "   -param1-name param1-value -param2-name param2-value";
			die $FIN;
		}
	}

	&dev( Dumper( $input ), 'input parsed', 2 );

	return $input;
}

sub parseOptions
{
	my $args = $_[0];
	my $opt_st = {};

	# get options
	# the options are the parameters before object
	foreach my $o (@{$args})
	{
		if ( $o !~ /^-/ )
		{
			last;
		}
		else
		{
			my $opt = shift @{$args};
			if ($opt eq '-help')
			{
				$opt_st->{'help'} = 1;
			}
			elsif ($opt eq '-silence' or $opt eq '-s')
			{
				$opt_st->{'silence'} = 1;
			}
			elsif ($opt eq '-host' and $args->[0] !~ /^-/)
			{
				$opt_st->{'host'} = shift @{$args};
			}
			else
			{
				say "The '$o' option is not recognized.";
				say "";
				&printHelp(1);
				exit 1;
			}
		}
	}

	return $opt_st;
}

sub printHelp
{
	my $executed = shift // 0; # 1 when the help is printed for command line invocation

	if ($executed)
	{
		print "\n";
		print "ZCLI can be executed with the following options:\n";
		say "	-help: it prints this ZCLI help.";
		say "	-host <name>: it selects the 'name' load balancer as destination of the command.";
		say "	-silence, -s: it executes the action without the human interaction.";
	}
	print "\n";
	print "A ZCLI command uses the following arguments:\n";
	print "<object> <action> <id> <id2>... -param1 value [-param2 value]\n";
	print "    'object' is the load balancer module over the command is going to be executed\n";
	print "    'action' is the verb is going to be used. Each object has itself actions\n";
	print "    'id' specify a object name inside of a module. For example a farm name, an interface name or blacklist name.\n";
	print "         To execute some commands, it is necessary use more than one 'ids', to refer several objects that take part in the command.\n";
	print "    'param value' some command need parameters. Theese parameters are indicated using the hyphen symbol '-' following with the param name, a black space and the param value.\n";
	print "\n";

	print "ZCLI has an autocomplete feature. Pressing double <tab> to list the possible options for the current command\n";
	print "If the autocomplete does not list more options, press <intro> to get further information\n";
	print "\n";

	print "ZCLI is created using ZAPI (Zevenet API), so, to get descrition about the parameters, you can check the official documentation: \n";
	print "https://www.zevenet.com/zapidocv4.0/\n";
	print "\n";

	print "\n";
	print "Examples:\n";
	print "farms set gslbfarm -vport 53 -vip 10.0.0.20\n";
	print "  This command is setting the virtual port 53 and the virtual IP 10.0.0.20 in a farm named gslbfarm\n";
	print "\n";
	print "network-virtual create -name eth0:srv -ip 192.168.100.32\n";
	print "  This command is creating a virtual interface called eth0:srv that is using the IP 192.168.100.32\n";
	print "\n";


# 	print "$0 [-opt1 <val1> [..]] object order <id> -param1 value [-param2 value]";
# añadir:
# -h, help
# -js, js output, borrar todos los mensajes que no sean el json de respuesta
# -o, output, mandar la salida a un fichero. util para descargar backups, certs...
# -h,  host, cambia el host destinatario de la peticion. Añadir opcion para mandar a varios hosts a la vez
# -c, conf info. modifica la conf de un host

	die $FIN;
}

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
	if (exists $def->{uri_param})
	{
		my $tag = $Define::UriParamTag;
		foreach my $p (@{$input->{ uri_param }})
		{
			unless ($call{uri} =~ s/$tag/$p/)
			{
				print "Error replacing the param '$p'";
				die $FIN;
			}
		}
	}

	# getting upload file
	if (exists $call{ upload_file })
	{
		if ( ! defined $input->{upload_file} )
		{
			print "The file name to upload is not set";
			die $FIN;
		}
		if ( !-e $input->{upload_file})
		{
			print "The file '$input->{upload_file}' does not exist";
			die $FIN;
		}
		$call{ upload_file } = $input->{upload_file};
	}

	# getting download file
	if (exists $call{ download_file })
	{
		if ( ! defined $input->{download_file} )
		{
			print "The file name to save the download is not set";
			die $FIN;
		}
		if ( -e $input->{download_file})
		{
			print "The file '$input->{download_file}' already exist, select another name";
			die $FIN;
		}
		$call{ download_file } = $input->{download_file};
	}

	# get PARAMS
	if ( ($call{ method } eq 'POST' or $call{ method } eq 'PUT') and !exists $call{download_file} or $call{upload_file})
	{
# decidir aqui que hacer, si quitar los parametros para que la llamada
# busque los parametros necesarios, o saltarse la comprobacion si la llamada tiene algun parametro predefinido
		if ( exists $def->{ params } )
		{
			$call{ params } = $def->{ params };
		}

		# get possible params
		elsif ( !defined $input->{ params } and ! exists $def->{content_type} )
		{
			my $params = &listParams( \%call, $host );
			if ( ref $params eq 'ARRAY' )
			{
				my $join = join ( ', ', @{ $params } );
				print "The list of possible parameters are: \n\t> ";
				print $join;
				die $FIN;
			}
			else
			{
				print "Error: $params\n";
			}
		}
		else
		{
			$call{ params } = $input->{ params };
		}
	}

	&dev( Dumper( \%call ), "request sumary", 2 );

	return \%call;
}

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

# parsear posibles parametros de la peticion
sub parseInputParams
{

}

sub checkUriParams
{
	my $uri_param = shift;
	my @params = @_;
	my @p_out;
	if (defined $uri_param)
	{
		foreach my $p (@{$uri_param})
		{
			my $val = shift @params;
			my $tag = $Define::UriParamTag;
			unless ($uri_param =~ s/$tag/$val/)
			{
				push @p_out, undef;
				print "This command expects $p->{name}, $p->{desc}\n";
			}
		}
	}
	return @p_out;
}

sub listParams
{
	my $request = shift;
	my $host    = shift;

	my $resp = &zapi( $request, $host );
	my @params;

	if ( exists $resp->{ json }->{ params } )
	{
		foreach my $p ( @{ $resp->{ json }->{ params } } )
		{
			push @params, $p->{ name };
		}
	}
	elsif ( $resp->{ err } )
	{
		my $msg =
		  ( $resp->{ json }->{ message } )
		  ? $resp->{ json }->{ message }
		  : "";
		  #~ : "Action is not valid";
		return $msg;
	}
	return \@params;
}

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
	if ($resp->{ 'json' }->{ 'params' })
	{
		$tree = $resp->{ 'json' }->{ 'params' };
		$tree->{'monitoring'}->{'fg'} = $tree->{'farmguardians'};
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


sub create_description
{
	my $object_st = shift;
	my $obj = shift;
	my $act = shift;

	return "$obj" if not defined $act;

	my $def = $object_st->{ $obj }->{ $act };

	# action object @ids @uri_param @file @params
	my $msg = "$obj $act";
	my $params = 1;

	my @ids = &getIds($def->{uri});
	if (@ids)
	{
		$msg .= " <$_>" for @ids;
	}
	if (exists $def->{uri_param})
	{
		$msg .= " <$_->{name}>" for @{$def->{uri_param}};
	}
	if (exists $def->{upload_file})
	{
		$msg .= " <file_path>";
		$params = 0;
	}
	if (exists $def->{download_file})
	{
		$msg .= " <file_path>";
		$params = 0;
	}
	if ($def->{method} =~ /^POST|PUT$/ and
		not exists $def->{params} and
		$params )
	{
		$msg .= " [-param_name param_value ...]";
	}

	return $msg;
}

my $ua = getUserAgent();

sub getUserAgent
{
	$ua = LWP::UserAgent->new(
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
	$arg->{uri} =~ s|/services/_/|/|m;

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
		$arg->{content_type} = $arg->{content_type} // 'application/json';
		$request->content_type( $arg->{content_type} );

		# sending data in binary
		if ($arg->{content_type} eq 'application/gzip')
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
		elsif (exists $arg->{upload_file})
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
	elsif ($response->header('content-type') =~ 'text/plain')
	{
		$txt = $response->content();
	}
	else
	{
		eval { $json_dec = JSON::decode_json( $response->content() ); };
		if (exists $json_dec->{message})
		{
			$msg = $json_dec->{message};
			delete $json_dec->{message};
		}
	}

	# add message for error 500
	if ($response->code =~ /^5/)
	{
		$msg = "LB error. The command could not finish";
	}

	# create a enviorement variable with the body of the last zapi result.
	# if it is a error, put a blank ref.
	my $out = {
				'code' => $response->code,
				'json' => $json_dec,
				'msg' => $msg,
				'err'  => ( $response->code =~ /^2/ ) ? 0 : 1,
	};

	$out->{txt} = $txt if defined $txt;

	return $out;
}

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
		if (exists $resp->{ msg } and defined $resp->{ msg })
		{
			print "$resp->{ msg }\n";
		}

		if (exists $resp->{txt})
		{
			print "$resp->{txt}";
			print "\n";
		}

		if (%{$resp->{ json }})
		{
			my $json_enc = "";
			eval {
				$json_enc = JSON::to_json( $resp->{ json }, { utf8 => 1, pretty => 1 } );
			};
			print "$json_enc" if ($json_enc);
		}
	}
	print "\n";
}

sub setHost
{
	my $HOSTNAME = shift;	# if there is HOSTNAME, the function will mofidy, else it will create a new one
	my $new_flag = shift // 1;

	my $set_msg = "Press 'intro' to keep the value";
	my $ip_regex =
	  '((^\s*((([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5]))\s*$)|(^\s*((([0-9A-Fa-f]{1,4}:){7}([0-9A-Fa-f]{1,4}|:))|(([0-9A-Fa-f]{1,4}:){6}(:[0-9A-Fa-f]{1,4}|((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){5}(((:[0-9A-Fa-f]{1,4}){1,2})|:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){4}(((:[0-9A-Fa-f]{1,4}){1,3})|((:[0-9A-Fa-f]{1,4})?:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){3}(((:[0-9A-Fa-f]{1,4}){1,4})|((:[0-9A-Fa-f]{1,4}){0,2}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){2}(((:[0-9A-Fa-f]{1,4}){1,5})|((:[0-9A-Fa-f]{1,4}){0,3}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){1}(((:[0-9A-Fa-f]{1,4}){1,6})|((:[0-9A-Fa-f]{1,4}){0,4}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(:(((:[0-9A-Fa-f]{1,4}){1,7})|((:[0-9A-Fa-f]{1,4}){0,5}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:)))(%.+)?\s*$))';

	my $valid_flag = 1;

	# getting conf
	my $Config = (-e $HOST_FILE) ? Config::Tiny->read( $HOST_FILE ) : Config::Tiny->new;

	# validating
	my $cfg;
	if (!$new_flag )
	{
		if (!exists $Config->{$HOSTNAME})
		{
			if (!defined $HOSTNAME)
			{
				say "A host name is required";
			}
			else
			{
				say "The '$HOSTNAME' host does not exist";
			}
			return undef;
		}
		$cfg = $Config->{$HOSTNAME};
	}

	# get name
	if ($new_flag)
	{
		do
		{
			print "Load balancer host name: ";
			$valid_flag = 1;
			$HOSTNAME   = <STDIN>;
			chomp $HOSTNAME;
			$cfg->{ name } = $HOSTNAME;
			if ( $HOSTNAME !~ /\S+/ )
			{
				$valid_flag = 0;
				say
				  "Invalid name. It expects a string with the load balancer host name";
			}
			elsif ( exists $Config->{$HOSTNAME} )
			{
				$valid_flag = 0;
				say
				  "Invalid name. The '$HOSTNAME' host already exist";
			}
		} while ( !$valid_flag );
	}

	# get IP
	do
	{
		print "Load balancer management IP: ";
		print "[$set_msg: $cfg->{HOST}] " if not $new_flag;
		$valid_flag = 1;
		my $val = <STDIN>;
		chomp $val;
		$cfg->{ HOST } = $val unless ($val eq "" and not $new_flag) ;
		unless ( $cfg->{ HOST } =~ /$ip_regex/ )
		{
			$valid_flag = 0;
			say "Invalid IP for load balancer. It expects an IP v4 or v6";
		}
	} while ( !$valid_flag );

	# get port
	do
	{
		print "Load balancer management port: ";
		print "[$set_msg: $cfg->{PORT}] " if not $new_flag;
		$valid_flag = 1;
		my $val = <STDIN>;
		chomp $val;
		$cfg->{ PORT } = $val unless ($val eq "" and not $new_flag) ;
		unless ( $cfg->{ PORT } > 0 and $cfg->{ PORT } <= 65535 )
		{
			$valid_flag = 0;
			say "Invalid PORT for load balancer. It expects a port between 1 and 65535";
		}
	} while ( !$valid_flag );

	# get zapi key
	do
	{
		print "Load balancer zapi key: ";
		print "[$set_msg: $cfg->{ZAPI_KEY}] " if not $new_flag;
		$valid_flag = 1;
		my $val = <STDIN>;
		chomp $val;
		$cfg->{ ZAPI_KEY } = $val unless ($val eq "" and not $new_flag) ;
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


	$Config->{$HOSTNAME} = $cfg;

	# set the default
	if (defined $Config->{ _ }->{ default_host } and $Config->{ _ }->{ default_host } ne $HOSTNAME)
	{
		if ( !defined $Config->{ _ }->{ default_host } )
		{
			$Config->{ _ }->{ default_host } = $HOSTNAME;
			say "Saved as default profile";
		}
		else
		{
			print "Do you wish set this host as the default one? [yes|no=default]: ";
			my $confirmation = <STDIN>;
			chomp $confirmation;
			if ( $confirmation =~ /^(y|yes)$/i )
			{
				$Config->{ _ }->{ default_host } = $HOSTNAME;
				say "Saved as default profile";
			}
		}
	}
	say "";

	$Config->write($HOST_FILE);
	return $Config->{ $HOSTNAME };
}

sub delHost
{
	my $name = shift;
	my $Config;
	my $err = 1;
	if (-e $HOST_FILE)
	{
		$Config = Config::Tiny->read( $HOST_FILE );
		if( exists $Config->{$name})
		{
			delete $Config->{_}->{default_host} if $Config->{_}->{default_host} eq $name;

			delete $Config->{$name};
			$Config->write($HOST_FILE);
			$err = 0;
			say "The '$name' host was unregister from zcli";
		}
	}

	say "The '$name' host was not found" if $err;

	return $err;
}

sub listHost
{
	my $host_name = shift;

	use Config::Tiny;
	my $Config = Config::Tiny->read( $HOST_FILE );

	return grep ( !/^_$/, keys %{$Config});
}

sub hostInfo
{
	my $host_name = shift;

	use Config::Tiny;
	my $Config = Config::Tiny->read( $HOST_FILE );

	if ( !defined $host_name )
	{
		$host_name = $Config->{ _ }->{ default_host };
		if ( !defined $host_name )
		{
			print "Warning, there is no default host set\n";
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

sub dev
{
	my $st  = shift;
	my $tag = shift;
	my $lvl = shift // 1;

	chomp ( $st );

	return if ( $lvl > $Global::DEBUG );

	say "";
	say ">>>> Debug >>>> $tag";
	print "$st\n";
	say "<<<<<<<<<<<<<<< $tag";
	say "";

}

sub check_connectivity
{
	my $host = shift;

	# test connectivity:
	if (system("nmap $host->{HOST} -p $host->{PORT} | grep open 2>&1 >/dev/null"))
	{
		say "The '$host->{name}' host ($host->{HOST}:$host->{PORT}) cannot be reached.";
		return 0;
	}
	return 1;
}

1;
