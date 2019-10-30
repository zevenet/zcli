#!/usr/bin/perl

use strict;
use feature "say";
use LWP::UserAgent;
use JSON;

require "./Define.pm";
require "./Objects.pm";

# pedir parametros de la uri

# preguntar por los objetos

# preguntar por los posibles valores
sub parseInput
{
	my @args = @_;

	my $input = {
				  object => shift @args,
				  action => shift @args,
				  id     => [],
				  params => undef,
	};

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
			die "Error parsing IDs and parameters";
		}
		else
		{
			push @{ $input->{ id } }, $args[$ind];
		}
	}

	&dev( Dumper( $input ), 'input parsed', 2 );

	return $input;
}

sub parseOptions
{

}

sub printHelp
{
	# ??? mientras se crea el autocompletado
	print "$0 [-opt1 <val1> [..]] object order <id> -param1 value [-param2 value]";
	print "\n";

# añadir:
# -h, help
# -js, js output, borrar todos los mensajes que no sean el json de respuesta
# -o, output, mandar la salida a un fichero. util para descargar backups, certs...
# -h,  host, cambia el host destinatario de la peticion. Añadir opcion para mandar a varios hosts a la vez
# -c, conf info. modifica la conf de un host

	use Data::Dumper;
	print Dumper $Objects::zcli_objects;
	die "";
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
		die "";
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
		die "";
	}

	# getting IDs
	{
		%call = %{ $def };

		my @ids = @{ $input->{ id } };

		foreach my $id ( @ids )
		{
			unless ( $call{ uri } =~ s/\<[\w -]+\>/$id/ )
			{
				die "The id '$id' was not expected";
			}
		}

		# error si falta algun id por sustituir
		if ( $call{ uri } =~ /\<([\w -]+)\>/ )
		{
			die "The id '$1' was not set";
		}
	}

	# get PARAMS
	if ( $call{ method } eq 'POST' or $call{ method } eq 'PUT' )
	{
# decidir aqui que hacer, si quitar los parametros para que la llamada
# busque los parametros necesarios, o saltarse la comprobacion si la llamada tiene algun parametro predefinido
		if ( exists $def->{ params } )
		{
			$call{ params } = $def->{ params };
		}

		# get possible params
		elsif ( !defined $input->{ params } )
		{
			my $params = &listParams( \%call, $host );
			if ( ref $params eq 'ARRAY' )
			{
				my $join = join ( ', ', @{ $params } );
				print "The list of possible parameters are: \n\t> ";
				print $join;
				print "\n";
				die "\n";    # the "\n" character remove the msg "Died at ./lib.pm line 188."
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
		  : "Action do not valid";
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

	my $tree = $resp->{ 'json' }->{ 'params' };
	$tree->{'monitoring'}->{'fg'} = $tree->{'farmguardians'};

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

# Devuelve:
# array ref, si encuentra el id
# undef, si no encuentra el id
#~ sub getIdValues
#~ {
#~ my $tree = shift;	# arbol de keys, va comprobandose recursivamente
#~ my $key = shift;	# clave que estoy buscando

#~ # look for the key
#~ foreach my $id (keys %{$tree})
#~ {
#~ # found
#~ if ( $key eq $id )
#~ {
#~ &dev("found");
#~ my @params = keys ${$tree->{$id}};
#~ return \@paramss;
#~ }
#~ # look for recursive
#~ elsif (defined $tree->{$key})
#~ {
#~ my $params = &getIdValues($tree->{$id}, $key);
#~ return $params if (defined $params);
#~ }
#~ }

#~ return undef;
#~ }

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
		if ( !defined $arg->{ params } )
		{
			$arg->{ params } = {};
		}
		$request->content_type( 'application/json' );
		$request->content( JSON::encode_json( $arg->{ params } ) );

		#???  Check others headers to upload data
		#~ $request->content_type( 'text/plain' );
		#~ $request->content_type( 'application/x-pem-file' );
		#~ $request->content_type( 'application/gzip' );
	}

	my $response = $ua->request( $request );

	#~ &dev( Dumper( $response ), 'HTTP response', 3 );

	# ???? añadir tratamiento para descargar certs, backups...

	my $json_dec;
	eval { $json_dec = JSON::decode_json( $response->content() ); };

	# create a enviorement variable with the body of the last zapi result.
	# if it is a error, put a blank ref.

	my $out = {
				'code' => $response->code,
				'json' => $json_dec,
				'err'  => ( $response->code =~ /^2/ ) ? 0 : 1,
	};
	return $out;
}

sub printOutput
{
	my $resp = shift;

	&dev( Dumper( $resp ), "responsed json", 2 );

	if ( exists $resp->{ json }->{ description } )
	{
		print "Info: $resp->{json}->{description}\n\n";
		delete $resp->{ json }->{ description };
	}

	if ( $resp->{ err } )
	{
		print "Error!! ";
		print "$resp->{json}->{message}";
		print "\n\n";
	}
	else
	{
		if ( exists $resp->{ json }->{ message } )
		{
			print "Info: $resp->{json}->{message}\n\n";
			delete $resp->{ json }->{ message };
		}

		my $json_enc = "";
		eval {
			$json_enc = JSON::to_json( $resp->{ json }, { utf8 => 1, pretty => 1 } );
		};
		print "$json_enc\n\n";
	}
}

sub setHost
{
	my $ip_regex =
	  '((^\s*((([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5]))\s*$)|(^\s*((([0-9A-Fa-f]{1,4}:){7}([0-9A-Fa-f]{1,4}|:))|(([0-9A-Fa-f]{1,4}:){6}(:[0-9A-Fa-f]{1,4}|((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){5}(((:[0-9A-Fa-f]{1,4}){1,2})|:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3})|:))|(([0-9A-Fa-f]{1,4}:){4}(((:[0-9A-Fa-f]{1,4}){1,3})|((:[0-9A-Fa-f]{1,4})?:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){3}(((:[0-9A-Fa-f]{1,4}){1,4})|((:[0-9A-Fa-f]{1,4}){0,2}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){2}(((:[0-9A-Fa-f]{1,4}){1,5})|((:[0-9A-Fa-f]{1,4}){0,3}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(([0-9A-Fa-f]{1,4}:){1}(((:[0-9A-Fa-f]{1,4}){1,6})|((:[0-9A-Fa-f]{1,4}){0,4}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:))|(:(((:[0-9A-Fa-f]{1,4}){1,7})|((:[0-9A-Fa-f]{1,4}){0,5}:((25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)(\.(25[0-5]|2[0-4]\d|1\d\d|[1-9]?\d)){3}))|:)))(%.+)?\s*$))';
	my $cfg;
	my $HOSTNAME;
	my $valid_flag = 1;

	# get IP
	do
	{
		print "Load balancer management IP: ";
		$valid_flag = 1;
		$cfg->{ HOST } = <STDIN>;
		chomp $cfg->{ HOST };
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
		$valid_flag = 1;
		$cfg->{ PORT } = <STDIN>;
		chomp $cfg->{ PORT };
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
		$valid_flag = 1;
		$cfg->{ ZAPI_KEY } = <STDIN>;
		chomp $cfg->{ ZAPI_KEY };
		unless ( $cfg->{ ZAPI_KEY } =~ /\S+/ )
		{
			$valid_flag = 0;
			say "Invalid zapi key. It expects a string with the zapi key";
		}
	} while ( !$valid_flag );

	# get zapi version
	do
	{
		print "Load balancer zapi version: ";
		$valid_flag = 1;
		$cfg->{ ZAPI_VERSION } = <STDIN>;
		chomp $cfg->{ ZAPI_VERSION };
		unless ( $cfg->{ ZAPI_VERSION } =~ /^(3.1|3.2|4.0)$/ )
		{
			$valid_flag = 0;
			say
			  "Invalid zapi version. It expects once of the following versions: 3.1, 3.2 or 4.0.";
		}
	} while ( !$valid_flag );

	# get zapi key
	do
	{
		print "Load balancer host name: ";
		$valid_flag = 1;
		$HOSTNAME   = <STDIN>;
		chomp $HOSTNAME;
		unless ( $HOSTNAME =~ /\S+/ )
		{
			$valid_flag = 0;
			say
			  "Invalid zapi version. It expects a string with the load balancer host name";
		}
	} while ( !$valid_flag );

	# save data
	my $Config = Config::Tiny->new;
	$Config->{ $HOSTNAME } = $cfg;

	# set the default
	if ( !defined $Config->{ _ }->{ default_host } )
	{
		$Config->{ _ }->{ default_host } = $HOSTNAME;
		say "Saved as default profile";
	}
	else
	{
		print "Do you wish set this host as the default one? ";
		my $confirmation = <STDIN>;
		chomp $confirmation;
		if ( $confirmation =~ /^(y|yes)$/i )
		{
			$Config->{ _ }->{ default_host } = $HOSTNAME;
			say "Saved as default profile";
		}
	}
	say "";

	$Config->write( 'hosts.ini' );
}

sub hostInfo
{
	my $host_name = shift;

	use Config::Tiny;
	my $Config = Config::Tiny->read( 'hosts.ini' );

	if ( !defined $host_name )
	{
		$host_name = $Config->{ _ }->{ default_host };
		print "Warning, there is no default host set\n" if ( !defined $host_name );
	}
	$Config->{ $host_name }->{ name } = $host_name;

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

1;
