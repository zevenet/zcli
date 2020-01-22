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

our $Rbl = {
			 'ipds-rbl' => {
							 $V{ LIST } => {
											 uri        => "/ipds/rbl",
											 method     => 'GET',
											 enterprise => 1,
							 },
							 $V{ GET } => {
											uri        => "/ipds/rbl/<$K{RBL}>",
											method     => 'GET',
											enterprise => 1,
							 },
							 $V{ CREATE } => {
											   uri        => "/ipds/rbl",
											   method     => 'POST',
											   enterprise => 1,
							 },
							 $V{ SET } => {
											uri        => "/ipds/rbl/<$K{RBL}>",
											method     => 'PUT',
											enterprise => 1,
							 },
							 $V{ DELETE } => {
											   uri        => "/ipds/rbl/<$K{RBL}>",
											   method     => 'DELETE',
											   enterprise => 1,
							 },
							 $V{ START } => {
											  uri    => "/ipds/rbl/<$K{RBL}>/actions",
											  method => 'POST',
											  params => {
														  'action' => 'start',
											  },
											  enterprise => 1,
							 },
							 $V{ STOP } => {
											 uri    => "/ipds/rbl/<$K{RBL}>/actions",
											 method => 'POST',
											 params => {
														 'action' => 'stop',
											 },
											 enterprise => 1,
							 },
							 $V{ ADD } => {
											uri        => "/ipds/rbl/<$K{RBL}>/domains",
											method     => 'POST',
											enterprise => 1,
							 },
							 $V{ REMOVE } => {
										  uri => "/ipds/rbl/<$K{RBL}>/domains/<$K{DOMAIN}>",
										  method     => 'POST',
										  enterprise => 1,
							 },
			 },
			 'ipds-rbl-domains' => {
									 $V{ LIST } => {
													 uri        => "/ipds/rbl/domains",
													 method     => 'GET',
													 enterprise => 1,
									 },
									 $V{ CREATE } => {
													   uri        => "/ipds/rbl/domains",
													   method     => 'POST',
													   enterprise => 1,
									 },
									 $V{ SET } => {
													uri => "/ipds/rbl/domains/<$K{DOMAIN}>",
													method     => 'PUT',
													enterprise => 1,
									 },
									 $V{ DELETE } => {
													uri => "/ipds/rbl/domains/<$K{DOMAIN}>",
													method     => 'DELETE',
													enterprise => 1,
									 },
			 },
};

1;
