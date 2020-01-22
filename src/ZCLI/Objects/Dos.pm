#!/usr/bin/perl

use strict;
use warnings;

use ZCLI::Define;

# verbs
my %V = %Define::Actions;

# keys
my %K = %Define::Keys;

package Objects;

our $Dos = {
			 'ipds-dos' => {
							 $V{ LIST } => {
											 uri        => "/ipds/dos",
											 method     => 'GET',
											 enterprise => 1,
							 },
							 $V{ GET } => {
											uri        => "/ipds/dos/<$K{DOS}>",
											method     => 'GET',
											enterprise => 1,
							 },
							 $V{ CREATE } => {
											   uri        => "/ipds/dos",
											   method     => 'POST',
											   enterprise => 1,
							 },
							 $V{ SET } => {
											uri        => "/ipds/dos/<$K{DOS}>",
											method     => 'PUT',
											enterprise => 1,
							 },
							 $V{ DELETE } => {
											   uri        => "/ipds/dos/<$K{DOS}>",
											   method     => 'DELETE',
											   enterprise => 1,
							 },
							 $V{ START } => {
											  uri    => "/ipds/dos/<$K{DOS}>/actions",
											  method => 'POST',
											  params => {
														  'action' => 'start',
											  },
											  enterprise => 1,
							 },
							 $V{ STOP } => {
											 uri    => "/ipds/dos/<$K{DOS}>/actions",
											 method => 'POST',
											 params => {
														 'action' => 'stop',
											 },
											 enterprise => 1,
							 },
			 },
};

1;
