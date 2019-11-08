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
											 uri    => "/ipds/dos",
											 method => 'GET',
							 },
							 $V{ GET } => {
											uri    => "/ipds/dos/<$K{DOS}>",
											method => 'GET',
							 },
							 $V{ CREATE } => {
											   uri    => "/ipds/dos",
											   method => 'POST',
							 },
							 $V{ SET } => {
											uri    => "/ipds/dos/<$K{DOS}>",
											method => 'PUT',
							 },
							 $V{ DELETE } => {
											   uri    => "/ipds/dos/<$K{DOS}>",
											   method => 'DELETE',
							 },
							 $V{ START } => {
											  uri    => "/ipds/dos/<$K{DOS}>/actions",
											  method => 'POST',
											  params => {
														  'action' => 'start',
											  },
							 },
							 $V{ STOP } => {
											 uri    => "/ipds/dos/<$K{DOS}>/actions",
											 method => 'POST',
											 params => {
														 'action' => 'stop',
											 },
							 },
			 },
};

1;
