#!/usr/bin/perl

use strict;
use warnings;

package Global;
our $DEBUG = 0;
our $FIN = ( $DEBUG ) ? "" : "\n";  # This will add the dying line in debug mode
our $REQ_ZEVEVENET_VERSION = "6.1";

our $config_dir   = "$ENV{HOME}/.zcli";
our $history_path = "$config_dir/zcli-history";
our $hosts_path   = "$config_dir/hosts.ini";
our $CONNECTIVITY = 1;    # It is the result of a connectivity test with the lb

package Env;
our $INPUT_JSON = 0;    # It is the execution options to run without interactive
our $SILENCE    = 0;    # It is the execution options to run without interactive
our $HOST;   # It is the host struct with info to connect with the load balancer
our
  $HOST_IDS_TREE;  # It is the tree with the IDs that the load balancer contains
our $ZCLI_OBJECTS_DEF
  ;    # It is the the hash with the definition for all the possible commands
our $ZCLI;        # It is the object TERM used to implement the autocompletation
our $ZCLI_CMD_ST; # It is the ZCLI commands struct used for the TERM module
our $ZCLI_OPTIONS;    #

# save the last parameter list to avoid repeat the params zapi call for each tab
our $CMD_PARAMS_DEF = undef;
; # It is the last parameter object returned by the ZAPI. It is used to autocomplete the command
our $CMD_STRING = ''
  ; # It is the last command used with autocomplete. It is used as flag, if it changes, the ZAPI parameters will be reloaded

package Define;

our $Description_param =
  "[-param_name_1 param_value_1] [-param_name_2 param_value_2] ...";
our $L4_SERVICE = "default_service";

# object keys
our %Keys = (
			  FARM          => 'farm',
			  SRV           => 'service',
			  BK            => 'backend',
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

our $UriParamTag =
  "PARAM_URI";    # is a tag used to replace a parameter of the uri

1;
