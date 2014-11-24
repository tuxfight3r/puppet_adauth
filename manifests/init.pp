#
class adauth(
  $krb_config           = $adauth::params::krb_config,
  $krbcfg_template      = $adauth::params::krbcfg_template,
  $sssd_config          = $adauth::params::sssd_config,
  $sssdcfg_template     = $adauth::params::sssdcfg_template,
  $package_ensure       = $adauth::params::package_ensure,
  $package_name         = $adauth::params::package_name,
  $ad_description       = $adauth::params::description,
  $ad_domain            = $adauth::params::ad_domain,
  $ad_servers           = $adauth::params::ad_servers,
  $adbind_userdn        = $adauth::params::adbind_userdn,
  $adbind_pass          = $adauth::params::adbind_pass,
  $aduser_search_base   = $adauth::params::aduser_base,
  $adgroup_search_base  = $adauth::params::adgroup_base,
  $service_enable       = $adauth::params::service_enable,
  $service_ensure       = $adauth::params::service_ensure,
  $service_manage       = $adauth::params::service_manage,
  $service_name         = $adauth::params::service_name,
) inherits adauth::params {

  validate_absolute_path($krb_config)
  validate_string($krbcfg_template)
  validate_absolute_path($sssd_config)
  validate_string($sssdcfg_template)
  validate_string($package_ensure)
  validate_array($package_name)
  validate_string($ad_domain)
  validate_array($ad_servers)
  validate_string($adbind_userdn)
  validate_string($adbind_pass)
  validate_string($aduser_search_base)
  validate_string($adgroup_search_base)
  validate_bool($service_enable)
  validate_string($service_ensure)
  validate_bool($service_manage)
  validate_string($service_name)

  anchor { 'adauth::begin': } ->
  class { '::adauth::install': } ->
  class { '::adauth::config': } ~>
  class { '::adauth::service': } ->
  anchor { 'adauth::end': }

}
