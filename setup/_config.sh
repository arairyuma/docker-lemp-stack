#!/bin/bash

# Make ssh key permissions correct
chmod 700 .ssh/*

if [ ! -d "db_dumps" ]; then
	echo "Creating db_dumps directory";
	mkdir db_dumps;
fi

# Global variables used in all projects
resource_server_ssh=vmresource@vmresource.lemp.dm
