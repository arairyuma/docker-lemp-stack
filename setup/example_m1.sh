#!/bin/bash

###########################################
# IMPORT SHARED CODE.
# YOU SHOULD NOT NEED TO EDIT THIS SECTION.
###########################################
source ./setup/_config.sh                  # Import global variables
source ./setup/_functions.sh               # Import the common code used by all of our setup scripts..

##########################
# PROJECT VARIABLES
# CHANGE THESE AS REQUIRED
##########################
repo_type='github'; # 'github' or 'bitbucket'
cvs_organisation='OpenMage'; # the organisation name for Github or Bitbucket
project_name='magento-mirror'; # Name as used in Github or Bitbucket
resources_storage='local'; # Where to access shared resources (see README.md), 'local' or 'server'
db_host='percona56'; # 'percona56' or 'percona57'
db_name='example_m1_vm'; # unique name for this database
vmhost_name='eg-m1.lemp.dm'; # domain name for this project in local vm.

############################
# CALL THE SHARED FUNCTIONS.
############################
clone_repository;
fix_dirs_m1;
get_config_m1;
# Adhoc-task Enable Redis sessions
sed -i .orig 's/false/true/g' src/${project_name}/app/etc/modules/Cm_RedisSession.xml
get_db_backups;
load_db_backups;
display_host_entry;
