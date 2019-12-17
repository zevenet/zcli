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

my %V = %Define::Actions;
my $FIN = $Define::FIN;

my $zcli_dir = &getZcliDir();
my $zcli_history = &getZcliHistoryPath();


system("mkdir -p $zcli_dir") if (!-d $zcli_dir);



my $opt = &parseOptions( \@ARGV );

&printHelp() if ( $opt->{'help'} );

# add local lb if it exists
my $localhost = &hostInfo($opt->{'host'});
if (&check_is_lb())
{
	if (!defined $localhost)
	{
		print "Type the zapi key for the current load balancer\n";
		&setHost("localhost",1);
	}
	# refresh ip and port. Maybe they were modified
	else
	{
		&refreshLocalHost();
	}
}

$Env::HOST = &hostInfo($opt->{'host'});
if (!$Env::HOST)
{
	if (exists $opt->{'host'})
	{
		say "Not found the '$opt->{host}' host, selecting the default host";
		$Env::HOST = &hostInfo($opt->{'host'});
	}

	if ($opt->{'silence'})
	{
		say "The silence mode needs a host profile";
		exit 1;
	}
}

if (!$Env::HOST)
{
	say "Not found the host info, try to configure the default host profile";
	$Env::HOST = &setHost();
}


# Preparing Interface
my $objects = $Objects::zcli_objects;

&reload_cmd_struct();

# Launching only a cmd
if ( $opt->{'silence'} )
{
	my $resp;
	eval {
		my $obj=$_[0];
		my $act=$_[1];

		my $input = &parseInput( $objects->{ $obj }->{ $act }, @ARGV );
		my $request = &checkInput( $objects, $input, $Env::HOST, $Env::HOST_IDS_TREE );
		$resp    = &zapi( $request, $Env::HOST );
		&printOutput( $resp );
	};
	say $@ if $@;
	my $err = ($@ or $resp->{err})? 1 : 0;
	POSIX::_exit( $err );
}



# overriding error method
*{Term::ShellUI::error} = sub {
	say "$_[1]";
	&reload_prompt(1);
};


$Env::ZCLI = new Term::ShellUI( commands     => $Env::ZCLI_CMD_ST,
							  history_file => $zcli_history, );
print "Zevenet Client Line Interface\n";
&reload_prompt();
$Env::ZCLI->load_history();
$Env::ZCLI->run();


### definition of functions

sub reload_prompt
{
	my $err = shift // 0;
	my $conn = $Env::CONNECTIVITY;
	my $host = $Env::HOST->{NAME} // "";


	my $gray = "\033[01;90m";
	my $red = "\033[01;31m";
	my $green = "\033[01;32m";
	my $no_color = "\033[0m";


	my $color = ($err) ? $red: $green;
	my $conn_color = (!$conn) ? $gray: "";

	my $tag = "zcli($conn_color$host$color)";
	$Env::ZCLI->prompt( "$color$tag$no_color: " );
}

sub gen_cmd_struct
{
	my $st;

	# features of the lb
	if ($Env::CONNECTIVITY)
	{
		foreach my $cmd ( keys %{ $objects } )
		{
			$st->{ $cmd } = &gen_obj( $cmd );
		}
	}

	# add static functions
	$st->{ 'help' }->{ cmds }->{ $V{LIST} }->{ desc } = "Print the ZCLI help";
	$st->{ 'help' }->{ cmds }->{ $V{LIST} }->{ proc } = sub { &printHelp(); &reload_prompt(0); };
	$st->{ 'help' }->{ cmds }->{ $V{LIST} }->{ maxargs } = 0;

	$st->{ 'history' }->{ cmds }->{ $V{LIST} }->{ desc } = "Print the list of commands executed";
	$st->{ 'history' }->{ cmds }->{ $V{LIST} }->{ method } = sub { shift->history_call(); };
	$st->{ 'history' }->{ cmds }->{ $V{LIST} }->{ maxargs } = 0;

	$st->{ 'zcli' }->{ cmds }->{ $V{RELOAD} }->{ desc } = "Force a ZCLI reload to refresh the ID objects";
	$st->{ 'zcli' }->{ cmds }->{ $V{RELOAD} }->{ proc } = sub { &reload_cmd_struct(); };
	$st->{ 'zcli' }->{ cmds }->{ $V{RELOAD} }->{ maxargs } = 0;
	$st->{ 'zcli' }->{ cmds }->{ $V{QUIT} }->{ dec } = "Escape from the ZCLI";
	$st->{ 'zcli' }->{ cmds }->{ $V{QUIT} }->{ method } = sub { shift->exit_requested(1); };
	$st->{ 'zcli' }->{ cmds }->{ $V{QUIT} }->{ exclude_from_history } = 1;
	$st->{ 'zcli' }->{ cmds }->{ $V{QUIT} }->{ maxargs } = 0;


	my $host_st;
	my @host_list = &listHost();
	$host_st->{ $V{LIST} }->{ proc } = sub { say $_ for (&listHost) };
	$host_st->{ $V{LIST} }->{ maxargs } = 1;
	$host_st->{ $V{CREATE} }->{ proc } = \&setHost;
	$host_st->{ $V{CREATE} }->{ maxargs } = 1;
	$host_st->{ $V{SET} } = {
		args => [sub {\@host_list}],
		maxargs => 1,
		proc => sub {
			my $new_host = &setHost($_[0],0);
			my $err = (defined $new_host) ? 0 : 1;
			if (!$err)
			{
				# reload the host configuration
				$Env::HOST = $new_host if ($Env::HOST->{NAME} eq $new_host->{NAME});
			}
			$Env::CONNECTIVITY = &check_connectivity($Env::HOST);
			&reload_prompt($err);
		},
	};
	$host_st->{ $V{DELETE} } = {
		proc => sub {
			if ($Env::HOST->{name} eq @_[0])
			{
				say "The '$Env::HOST->{NAME}' host is being used";
			}
			else
			{
				&delHost(@_);
			}
		},
		args => [sub {\@host_list}],
		maxargs => 1,
	};
	$host_st->{ $V{APPLY} } = {
		proc => sub {
			$Env::HOST=hostInfo(@_);
			my $err = (defined $Env::HOST) ? 0 : 1;
			&reload_prompt($err);
			&reload_cmd_struct();
		},
		args => [sub {\@host_list}],
		maxargs => 1,
	};
	$st->{ hosts }->{ desc } = "apply an action about which is the destination load balancer";
	$st->{ hosts }->{ cmds } = $host_st;


	return $st;
}

sub gen_obj
{
	my $obj = shift;
	my $def;

	foreach my $action ( keys %{ $objects->{ $obj } } )
	{
		my @ids_def = &getIds( $objects->{ $obj }->{ $action }->{ uri } );
		$objects->{ $obj }->{ $action }->{ ids } = \@ids_def;
		$def->{ cmds }->{ $action } =
		  &add_ids( $obj, $action, $objects->{ $obj }->{ $action }->{ uri }, $Env::HOST_IDS_TREE );
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

		$def->{ desc } = &create_description($objects, $obj, $action);

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
					print "The id '$key' could not be replaced";
					my $FIN = $Define::FIN;
				}

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
	$def->{ desc } = $def->{ desc } = &create_description($objects, $obj, $act);

	my @in_args = ();
	if (exists $objects->{ $obj }->{ $act }->{ 'uri_param'} )
	{
		foreach my $p (@{ $objects->{ $obj }->{ $act }->{ 'uri_param'} })
		{
			push @in_args, "<$p->{name}>";
		}
		$def->{ args } = \@in_args;
		$def->{ maxargs } = scalar @in_args;
	}

	# check if the call is expecting a file name to upload or download
	if (    exists $objects->{ $obj }->{ $act }->{ 'download_file' }
		 or exists $objects->{ $obj }->{ $act }->{ 'upload_file' } )
	{
		push @in_args, sub { shift->complete_files(@_); };
		$def->{ args } = \@in_args;
		$def->{ maxargs } = scalar @in_args;
	}

	elsif ( $objects->{ $obj }->{ $act }->{method} =~ /POST|PUT/)
	{
		# comprobar si objeto ya tiene cargado los posibles parametros.
		#  ???? pueden faltar parametros de uri
		$def->{ args } = sub {&complete_body_params( @_, $objects->{ $obj }->{ $act }, $obj, $act, $ids ); };
	}


	$def->{ proc } = sub {
		my $resp;
		eval {
			my @args = ( $objects->{ $obj }->{ $act }, $obj, $act, @{ $ids }, @_ );
			my $input = &parseInput( @args );

			my $request = &checkInput( $objects, $input, $Env::HOST, $Env::HOST_IDS_TREE );
			$resp    = &zapi( $request, $Env::HOST );
			&printOutput( $resp );
			$Env::ZCLI->save_history();

			# reload structs
			&reload_cmd_struct();
		};
		say $@ if $@;
		my $err = ($@ or $resp->{err})? 1 : 0;
		&reload_prompt($err);
		#~ POSIX::_exit( $resp->{err} );
	};

	return $def;
}

sub complete_body_params
{
	my (undef, $input, $obj_def, $obj, $act, $ids) = @_;

	# get list
	if ($Env::CMD_STRING eq '' or $Env::CMD_STRING ne $input->{str})
	{
		$Env::CMD_STRING = $input->{str};
		my @args = ( $objects->{ $obj }->{ $act }, $obj, $act, @{ $ids });
		my $in_parsed = &parseInput( @args );
		my $request = &checkInput( $objects, $in_parsed, $Env::HOST, $Env::HOST_IDS_TREE );
		my $paramlist_ref = &listParams( $request, $Env::HOST );
		@Env::PARAM_LIST = @{$paramlist_ref};
	}

	my $out;
	my @params_used = @{$input->{args}};

	# get last completed parameter used
	my $previus_param = $params_used[$input->{argno} - 1];
	$previus_param =~ s/^-//;
	if (grep (/^$previus_param$/, @Env::PARAM_LIST))
	{
		$out = "<$previus_param>";
	}
	else
	{
		# remove the parameters already exists
		my @params = ();

		foreach my $p (@Env::PARAM_LIST)
		{
			push @params, "-$p" if ( !grep(/^-$p$/, @params_used) );
		}
		@params = () if (!@params);

		$out = \@params;
	}

	return $out;
}

sub reload_cmd_struct
{
	$Env::CONNECTIVITY = &check_connectivity($Env::HOST);
	if ($Env::CONNECTIVITY)
	{
		$Env::HOST_IDS_TREE = &getLBIdsTree( $Env::HOST );
	}
	$Env::ZCLI_CMD_ST = &gen_cmd_struct();

	$Env::ZCLI->commands( $Env::ZCLI_CMD_ST ) if (defined $Env::ZCLI);
}
