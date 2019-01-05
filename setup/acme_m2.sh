#!/bin/bash

###########################################
# IMPORT SHARED CODE.
# YOU SHOULD NOT NEED TO EDIT THIS SECTION.
###########################################
source ./setup/_config.sh                  # Import global variables
source ./setup/_functions.sh               # Import the common code used by all of our setup scripts..


######################################################################
#
#              THIS IS AN EXAMPLE NON-FUNCTIONING SCRIPT.
#              ##########################################
#
# USE IT AS THE BASIS FOR MAGENTO 2 PROJECT SETUP.
#
# CHANGE VARIABLES IN THE PROJECT VARIABLES SECTION.
#
# YOUR ${vmhost_name} VARIABLE MUST BE IN THE FORMAT:
#        <some_unique_id>-m2.lemp.dm
#
# ADD THE HOST NAME YOU'VE DEFINED AS ${vmhost_name} TO :
#      /etc/hosts (or equivalent local hosts file ... SEE README.md)
#
# ADD YOUR HOSTNAME TO THE $MAGE_ROOT MAP IN:
#      docker/nginx/m2-hosts.conf
#
# ADD THE TWO DATABASE BACKUPS, env.php AND config.php TO:
#      setup/resources/${project_name}/ (SEE README.md)
#
# REBUILD AND UPDATE THE DOCKER CONTAINERS:
#      docker-compose build
#      docker-compose up -d
#
# RUN THIS SETUP SCRIPT AND IF ALL GOES TO PLAN YOU SHOULD BE ABLE TO
# VISIT http://${vmhost_name}
#
# GOOD LUCK!
#
######################################################################

# Project Variables
repo_type='github'; # 'github' or 'bitbucket'
cvs_organisation='Acme'; # the organisation name for Github or Bitbucket
project_name='project-m2'; # Name as used in Github or Bitbukcet
db_host='percona56'; # 'percona56' or 'percona57'
php_host='php71'; # 'php56', 'php70', 'php72' or 'php72'
db_name='acme_m2_vm'; # unique name for this database
vmhost_name='acme-m2.lemp.dm'; # domain name for this project in local vm.

############################
# CALL THE SHARED FUNCTIONS.
############################
clone_repository;
fix_dirs_m2;
get_config_m2;
get_db_backups;
load_db_backups;
composer_update_m2;
fix_dev_static_sign_m2;
fix_outdated_error_m2 Fastly_Cdn ;
fix_outdated_error_m2 Magento_Braintree ;
setup_upgrade_m2;
static_content_deploy_m2;
cache_clean_m2;
cache_flush_m2;
create_devvm_admin_user_m2;
display_host_entry;
