#!/usr/bin/perl

use strict;
use warnings;

package Global;
our $DEBUG = 1;

package Define;

# object keys
our %Keys = (
			  FARM => 'farm',
			  SRV  => 'service',
			  CERT => 'certificate',
			  WAF  => 'waf',
			  BL   => 'blacklists',
			  RBL  => 'rbl',
			  DOS  => 'dos',
);

our %Actions = (
	LIST   => 'list',      # List all objects of the type
	GET    => 'get',       # get the object with all its configuration
	SET    => 'set',       # modify an object
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
	MOVE => 'move',    # apply a action to move a item in a list
);

1;
