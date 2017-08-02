title: Mongodb 权限和数据备份
author: Shaojun Liu
tags:
  - mongodb
categories:
  - DB
  - Mongo DB
date: 2017-08-02 18:43:00
---


## 数据导出

``` bash
mongodump -h 127.0.0.1:27017 -d <db> -o <path> [-u -p]
```
## 数据导入

``` bash
mongorestore —host 127.0.0.1: 27017 -d <db> <path>

```
## 单表导出

``` bash
mongoexport -d <db> -c <table> -q ‘{“name”:{$ne:null}}’ -o <path>.json
```
## 单表导入

``` bash
mongoimport —host 127.0.0.1:27017 -d <db> -c <table> <path>.json
```
## 数据清空

``` bash
mongo —host 127.0.0.1:19999 <db> —eval “db.dropDatabase()"
```

## 权限

### 设置超级管理员

``` js
db.createUser({
	user: 'admin',
	pwd: 'admin',
	roles :[{
		role: 'userAdminAnyDatabase',
		db: 'admin'}
	]})
```
### 授权

``` javascript

db.auth('admin','admin')
```
### 某个库的用户

``` javascript

// 在设置某个数据库的时候，先执行授权
use admin;
db.auth('admin','admin');
use demo;
db.createUser({
	user: 'demo_user',
	pwd: ‘123456’,
	roles :[{
		role: 'readWrite',
		db: 'demo'
	}]}) 
```
### 备份用户

``` javascript

// 在设置某个数据库的时候，先执行授权
use admin;
db.auth('admin','admin');
use demo;
db.createUser({
	user: 'demo_wheel',
	pwd: ‘123456’,
	roles :[{
		role: 'read',
		db: 'demo'
	}]}) 
```

### 开启授权认证

``` bash
sudo vi /etc/mongod.conf
# 去掉注释 
security:
	authorization: 'enabled'
# 重启
sudo service mongod restart
```
### 访问某个库

``` bash
mongo 127.0.0.1:27017/<db> -u demo_user -p 123456
```
## 定时备份
### 备份脚本

``` bash
#!/bin/bash
backup_file=/home/backup/<db>
date_now=`date +%Y_%m_%d_%H%M`
backfile_name=movie_$date_now
cd $backfile
mkdir -p $backfile_name
mongodump -h 127.0.0.1:27017 -d <db> -u user_wheel -p 123456 -o $backfile_name
tar zcf $backfile_name.tar.gz $backfile_name
rm -rf $backfile_name

# 可以把备份文件上传到云服务器(七牛)
#NODE_ENV=$backfile@$backfile_name node /home/upload.js

```
### 定时任务

``` bash
crontab -e 
# 凌晨13分
13 00 * * *  sh /home/backup.sh
```
