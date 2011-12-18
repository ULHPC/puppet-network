name       'network'
version    '0.1.0'
source     'git-admin.uni.lu:puppet-repo.git'
author     'Sebastien Varrette (Sebastien.Varrette@uni.lu)'
license    'GPL v3'
summary    'Configure various network aspects (interfaces etc.)'
description 'Configure various network aspects (interfaces etc.)'
project_page 'UNKNOWN'

## List of the classes defined in this module
classes    'network::params, network, network::common, network::debian'

## Add dependencies, if any:
# dependency 'username/name', '>= 1.2.0'
dependency 'concat'
defines    '["network::interface"]'
