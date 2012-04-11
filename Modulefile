name    'network'
version '0.1.1'
source  'git-admin.uni.lu:puppet-repo.git'
author  'Hyacinthe Cartiaux (hyacinthe.cartiaux@uni.lu)'
license 'GPL v3'
summary      'Configure various network aspects (interfaces etc.)'
description  'Configure various network aspects (interfaces etc.)'
project_page 'UNKNOWN'

## List of the classes defined in this module
classes     'network, network::common, network::debian, network::redhat, network::params'
## List of the definitions defined in this module
definitions 'concat'

## Add dependencies, if any:
# dependency 'username/name', '>= 1.2.0'
dependency 'concat' 
