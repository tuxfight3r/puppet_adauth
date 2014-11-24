#
class adauth::params {
  $krbcfg_template       = 'adauth/etc/krb5.conf.erb'
  $sssdcfg_template      = 'adauth/etc/sssd/sssd.conf.erb'
  $package_ensure        = 'present'
  $ad_description        = 'AD'
  $ad_domain             = ''
  $ad_servers            = [] 
  $adbind_userdn         = ''
  $adbind_pass           = ''
  $aduser_search_base    = ''
  $adgroup_search_base   = ''
  $service_enable        = true
  $service_ensure        = 'running'
  $service_manage        = true
  $service_name          = 'sssd'

case $::osfamily {
    'RedHat': {
      $sssd_config     = '/etc/sssd/sssd.conf'
      $krb_config      = '/etc/krb5.conf'
      $package_name    = [
  'sssd',
  'sssd-client',
  'krb5-workstation',
  'samba-client',
  'openldap-clients',
  'policycoreutils-python'
      ]
    }

    default: {
      fail("The ${module_name} module is not supported on an ${::osfamily} based system.")
    }
  }
}
