#!/usr/bin/perl

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
								   uri => "/ipds/waf/<$K{WAF}>/rules/$Define::UriParamTag",
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
								   uri => "/ipds/waf/<$K{WAF}>/rules/$Define::UriParamTag",
								   method     => 'PUT',
								   param_uri  => $param_uri_rule,
								   enterprise => 1,
					},
					$V{ DELETE } => {
									uri => "/ipds/waf/<$K{WAF}>/rules/$Define::UriParamTag",
									method     => 'DELETE',
									param_uri  => $param_uri_rule,
									enterprise => 1,
					},
					$V{ MOVE } => {
							uri => "/ipds/waf/<$K{WAF}>/rules/$Define::UriParamTag/actions",
							method     => 'POST',
							param_uri  => $param_uri_rule,
							enterprise => 1,
					},
	},
	'ipds-waf-rule-match' => {
		$V{ CREATE } => {
						  uri => "/ipds/waf/<$K{WAF}>/rules/$Define::UriParamTag/matches",
						  method     => 'POST',
						  param_uri  => $param_uri_rule,
						  enterprise => 1,
		},
		$V{ SET } => {
			uri =>
			  "/ipds/waf/<$K{WAF}>/rules/$Define::UriParamTag/matches/$Define::UriParamTag",
			method     => 'PUT',
			param_uri  => $param_uri_match,
			enterprise => 1,
		},
		$V{ DELETE } => {
			uri =>
			  "/ipds/waf/<$K{WAF}>/rules/$Define::UriParamTag/matches/$Define::UriParamTag",
			method     => 'DELETE',
			param_uri  => $param_uri_match,
			enterprise => 1,
		},
	},
};

1;
