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
# USE IT AS THE BASIS FOR MAGENTO 1 PROJECT SETUP.
#
# CHANGE VARIABLES IN THE PROJECT VARIABLES SECTION.
#
# YOUR ${vmhost_name} VARIABLE MUST BE IN THE FORMAT:
#        <some_unique_id>-m1.lemp.dm
#
# ADD THE HOST NAME YOU'VE DEFINED AS ${vmhost_name} TO :
#      /etc/hosts (or equivalent local hosts file ... SEE README.md)
#
# ADD YOUR HOSTNAME TO THE $MAGE_ROOT MAP IN:
#      docker/nginx/m2-hosts.conf
#
# ADD THE TWO DATABASE BACKUPS, local.xml TO:
#      setup/resources/${project_name}/ (SEE README.md)
#
# REBUILD AND UPDATE THE DOCKER CONTAINERS:
#      docker-compose build
#      docker-compose up -d
#
# RUN THIS SETUP SCRIPT AND IF ALL GOES TO PLAN YOU SHOULD BE ABLE TO
# VISIT http://${vmhost_name}
#
# GOOD LUCK!
#
######################################################################

##########################
# PROJECT VARIABLES
# CHANGE THESE AS REQUIRED
##########################
repo_type='github';               # 'github' or 'bitbucket'
cvs_organisation='acme';          # the organisation name for Github or Bitbucket
project_name='project_m1';        # Name as used in Github or Bitbukcet
db_host='percona56';              # 'percona56' or 'percona57'
db_name='acme_m1_vm';             # unique name for this database
vmhost_name='acme-m1.lemp.dm';    # domain name for this project in local vm.

############################
# CALL THE SHARED FUNCTIONS.
############################
clone_repository;
fix_dirs_m1;
get_config_m1;
get_db_backups;
load_db_backups;
display_host_entry;
