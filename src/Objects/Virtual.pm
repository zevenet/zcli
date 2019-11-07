#!/usr/bin/perl

use strict;
use warnings;

require "./Define.pm";

# verbs
my %V = %Define::Actions;

# keys
my %K = %Define::Keys;

package Objects;

our $Virtual = {
				 'network-virtual' => {
								   $V{ LIST } => {
												   uri    => "/interfaces/virtual",
												   method => 'GET',
								   },
								   $V{ GET } => {
												  uri => "/interfaces/virtual/<$K{IFACE}>",
												  method => 'GET',
								   },
								   $V{ CREATE } => {
													 uri    => "/interfaces/virtual",
													 method => 'POST',
								   },
								   $V{ SET } => {
												  uri => "/interfaces/virtual/<$K{IFACE}>",
												  method => 'PUT',
								   },
								   $V{ DELETE } => {
												   uri => "/interfaces/virtual/<$K{IFACE}>",
												   method => 'DELETE',
								   },
								   $V{ START } => {
										   uri => "/interfaces/virtual/<$K{IFACE}>/actions",
										   method => 'POST',
										   params => {
													   'action' => 'up',
										   },
								   },
								   $V{ STOP } => {
										   uri => "/interfaces/virtual/<$K{IFACE}>/actions",
										   method => 'POST',
										   params => {
													   'action' => 'down',
										   },
								   },
				 },
};

1;
