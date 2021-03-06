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
												 uri    => "/rbac/users/<$K{RBAC_USER}>",
												 method => 'DELETE',
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
											   uri    => "/rbac/groups/<$K{RBAC_GROUP}>",
											   method => 'GET',
											   enterprise => 1,
								},
								$V{ CREATE } => {
												  uri        => "/rbac/groups",
												  method     => 'POST',
												  enterprise => 1,
								},
								$V{ SET } => {
											   uri    => "/rbac/groups/<$K{RBAC_GROUP}>",
											   method => 'PUT',
											   params_autocomplete => {
																	  role => ['rbac', 'roles'],
											   },
											   enterprise => 1,
								},
								$V{ DELETE } => {
												  uri    => "/rbac/groups/<$K{RBAC_GROUP}>",
												  method => 'DELETE',
												  enterprise => 1,
								},
			  },
			  'rbac-group-interface' => {
					  $V{ ADD } => {
									 uri    => "/rbac/groups/<$K{RBAC_GROUP}>/interfaces",
									 method => 'POST',
									 params_autocomplete => {
															  name => ['interfaces', 'virtual'],
									 },
									 enterprise => 1,
					  },
					  $V{ REMOVE } => {
							  uri => "/rbac/groups/<$K{RBAC_GROUP}>/interfaces/<$K{IFACE}>",
							  method     => 'DELETE',
							  enterprise => 1,
					  },
			  },
			  'rbac-group-farm' => {
							$V{ ADD } => {
										   uri    => "/rbac/groups/<$K{RBAC_GROUP}>/farms",
										   method => 'POST',
										   params_autocomplete => {
																	name => ['farms'],
										   },
										   enterprise => 1,
							},
							$V{ REMOVE } => {
									uri => "/rbac/groups/<$K{RBAC_GROUP}>/farms/<$K{FARM}>",
									method     => 'DELETE',
									enterprise => 1,
							},
			  },
			  'rbac-group-user' => {
					   $V{ ADD } => {
									  uri    => "/rbac/groups/<$K{RBAC_GROUP}>/users",
									  method => 'POST',
									  params_autocomplete => {
															   name => ['rbac', 'users'],
									  },
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
							   $V{ SET } => {
									   uri                => "/rbac/roles/<$K{RBAC_ROLE}>",
									   method             => 'PUT',
									   params_funct_parse => 'Objects::complete_rbac_roles',
									   params_funct_build => 'Objects::body_rbac_roles',
							   },
							   $V{ DELETE } => {
												 uri    => "/rbac/roles/<$K{RBAC_ROLE}>",
												 method => 'DELETE',
												 enterprise => 1,
							   },
			  },
			  'rbac-services' => {
								   $V{ LIST } => {
												   uri    => "/rbac/services",
												   method => 'GET',
								   },
								   $V{ SET } => {
												  uri        => "/rbac/services",
												  method     => 'POST',
												  enterprise => 1,
								   },
			  },
			  'rbac-services-ldap' => {
										$V{ GET } => {
													   uri    => "/rbac/ldap",
													   method => 'GET',
										},
										$V{ SET } => {
													   uri        => "/rbac/ldap",
													   method     => 'POST',
													   enterprise => 1,
										},
										$V{ TEST } => {
														uri        => "/rbac/ldap/actions",
														method     => 'POST',
														enterprise => 1,
														params     => {
																	'action' => 'test',
														},
										},
			  },
};

sub complete_rbac_roles
{
	my @args = @_;

	if ( !@args )
	{
		return ["-section"];
	}

	my @out = keys %Define::Rbac_roles;
	if ( @args == 1 )
	{
		return \@out;
	}
	elsif ( !grep ( /^$args[1]$/, @out ) )
	{
		print "# the section is not valid";
		return [];
	}

	shift @args;
	my $section = shift @args;

	my $key_flag = 1;
	my @list     = keys %{ $Define::Rbac_roles{ $section } };
	$_ = "-$_" for ( @list );

	my @used = ();
	foreach my $a ( @args )
	{
		if ( $key_flag )
		{
			$key_flag = 0;
			if ( !grep ( /^$a$/, @list ) )
			{
				print "# the parameter '$a' was not expected";
				return [];
			}
			else
			{
				push @used, $a;
			}
		}
		else
		{
			$key_flag = 1;
		}
	}

	# the following parameter is:
	if ( $key_flag )
	{
		my @notused = ();

		foreach my $p ( @list )
		{
			push @notused, "$p" if ( !grep /^$p$/, @used );
		}

		return \@notused;
	}
	else
	{
		return ["false", "true"];
	}
}

sub body_rbac_roles
{
	my @args = @_;

	shift @args;    # remove the "-section" key
	my $section = shift @args;    # get the key value

	my $params;
	my $key = "";
	foreach my $a ( @args )
	{
		if ( !$key )
		{
			$key = $a;
			$key =~ s/^-//;
		}
		else
		{
			$params->{ $section }->{ $key } = $a;
			$key = "";
		}
	}

	return $params;
}

1;
