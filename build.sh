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

GEOIP_PATH="/usr/local/nginx/GeoIP"

build_GeoIP(){
    cd vendor/GeoIP
    autoreconf -f -i . autoreconf
    ./configure  --prefix=$GEOIP_PATH 
    make -j$CPU_COUNT
    make install
    cd -
}

build_Modsecurity(){
    cd ModSecurity
    ./build.sh
    ./configure  --prefix=$MOD_PATH \
    --with-geoip=$GEOIP_PATH
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
        --with-http_ssl_module \
        --with-http_realip_module   \
        --with-http_mp4_module  \
        --with-http_dav_module  \
        --with-http_flv_module  \
        --with-stream   \
        --with-stream_realip_module \
        --with-stream_ssl_module     \
        --with-http_dav_module  \
        --http-client-body-temp-path=$NGX_PATH/temp/client \
        --http-proxy-temp-path=$NGX_PATH/temp/proxy   \
        --http-fastcgi-temp-path=$NGX_PATH/temp/fcgi  \
        --http-scgi-temp-path=$NGX_PATH/temp/scgi     \
        --http-uwsgi-temp-path=$NGX_PATH/temp/uwsgi   \
        --with-openssl=../vendor/openssl \
        --add-dynamic-module=../ModSecurity-nginx   \
        --add-module=../ngx_modules/nginx-sticky-module-ng  \
        --add-module=../ngx_modules/nginx_upstream_check_module  \
        --add-module=../ngx_modules/nginx-rtmp-module
		
    make -j$CPU_COUNT
    make install
    cd -
    cp control.sh $NGX_BIN_PATH
}

build_config(){
    cp -af conf/* $NGX_CONF_PATH
}

build_hLive(){
    cp -af vendor/hLive/  /usr/local/nginx/html/ 
}

if [ "$1" == "GeoIP" ]
then
    build_GeoIP
elif [ "$1" == "Modsecurity" ]
then
    build_Modsecurity
elif [ "$1" == "nginx" ]
then
    build_nginx
elif [ "$1" == "config" ]
then
    build_config 
elif [ "$1" == "hLive" ]
then
    build_hLive 
else
    build_GeoIP
    build_Modsecurity
    build_nginx
    build_config
    build_hLive
fi

