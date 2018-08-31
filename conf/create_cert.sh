#!/bin/bash

DOMAIN_NAME=$1


if [ "" = "$DOMAIN_NAME" ] ;then
    echo "Please input domain name:"
    exit
fi

rf -rf ./ssl/$DOMAIN_NAME
mkdir -p ./ssl/$DOMAIN_NAME
cd ./ssl/$DOMAIN_NAME

#1. create $DOMAIN_NAME root private key with pasword
openssl genrsa -des3 -out server.key.root 1024

#2. create request file
openssl req -new -key server.key.root -out server.csr

#3. erase passwd of $DOMAIN_NAME.key -> $DOMAIN_NAME.key.org
openssl rsa -in server.key.root -out server.key

#4. create cert with key & requestfile
openssl x509 -req -days 365 -in server.csr -signkey server.key -out server.crt

#5. dhparam
openssl dhparam -out server.dhparam.pem 1024
