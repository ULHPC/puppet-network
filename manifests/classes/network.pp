# File::      <tt>network.pp</tt>
# Author::    Sebastien Varrette (Sebastien.Varrette@uni.lu)
# Copyright:: Copyright (c) 2011 Sebastien Varrette
# License::   GPLv3
#
# ------------------------------------------------------------------------------
# = Class: network
#
# Configure various network aspects (interfaces etc.)
#
# == Parameters:
#
# $ensure:: *Default*: 'present'. Ensure the presence (or absence) of network
#
# == Actions:
#
# Install and configure network
#
# == Requires:
#
# n/a
#
# == Sample Usage:
#
#     import network
#
# You can then specialize the various aspects of the configuration,
# for instance:
#
#         class { 'network':
#             ensure => 'present'
#         }
#
# == Warnings
#
# /!\ Always respect the style guide available
# here[http://docs.puppetlabs.com/guides/style_guide]
#
#
# [Remember: No empty lines between comments and class definition]
#
class network inherits network::params
{
    info ("Configuring network interfaces")


    case $::operatingsystem {
        debian, ubuntu:         { include network::debian }
        default: {
            fail("Module $module_name is not supported on $operatingsystem")
        }
    }
}

# ------------------------------------------------------------------------------
# = Class: network::common
#
# Base class to be inherited by the other network classes
#
# Note: respect the Naming standard provided here[http://projects.puppetlabs.com/projects/puppet/wiki/Module_Standards]
class network::common {

    # Load the variables used in this module. Check the network-params.pp file
    require network::params

    file { "${network::params::configdir}":
        ensure => 'directory',
        owner   => "${network::params::configdir_owner}",
        group   => "${network::params::configdir_group}",
        mode    => "${network::params::configdir_mode}",
    }

    include concat::setup

    concat { "${network::params::interfacesfile}":
        owner   => "${network::params::interfacesfile_owner}",
        group   => "${network::params::interfacesfile_group}",
        mode    => "${network::params::interfacesfile_mode}",
        warn    => true,
        require => File["${network::params::configdir}"],
        notify  => Service["${network::params::servicename}"]
        #backup  => 'main',
        #require => Exec["backup ${sudo::params::configfile}"],
        #Package['sudo'],
        #content => template("sudo/sudoconf.erb"),
        #notify  => Service['sudo'],
    }

    # Header of the file
    concat::fragment { "network_interfaces_header":
        target  => "${network::params::interfacesfile}",
        content => template("network/01-interfaces_header.erb"),
        ensure  => 'present',
        order   => 01,
    }

    service { "${network::params::servicename}":
        enable     => true,
        ensure     => running,
        pattern    => "${network::params::processname}",
        hasrestart => "${network::params::hasrestart}",
        hasstatus  => "${network::params::hasstatus}",
    }

    ### Eventually complete the eth0 configuration if it has not been configured
    ### via network::interfaces. Do it in a puppet stage run at the end.
    # stage { 'network_last':  require => Stage['main'] }
    # class { 'network::eth0::defaultconfig':
    #     stage => 'network_last'
    # }

    # $default_eth0_ensure = defined(Concat::Fragment["${network::params::config_interface_label}_eth0"])
    # ? {
    #     true    => 'absent',
    #     default => 'present' 
    # }

    # concat::fragment { "default_${network::params::config_interface_label}_eth0":
    #     target  => "${network::params::interfacesfile}",
    #     ensure  => $default_eth0_ensure,
    #     source  => "puppet:///modules/network/default_eth0_config",
    #     order   => 02,
    # }

}


# ------------------------------------------------------------------------------
# = Class: network::debian
#
# Specialization class for Debian systems
class network::debian inherits network::common { }


# ------------------------------------------------------------------------------
# = Class: network::eth0::defaultconfig
#
# INTERNAL USAGE ONLY (inside the class 'network') - stages required to
# externalize the code in a separate class to work
# (see http://docs.puppetlabs.com/guides/language_guide.html#resource-collections)
#
# Set the default configuration of the eth0 interfaces (to dhcp).
# Ensure that you won't end in a non-working network configuration in the case
# you just instanciate the class 'network'
#
# == Require
#
# * the network class should have been instanciated
# * the stage 'network_last' should have been defined
#
# class network::eth0::defaultconfig {

#     # Load the variables used in this module.
#     require sysadmin::params

#     $default_eth0_ensure = defined(Network::Interface['eth0'])
#     notice("default eth0 : $default_eth0_ensure")
    

    #     if (! defined(Concat::Fragment['configure_network_interface_eth0'])) {
#         notify("default configuration for eth0")
#         # network::interface{ 'eth0:0':
#         #     auto => true,
#         #     dhcp => true,
#         # }
#     }

#}

