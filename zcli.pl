#!/usr/bin/perl

use strict;
use Data::Dumper;
use feature "say";
use POSIX qw(_exit);

require "./lib.pm";
require "./objects.pm";


my $zcli_history = '.zcli-history';


&printHelp() if ($ARGV[0] eq '-h');

my $options = &parseOptions(@ARGV);

my $host = &hostInfo() or do
{
	say "Not found the host info, try to configure the default host profile";
	&setHost();
	&hostInfo();
};

my $objects = $Objects::zcli_objects;



#~ my $input = &parseInput(@ARGV);

#~ my $request = &checkInput($objects, $input, $host);

#~ my $resp = &zapi($request, $host);

#~ &printOutput($resp);
#~ POSIX::_exit( $resp->{err} );



my $cmd_st = &gen_cmd_struct();


# https://metacpan.org/pod/Term::ShellUI
use Term::ShellUI;
my $term = new Term::ShellUI(
    commands => $cmd_st,
    history_file => $zcli_history,
);
print "Zevenet Client Line Interface\n";
$term->run();




 #~ "cd" => {
                #~ desc => "Change to directory DIR",
                #~ maxargs => 1, args => sub { shift->complete_onlydirs(@_); },
                #~ proc => sub { chdir($_[0] || $ENV{HOME} || $ENV{LOGDIR}); },
          #~ },
#~ "show" => {
            #~ desc => "An example of using subcommands",
            #~ cmds => {
                #~ "warranty" => { proc => "You have no warranty!\n" },
                #~ "args" => {
                    #~ minargs => 2, maxargs => 2,
                    #~ args => [ sub {qw(create delete)},
                              #~ \&Term::ShellUI::complete_files ],
                    #~ desc => "Demonstrate method calling",
                    #~ method => sub {
                        #~ my $self = shift;
                        #~ my $parms = shift;
                        #~ print $self->get_cname($parms->{cname}) .
                            #~ ": " . join(" ",@_), "\n";
                    #~ },
                #~ },
            #~ },
        #~ },



sub gen_cmd_struct
{
	my $st;

	foreach my $cmd ( keys %{$objects} )
	{
		$st->{$cmd} = &gen_obj($cmd);
	}

	$st->{help}->{proc} = \&printHelp;

	return $st;
}


sub gen_obj
{
	my $obj = shift;
	my $def;

	$def->{ desc } = "Apply an action about '$obj' objects";

	foreach my $action ( keys %{$objects->{$obj}} )
	{
		$def->{cmds}->{$action} = &gen_act($obj, $action);
	}

	return $def;
}

sub gen_act
{
	my $obj = shift;
	my $act = shift;
	my $def;

	my $call;

		# posibilidad de listar los ids

	my @ids = &getIds($objects->{$obj}->{$act}->{uri});
	my $join = join (', ',@ids);
	$def->{desc} = "$obj: Applying the action '$act' about $join";

	$def->{proc} = sub {

			eval {
				my @args=($obj,$act,@_);

				my $input = &parseInput(@args);
				my $request = &checkInput($objects, $input, $host);
				my $resp = &zapi($request, $host);
				&printOutput($resp);
			};
			say $@ if $@;
				#~ POSIX::_exit( $resp->{err} );
	};

	return $def;
}



