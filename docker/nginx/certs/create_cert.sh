#!/bin/sh

sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout lemp.dm.key -out lemp.dm.crt -config lemp.dm.conf

