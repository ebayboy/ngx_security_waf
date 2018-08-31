
#!/bin/sh

#log dir
NGX_DIR=/usr/local/nginx/
NGX_LOG_DIR=$NGX_DIR/logs/
NGX_PID=/usr/local/nginx/run/nginx.pid

#log dir
sourceDir=$NGX_DIR/logs/

#log backup dir
backDir=$NGX_DIR/logs_back/

echo "split-logs start: $(date '+%Y-%m-%d %H:%M:%S')"

ls $sourceDir | while read filename
do
    mkdir -p "$backDir/$(date '+%Y%m%d')/"
    mv "$sourceDir/$filename" "$backDir/$(date '+%Y%m%d')/"
    echo "$sourceDir/$filename => $backDir/$(date '+%Y%m%d')/$filename"
done

# 刷新nginx
kill -USR1 `cat $NGX_PID`

echo "split-logs end: $(date '+%Y-%m-%d %H:%M:%S')"
echo "----------------"
