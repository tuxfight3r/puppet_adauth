# Puppet module for AD authentication with SSSD and Kerberos

####Table of Contents

1. [Overview](#overview)
2. [Module Description - What the module does and why it is useful](#module-description)
3. [Setup - The basics of getting started with adauth](#setup)
    * [What adauth affects](#what-ntp-affects)
	* [Usage - Configuration options and additional functionality](#usage)
4. [Reference - An under-the-hood peek at what the module is doing and how](#reference)
5. [Troubleshooting - Fixing issues](#troubleshooting)

##Overview

The adauth module installs, configures and manages sssd daemon with kerberos.

##Module Description

The adauth module is supposed to make AD authentication of linuxboxes against AD really simple for redhat/centos boxes.

### Prerequisites

* Networking - Either both machines(AD/Jumpbox) lie on the same subnet or the relevanet firewall ports are open.
 (Relevant ports can be found here: http://technet.microsoft.com/en-us/library/dd772723%28v=ws.10%29.aspx )
* AD Server is prepped with the below steps
* Requires Puppetlabs Stdlib module

###Windows AD Preparation in Short

In Server Manager, add the Role Service "Identity Management for UNIX". This is under the Role 
"Active Directory Domain Services". When it asks, use your AD domain name as the NIS name. 
For example, with a AD domain of test.local, use test.

Create 2 Groups LinuxAdmins, LinuxUsers with gid (10000,10001) and shell = /bin/bash, home dir = /home/<DOMAIN>/<USERID>

Edit relevant users -> go to nix Attributes and configure (shell,homedir, primary group (LinuxUsers)),
 add them to LinuxAdmins group if needed. 

This module is written with reference to the following article from chirscowley.me.uk
http://www.chriscowley.me.uk/blog/2013/12/16/integrating-rhel-with-active-directory/

please follow above with the above link for the full article.

If needed to provide sudo access to the users, Add the relevant LinuxAdmins group to sudoers.

##Setup

###what adauth affects

* packages - ssd sssd-client krb5-workstation samba-client openldap-clients policycoreutils-python
* kerberos config - /etc/krb5.conf 
* sssd config - /etc/sssd/sssd.config
* sssd service

###Begininng with adauth

##Usage

adauth requires a minimum of the following parameters passed to it to function properly

```puppet
class { '::adauth':
  ad_domain 			=> 'test.local'
  ad_servers 			=> [ 'ads01.test.local', 'ads02.test.local' ], 
  adbind_userdn			=> 'CN=UnixLookup,OU=TEST Users & Groups,DC=test,DC=local',
  adbind_pass			=> 'S3cretPassw0rd',
  aduser_search_base	=> 'DC=test,DC=local',
  adgroup_search_base	=> 'DC=test,DC=local',
}
```

###I'd like to stop the service from autostarting and use a different template

```puppet
class { '::adauth':
  ad_domain 			=> 'test.local'
  ad_servers 			=> [ 'ads01.test.local', 'ads02.test.local' ], 
  adbind_userdn			=> 'CN=UnixLookup,OU=TEST Users & Groups,DC=test,DC=local',
  adbind_pass			=> 'S3cretPassw0rd',
  aduser_search_base	=> 'DC=test,DC=local',
  adgroup_search_base	=> 'DC=test,DC=local',
  service_ensure		=> 'stopped',
  krbcfg_template		=> 'different/module/custom.template.erb',  
}
```

### I'd like to use it with an existing Hiera Installation. Add the following lines to your yaml file and include the class adauth

```puppet
adauth::package_ensure: latest
adauth::service_enable: true
adauth::service_ensure: running
#Domain Description     
adauth::ad_description: 'TEST AD DOMAIN'
adauth::ad_domain: 'test.local'
#Server Array
adauth::ad_servers: 
  - ads01.test.local
  - ads02.test.local
#AD Bind User
adauth::adbind_userdn: 'CN=UnixLookup,OU=TEST Users & Groups,DC=test,DC=local'
adauth::adbind_pass: 'S3cretPassw0rd'
adauth::aduser_search_base: 'DC=test,DC=local'
adauth::adgroup_search_base: 'DC=test,DC=local'
```

### I'd like to run it as a standalone module on machines
Lets say the adauth module is downloaded into a directory /root/puppet_modules.
you need stdlib modules under the modulepath for it to work properly. If the module 
is downloaded into a different location update the hieradata/hiera.yaml datadir path.


```puppet
#Remove --noop when you wanted to apply the changes
puppet apply --modulepath=/root/puppet_modules -e 'include ::adauth' \
 --hiera_config=/root/puppet_modules/adauth/hieradata/hiera.yaml --verbose --noop
```

##Reference

###Classes

####Public Classes

* adauth: Main Class, includes all other classes.

####Private Classes

* adauth::install: Handles the packages.
* adauth::config: Handles the configuration files
* aduath::service: Handles the service

###Parameters

The following parameters are available in the adauth module: 

####`krb_config`

Sets the file that kerberos configuration is written into.

####`krbcfg_template`

Determines which template Puppet should use for the kerberos configuration.

####`sssd_config`

Sets the file that sssd configuration is written into.

####`sssdcfg_template`

Determines which template Puppet should use for the sssd configuration.

####`package_ensure`

Sets the packages version to be installed. Can be set to 'present', 'latest', or a specific version. 

####`package_name`

Determines the name of the package to install. (Array of packages to be passed)

####`service_enable`

Determines if the service should be enabled at boot.

####`service_ensure`

Determines if the service should be running or not.

####`service_manage`

Selects whether Puppet should manage the service.

####`service_name`

Selects the name of the ntp service for Puppet to manage.

##AD SPECIFIC OPTIONS

####`ad_description`

Sets the description for the AD Domain.

####`ad_domain`

Sets the domain which we are going to authenticate against AD.

####`ad_servers`

Sets the servers FQDN for the domain which we are going to authenticate against.

####`adbind_userdn`

Sets the username dn created on the AD to do AD queries.

####`adbind_pass`

Sets the password for the adbind username created on the AD.

####`aduser_search_base`

Sets the AD search path for querying the users in domain.

####`adgroup_search_base`

Sets the AD search path for querying the groups in domain.

##Troubleshooting

####Finding the AD servers FQDN by SRV Record

```puppet
dig -t SRV _ldap._tcp.test.local
```

####check if kerberos setup properly

```puppet
#kinit aduser - (it should prompt for the user and if it works klist should display the TGT)

#klist
```

####Query AD via ldap

```puppet
#kinit aduser (upon successfull authentication )

#search user
ldapsearch -H ldap://ads01.nzp.local:3268 -Y GSSAPI -b "dc=test,dc=local" "(&(objectClass=user)(sAMAccountName=mbalasundaram))"

#search group
ldapsearch -H ldap://ads01.nzp.local:3268 -Y GSSAPI -b "dc=test,dc=local" "(&(objectClass=group)(sAMAccountName=LinuxAdmins))"
```

####Todo
 - clean the exec method used
 - write puppet rspec tests for the module

