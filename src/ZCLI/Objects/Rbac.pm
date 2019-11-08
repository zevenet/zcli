#!/usr/bin/perl

use strict;
use warnings;

use ZCLI::Define;

# verbs
my %V = %Define::Actions;

# keys
my %K = %Define::Keys;

package Objects;

our $Rbac = {
	'rbac-user' => {
					 $V{ LIST } => {
									 uri    => "/rbac/users",
									 method => 'GET',
					 },
					 $V{ GET } => {
									uri    => "/rbac/users/<$K{RBAC_USER}>",
									method => 'GET',
					 },
					 $V{ CREATE } => {
									   uri    => "/rbac/users",
									   method => 'POST',
					 },
					 $V{ SET } => {
									uri    => "/rbac/users/<$K{RBAC_USER}>",
									method => 'PUT',
					 },
					 $V{ DELETE } => {
									   uri    => "/rbac/users/<$K{RBAC_USER}>",
									   method => 'DELETE',
					 },
	},
	'rbac-group' => {
					  $V{ LIST } => {
									  uri    => "/rbac/groups",
									  method => 'GET',
					  },
					  $V{ GET } => {
									 uri    => "/rbac/groups/<$K{RBAC_GROUP}>",
									 method => 'GET',
					  },
					  $V{ CREATE } => {
										uri    => "/rbac/groups",
										method => 'POST',
					  },
					  $V{ SET } => {
									 uri    => "/rbac/groups/<$K{RBAC_GROUP}>",
									 method => 'PUT',
					  },
					  $V{ DELETE } => {
										uri    => "/rbac/groups/<$K{RBAC_GROUP}>",
										method => 'DELETE',
					  },
	},
	'rbac-group-interfaces' => {
					  $V{ ADD } => {
									 uri    => "/rbac/groups/<$K{RBAC_GROUP}>/interfaces",
									 method => 'POST',
					  },
					  $V{ REMOVE} => {
										uri    => "/rbac/groups/<$K{RBAC_GROUP}>/interfaces/<$K{IFACE}>",
										method => 'DELETE',
					  },
	},
	'rbac-group-farms' => {
					  $V{ ADD } => {
									 uri    => "/rbac/groups/<$K{RBAC_GROUP}>/farms",
									 method => 'POST',
					  },
					  $V{ REMOVE} => {
										uri    => "/rbac/groups/<$K{RBAC_GROUP}>/farms/<$K{FARM}>",
										method => 'DELETE',
					  },
	},
	'rbac-group-users' => {
					  $V{ ADD } => {
									 uri    => "/rbac/groups/<$K{RBAC_GROUP}>/users",
									 method => 'POST',
					  },
					  $V{ REMOVE} => {
										uri    => "/rbac/groups/<$K{RBAC_GROUP}>/users/<$K{RBAC_USER}>",
										method => 'DELETE',
					  },
	},
	'rbac-role' => {
		$V{ LIST } => {
						uri    => "/rbac/roles",
						method => 'GET',
		},
		$V{ GET } => {
					   uri    => "/rbac/roles/<$K{RBAC_ROLE}>",
					   method => 'GET',
		},
		$V{ CREATE } => {
						  uri    => "/rbac/roles",
						  method => 'POST',
		},
		$V{ SET } => {  # ??? PUEDE dar problemas por la forma de parsear lss parametros
					   uri    => "/rbac/roles/<$K{RBAC_ROLE}>",
					   method => 'PUT',
		},
		$V{ DELETE } => {
						  uri    => "/rbac/roles/<$K{RBAC_ROLE}>",
						  method => 'DELETE',
		},
	},
};

1;
