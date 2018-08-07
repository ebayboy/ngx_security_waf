#!/bin/bash

CPU_COUNT=`cat /proc/cpuinfo | grep processor | wc -l`

MOD_PATH="/usr/local/modsecurity"
NGX_MODULES_PATH="/usr/local/nginx/modules"

NGX_ERR_LOG_PATH="/usr/local/nginx/logs/error.log"
NGX_ACCESS_LOG_PATH="/usr/local/nginx/logs/access.log"

NGX_PATH="/usr/local/nginx"
NGX_CONF_PATH="/usr/local/nginx/conf"
NGX_PID_PATH="/usr/local/nginx/logs/nginx.pid"
NGX_LOCK_PATH="/usr/local/nginx/logs/nginx.lock"

build_mod_security(){
    cd ModSecurity
    ./configure  --prefix=/usr/local/modsecurity 
    make -j$CPU_COUNT
    make install
    cd -
}

build_nginx(){
    cd nginx
    ./configure  --prefix=/usr/local/nginx \
        --conf-path=${DEST}/conf/smartl7.conf \
		--error-log-path=$NGX_ERR_LOG_PATH \
		--http-log-path=$NGX_ACCESS_LOG_PATH \
		--pid-path=$NGX_PID_PATH \
		--lock-path=$NGX_LOCK_PATH \
    	--with-ipv6 \
		--with-debug	\
		
    make -j$CPU_COUNT
    make install
    cd -
}

build_nginx_modules(){
    cd nginx
    ./configure --add-dynamic-module=../ModSecurity-nginx
    make modules
    if [ ! -d "$NGX_MODULES_PATH" ];then
        mkdir -p $NGX_MODULES_PATH
    fi
    cp objs/ngx_http_modsecurity_module.so $NGX_MODULES_PATH
    cd -
}

install_config(){
    cp -af conf/* $NGX_CONF_PATH
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
elif [ "$1" == "config" ]
then
    install_config 
else
    build_mod_security
    build_nginx
    build_nginx_modules
fi

