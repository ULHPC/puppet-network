# File::      <tt>network-interface.pp</tt>
# Author::    Sebastien Varrette (<Sebastien.Varrette@uni.lu>)
# Copyright:: Copyright (c) 2011 Sebastien Varrette (www[http://varrette.gforge.uni.lu])
# License::   GPLv3
#
# ------------------------------------------------------------------------------
# = Define: network::interface
#
# Configure a network interfaces (in /etc/network/interfaces typically)
#
# == Parameters:
#
# TODO
#
# == Examples
#
#  include 'network'
#  network::interface { 'eth0': 
#       auto => true,
#       dhcp => true,
#  }
#
#
#
# == Warnings
#
# /!\ Always respect the style guide available
# here[http://docs.puppetlabs.com/guides/style_guide]
#
# [Remember: No empty lines between comments and class definition]
#
define network::interface(
    $comment   = '',
    $address   = '',
    $gateway   = '',
    $netmask   = '255.255.0.0',
    $network   = '',
    $broadcast = '',
    $auto      = true,
    $manual    = false,
    $dhcp      = true,
    $ensure    = 'present',
    $priority  = 50
)
{

    include network::params

    if (! $manual) and (! $dhcp) and ($address == '') {
        fail("Wrong format in the configuration of the network interface ${interface}")
    }
    
    # $name is provided by define invocation
    # guid of this entry
    $interface = $name

    # TODO: compute directly network and broadcast from $adress and $netmask....
    
    concat::fragment { "${network::params::config_interface_label}_${interface}": 
        target  => "${network::params::interfacesfile}",
        ensure  => "${ensure}",
        content => template("network/network-interface.erb"),
        order   => $priority,
    }
}







