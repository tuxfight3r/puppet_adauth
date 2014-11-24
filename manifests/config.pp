#
class adauth::config inherits adauth {

  file { $krb_config:
    ensure  => file,
    owner   => 0,
    group   => 0,
    mode    => '0644',
    content => template($krbcfg_template),
  }

  file { $sssd_config:
    ensure  => file,
    owner   => 0,
    group   => 0,
    mode    => '0600',
    content => template($sssdcfg_template),
    notify  => Class['adauth::service'],
  }

  #Ugly hack needs to be fixed
  #backups are stored in /var/lib/authconfig/backup-authconfig.$(date +%Y-%m-%d)
  exec { "backup_authconfig":
    command => "authconfig --savebackup=authconfig.$(date +%Y%m%d.%H)",
    path    => [ "/usr/local/sbin:/sbin:/usr/sbin:/bin:/usr/bin:/usr/local/bin" ],
    unless  => "test -d /var/lib/authconfig/backup-authconfig.$(date +%Y%m%d.%H)",
  }

  #update pam modules for AD authentication
  exec { "run_authconfig":
    command => "authconfig --enablesssd --enablesssdauth --enablemkhomedir --update",
    path    => [ "/usr/local/sbin:/sbin:/usr/sbin:/bin:/usr/bin:/usr/local/bin" ],
    onlyif  => "test $(grep -c 'files sss' /etc/nsswitch.conf) -lt 5",
    require => Exec['backup_authconfig'],
  }

}
