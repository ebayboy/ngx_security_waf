#!/usr/bin/python
#encoding=utf8

import requests
import hashlib, sys, os, shutil

token="06c536d67ab62f429e5ab50e3e9b523407e133d4"

#下载地址
down_url="https://user.ipip.net/download.php?type=datx&token=" + token

print(down_url)

response = requests.get(down_url)  # 发起http请求
etag_value = response.headers.get("ETag")  # 获取ETag值
if not etag_value:  # ETag不存在就退出
    print("etag not exists")
    sys.exit(0)
with open("ipip_temp.datx", 'wb+') as fd:  # 写临时文件
    for chunk in response.iter_content(4096):
        fd.write(chunk)
with open("ipip_temp.datx", 'rb') as fd:  # 读取临时文件
    sha1 = hashlib.sha1()
    while True:
        content = fd.read(4096)
        if not content:
            break
        sha1.update(content)
    content_sha1_value = sha1.hexdigest()  # 计算临时文件sha1
    etag_sha1_value = etag_value[5:]
    if etag_sha1_value != content_sha1_value:  # sha1 不一致退出
        print("etag err")
        sys.exit(0)
shutil.copyfile("ipip_temp.datx", "ipip_station.datx")  # 覆盖正式文件，目标目录必须有可写权限。
print("ok")

