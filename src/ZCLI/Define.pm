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
use warnings;

package Global;
our $Debug = 0;
our $Fin = ( $Debug ) ? "" : "\n";  # This will add the dying line in debug mode

our $Req_ee_zevenet_version = "6.1";
our $Req_ce_zevenet_version = "5.10.3";

our $Config_dir    = "$ENV{HOME}/.zcli";
our $History_path  = "$Config_dir/zcli-history";
our $Profiles_path = "$Config_dir/profiles.ini";
our $Connectivity = 1;    # It is the result of a connectivity test with the lb

package Env;
our $Input_json = 0;    # It is the execution options to run without interactive
our $Silence    = 0;    # It is the execution options to run without interactive
our $Color      = 1;    # It is the execution options to run without interactive
our $Profile;    # It is a struct with info to connect with the load balancer
our $Profile_ids_tree
  ;              # It is the tree with the IDs that the load balancer contains
;    # It is the the hash with the definition for all the possible commands
our $Zcli;        # It is the object TERM used to implement the autocompletation
our $Zcli_cmd_st; # It is the ZCLI commands struct used for the TERM module

# save the last parameter list to avoid repeat the params zapi call for each tab
our $Cmd_params_def = undef;
; # It is the last parameter object returned by the ZAPI. It is used to autocomplete the command
our $Cmd_string = ''
  ; # It is the last command used with autocomplete. It is used as flag, if it changes, the ZAPI parameters will be reloaded.
    # This string contains the string without the parameters

package Color;

# the strings '\001' and '\002' are used to avoid garbage in the prompt line
# when a histroy command is recovered
our $Init  = "\001";
our $End   = "\002";
our $Gray  = "\033[01;90m";
our $Red   = "\033[01;31m";
our $Green = "\033[01;32m";
our $Clean = "\033[0m";
our $Reset = "$Init\033[0m$End";

package Define;

our $Zapi_doc_uri      = "https://www.zevenet.com/zapidocv4.0/";
our $Description_param = "[-param_1 value] [-param_2 value] ...";
our $L4_service        = "default_service";

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

our $Uri_param_tag =
  "PARAM_URI";    # is a tag used to replace a parameter of the uri

1;
