#!/usr/bin/perl
###############################################################################
#
#    ZEVENET Software License
#    This file is part of the ZEVENET Load Balancer software package.
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
use warnings;

use File::HomeDir;
use File::Spec;

package Env;
our $OS =
  ( $^O =~ /win/i ) ? 'win' : "linux";  # It is the SO where the ZCLI is running
our $Input_json   = 0;  # It is the execution options to run without interactive
our @OutputFilter = ()
  ; # it is an array reference with the parameters that must be listed in the output
our $Silence = 0;    # It is the execution options to run without interactive
our $Color   = 1;    # ZCLI will not use colors in the output or prompt
our $Profile;    # It is a struct with info to connect with the load balancer
our $Profile_ids_tree
  ;              # It is the tree with the IDs that the load balancer contains
;    # It is the the hash with the definition for all the possible commands
our $Zcli;        # It is the object TERM used to implement the autocompletation
our $Zcli_cmd_st; # It is the ZCLI commands struct used for the TERM module

# save the last parameter list to avoid repeat the params zapi call for each tab
our $Cmd_params_def = undef;

# It is the ZAPI error message when command params could not the get.
our $Cmd_params_msg = undef;

# It is the last command used with autocomplete. It is used as flag, if it changes, the ZAPI parameters will be reloaded.
# This string contains the string without the parameters
our $Cmd_string = '';

package Global;

our $Version = "1.0.6";
our $Debug   = 0;
our $Fin = ( $Debug ) ? "" : "\n";  # This will add the dying line in debug mode

our $Req_ee_zevenet_version = "6.1";
our $Req_ce_zevenet_version = "5.11";

my $home = File::HomeDir->my_home;

our $Config_dir    = File::Spec->catdir( $home,       ".zcli" );
our $History_path  = File::Spec->catdir( $Config_dir, "zcli-history" );
our $Profiles_path = File::Spec->catdir( $Config_dir, "profiles.ini" );
our $Connectivity = 1;    # It is the result of a connectivity test with the lb

package Color;

# the strings '\001' and '\002' are used to avoid garbage in the prompt line
# when a histroy command is recovered

use Term::ANSIColor qw(:constants);
use Term::ANSIColor qw(:constants256);

my $Gray  = "\033[01;90m";
my $Red   = "\033[01;31m";
my $Green = "\033[01;32m";

my $Zgreen = RGB150;
my $Zgray  = RGB444;

our $Init = "\001";
our $End  = "\002";

our $Clean = RESET;
our $Reset = "$Init$Clean$End";

# logo
our $Logo = $Green;

# prompt
our $Error      = $Red;
our $Success    = $Green;
our $Disconnect = $Gray;

# json
my $Json_key    = $Zgray;
my $Json_string = $Zgreen;
my $Json_number = BRIGHT_YELLOW;
my $Json_null   = BRIGHT_CYAN;

our %Json = (
		   start_quote             => $Json_string,
		   end_quote               => $Clean,
		   start_string            => $Json_string,
		   end_string              => $Clean,
		   start_string_escape     => $Clean . $Json_string,
		   end_string_escape       => $Clean . $Json_string,    # back to string
		   start_number            => $Json_number,
		   end_number              => $Clean,
		   start_bool              => $Json_null,
		   end_bool                => $Clean,
		   start_null              => BOLD . $Json_null,
		   end_null                => $Clean,
		   start_object_key        => $Json_key,
		   end_object_key          => $Clean,
		   start_object_key_escape => BOLD,
		   end_object_key_escape   => $Clean . $Json_key,       # back to object key
		   start_linum             => REVERSE . WHITE,
		   end_linum               => $Clean,
);

package Define;

# it is the ZAPI connection timeout
our $Zapi_timeout = 8;

# it is the reserve word to automaticaly modify the conf when zcli is running in a load balancer
our $Profile_local = "localhost";

# it is the zapi version that is configured when a new profile is added
our $Default_zapi_version = "4.0";

# it is the ZAPI documentation URL
our $Zapi_doc_uri = "https://www.zevenet.com/zapidocv4.0/";

# it is the configuration file of the load balancer http service
our $LB_http_cfg = "/usr/local/zevenet/app/cherokee/etc/cherokee/cherokee.conf";

# it is the IP directive of the http cfg file
our $LB_http_ip_directive = 'server!bind!1!interface';

# it is the port directive of the http cfg file
our $LB_http_port_directive = 'server!bind!1!port';

# it is the ZAPI message returned when the API params help is requested
our $Zapi_param_help_msg = "No parameter has been sent. Please, try with:";

# it is the default port for lb http service
our $LB_http_port = 444;

# it is the default ip for lb http service
our $LB_http_ip = "127.0.0.1";

# Character used to split the array parameters that are serialized
our $Params_array_splitter = ",";

# those are constant strings to use in ZCLI
our $Uri_param_tag     = "PARAM_URI";
our $Description_param = "[params list]";
our $L4_service        = "default_service";

our %Options = ( FILTER => '-filter', );

# object keys
our %Keys = (
			  FARM          => 'farm',
			  SRV           => 'service',
			  BK            => 'backend',
			  SESSION       => 'session',
			  FG            => 'farmguardian',
			  ZONES         => 'zones',
			  CERT          => 'certificate',
			  WAF           => 'waf',
			  WAF_RULE      => 'rule',
			  WAF_MATCH     => 'match',
			  BL            => 'blacklist',
			  RBL           => 'rbl',
			  DOS           => 'dos',
			  IFACE         => 'interface',
			  BOND_SLAVE    => 'slave',
			  ALIAS         => 'slave',
			  DOMAIN        => 'domain',
			  LOG           => 'log',
			  BACKUP        => 'backup',
			  RBAC_USER     => 'user',
			  RBAC_GROUP    => 'group',
			  RBAC_ROLE     => 'role',
			  ROUTING_TABLE => 'table',
);

our %Actions = (
	LIST   => 'list',      # List all objects of the type
	GET    => 'get',       # get the object with all its configuration
	SET    => 'set',       # modify an object
	UNSET  => 'unset',     # remove the configuration
	DELETE => 'delete',    # delete an object
	CREATE => 'create',    #  create a new object
	REMOVE => 'remove',    # unlink an object with another one
	ADD    => 'add',       # link an object with another one
	START =>
	  'start', # apply a status action about the object start/stop/restart/up/down..
	STOP =>
	  'stop',  # apply a status action about the object start/stop/restart/up/down..
	RESTART => 'restart'
	,          # apply a status action about the object start/stop/restart/up/down..
	MOVE            => 'move',             # apply a action to move a item in a list
	UPLOAD          => 'upload',           # upload a file to the load balancer
	DOWNLOAD        => 'download',         # download a file from the load balancer
										   # COPY => 'copy',
	UPGRADE         => 'upgrade',          # upgrade a package or a package list
	TEST            => 'test',             # do a action with a testing purpose
	MAINTENANCE     => 'maintenance',      # Set a object in maintenance mode
	NON_MAINTENANCE => 'non_maintenance',  # Unset the maintenance mode of a object
	APPLY           => 'apply',            # Apply an object to the system
	UPDATE          => 'update',           # Apply an object to the system

	RELOAD => 'reload',                    # Refresh a item or reload an object
	QUIT   => 'quit',                      # exit from program
);

our %Rbac_roles = (

	"rbac-user" => {
					 "show"   => "false",
					 "delete" => "false",
					 "create" => "false",
					 "modify" => "false",
					 "list"   => "false",
					 "menu"   => "false"
	},
	"notification" => {
						"show"   => "false",
						"modify" => "false",
						"action" => "false",
						"menu"   => "false",
						"test"   => "false"
	},
	"rbac-role" => {
					 "modify" => "false",
					 "menu"   => "false",
					 "delete" => "false",
					 "create" => "false",
					 "show"   => "false"
	},
	"system-service" => {
						  "modify" => "false",
						  "menu"   => "false"
	},
	"supportsave" => {
					   "download" => "false",
					   "menu"     => "false"
	},
	"interface-virtual" => {
							 "modify" => "false",
							 "action" => "false",
							 "delete" => "false",
							 "create" => "false"
	},
	"farm" => {
				"modify"      => "false",
				"menu"        => "false",
				"action"      => "false",
				"delete"      => "false",
				"create"      => "false",
				"maintenance" => "false"
	},
	"ipds" => {
				"menu"   => "false",
				"modify" => "false",
				"action" => "false"
	},
	"log" => {
			   "show"     => "false",
			   "download" => "false",
			   "menu"     => "false"
	},
	"alias" => {
				 "list"   => "false",
				 "modify" => "false",
				 "menu"   => "false",
				 "delete" => "false"
	},
	"rbac-group" => {
					  "show"   => "false",
					  "menu"   => "false",
					  "modify" => "false",
					  "list"   => "false",
					  "delete" => "false",
					  "create" => "false"
	},
	"interface" => {
					 "modify" => "false",
					 "menu"   => "false"
	},
	"certificate" => {
					   "menu"     => "false",
					   "download" => "false",
					   "upload"   => "false",
					   "create"   => "false",
					   "delete"   => "false",
					   "show"     => "false"
	},
	"farmguardian" => {
						"menu"   => "false",
						"modify" => "false"
	},
	"backup" => {
				  "menu"     => "false",
				  "download" => "false",
				  "upload"   => "false",
				  "delete"   => "false",
				  "create"   => "false",
				  "apply"    => "false"
	},
	"cluster" => {
				   "maintenance" => "false",
				   "delete"      => "false",
				   "create"      => "false",
				   "menu"        => "false",
				   "modify"      => "false"
	}

);

1;
