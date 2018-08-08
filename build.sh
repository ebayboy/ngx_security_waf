#!/bin/bash

CPU_COUNT=`cat /proc/cpuinfo | grep processor | wc -l`

MOD_PATH="/usr/local/nginx/modsecurity"
NGX_MODULES_PATH="/usr/local/nginx/modules"

NGX_ERR_LOG_PATH="/usr/local/nginx/logs/error.log"
NGX_ACCESS_LOG_PATH="/usr/local/nginx/logs/access.log"

NGX_PATH="/usr/local/nginx"
NGX_BIN_PATH="/usr/local/nginx/sbin/"
NGX_CONF_PATH="/usr/local/nginx/conf"
NGX_CONF_FILE_PATH="/usr/local/nginx/conf/nginx.conf"
NGX_PID_PATH="/usr/local/nginx/logs/nginx.pid"
NGX_LOCK_PATH="/usr/local/nginx/logs/nginx.lock"

buid_GeoIP(){

}

build_mod_security(){
    cd ModSecurity
    ./build.sh
    ./configure  --prefix=$MOD_PATH \
    --with-geoip=/usr/local/nginx/GeoIP
    make -j$CPU_COUNT
    make install
    cd -
}

build_nginx(){
    cd nginx
    ./configure  --prefix=$NGX_PATH \
        --conf-path=$NGX_CONF_FILE_PATH \
		--error-log-path=$NGX_ERR_LOG_PATH \
		--http-log-path=$NGX_ACCESS_LOG_PATH \
		--pid-path=$NGX_PID_PATH \
		--lock-path=$NGX_LOCK_PATH \
        --with-http_ssl_module  \
        --with-http_realip_module   \
        --with-http_geoip_module    \
        --with-http_stub_status_module  \
        --add-dynamic-module=../ModSecurity-nginx
		
    make -j$CPU_COUNT
    make install
    cd -
    cp control.sh $NGX_BIN_PATH
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
elif [ "$1" == "config" ]
then
    install_config 
else
    build_mod_security
    build_nginx
    build_config
fi

