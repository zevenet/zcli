#!/usr/bin/perl

use strict;
use warnings;

use ZCLI::Define;

# verbs
my %V = %Define::Actions;

# keys
my %K = %Define::Keys;

package Objects;

our $Routing = {
				 'network-routing-rules' => {
								   $V{ LIST } => {
												   uri    => "/routing/rules",
												   method => 'GET',
								   },
								   $V{ CREATE } => {
													 uri    => "/routing/rules",
													 method => 'POST',
								   },
								   $V{ SET } => {
												    uri => "/routing/rules/$Define::UriParamTag",
												    method => 'PUT',
                                                    uri_param    => [
                                                            {
                                                                name => "rule",
                                                                desc => "the rule id of the rule that is going to be modified",
                                                            },
		                						    ],
								   },
								   $V{ DELETE } => {
												   uri => "/routing/rules/$Define::UriParamTag",
												   method => 'DELETE',
                                                   uri_param    => [
                                                            {
                                                                name => "rule",
                                                                desc => "the rule id of the rule that is going to be deleted",
                                                            },
		                						    ],
								   },
                 },
                 'network-routing-tables' => {
								   $V{ LIST } => {
												   uri    => "/routing/tables",
												   method => 'GET',
								   },
                                   $V{ GET } => {
												   uri    => "/routing/tables/<$K{ROUTING_TABLE}>",
												   method => 'GET',
								   },
								   $V{ CREATE } => {
													 uri    => "/routing/tables/<$K{ROUTING_TABLE}>/routes",
													 method => 'POST',
								   },
								   $V{ SET } => {
												  uri => "/routing/tables/<$K{ROUTING_TABLE}>/routes/$Define::UriParamTag",
												  method => 'PUT',
                                                  uri_param    => [
                                                            {
                                                                name => "id",
                                                                desc => "the route id of the route that is going to be modified",
                                                            },
		                						    ],
								   },
								   $V{ DELETE } => {
												   uri => "/routing/tables/<$K{ROUTING_TABLE}>/routes/$Define::UriParamTag",
												   method => 'DELETE',
                                                   uri_param    => [
                                                            {
                                                                name => "id",
                                                                desc => "the route id of the route that is going to be modified",
                                                            },
		                						    ],
								   },
				 },  
                 'network-routing-tables-unmanaged' => {
								   $V{ LIST } => {
												   uri    => "/routing/tables",
												   method => 'GET',
								   },
								   $V{ ADD } => {
													 uri    => "/routing/tables/<$K{ROUTING_TABLE}>/unmanaged",
													 method => 'POST',
								   },
								   $V{ REMOVE } => {
												   uri => "/routing/tables/<$K{ROUTING_TABLE}>/unmanaged/$Define::UriParamTag",
												   method => 'DELETE',
                                                   uri_param    => [
                                                            {
                                                                name => "interface",
                                                                desc => "the interface name that is going to be managed for the table",
                                                            },
		                						    ],
								   },
				 },
};

1;
