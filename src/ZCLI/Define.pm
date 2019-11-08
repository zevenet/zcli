#!/usr/bin/perl

use strict;
use warnings;

package Global;
our $DEBUG = 0;

package Define;

# object keys
our %Keys = (
			  FARM       => 'farm',
			  SRV        => 'service',
			  BK         => 'backend',
			  FG         => 'farmguardian',
			  ZONES      => 'zones',
			  CERT       => 'certificate',
			  WAF        => 'waf',
			  WAF_RULE   => 'rule',
			  WAF_MATCH  => 'match',
			  BL         => 'blacklist',
			  RBL        => 'rbl',
			  DOS        => 'dos',
			  IFACE      => 'interface',
			  BOND_SLAVE => 'slave',
			  ALIAS      => 'slave',
			  DOMAIN     => 'domain',
			  LOG        => 'log',
			  BACKUP     => 'backup',
			  RBAC_USER  => 'user',
			  RBAC_GROUP => 'group',
			  RBAC_ROLE  => 'role',
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
	APPLY => 'apply',  # Apply an object to the system
	UPDATE => 'update',  # Apply an object to the system

	RELOAD => 'reload',  # Refresh a item or reload an object
	QUIT => 'quit',  	# exit from program
);

our $UriParamTag =
  "URI_PARAM";    # is a tag used to replace a parameter of the uri

1;
