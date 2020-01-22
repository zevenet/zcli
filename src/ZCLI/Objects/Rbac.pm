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
									 uri        => "/rbac/users",
									 method     => 'GET',
									 enterprise => 1,
					 },
					 $V{ GET } => {
									uri        => "/rbac/users/<$K{RBAC_USER}>",
									method     => 'GET',
									enterprise => 1,
					 },
					 $V{ CREATE } => {
									   uri        => "/rbac/users",
									   method     => 'POST',
									   enterprise => 1,
					 },
					 $V{ SET } => {
									uri        => "/rbac/users/<$K{RBAC_USER}>",
									method     => 'PUT',
									enterprise => 1,
					 },
					 $V{ DELETE } => {
									   uri        => "/rbac/users/<$K{RBAC_USER}>",
									   method     => 'DELETE',
									   enterprise => 1,
					 },
	},
	'rbac-group' => {
					  $V{ LIST } => {
									  uri        => "/rbac/groups",
									  method     => 'GET',
									  enterprise => 1,
					  },
					  $V{ GET } => {
									 uri        => "/rbac/groups/<$K{RBAC_GROUP}>",
									 method     => 'GET',
									 enterprise => 1,
					  },
					  $V{ CREATE } => {
										uri        => "/rbac/groups",
										method     => 'POST',
										enterprise => 1,
					  },
					  $V{ SET } => {
									 uri        => "/rbac/groups/<$K{RBAC_GROUP}>",
									 method     => 'PUT',
									 enterprise => 1,
					  },
					  $V{ DELETE } => {
										uri        => "/rbac/groups/<$K{RBAC_GROUP}>",
										method     => 'DELETE',
										enterprise => 1,
					  },
	},
	'rbac-group-interfaces' => {
					  $V{ ADD } => {
									 uri    => "/rbac/groups/<$K{RBAC_GROUP}>/interfaces",
									 method => 'POST',
									 enterprise => 1,
					  },
					  $V{ REMOVE } => {
							  uri => "/rbac/groups/<$K{RBAC_GROUP}>/interfaces/<$K{IFACE}>",
							  method     => 'DELETE',
							  enterprise => 1,
					  },
	},
	'rbac-group-farms' => {
							$V{ ADD } => {
										   uri    => "/rbac/groups/<$K{RBAC_GROUP}>/farms",
										   method => 'POST',
										   enterprise => 1,
							},
							$V{ REMOVE } => {
									uri => "/rbac/groups/<$K{RBAC_GROUP}>/farms/<$K{FARM}>",
									method     => 'DELETE',
									enterprise => 1,
							},
	},
	'rbac-group-users' => {
					   $V{ ADD } => {
									  uri        => "/rbac/groups/<$K{RBAC_GROUP}>/users",
									  method     => 'POST',
									  enterprise => 1,
					   },
					   $V{ REMOVE } => {
							   uri => "/rbac/groups/<$K{RBAC_GROUP}>/users/<$K{RBAC_USER}>",
							   method     => 'DELETE',
							   enterprise => 1,
					   },
	},
	'rbac-role' => {
		$V{ LIST } => {
						uri        => "/rbac/roles",
						method     => 'GET',
						enterprise => 1,
		},
		$V{ GET } => {
					   uri        => "/rbac/roles/<$K{RBAC_ROLE}>",
					   method     => 'GET',
					   enterprise => 1,
		},
		$V{ CREATE } => {
						  uri        => "/rbac/roles",
						  method     => 'POST',
						  enterprise => 1,
		},

		#		$V{ SET } => {
		#					   uri    => "/rbac/roles/<$K{RBAC_ROLE}>",
		#					   method => 'PUT',
		#		},
		$V{ DELETE } => {
						  uri        => "/rbac/roles/<$K{RBAC_ROLE}>",
						  method     => 'DELETE',
						  enterprise => 1,
		},
	},
};

1;
