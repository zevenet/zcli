#!/usr/bin/perl

use strict;
use warnings;

require "./Define.pm";

# verbs
my %V = %Define::Actions;

# keys
my %K = %Define::Keys;

package Objects;

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
										uri => "/ipds/waf/<$K{WAF}>/rules/<$K{WAF_RULE}>",
										method => 'GET',
						 },
						 $V{ CREATE } => {
										   uri    => "/ipds/waf/<$K{WAF}>/rules",
										   method => 'POST',
						 },
						 $V{ SET } => {
										uri => "/ipds/waf/<$K{WAF}>/rules/<$K{WAF_RULE}>",
										method => 'PUT',
						 },
						 $V{ DELETE } => {
										  uri => "/ipds/waf/<$K{WAF}>/rules/<$K{WAF_RULE}>",
										  method => 'DELETE',
						 },
						 $V{ MOVE } => {
								  uri => "/ipds/waf/<$K{WAF}>/rules/<$K{WAF_RULE}>/actions",
								  method => 'POST',
						 },
	},
	'ipds-waf-rule-match' => {
		  $V{ CREATE } => {
							uri    => "/ipds/waf/<$K{WAF}>/rules/<$K{WAF_RULE}>/matches",
							method => 'POST',
		  },
		  $V{ SET } => {
				  uri => "/ipds/waf/<$K{WAF}>/rules/<$K{WAF_RULE}>/matches/<$K{WAF_MATCH}>",
				  method => 'PUT',
		  },
		  $V{ DELETE } => {
				  uri => "/ipds/waf/<$K{WAF}>/rules/<$K{WAF_RULE}>/matches/<$K{WAF_MATCH}>",
				  method => 'DELETE',
		  },
	},
};

1;
