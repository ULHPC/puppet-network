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
    $ensure     = 'present',
    $source     = '',
    $content    = '',
    $comment    = '',
    $address    = '',
    $gateway    = '',
    $netmask    = '255.255.0.0',
    $network    = '',
    $broadcast  = '',
    $hwaddr     = '',
    $nettype    = '',
    $auto       = true,
    $manual     = false,
    $dhcp       = true,
    $hotplug    = false,
    $connected_mode = false,
    $pre_up     = [  ],
    $post_up    = [  ],
    $pre_down   = [  ],
    $post_down  = [  ],
    $dns_nameservers = '',
    $dns_search = '',
    $priority   = 50
)
{

    include network::params

    if (! defined(Class['network'])) {
        include 'network'
    }

    if (! $manual) and (! $dhcp) and ($address == '') {
        fail("Wrong format in the configuration of the network interface ${interface}")
    }

    if ( ($pre_up or $post_up or $pre_down or $post_down)
          and ! ($::operatingsystem in [ 'Debian', 'Ubuntu' ])
       ) {
        fail("pre_up, post_up, pre_down and post_down parameters are supported only on debian and ubuntu systems")
    }

    # $name is provided by define invocation
    # guid of this entry
    $interface = $name

    case $::operatingsystem {
        debian, ubuntu: {
            $netconfig_template = 'network/network-interface.erb'
        }
        centos, fedora, redhat: {
            $netconfig_template = 'network/network-interface.redhat-ifcfg.erb'
        }
        default: {
            fail("network::interface is not supported on $operatingsystem")
        }
    }

    case $content {
        '': {
            case $source {
                '':      { $real_content = template($netconfig_template) }
                default: { $real_source  = $source }
            }
        }
        default: { $real_content = $content }
    }

    # TODO: compute directly network and broadcast from $adress and $netmask....
    case $::operatingsystem {
        debian, ubuntu: {
            concat::fragment { "${network::params::config_interface_label}_${interface}":
                target  => "${network::params::interfacesfile}",
                ensure  => "${ensure}",
                content => $real_content,
                source  => $real_source,
                order   => $priority,
            }
        }
        centos, fedora, redhat: {
            file { "${network::params::config_interface_label}_${interface}":
                ensure  => "${ensure}",
                path    => "${network::params::configdir}/${network::params::ifcfg_prefix}${interface}",
                owner   => "${network::params::interfacesfile_owner}",
                group   => "${network::params::interfacesfile_group}",
                mode    => "${network::params::interfacesfile_mode}",
                require => File["${network::params::configdir}"],
                notify  => Service["${network::params::servicename}"],
                content => $real_content,
            }

        }
    }

}






