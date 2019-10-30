#!/usr/bin/perl

use strict;
use warnings;

require "./Define.pm";

# verbs
my %V = %Define::Actions;

# keys
my %K = %Define::Keys;

package Objects;

our $Rbl = {
			 'ipds-rbl' => {
							 $V{ LIST } => {
											 uri    => "/ipds/rbl",
											 method => 'GET',
							 },
							 $V{ GET } => {
											uri    => "/ipds/rbl/<$K{RBL}>",
											method => 'GET',
							 },
							 $V{ CREATE } => {
											   uri    => "/ipds/rbl",
											   method => 'POST',
							 },
							 $V{ SET } => {
											uri    => "/ipds/rbl/<$K{RBL}>",
											method => 'PUT',
							 },
							 $V{ DELETE } => {
											   uri    => "/ipds/rbl/<$K{RBL}>",
											   method => 'DELETE',
							 },
							 $V{ START } => {
											  uri    => "/ipds/rbl/<$K{RBL}>/actions",
											  method => 'POST',
											  params => {
														  'action' => 'start',
											  },
							 },
							 $V{ STOP } => {
											 uri    => "/ipds/rbl/<$K{RBL}>/actions",
											 method => 'POST',
											 params => {
														 'action' => 'stop',
											 },
							 },
							 $V{ ADD } => {
											uri    => "/ipds/rbl/<$K{RBL}>/domains",
											method => 'POST',
							 },
							 $V{ REMOVE } => {
										   uri => "/ipds/rbl/<$K{RBL}>/domains/<$K{DOMAIN}>",
										   method => 'POST',
							 },
			 },
			 'ipds-rbl-domains' => {
									 $V{ LIST } => {
													 uri    => "/ipds/rbl/domains",
													 method => 'GET',
									 },
									 $V{ CREATE } => {
													   uri    => "/ipds/rbl/domains",
													   method => 'POST',
									 },
									 $V{ SET } => {
													uri => "/ipds/rbl/domains/<$K{DOMAIN}>",
													method => 'PUT',
									 },
									 $V{ DELETE } => {
													 uri => "/ipds/rbl/domains/<$K{DOMAIN}>",
													 method => 'DELETE',
									 },
			 },
};

1;
