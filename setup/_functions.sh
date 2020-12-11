#!/bin/bash

###############################################
# Allow the user to start run specific portions
# of the setup script.
###############################################
echo "This script contains 3 phases of installation:
files    : Download the codebase, run any additional commands to get the code structure ready for running.
database : Downloads a copy of the database and configuration then loads these into the correct container.
install  : Any final tasks required to get make the codebase operational e.g. composer or bin/magento


You can provide an OPTIONAL parameter 'start_phase'. to this script.
This determines which part of the install you want to run.
The default is that ALL phases will run.
start_phase supported options :: [files, database, install, all]

files/all = files, database and install
database  = database and install
install   = install ONLY

";

if [ $# -eq 1 ]; then
   START_PHASE=$1
else
   START_PHASE=all
fi
echo "Running with start_phase = $START_PHASE
";

# Map the phases to a number so we can compare with less than or equals to.
# PHASE 1 = all (STEPS : files, database, install);
# PHASE 2 = database (STEPS : database, install);
# PHASE 3 = install (STEPS: install ONLY);
if [ "$START_PHASE" == "files" ] | [ "$START_PHASE" == "all" ]; then
    START_PHASE=1;
elif [ "$START_PHASE" == "database" ]; then
    START_PHASE=2;
elif [ "$START_PHASE" == "install" ]; then
    START_PHASE=3;
fi

######################################
# Create local clone of CVS Repository
#
# Required variables:
#     $repo_type
#     $project_name
######################################
clone_repository () {
    # Phase ths step should run at.
    if [ ${START_PHASE} -gt 1 ] ; then
        echo "[!!] Skipping ${repo_type} clone ...";
        return;
    fi

    if [ -d "./src/$project_name" ]; then
        echo "Removing previous ${repo_type} clone";
        rm -rf ./src/$project_name;
    fi

    if [ 'github' == $repo_type ]; then
        echo "Cloning the codebase from Github ...";
        git clone git@github.com:${cvs_organisation}/${project_name}.git ./src/${project_name};
    elif [ 'bitbucket' == $repo_type ]; then
        echo "Cloning the codebase from Bitbucket ...";
        git clone git@bitbucket.org:${cvs_organisation}/${project_name}.git ./src/${project_name};
    else
        echo "Unsupported CVS repository type $repo_type";
        exit 1;
    fi
}

#######################################################
# Magento 1 needs certain directories to work properly.
# Create them if they're missing.
#######################################################
fix_dirs_m1 () {
    # Phase ths step should run at.
    if [ ${START_PHASE} -gt 1 ] ; then
        echo "[!!] Skipping M1 directory fixes ...";
        return;
    fi

    if [ ! -d "./src/$project_name/media" ]; then
        echo "Creating media directory ...";
        mkdir ./src/$project_name/media;
    fi
}

#######################################################
# Magento 2 needs certain directories to work properly.
# Create them if they're missing.
#######################################################
fix_dirs_m2 () {
    # Phase ths step should run at.
    if [ $START_PHASE -gt 1 ] ; then
        echo "[!!] Skipping M2 directory fixes ...";
        return;
    fi

   # NOTHING HERE YET, PLACEHOLDER
   echo "";
}

################################
# Download the database backups.
#
# Required variables:
#    $resource_server_ssh
#    $project_name
################################
get_db_backups () {
    # Phase ths step should run at.
    if [ $START_PHASE -gt 2 ] ; then
        echo "[!!] Skipping database downloads ...";
        return;
    fi

    if [ "server" == $resources_storage ]; then
        echo "Downloading latest database dump and database config file ..."
        scp -i .ssh/id_rsa ${resource_server_ssh}:${project_name}/db.tar.gz ./db_dumps/
        scp -i .ssh/id_rsa ${resource_server_ssh}:${project_name}/dbconfig.tar.gz ./db_dumps/
    elif [ "local" == $resources_storage ]; then
        echo "Copying latest database dump and database config file from local ..."
        cp ./setup/resources/${project_name}/db.tar.gz ./db_dumps/
        cp ./setup/resources/${project_name}/dbconfig.tar.gz ./db_dumps/
    else
        echo "Unsupported resources_storage  type $resources_storage";
        exit 1;
    fi
}

##################################################
# Load the db backups into the database container.
#
# Required variables:
#     $db_host
#     $db_name
##################################################
load_db_backups () {
    # Phase ths step should run at.
    if [ $START_PHASE -gt 2 ] ; then
        echo "[!!] Skipping database load ...";
        return;
    fi

    echo "Loading db dump into database container (${db_host}) ..."
    # Copy the backup into the container for faster load time.
    docker cp ./db_dumps/db.tar.gz docker-lemp-stack_${db_host}_1:/tmp/
    docker cp ./db_dumps/dbconfig.tar.gz docker-lemp-stack_${db_host}_1:/tmp/
    rm ./db_dumps/db.tar.gz
    rm ./db_dumps/dbconfig.tar.gz
    # Create a fresh database to load into.
    docker exec -u mysql -i docker-lemp-stack_${db_host}_1 mysql -h 127.0.0.1 -uroot -proot -e "DROP DATABASE IF EXISTS ${db_name}";
    docker exec -u mysql -i docker-lemp-stack_${db_host}_1 mysql -h 127.0.0.1 -uroot -proot -e "CREATE DATABASE ${db_name}";
    # Load the file from /tmp of container into MySQL.
    echo "zcat /tmp/db.tar.gz | mysql -h 127.0.0.1 -uroot -proot ${db_name}" | docker exec -u mysql -i docker-lemp-stack_${db_host}_1 bash -
    echo "zcat /tmp/dbconfig.tar.gz | mysql -h 127.0.0.1 -uroot -proot ${db_name}" | docker exec -u mysql -i docker-lemp-stack_${db_host}_1 bash -
    echo "rm /tmp/db.tar.gz" | docker exec -u mysql -i docker-lemp-stack_${db_host}_1 bash -
    echo "rm /tmp/dbconfig.tar.gz" | docker exec -u mysql -i docker-lemp-stack_${db_host}_1 bash -

}


###################################################
# Return the M2 database prefix value from env.php
#
# Required variables:
#    $project_name
#    $php_host
###################################################
get_db_prefix_m2 () {
    echo $(echo "php -r '\$config = include \"/var/www/htdocs/${project_name}/app/etc/env.php\"; echo \$config && isset(\$config[\"db\"]) && isset(\$config[\"db\"][\"table_prefix\"]) ? \$config[\"db\"][\"table_prefix\"] : \"\";'"  | docker exec -u www-data -i docker-lemp-stack_${php_host}_1 bash -)
}

########################################
# Download a Magento 1 "local.xml" file.
#
# Required variables:
#    $resource_server_ssh
#    $project_name
########################################
get_config_m1 () {
    # Phase ths step should run at.
    if [ $START_PHASE -gt 1 ] ; then
        echo "[!!] Skipping local.xml download ...";
        return;
    fi

    if [ "server" == $resources_storage ]; then
        echo "Downloading the local.xml file ..."
        scp -i .ssh/id_rsa ${resource_server_ssh}:${project_name}/local.xml ./src/${project_name}/app/etc/
    elif [ "local" == $resources_storage ]; then
        echo "Copying the local.xml file ..."
        cp ./setup/resources/${project_name}/local.xml ./src/${project_name}/app/etc/
    else
        echo "Unsupported resources_storage type $resources_storage";
        exit 1;
    fi
}

########################################
# Download a Magento 2 "env.php" file.
#
# Required variables:
#    $resource_server_ssh
#    $project_name
########################################
get_config_m2 () {
    # Phase ths step should run at.
    if [ $START_PHASE -gt 1 ] ; then
        echo "[!!] Skipping env.php download ...";
        return;
    fi

    if [ "server" == $resources_storage ]; then
        echo "Downloading the env.php file ..."
        scp -i .ssh/id_rsa ${resource_server_ssh}:${project_name}/env.php ./src/${project_name}/app/etc/

        echo "Downloading the config.php file ..."
        scp -i .ssh/id_rsa ${resource_server_ssh}:${project_name}/config.php ./src/${project_name}/app/etc/
    elif [ "local" == $resources_storage ]; then
        echo "Copying the env.php file ..."
        cp ./setup/resources/${project_name}/env.php ./src/${project_name}/app/etc/

        echo "Copying the config.php file ..."
        cp ./setup/resources/${project_name}/config.php ./src/${project_name}/app/etc/
    else
        echo "Unsupported resources_storage type $resources_storage";
        exit 1;
    fi
}

###########################################################
# Use the correct uth.json file for access to repo.magento
# Required variables:
#     $project_name
###########################################################
copy_composer_auth_json () {
    if [ -f ./setup/.composer/${project_name}-auth.json ]; then
        echo "Copying project specific auth.json file ... ";
        docker cp ./setup/.composer/${project_name}-auth.json docker-lemp-stack_${php_host}_1:/root/.composer/auth.json
    else
        echo "Copying generic auth.json file ... ";
        docker cp ./setup/.composer/auth.json docker-lemp-stack_${php_host}_1:/root/.composer/auth.json
    fi
}

####################################
# Composer update (required for M2)
# where we don't have access to all
# repositories.
#
# Required variables:
#    $project_name
#    $php_host
####################################
composer_update_m2 () {
    # Phase ths step should run at.
    if [ $START_PHASE -gt 3 ] ; then
        echo "[!!] Skipping composer update ...";
        return;
    fi

    copy_composer_auth_json;
    echo "Running composer update ...";
    echo "cd /var/www/htdocs/${project_name}/; composer update" | docker exec -u www-data -i docker-lemp-stack_${php_host}_1 bash -
}

####################################
# Composer install (required for M2)
#
# Required variables:
#    $project_name
#    $php_host
####################################
composer_install_m2 () {
    # Phase ths step should run at.
    if [ $START_PHASE -gt 3 ] ; then
        echo "[!!] Skipping composer install ...";
        return;
    fi

    copy_composer_auth_json;
    echo "Running composer install ...";
    echo "cd /var/www/htdocs/${project_name}/; composer install" | docker exec -u www-data -i docker-lemp-stack_${php_host}_1 bash -
}


#####################################
# START ....
# VARIOUS bin/magento COMMANDS FOR M2
#
# Required variables:
#    $project_name
#    $php_host
#####################################
setup_upgrade_m2 () {
    echo "Running setup:upgrade ... ";
    echo "cd /var/www/htdocs/${project_name}/; php -d memory_limit=1G bin/magento setup:upgrade" | docker exec -u www-data -i docker-lemp-stack_${php_host}_1 bash -
}

di_compile_m2 () {
    echo "Running setup:di:compile ... ";
    echo "cd /var/www/htdocs/${project_name}/; php -d memory_limit=1G bin/magento setup:di:compile" | docker exec -u www-data -i docker-lemp-stack_${php_host}_1 bash -
}

static_content_deploy_m2 () {
    echo "Running setup:static-content:deploy ... ";
    echo "cd /var/www/htdocs/${project_name}/; php -d memory_limit=1G bin/magento setup:static-content:deploy en_US en_GB" | docker exec -u www-data -i docker-lemp-stack_${php_host}_1 bash -
}

cache_clean_m2 () {
    echo "Running cache:clean ... ";
    echo "cd /var/www/htdocs/${project_name}/; php -d memory_limit=1G bin/magento cache:clean " | docker exec -u www-data -i docker-lemp-stack_${php_host}_1 bash -
}

cache_flush_m2 () {
    echo "Running cache:flush ... ";
    echo "cd /var/www/htdocs/${project_name}/; php -d memory_limit=1G bin/magento cache:flush " | docker exec -u www-data -i docker-lemp-stack_${php_host}_1 bash -
}
#####################################
# END ....
# VARIOUS bin/magento COMMANDS FOR M2
#####################################

####################################
# Create an admin user 'dev-vm'
# password 'dev-vm'
#
# Required variables:
#    $project_name
#    $php_host
####################################
create_devvm_admin_user_m2 () {
    if [ $START_PHASE -gt 2 ] ; then
        echo "[!!] Skipping creation of admin user ...";
        return;
    fi

    echo "Creating admin user ...";
    echo "cd /var/www/htdocs/${project_name}/; php -d memory_limit=1G bin/magento admin:user:create --admin-user=\"dev-vm\" --admin-password=\"dev-vm123\" --admin-email=\"noreply@lemp.dm\" --admin-firstname=\"Development\" --admin-lastname=\"User\" --magento-init-params=\"1\";" | docker exec -u www-data -i docker-lemp-stack_${php_host}_1 bash - ;
    echo "

#####################################
# Magento Admin user has been created
#
# username : dev-vm
# password : dev-vm123
#####################################
    ";
}

#########################################################
# Resolve error : The following modules are outdated
#
# Function requires 1 argument (module to delete from db)
#########################################################
fix_outdated_error_m2 () {
    # Phase ths step should run at.
    if [ $START_PHASE -gt 3 ] ; then
        echo "[!!] Skipping setup_module fix for $1 ....";
        return;
    fi

    db_prefix=$(get_db_prefix_m2);
    echo "Removing $1 from setup_module ... ";
    docker exec -u mysql -i docker-lemp-stack_${db_host}_1 mysql -h 127.0.0.1 -uroot -proot ${db_name} -e "DELETE FROM ${db_prefix}setup_module WHERE module = '$1'";
}

#############################################################
# Resolve error : e.g. css file "Requested path ... is wrong"
#
# Function requires 1 argument (module to delete from db)
#############################################################
fix_dev_static_sign_m2 () {
    # Phase ths step should run at.
    if [ $START_PHASE -gt 2 ] ; then
        echo "[!!] Skipping dev/static/sign config change ....";
        return;
    fi

    echo "Disabling dev/static/sign in config ... ";
    docker exec -u mysql -i docker-lemp-stack_${db_host}_1 mysql -h 127.0.0.1 -uroot -proot ${db_name} -e "UPDATE ${db_prefix}core_config_data SET value=0 WHERE path='dev/static/sign'";
}
#############################################
# Display instructions for adding host entry.
#
# Required variables:
#     $vmhost_name
#############################################
display_host_entry () {
    # Phase ths step should run at.
    if [ $START_PHASE -gt 3 ] ; then
        return;
    fi

    echo "\

####################################
# Please add host entry
#
# MAC/LINUX:
# 127.0.0.1 ${vmhost_name}
#
# WINDOWS:
# 192.168.99.100 ${vmhost_name}
####################################
    ";
}

