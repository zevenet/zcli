#!/usr/bin/perl
###############################################################################
#
#    ZEVENET Software License
#    This file is part of the ZEVENET Load Balancer software package.
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

our $Certificates = {
	'certificate' => {
		$V{ LIST } => {
						uri    => "/certificates",
						method => 'GET',
		},
		$V{ DOWNLOAD } => {
							uri           => "/certificates/<$K{CERT}>",
							method        => 'GET',
							download_file => undef,
		},
		$V{ GET } => {
					   uri    => "/certificates/<$K{CERT}>/info",
					   method => 'GET',
		},
		$V{ DELETE } => {
						  uri    => "/certificates/<$K{CERT}>",
						  method => 'DELETE',
		},
		$V{ CREATE } => {
						  uri    => "/certificates",
						  method => 'POST',
		},
		$V{ UPLOAD } => {
			uri          => "/certificates/$Define::Uri_param_tag",
			method       => 'POST',
			content_type => 'application/x-pem-file',
			upload_file  => undef,
			param_uri    => [
				{
				   name => "name",
				   desc =>
					 "the name which the certificate will be saved. The file has to have the extension '.pem'",
				},
			],
		},
	},

	# It is not useful for a ZCLI
	# 				  'certificates-ciphers' => {
	# 											  $V{ LIST } => {
	# 															  uri    => "/ciphers",
	# 															  method => 'GET',
	# 											  },
	# 				  },
	'certificate-le-config' => {
								  $V{ LIST } => {
												  uri    => "/certificates/letsencryptz/config",
												  method => 'GET',
								  },
								  $V{ SET } => {
												 uri    => "/certificates/letsencryptz/config",
												 method => 'PUT',
								  }
	},
	'certificate-le' => {
								  $V{ LIST } => {
												  uri    => "/certificates/letsencryptz",
												  method => 'GET',
								  },
								  $V{ CREATE } => {
												  uri    => "/certificates/letsencryptz",
												  method => 'POST',
												  params_arr => {
															 'domains' => 1,
											      },
								  },
								  $V{ RENEW } => {
												  uri    => "/certificates/letsencryptz/<$K{CERT}>/actions",
												  method => 'POST',
												  params => {
													   'action' => 'renew',
										   		  },
								  },
								  $V{ DELETE } => {
												  uri    => "/certificates/letsencryptz/<$K{CERT}>",
												  method => 'DELETE',
								  }
	},
	'certificate-le-wildcard' => {
								  $V{ CREATE } => {
												  uri    => "/certificates/letsencryptz-wildcard",
												  method => 'POST',
												  params_arr => {
															 'domains' => 1,
											      },
								  },
								  $V{ RENEW } => {
												  uri    => "/certificates/letsencryptz-wildcard/<$K{CERT}>/actions",
												  method => 'POST',
												  params => {
													   'action' => 'renew',
										   		  },
								  },
								  $V{ TEST } => {
												  uri    => "/certificates/letsencryptz-wildcard/<$K{CERT}>/actions",
												  method => 'POST',
												  params => {
													   'action' => 'test',
										   	 	  },
								  },
								  $V{ DELETE } => {
												  uri    => "/certificates/letsencryptz-wildcard/<$K{CERT}>",
												  method => 'DELETE',
								  }
	},
};

1;
