
# What is ZCLI

ZCLI is the acronym of Zevenet Command Line Interface. This tool allows managing multiple load balancers from a command line or automatizes load balancer actions in the operation scripts.

ZCLI is a wrapper of the ZAPI (Zevenet Application Programming Interface), it has an autocompletion feature to navigate easier for the load balancer modules and its items.

*It depends on the Zevenet EE 6.1 or higher.*



# How to use

The ZCLI user guide is in the following link, [guide](????).





# How to build

Those are the perl modules dependencies and the steps to create the package for different distributions.

## CPAN dependencies

`cpan install JSON Term::Shell Hash::Merge LWP::Protocol::Https Term::ShellUI Config::Tiny IO:Socket:Ssl JSON::Color IO::Pager`


## Debian

- Install cpan dependences.
- Execute **gen_pkg.sh** script: `./gen_pkg.sh`


## Windows

Steps to build:

- Install Strawberry Perl for windows (It was tested with strawberry-perl-5.16.3.1-64bit.msi)
- Install CPAN dependences adding the **pp** package
- Build package (from the root repo directory) adding the **.exe** extension:
`pp -c -m -x -I src/ -M ZCLI::Define -M ZCLI::Lib -M ZCLI::Objects -o zcli.exe src/zcli.pl`


* These steps are based on the following links:*
https://metacpan.org/pod/pp
https://stackoverflow.com/questions/8055063/how-to-install-pp-par-packager



# Implementation

This section explains some implementation details.

## Building a command

The command line arguments look like:
```
command line:    zcli [options] <object> <action> [         ids list         ] [              param_body list              ]
zcli internally: zcli [options] <object> <action> [ids list] [ids_params list] [file_upload|download] [param_body list|json]
```

*Note: The `options` arguments are only checked in the ZCLI invoke. The options are available using `zcli help`.*

The command parses the input arguments to execute an HTTP request to the ZAPI. A command internally has the following syntaxis:

The command syntasis:
```
zcli <object> <action> [ids list] [ids_params list] [file_upload|download] [param_body list|json]
         |       |       |                 |               |                      |
         |       |       ---------------------------------------------------------------> They are ZAPI parameters
         -------------------------------------------------------------------------------> Defines ZAPI request
```

- object: it is the kind of object of the load balancer selected.
- action: it is the verb to execute.
- ids list: they are mandatories and they identify the object selected. They are taken from Zevenet with the GET /ids ZAPI request. It is used to make the HTTP URI. If the object is a subobject (e.g. service) the previous keys are mandatories (e.g. farm name).
- ids_params list: they are ids mandatories that cannot be parsed from id tree. It is used to make the URI. e.g.: the number of lines to show from a log file.
- file_upload and file_download: it is the local file to upload/download to/from the load balancer.
- param_body: They are the JSON parameters that are sent in the ZAPI request. The parameter name is indicated using the hyphen operator followed by the value (e.g.: -vip 192.168.100.144). This field can use the JSON input format using the option *-j*.

Some examples:

* Modifiying the backend *0* of the service *service1* of the farm *farm1*:
`zcli farms-services-backend modify farm1 service1 0 -ip 1.1.1.1 -port 80`
* Downloading the backup *backup-200320* and saving it as *backup1.tar.gz*:
`zcli system-backup download backup-200320 backup1.tar.gz`
* Uploading the backup *backup1.tar.gz* and it's created with the name *backup-cfg*:
`zcli system-backup upload backup-cfg backup1.tar.gz`
* Modifying the source  with ID *0*  of the blacklist *denied_ips*:
`zcli ipds-blacklist-source set denied_ipds 0 -source 32.21.12.4`


How ZCLI expands the command internally:

object   | action  | ids list | ids_params list | file to upload or download | param_body list or json format
-------- | ------- | -------- | --------------- | -------------------------- | --------------------------------
farms-services-backend    | modify    | farm1 service1 0    |     |                     | -ip 1.1.1.1 -port 80
system-backup            | download    | backup-200320        |     | backup1.tar.gz    |
system-backup            | upload    | backup-cfg        |     | backup1.tar.gz    |
ipds-blacklist-source    | set        | denied_ips        | 0    |                    | -source 32.21.12.4



## Defining objects to create commands based on ZAPI.

The command objects are used to implement the ZCLI commands and they are defined in the directory src/ZCLI/Objects.
Each object has a list of options that define how to implement the ZAPI request.

Module key used in ZCLI commands
```
'command-obj' => {

    # action key used in ZCLI commands. There are reserved words in Define.pm module to be used here.
    'action' => {

        # 'uri' is the URI used for the ZAPI request. It can contain two kind of 'parameters' inside:
        #    '<id>' is a id parameter of the command and has to match with one element of the IDs tree of the load balancer.
        #        Those parameters are delemited for the characeters '<' and '>'
        #    '$Define::Uri_param_tag' is a id_param parameter of the command and it is not implemented in the IDs tree of the load balancer.
        #       The name for this value is in the key of this hash 'param_uri'.
        #       The string that defines this parameters is defined in the Define module of ZCLI.
        uri       => "/system/logs/<$K{LOG}>/lines/$Define::Uri_param_tag",

        # 'method' is the HTTP method used to do the ZAPI request.
        method       => 'PUT',

        # 'content_type' is the content_type header used to send the request parameters in PUT and POST requests.
        #       If this parameter is missing, the 'application/json' value will be used.
        content_type => 'application/gzip',

        # 'upload_file' is a flag to invoke the autocomplete subrutine and to require to upload a local file. It has the 'undef' value.
        upload_file  => undef,

        # 'download_file' is a flag to invoke the autocomplete subrutine and to require to upload a local file. It has the 'undef' value.
        download_file => undef,

        # 'param_uri' is the parameter name for 'ids_params'. This list is sort. Each element contains a 'name' and a 'desc' (description) field
        param_uri    => [
            {
                name => "name",
                desc => "the name which the backup will be saved",
            },
        ],
        # 'params' is a hash with pre-defined parameters. They are useful to create macros of command that does not need to modify
        #      its values as 'restart', 'stop'... Each element of this hash uses as key the parameter name and as value the value name.
        params => {
            'action' => 'stop',
        }

        # The option 'enterprise' is set to '1' when that call is exclusive of EE
        enterprise => 1,

        # 'params_autocomplete' defines how to autocomplete a parameter
        params_autocomplete => {
                name =>        # name of the parameter to autocomplete
                    'ipds/blacklists',    # it is the information to look for the IDs to autocomplete. The keys of the id tree is separated by '/'.
        }
    }
}
```

Examples:

```
'farms-services' => {
    $V{ CREATE } => {
                      uri    => "/farms/<$K{FARM}>/services",
                      method => 'POST',
    },
    $V{ SET } => {
                   uri    => "/farms/<$K{FARM}>/services/<$K{SRV}>",
                   method => 'PUT',
    },
},

'farms' => $V{ STOP } => {
                     uri    => "/farms/<$K{FARM}>/actions",
                     method => 'PUT',
                     params => {
                                 'action' => 'stop',
                     },
     },
},

'system-backups' => {
      $V{ DOWNLOAD } => {
                          uri    => "/system/backup/<$K{BACKUP}>",
                          method => 'GET',
                          download_file => undef,
      },
      $V{ UPLOAD } => {
              uri          => "/system/backup/$Define::Uri_param_tag",
              method       => 'PUT',
              content_type => 'application/gzip',
              upload_file  => undef,
              param_uri    => [
                    {
                        name => "name",
                        desc => "the name which the backup will be saved",
                    },
              ],
      },
},
```

Note: In the ZCLI module `Defines.pm` there are some macros to implement verbs and keys for the URIs.


## The module Interactive

It is the module that implements the interactive feature using the `Term::ShellUI` perl module.
It uses the definitions of the objects to expand a command tree with the possible actions and required parameters.

The expansion is done using the object `$Objects::Zcli` as a template and creating the `$Env::Zcli_cmd_st` command struct.

ZCLI code uses following flow:

```
-> reloadCmdStruct
-> createZcliCmd
-> createCmdObject add_ids(recursively) create a temporality description using 'create_description'
-> gen_act:
    |-> $def->{ desc } = getCmdDescription(): creates the command syntaxis for the input arguments.
    |-> $def->{ proc } = geCmdProccessCallback(): is the subrutine that executes the ZAPI request.
    |-> $def->{ args } = getCmdArgsCallBack() : parses the input parameters and autocomplete the next expected parameter.
                | ->completeArgsBodyParams(): autocompletes the next expected HTTP body parameter, checking between keys and values in the JSON.
                    |-> listParams(): Do a ZAPI request without parameters to get the list of possible body parameters.

```

