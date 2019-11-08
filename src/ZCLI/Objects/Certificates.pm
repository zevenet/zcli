#!/usr/bin/perl

use strict;
use warnings;

use ZCLI::Define;

# verbs
my %V = %Define::Actions;

# keys
my %K = %Define::Keys;

package Objects;

our $Certificates = {
				  'certificates' => {
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
								  uri          => "/certificates/$Define::UriParamTag",
								  method       => 'POST',
								  content_type => 'application/x-pem-file',
								  upload_file  => undef,
								  uri_param    => [
										{
											name => "name",
											desc => "the name which the certificate will be saved",
										},
								  ],
						  },
				  },
				  'certificates-ciphers' => {
											  $V{ LIST } => {
															  uri    => "/ciphers",
															  method => 'GET',
											  },
				  },
};

1;
