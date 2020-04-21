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

use ZCLI::Define;

# verbs
my %V = %Define::Actions;

# keys
my %K = %Define::Keys;

package Objects;

my $param_uri_rule = [
					  {
						 name => "id",
						 desc => "the id inside the set rule",
					  },
];

my $param_uri_match = [
					   {
						  name => "id",
						  desc => "the id inside the set rule",
					   },
					   {
						  name => "match",
						  desc => "the match inside the rule",
					   },
];

our $Waf = {
	'ipds-waf' => {
					$V{ LIST } => {
									uri        => "/ipds/waf",
									method     => 'GET',
									enterprise => 1,
					},
					$V{ GET } => {
								   uri        => "/ipds/waf/<$K{WAF}>",
								   method     => 'GET',
								   enterprise => 1,
					},
					$V{ CREATE } => {
									  uri        => "/ipds/waf",
									  method     => 'POST',
									  enterprise => 1,
					},
					$V{ SET } => {
								   uri        => "/ipds/waf/<$K{WAF}>",
								   method     => 'PUT',
								   enterprise => 1,
					},
					$V{ DELETE } => {
									  uri        => "/ipds/waf/<$K{WAF}>",
									  method     => 'DELETE',
									  enterprise => 1,
					},
					$V{ START } => {
									 uri    => "/ipds/waf/<$K{WAF}>/actions",
									 method => 'POST',
									 params => {
												 'action' => 'start',
									 },
									 enterprise => 1,
					},
					$V{ STOP } => {
									uri    => "/ipds/waf/<$K{WAF}>/actions",
									method => 'POST',
									params => {
												'action' => 'stop',
									},
									enterprise => 1,
					},
	},
	'ipds-waf-rule' => {
				  $V{ GET } => {
								 uri => "/ipds/waf/<$K{WAF}>/rules/$Define::Uri_param_tag",
								 method     => 'GET',
								 param_uri  => $param_uri_rule,
								 enterprise => 1,
				  },
				  $V{ CREATE } => {
									uri        => "/ipds/waf/<$K{WAF}>/rules",
									method     => 'POST',
									enterprise => 1,
				  },
				  $V{ SET } => {
								 uri => "/ipds/waf/<$K{WAF}>/rules/$Define::Uri_param_tag",
								 method     => 'PUT',
								 param_uri  => $param_uri_rule,
								 enterprise => 1,
				  },
				  $V{ DELETE } => {
								  uri => "/ipds/waf/<$K{WAF}>/rules/$Define::Uri_param_tag",
								  method     => 'DELETE',
								  param_uri  => $param_uri_rule,
								  enterprise => 1,
				  },
				  $V{ MOVE } => {
						  uri => "/ipds/waf/<$K{WAF}>/rules/$Define::Uri_param_tag/actions",
						  method     => 'POST',
						  param_uri  => $param_uri_rule,
						  enterprise => 1,
				  },
	},
	'ipds-waf-rule-match' => {
		$V{ CREATE } => {
						  uri => "/ipds/waf/<$K{WAF}>/rules/$Define::Uri_param_tag/matches",
						  method     => 'POST',
						  param_uri  => $param_uri_rule,
						  enterprise => 1,
		},
		$V{ SET } => {
			uri =>
			  "/ipds/waf/<$K{WAF}>/rules/$Define::Uri_param_tag/matches/$Define::Uri_param_tag",
			method     => 'PUT',
			param_uri  => $param_uri_match,
			enterprise => 1,
		},
		$V{ DELETE } => {
			uri =>
			  "/ipds/waf/<$K{WAF}>/rules/$Define::Uri_param_tag/matches/$Define::Uri_param_tag",
			method     => 'DELETE',
			param_uri  => $param_uri_match,
			enterprise => 1,
		},
	},
};

1;
