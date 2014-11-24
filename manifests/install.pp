#
class adauth::install inherits adauth {

  #bug cannot pass array of packages to name variable
  package { $package_name:
    ensure => $package_ensure,
    #name   => $package_name,
  }

}

