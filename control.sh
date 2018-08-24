

#!/bin/bash
# chkconfig: - 85 15
# description: Nginx server control script
# processname: nginx
# config file:  /usr/local/nginx/conf/nginx.conf
# pid file:     /usr/local/nginx/logs/nginx.pid
# 
# eastmoney public tools
# version: v1.0.0
# create by fanpf, 2018-8-14
# 

# source function library
. /etc/rc.d/init.d/functions

NGX_NAME="nginx"
NGX_BIN_PATH="/usr/local/nginx/sbin/nginx"
NGX_CONF_PATH="/usr/local/nginx/conf"
NGX_PATH="/usr/local/nginx"
NGX_CONF_FILE_PATH="/usr/local/nginx/conf/nginx.conf"
NGX_PID_PATH="/usr/local/nginx/logs/nginx.pid"
NGX_LOCK_PATH="/usr/local/nginx/logs/nginx.lock"


# check current user
[ "$USER" != "root" ] && exit 1

start() {
    status
    if [[ $? -eq 0 ]]; then
        echo $"Nginx (PID $(cat $NGX_PID_PATH)) already started."
        return 1
    fi
    echo -n $"Starting $NGX_NAME: "
    daemon $NGX_BIN_PATH -c $NGX_CONF_FILE_PATH
    retval=$?
    echo
    [ $retval -eq 0 ] && touch $NGX_LOCK_PATH
    return $retval
}

stop() {
    status
    if [[ $? -eq 1 ]]; then
        echo "Nginx server already stopped."
        return 1
    fi
    echo -n $"Stoping $NGX_NAME: "
    killproc $NGX_BIN_PATH
    retval=$?
    echo
    [ $retval -eq 0 ] && rm -f $NGX_LOCK_PATH
    return $retval
}

restart() {
    stop
    sleep 1
    start
    retval=$?
    return $retval
}

reload() {
    echo -n $"Reloading $NGX_NAME: "
    killproc $NGX_BIN_PATH -HUP
    retval=$?
    echo
    return $retval
}

status() {
    netstat -anpt | grep "/nginx" | awk '{print $6}' &> /dev/null
    if [[ $? -eq 0 ]]; then
        if [[ -f $NGX_LOCK_PATH ]]; then
            return 0
        else
            return 1
        fi
    fi
    return 1
}

_status() {
    status
    if [[ $? -eq 0 ]]; then
        state=`netstat -anpt | grep "/nginx" | awk '{ print $4,$6 }'`
        echo $"Nginx server status is: $state"
    else
        echo "Nginx server is not running"
    fi
}

test() {
    $NGX_BIN_PATH -t -c $NGX_CONF_FILE_PATH
    retval=$?
    return $retval
}

case "$1" in
    start)
        start
        ;;
    stop)
        stop
        ;;
    reload)
        reload
        ;;
    restart)
        restart
        ;;
    status)
        _status
        ;;
    test)
        test
        ;;
    *)
        echo "Usage: { start | stop | reload | restart | status | test }"
        exit 1
esac
