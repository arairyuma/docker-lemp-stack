# cmtickle/docker-lemp-stack
Dockerised system to run LEMP stack applications (Primarily developed to run Magento 1 and Magento 2)

## TLDR; Quick Start
Install Docker and Docker Compose.

Run the following commands (this assumes you're using Linux, PC needs a few changes making):
```
git clone git@github.com:cmtickle/docker-lemp-stack.git
cd docker-lemp-stack
docker-compose up -d
sudo echo '127.0.0.1 eg-m1.lemp.dm eg-m2.lemp.dm' >> /etc/hosts
sh setup/example_m1.sh
sh setup/example_m2.sh
```

Visit http://eg-m1.lemp.dm/ for a working Magento 1 installation using PHP 5.6 and Percona 5.6.

Visit http://eg-m2.lemp.dm/ for a working Magento 2 installation using PHP 7.1 and Percona 5.7.

------

NOTE : TO USE THIS REPOSITORY, CLONE IT TO A !!!__PRIVATE__!!! REPOSITORY AS IT WILL CONTAIN SENSITIVE INFORMATION ONCE IN USE.

This repository contains everything which should be needed to start work on a Magento 1 or 2 project. It should be able to run any LEMP app but this has not been confirmed.

If a new project is needed, some initial setup will need to be completed by someone familiar with basic Sysadmin type tasks.

## How to use this repository.
* Create a private clone of the repository
* Clone the repository to your local machine.
* Install Docker -  Follow instructions available from : https://docs.docker.com/install/
* Install Docker Compose - Follow instructions available from : https://docs.docker.com/compose/install/

#### OPTIONAL : Centralised storage of databases and configuration.
If you have multiple people using this setup (e.g. a Dev team) and host your fork of this project in a __PRIVATE REPOSITORY__ SSH keys can be committed to version control as per the following steps.
This will allow all team members to access a standardised database and configuration.

* Create a private+public SSH key pair and put the contents of the private key in file .ssh/id_rsa of this repository.
* Put the public key in file .ssh/id_rsa.pub of this repository.
* Add a host entry to you local hosts file for "vmresource.lemp.dm" to point at your SSH server. 
Alternatively you can change the host name in setup/_config.sh


* On a server which has sshd, create a 'vmresource' user. Allow password-less ssh access using the public key you created above.

    __NOTE__ : In the vmresource user's home folder you will need to create a folder for each Magento project you create. 
    The folder should be named as per the $project_name in the setup scripts. 
    
    For a Magento 1 project you need :
    * db.tar.gz = a 'full' database backup (I suggest you use n98-magerun and create the backup without customer data).
    * dbconfig.tar.gz = a backup of the core_config_data tables with the hostname changed to same as defined in $vmhost_name of setup script.
    * local.xml = a working local.xml file with the correct db host name (e.g. percona56), username and password. If you use Redis these are available as 'rediscache', 'redisfullpage', and 'redissession' on port 6379. 
    
    For a Magento 2 project you need:
    * db.tar.gz and dbconfig.tar.gz as above
    * env.php = a fully completed env.php with correct dbhost etc.
    * config.php = a backup of the correct M2 config.php file.

## How to build and start the Docker containers

**All commands in this README should be executed from the base folder of your clone of this repository.**

If this is the first time you've used this Docker setup:

```
docker-compose up -d
```

If you need to update your Docker containers to reflect changes in made in version control:
```
git pull
docker-compose stop
docker-compose build
docker-compose up -d
```

If you want to remove the contaners (for example if they are somehow broken):
```
docker-compose stop
docker rm $(docker ps -aq)
```


##How to start using a Magento project

Each project should have a script in the 'setup' folder of this repository. To start the project determine/create the appropriate shell script and run it using 'sh' on the command line.
e.g. ```sh setup/some_project.sh```

Sample scripts are provided for a ficticious Magento 1 and Magento 2 project.

The Magento scripts will:
 * Clone the Github/Bitbucket repository into the 'src' folder.
 * Download a recent backup of the magento database (recommended this is without sensitive data).
 * Download a backup of the database configuration tables.
 * Load in both database backups (configuration is loaded second).
 * Download a working local.xml *(M1)* or env.php *(M2)*.
 * Run composer install. *(for M2 only)*
 
When the script finishes you will be informed of an entry which you need to add to your local hosts file. Once you've added this entry you should be able to access the project using a web browser.

## How to develop using these Docker containers

**IMPORTANT :**  From this point onwards, you **MUST** use the Git repositories which reside in the 'src' folder. Any changes here will be immediately reflected in your Docker containers

To see what Docker containers are running :

```
docker ps
```

To connect to command line in one of the Docker containers:
```
docker exec -it <container_name> bash
```

To connect as 'root' user to command line in one of the Docker containers:
```
docker exec -u root -it <container_name> bash
```

To connect to MySQL:
 
connect to port 3306 of the Docker IP (127.0.0.1 for Mac/Linux, 192.168.99.100 for PC) using credentials from [.env](.env)

To view email which has been sent from Magento:

One of the containers in this setup is Mailhog. All email has been redirected to this container to prevent accidental customer contact.
Mailhog can be viewed at [http://localhost:8025/](http://localhost:8025/) (Linux or Mac) or [http://192.168.99.100:8025/](http://192.168.99.100:8025/) on PC.

## How does all this work?

### [docker-compose.yml](docker-compose.yml)
Responsible for the basic configuration of each container.

for example :
```yaml
    php56:
        build:
            context: ./docker/php/5.6
        ports:
            - 9001:9001
        volumes:
            - composer_cache:/root/.composer/cache
            - ./src:/var/www/htdocs
        environment:
            MYSQL_USER: ${MYSQL_USER}
            MYSQL_PASSWORD: ${MYSQL_PASSWORD}
```
This creates a container which will be referred to and accessible on the internal Docker network as "php56". 
The name which your host PC refers to the container as will be different and can be viewed by checking for running containers (command above).
Port 9001 of your host PC is mapped to port 9001 published by the container, so connectivity will be available to the host PC also. 
A named volume 'composer_cache' is created so that data can persist between restarts/rebuild of the container and be shared between containers. 
The named volume is mounted to folder '/root/.composer/cache'.
The relative directory './src' is mounted as a volume to '/var/www/htdocs' of the container.
Finally, some environment variables defined in file [.env](.env) of this repository are made available to the container.

### The Dockerfile
e.g. [docker/nginx/Dockerfile](docker/nginx/Dockerfile)
```yaml
FROM nginx:1.13.8

ADD default.conf /etc/nginx/conf.d/default.conf
ADD m1-hosts.conf /etc/nginx/conf.d/z-m1hosts.conf
...

```
This file is referred to in the docker-compose.yml file and tells docker how to build the container. 
The first line of the file dictates the basse container to use (which will download from Docker Hub).
The remaining lines of the file can be used to add additional configuration files, set environment variables, add packages which are required to host your application etc.
