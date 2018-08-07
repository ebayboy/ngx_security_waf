#!/bin/bash

MOD_PATH="/usr/local/modsecurity"
NGX_PATH="/usr/local/nginx"
NGX_MODULES_PATH="/usr/local/nginx/modules"
CPU_COUNT=`cat /proc/cpuinfo | grep processor | wc -l`

build_mod_security(){
    cd ModSecurity
    ./configure  --prefix=/usr/local/modsecurity 
    make -j$CPU_COUNT
    make install
    cd -
}

build_nginx(){
    cd nginx
    ./configure  --prefix=/usr/local/nginx 
    make -j$CPU_COUNT
    make install
    cd -
}

build_nginx_modules(){
    cd nginx
    ./configure --add-dynamic-module=../ModSecurity-nginx
    make modules
    cp objs/ngx_http_modsecurity_module.so $NGX_MODULES_PATH
    cd -
}

if [ "$1" == "mod_security" ]
then
    build_mod_security
elif [ "$1" == "nginx" ]
then
    build_nginx
elif [ "$1" == "modules" ]
then
    build_nginx_modules
else
    build_mod_security
    build_nginx
    build_nginx_modules
fi

