title: Mongodb 教程
author: Shaojun Liu
top: true
tags:
  - mongodb
  - db
categories:
  - MongoDB
date: 2017-08-02 15:14:00
---

> [`MongoDB`][1] 是一个介于关系数据库和非关系数据库之间的产品，是非关系数据库当中功能最丰富，最像关系数据库的。他支持的数据结构非常松散，是类似`json`的`bson`格式，因此可以存储比较复杂的数据类型。`Mongo`最大的特点是他支持的查询语言非常强大，其语法有点类似于面向对象的查询语言，几乎可以实现类似关系数据库单表查询的绝大部分功能，而且还支持对数据建立索引。

<!-- more -->

## 安装
[社区版安装](https://www.mongodb.com/download-center?jmp=nav#community)

### Mac 
Mac系统 可以通过[Homebrew](http://brew.sh/)安装
```bash
 brew update
 brew install mongodb
```
要安装具有TLS / SSL支持的MongoDB二进制文件

``` bash
brew install mongodb --with-openssl
```
安装最新开发版本
```bash
brew install mongodb --devel

```

### Linux 
- 下载和安装

```bash
  curl -O https://fastdl.mongodb.org/osx/mongodb-osx-x86_64-3.5.10.tgz

  tar -zxvf mongodb-osx-x86_64-3.5.10.tgz

  mkdir -p mongodb

  cp -R -n mongodb-osx-x86_64-3.5.10/ mongodb
```

- 配置环境变量 编辑 `~/.bashrc`

```bash
	export PATH=<mongodb-install-directory>/bin:$PATH
```
## 运行

1. 创建数据目录

在首次启动MongoDB之前，请创建`mongod`进程将写入数据的目录。
默认情况下，`mongod`进程使用`/data /db`目录。
如果创建一个除此之外的目录，则必须在此过程稍后再启动mongod进程时
在`dbpath`选项中指定该目录。

2. 设置数据目录读写权限

```bash
	chmod 755 -R /data/db
```
3. 运行 Mongo DB
``` bash
  mongod # 默认使用/data/db

  # 如果你的PATH 没有加入mongod 的目录
  <path to binary>/mongod

  # 可以通过 --dbpath 指定数据目录
  mongod --dbpath <path to data directory>
```
4. 开始使用Mongo DB
停止运行，按键`Ctrl + C` 在mongod 所运行的终端

## Mongo Shell

要启动`mongo shell`并连接到在`localhost`上运行的`MongoDB`实例使用默认端口：27017

1. 在终端窗口中提示（或Windows的命令提示符），进入您的mongodb安装目录：
```bash
cd <mongodb installation dir>
./bin/mongo
```
2. 可选参数

  `.mongorc.js` 文件

  启动时，`mongo`会检查用户的`HOME`目录，找到一个名为`.mongorc.js`的JavaScript文件。
  如果找到，`mongo`首先解释`.mongorc.js`的内容，然后再显示提示。
  如果您使用`shell`来评估`JavaScript`文件或表达式，可以通过在命令行中使用`--eval`选项，或者通过将.js文件指定为`mongo`，`mongo`将在`JavaScript`完成处理之后读取`.mongorc.js`文件
  。
  您可以通过使用`--norc`选项来阻止`.mongorc.js`被加载。

3. 全局配置文件

	UNIX 环境 `/etc/mongorc.js `
	WIndows 环境 `％ProgramData％\ MongoDB` 目录中。

4.  使用

	要使用身份验证和非标准端口连接到远程主机上的数据库，请使用以下格式：
	```bash?linenums
	mongo --username <user> --password <pass> --host <host> --port 28015
	```
	或者简单形式
	```bash
		mongo -u <user> -p <pass> --host <host> --port 28015
	```
	要在启动shell会话之前不执行〜/ .mongorc.js文件执行JavaScript文件，请使用以下格式：
	```bash
		mongo --shell --norc alternate-environment.js
	```
	要通过身份验证执行JavaScript文件，使用提示而不是命令行提供的密码，请使用以下格式：
	``` bash
		mongo script-file.js -u <user> -p
	```
	要打印以JSON格式返回查询，请使用`--eval`选项从系统提示符中使用以下格式：
	```bash
	mongo --eval 'db.<collection>.find().forEach(printjson)'
	```
## mongo db 配置文件
1. 命令

``` bash
 mongod --config /etc/mongod.conf
 mongos --config /etc/mongos.conf
 
# 或者 简化形式
mongod -f /etc/mongod.conf
mongos -f /etc/mongos.conf
 
```

2. 配置文件YAML
注意yaml 不能使用制表符缩进，要用空格
 
```
 systemLog:
   destination: file
   path: "/var/log/mongodb/mongod.log"
   logAppend: true
 storage:
   journal:
      enabled: true
processManagement:
   fork: true
net:
   bindIp: 127.0.0.1
   port: 27017
setParameter:
   enableLocalhostAuthBypass: false
```
	
## 命令 CRUD 操作

### 创建
MongoDB提供以下方法将文档插入到集合中：
- [db.collection.insertOne()](https://docs.mongodb.com/manual/reference/method/db.collection.insertOne/#db.collection.insertOne)
- [db.collection.insertMany()](https://docs.mongodb.com/manual/reference/method/db.collection.insertMany/#db.collection.insertMany) 最新3.2 版本


在MongoDB中，插入操作指向单个集合。 MongoDB中的所有写入操作都是基于单个文档的级别的。
![enter description here][2]

``` javascript
	db.collection('inventory').insertMany([
	  { item: "journal",
		qty: 25,
		tags: ["blank", "red"],
		size: { h: 14, w: 21, uom: "cm" }},
	  { item: "mat",
		qty: 85,
		tags: ["gray"],
		size: { h: 27.9, w: 35.5, uom: "cm" }},
	  { item: "mousepad",
		qty: 25,
		tags: ["gel", "blue"],
		size: { h: 19, w: 22.85, uom: "cm" }}
	])
	.then(function(result) {
	  //result 是一个_id 数组
	  
	})
```


### 读取
- [db.collection.find()][3]

![enter description here][4]

``` javascript
	var cursor = db.collection('inventory')
	.find({ 
  		size: { h: 14, w: 21, uom: "cm" }
	});
	
	// 高度小于 15
	var cursor = db.collection('inventory').find({ 
  		"size.h": { $lt: 15 }
	});
```


### 修改

- [db.collection.updateOne() ][5]
- [db.collection.updateMany()][6]
- [db.collection.replaceOne()](https://docs.mongodb.com/manual/reference/method/db.collection.replaceOne/#db.collection.replaceOne)

![enter description here][7]



### 删除
- [db.collection.deleteOne()][8]
- [db.collection.deleteMany()][9]

![enter description here][10]

### 全文搜索
`MongoDB`支持执行字符串内容的文本搜索的查询操作。要执行文本搜索，`MongoDB`使用文本索引和`$text`操作符。
例子
``` javascript
 # 创建商店
 db.stores.insert(
   [
     { _id: 1, name: "Java Hut", description: "Coffee and cakes" },
     { _id: 2, name: "Burger Buns", description: "Gourmet hamburgers" },
     { _id: 3, name: "Coffee Shop", description: "Just coffee" },
     { _id: 4, name: "Clothes Clothes Clothes", description: "Discount clothing" },
     { _id: 5, name: "Java Shopping", description: "Indonesian goods" }
   ]
)
```
**全文索引**

要执行文本搜索查询，您必须在集合上具有文本索引。一个集合只能有一个文本搜索索引，但该索引可以覆盖多个字段。

```javascript
db.stores.createIndex( { name: "text", description: "text" } )
```
**操作**
您可以使用以下查询来查找包含“coffee”，“shop”和“java”列表中任何术语的所有商店：
```javascript
	db.stores.find( { $text: { $search: "java coffee shop" } } )
```
您还可以通过将其包装成双引号来搜索确切的短语。例如，以下将找到包含“java”或“咖啡店”的所有文档：

```javascript
 db.stores.find( { $text: { $search: "java \"coffee shop\"" } } )
```
要排除一个单词，您可以添加一个“ - ”字符。例如，要查找包含“java”或“shop”而不是“coffee”的所有商店，请使用以下命令：

``` javascript
db.stores.find( { $text: { $search: "java shop -coffee" } } )
```
``` javascript
db.stores.find(
  	 { $text: { $search: "java coffee shop" } },
     { score: { $meta: "textScore" } })
   .sort( { score: { $meta: "textScore" } } )
```

## 可视化管理工具

### [MongoDB Cloud Manager](https://www.mongodb.com/cloud/cloud-manager?jmp=docs&_ga=1.170083235.2005306875.1453858874)

`MongoDB Cloud Manager`是官方推出的运维自动化管理系统，是企业版才支持的功能，社区用户也可以下载试用。

- `MongoDB` 集群（复制集、分片）的自动化部署
- 集群监控、及报警定制
- 自动数据备份与还原


### [MongoDB compass](https://www.mongodb.com/products/compass?jmp=docs)
> `MongoDB compass` 也是官方推出的可视化管理工具，企业版才支持，`compass` 与 `Cloud Manager` 功能互补，`Cloud Manager` 偏向于部署、运维、监控，而 `compass` 则偏向于数据管理、查询优化等，其主要功能包括

- 数据分布可视化，自动分析各个字段取值的分布情况
- 支持 CRUD 操作
- 索引自动分析及优化建议
- explain 的结果可视化

### [MongoDB Atlas](https://www.mongodb.com/cloud?jmp=docs&_ga=1.150153781.2005306875.1453858874)

> `MongoDB`官方提供的 `DBaaS` 服务（`Database as a Service`），目前支持在 `Amazon AWS` 上构建 MongoDB 的云服务，未来有可能会支持更多的云厂商（ 例如` Azure`、`Alibaba Cloud`等）并通过`Cloud Manager + compass` 来提供可视化的数据管理。


  [1]: `MongoDB`刚刚发布了其3.4.6版本，是目前最新的稳定版。
  [2]: https://docs.mongodb.com/manual/_images/crud-annotated-mongodb-insertOne.bakedsvg.svg
  [3]: https://docs.mongodb.com/manual/reference/method/db.collection.find/#db.collection.find
  [4]: https://docs.mongodb.com/manual/_images/crud-annotated-mongodb-find.bakedsvg.svg
  [5]: https://docs.mongodb.com/manual/reference/method/db.collection.updateOne/#db.collection.updateOne
  [6]: https://docs.mongodb.com/manual/reference/method/db.collection.updateMany/#db.collection.updateMany
  [7]: http://7xouu0.com1.z0.glb.clouddn.com/1501664080677.jpg
  [8]: https://docs.mongodb.com/manual/reference/method/db.collection.deleteOne/#db.collection.deleteOne
  [9]: https://docs.mongodb.com/manual/reference/method/db.collection.deleteMany/#db.collection.deleteMany
  [10]: http://7xouu0.com1.z0.glb.clouddn.com/1501664188511.jpg