#!/bin/bash

###########################################
# IMPORT SHARED CODE.
# YOU SHOULD NOT NEED TO EDIT THIS SECTION.
###########################################
source ./setup/_config.sh                  # Import global variables
source ./setup/_functions.sh               # Import the common code used by all of our setup scripts..

# Project Variables
repo_type='github'; # 'github' or 'bitbucket'
cvs_organisation='magento'; # the organisation name for Github or Bitbucket
project_name='magento2'; # Name as used in Github or Bitbucket
resources_storage='local'; # Where to access shared resources (see README.md), 'local' or 'server'
db_host='percona57'; # 'percona56' or 'percona57'
php_host='php71'; # 'php56', 'php70', 'php72' or 'php72'
db_name='example_m2_vm'; # unique name for this database
vmhost_name='eg-m2.lemp.dm'; # domain name for this project in local vm.

############################
# CALL THE SHARED FUNCTIONS.
############################
clone_repository;
fix_dirs_m2;
get_config_m2;
get_db_backups;
load_db_backups;
composer_install_m2;
setup_upgrade_m2;
static_content_deploy_m2;
cache_clean_m2;
cache_flush_m2;
create_devvm_admin_user_m2;
display_host_entry;
