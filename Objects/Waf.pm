#!/usr/bin/perl

use strict;
use warnings;

require "./Define.pm";

# verbs
my %V = %Define::Actions;

# keys
my %K = %Define::Keys;

package Objects;

my $uri_param_rule = [
					{
						name => "id",
						desc => "the id inside the set rule",
					},
			  ];

my $uri_param_match = [
					{
						name => "id",
						desc => "the id inside the set rule",
					},
					{
						name => "match",
						desc => "the match inside the rule",
					},
			  ];


our $WAf = {
	'ipds-waf' => {
					$V{ LIST } => {
									uri    => "/ipds/waf",
									method => 'GET',
					},
					$V{ GET } => {
								   uri    => "/ipds/waf/<$K{WAF}>",
								   method => 'GET',
					},
					$V{ CREATE } => {
									  uri    => "/ipds/waf",
									  method => 'POST',
					},
					$V{ SET } => {
								   uri    => "/ipds/waf/<$K{WAF}>",
								   method => 'PUT',
					},
					$V{ DELETE } => {
									  uri    => "/ipds/waf/<$K{WAF}>",
									  method => 'DELETE',
					},
					$V{ START } => {
									 uri    => "/ipds/waf/<$K{WAF}>/actions",
									 method => 'POST',
									 params => {
												 'action' => 'start',
									 },
					},
					$V{ STOP } => {
									uri    => "/ipds/waf/<$K{WAF}>/actions",
									method => 'POST',
									params => {
												'action' => 'stop',
									},
					},
	},
	'ipds-waf-rule' => {
						 $V{ GET } => {
										uri => "/ipds/waf/<$K{WAF}>/rules/$Define::UriParamTag",
										method => 'GET',
										uri_param => $uri_param_rule,
						 },
						 $V{ CREATE } => {
										   uri    => "/ipds/waf/<$K{WAF}>/rules",
										   method => 'POST',
						 },
						 $V{ SET } => {
										uri => "/ipds/waf/<$K{WAF}>/rules/$Define::UriParamTag",
										method => 'PUT',
										uri_param => $uri_param_rule,
						 },
						 $V{ DELETE } => {
										  uri => "/ipds/waf/<$K{WAF}>/rules/$Define::UriParamTag",
										  method => 'DELETE',
										  uri_param => $uri_param_rule,
						 },
						 $V{ MOVE } => {
								  uri => "/ipds/waf/<$K{WAF}>/rules/$Define::UriParamTag/actions",
								  method => 'POST',
								  uri_param => $uri_param_rule,
						 },
	},
	'ipds-waf-rule-match' => {
		  $V{ CREATE } => {
							uri    => "/ipds/waf/<$K{WAF}>/rules/$Define::UriParamTag/matches",
							method => 'POST',
							uri_param => $uri_param_rule,
		  },
		  $V{ SET } => {
				  uri => "/ipds/waf/<$K{WAF}>/rules/$Define::UriParamTag/matches/$Define::UriParamTag",
				  method => 'PUT',
				  uri_param => $uri_param_match,
		  },
		  $V{ DELETE } => {
				  uri => "/ipds/waf/<$K{WAF}>/rules/$Define::UriParamTag/matches/$Define::UriParamTag",
				  method => 'DELETE',
				  uri_param => $uri_param_match,
		  },
	},
};

1;
