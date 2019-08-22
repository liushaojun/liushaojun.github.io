title: zookeeper教程
date: 2016-07-27 10:07:53
categories: Java
tags: [ zookeeper ]
---


> zookeeper 是一个开源的分布式协调服务，由知名互联网公司雅虎公司创建，是Google Chubby 开源实现。 他致力于提供一个高性能，高可用，且具有严格的顺序访问控制能力的分布式协调服务。分布式应用可以基于诸如数据发布/订阅、负载均衡、命名服务、分布式协调/通知，集群管理、Master选举、分布式锁和分布式队列。 

<!-- more -->

## 基本概念

## zookeeper 应用场景

### 数据的发布、订阅

一方可以发布数据另一方接受数据

通常数据的订阅、发布 有两种方式：push / pull  
zk 采用两种方式相结合

发布者将数据发布到集群的节点上，订阅者通过一定的方法告诉服务器，我对那个节点的数据感兴趣，那个服务器在这些节点的数据发生变化时，就通知客户端，客户端得到通知后就可以去服务端获取数据
    
### 负载均衡

### DB
1. 首先DB在启动的是先把自己在zk 注册成一个临时的节点，zk的节点有两种一种是永久节点，另一种是临时节点。临时节点在服务器出现问题的时候，节点会自动从zk上删除，那么这样zk上的服务器列表是最新的可用的列表
2. 客户端需要读写数据库的时候首先去zk得到所有可用的DB连接信息（一张列表）
3. 客户端随机选择一台进行连接
4. 当客户端发现连接的时候再次从zk上获取可用的DB信息，当然也可以在刚获取的那个列表里移除掉不可用的连接后再选择一个DB连接


### 命名服务
     顾名思义就是提供名称服务，例如数据库表格ID，一般有两种ID，一种是分布式中使用的，一种是自增长的ID，UUID 可以在分布式中使用但由于没有规律较难理解，友好性不好，我们可以使用zk来生成一个顺序增长的，可以在集群环境下使用。

### 分布式协调/通知
心跳检测 
在分布式系统中，我们常常需要知道某个服务器是否可用，传统开发中，可以通过ping 某个主机。zk 中我们让所有机器都注册到一个临时节点，我们判断一个机器是否可用，我们只需判断这个节点zk是否存在就可以了，不需要直接去连接需要检查的机器，降低系统的复杂度。



## 环境搭建
1. 安装

     `wget http://mirrors.hust.edu.cn/apache/zookeeper/zookeeper-3.3.6/`
2. 解压

      `tar zxf zookeeper-3.3.6  && mv zookeeper-3.3.6 /usr/local/zookeeper`
3. 配置

     `vi /usr/local/<zookeeper>/conf/zoo.cnf`

    
     ```
    
          server.1=host:port:port-leader 
         
          server.2=host:port:port-leader   
         
          server.3=host:port:port-leader 
          touch myid && echo "<id>" > myid
     ```
      
4. 启动/停止

     `./zkServer start | stop`

5. 客户端连接    
     `./zkCli `

    
## master选举
**架构图**:
![](https://dn-imjun.qbox.me/2016-07-25-11-10-26.jpg)
**程序流程图:**

![](https://dn-imjun.qbox.me/2016-07-25-11-11-03.jpg)
**网络抖动:**

![](https://dn-imjun.qbox.me/2016-07-25-11-11-41.jpg)
**核心类图:**

![](https://dn-imjun.qbox.me/2016-07-25-11-12-08.jpg)

master 节点何时会删除

1. master 会主动放权

2. master 节点down机

3. master 节点网络斗动，会发生新一轮选举

4. 如果master 和上一轮选举的master 不是同一个节点，不一致时发生资源迁移

优化：让上一轮选举出的master 再新一轮选举中优先采用master 节点

**代码:**
``` java
package com.shaojun.zookeeper.mastersel;
import org.I0Itec.zkclient.ZkClient;
import org.I0Itec.zkclient.serialize.SerializableSerializer;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.List;

public class LeaderSelectorZkClient
{
    //启动的服务个数
    private static final int        CLIENT_QTY = 10;
    //zookeeper服务器的地址
    private static final  String  ZOOKEEPER_SERVER = "10.3.1.11:2181,10.3.1.11:2182,10.3.1.11:2183";
    
       
    public static void main(String[] args) throws Exception
    {
        //保存所有zkClient的列表
        List<ZkClient>  clients = new ArrayList<ZkClient>();
        //保存所有服务的列表
        List<WorkServer>  workServers = new ArrayList<WorkServer>();

        try
        {
            for ( int i = 0; i < CLIENT_QTY; ++i )
            {
                //创建zkClient
                ZkClient client = new ZkClient(ZOOKEEPER_SERVER, 15000, 105000, new SerializableSerializer());
                clients.add(client);
                //创建serverData
                RunningData runningData = new RunningData();
                runningData.setCid(Long.valueOf(i));
                runningData.setName("Client #" + i);
                //创建服务
                WorkServer  workServer = new WorkServer(runningData);
                workServer.setZkClient(client);
                
                workServers.add(workServer);
                workServer.start();
            }

            System.out.println("敲回车键退出！\n");
            new BufferedReader(new InputStreamReader(System.in)).readLine();
        }
        finally
        {
            System.out.println("Shutting down...");

            for ( WorkServer workServer : workServers )
            {
                try {
                    workServer.stop();
                } catch (Exception e) {
                    e.printStackTrace();
                }               
            }
            for ( ZkClient client : clients )
            {
                try {
                    client.close();
                } catch (Exception e) {
                    e.printStackTrace();
                }               
            }
        }        
    }
}
```
**running data 实体类**
``` java
package com.shaojun.zookeeper.mastersel;

import java.io.Serializable;

public class RunningData implements Serializable {

    private static final long serialVersionUID = 4260577459043203630L;

    private Long cid;
    private String name;
    public Long getCid() {
        return cid;
    }
    public void setCid(Long cid) {
        this.cid = cid;
    }
    public String getName() {
        return name;
    }
    public void setName(String name) {
        this.name = name;
    }

}

```
**工作服务器类:**
``` java
package com.shaojun.zookeeper.mastersel;

import org.I0Itec.zkclient.IZkDataListener;
import org.I0Itec.zkclient.ZkClient;
import org.I0Itec.zkclient.exception.ZkException;
import org.I0Itec.zkclient.exception.ZkInterruptedException;
import org.I0Itec.zkclient.exception.ZkNoNodeException;
import org.I0Itec.zkclient.exception.ZkNodeExistsException;
import org.apache.zookeeper.CreateMode;

import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

public class WorkServer {

    private volatile boolean running = false;

    private ZkClient zkClient;

    private static final String MASTER_PATH = "/master";

    private IZkDataListener dataListener;

    private RunningData serverData;

    private RunningData masterData;
    
    private ScheduledExecutorService delayExector = Executors.newScheduledThreadPool(1);
    private int delayTime = 5;

    public WorkServer(RunningData rd) {
        this.serverData = rd;
        this.dataListener = new IZkDataListener() {

            public void handleDataDeleted(String dataPath) throws Exception {
                // TODO Auto-generated method stub
                
                //takeMaster();
                
                
                if (masterData!=null && masterData.getName().equals(serverData.getName())){
                    takeMaster();
                    
                }else{
                    delayExector.schedule(new Runnable(){
                        public void run(){
                            takeMaster();
                        }
                    }, delayTime, TimeUnit.SECONDS);
                    
                }
                
                
            }

            public void handleDataChange(String dataPath, Object data)
                    throws Exception {
                // TODO Auto-generated method stub

            }
        };
    }

    public ZkClient getZkClient() {
        return zkClient;
    }

    public void setZkClient(ZkClient zkClient) {
        this.zkClient = zkClient;
    }

    public void start() throws Exception {
        if (running) {
            throw new Exception("server has startup...");
        }
        running = true;
        zkClient.subscribeDataChanges(MASTER_PATH, dataListener);
        takeMaster();

    }

    public void stop() throws Exception {
        if (!running) {
            throw new Exception("server has stoped");
        }
        running = false;
        
        delayExector.shutdown();

        zkClient.unsubscribeDataChanges(MASTER_PATH, dataListener);

        releaseMaster();

    }

    private void takeMaster() {
        if (!running)
            return;

        try {
            zkClient.create(MASTER_PATH, serverData, CreateMode.EPHEMERAL);
            masterData = serverData;
            System.out.println(serverData.getName()+" is master");
            delayExector.schedule(new Runnable() {          
                public void run() {
                    // TODO Auto-generated method stub
                    if (checkMaster()){
                        releaseMaster();
                    }
                }
            }, 5, TimeUnit.SECONDS);
            
        } catch (ZkNodeExistsException e) {
            RunningData runningData = zkClient.readData(MASTER_PATH, true);
            if (runningData == null) {
                takeMaster();
            } else {
                masterData = runningData;
            }
        } catch (Exception e) {
            // ignore;
        }

    }

    private void releaseMaster() {
        if (checkMaster()) {
            zkClient.delete(MASTER_PATH);

        }

    }

    private boolean checkMaster() {
        try {
            RunningData eventData = zkClient.readData(MASTER_PATH);
            masterData = eventData;
            if (masterData.getName().equals(serverData.getName())) {
                return true;
            }
            return false;
        } catch (ZkNoNodeException e) {
            return false;
        } catch (ZkInterruptedException e) {
            return checkMaster();
        } catch (ZkException e) {
            return false;
        }
    }

}

```
## 发布/订阅
**架构图:**
![](https://dn-imjun.qbox.me/2016-07-25-11-17-16.jpg)
**Manga Server 流程图:**

![](https://dn-imjun.qbox.me/2016-07-25-11-17-48.jpg)
**WorkServer 流程图:**

![](https://dn-imjun.qbox.me/2016-07-25-11-18-27.jpg)
**系统核心类图:**

![](https://dn-imjun.qbox.me/2016-07-25-11-19-14.jpg)
**代码:**
``` java
package com.shaojun.zookeeper.subscribe;

import java.util.List;

import org.I0Itec.zkclient.IZkChildListener;
import org.I0Itec.zkclient.IZkDataListener;
import org.I0Itec.zkclient.ZkClient;
import org.I0Itec.zkclient.exception.ZkNoNodeException;
import org.I0Itec.zkclient.exception.ZkNodeExistsException;

import com.alibaba.fastjson.JSON;

public class ManageServer {

    private String serversPath;
    private String commandPath;
    private String configPath;
    private ZkClient zkClient;
    private ServerConfig config;
    private IZkChildListener childListener;
    private IZkDataListener dataListener;
    private List<String> workServerList;

    public ManageServer(String serversPath, String commandPath,
            String configPath, ZkClient zkClient, ServerConfig config) {
        this.serversPath = serversPath;
        this.commandPath = commandPath;
        this.zkClient = zkClient;
        this.config = config;
        this.configPath = configPath;
        this.childListener = new IZkChildListener() {

            public void handleChildChange(String parentPath,
                    List<String> currentChilds) throws Exception {
                // TODO Auto-generated method stub
                workServerList = currentChilds;
                
                System.out.println("work server list changed, new list is ");
                execList();

            }
        };
        this.dataListener = new IZkDataListener() {

            public void handleDataDeleted(String dataPath) throws Exception {
                // TODO Auto-generated method stub
                // ignore;
            }

            public void handleDataChange(String dataPath, Object data)
                    throws Exception {
                // TODO Auto-generated method stub
                String cmd = new String((byte[]) data);
                System.out.println("cmd:"+cmd);
                exeCmd(cmd);

            }
        };

    }

    private void initRunning() {
        zkClient.subscribeDataChanges(commandPath, dataListener);
        zkClient.subscribeChildChanges(serversPath, childListener);
    }

    /*
     * 1: list 2: create 3: modify
     */
    private void exeCmd(String cmdType) {
        if ("list".equals(cmdType)) {
            execList();

        } else if ("create".equals(cmdType)) {
            execCreate();
        } else if ("modify".equals(cmdType)) {
            execModify();
        } else {
            System.out.println("error command!" + cmdType);
        }

    }

    private void execList() {
        System.out.println(workServerList.toString());
    }

    private void execCreate() {
        if (!zkClient.exists(configPath)) {
            try {
                zkClient.createPersistent(configPath, JSON.toJSONString(config)
                        .getBytes());
            } catch (ZkNodeExistsException e) {
                zkClient.writeData(configPath, JSON.toJSONString(config)
                        .getBytes());
            } catch (ZkNoNodeException e) {
                String parentDir = configPath.substring(0,
                        configPath.lastIndexOf('/'));
                zkClient.createPersistent(parentDir, true);
                execCreate();
            }
        }
    }

    private void execModify() {
        config.setDbUser(config.getDbUser() + "_modify");

        try {
            zkClient.writeData(configPath, JSON.toJSONString(config).getBytes());
        } catch (ZkNoNodeException e) {
            execCreate();
        }
    }

    public void start() {
        initRunning();
    }

    public void stop() {
        zkClient.unsubscribeChildChanges(serversPath, childListener);
        zkClient.unsubscribeDataChanges(commandPath, dataListener);
    }
}

```
**Server Config:**
``` java
package com.shaojun.zookeeper.subscribe;

public class ServerConfig {
    
    private String dbUrl;
    private String dbPwd;
    private String dbUser;
    public String getDbUrl() {
        return dbUrl;
    }
    public void setDbUrl(String dbUrl) {
        this.dbUrl = dbUrl;
    }
    public String getDbPwd() {
        return dbPwd;
    }
    public void setDbPwd(String dbPwd) {
        this.dbPwd = dbPwd;
    }
    public String getDbUser() {
        return dbUser;
    }
    public void setDbUser(String dbUser) {
        this.dbUser = dbUser;
    }
    
    @Override
    public String toString() {
        return "ServerConfig [dbUrl=" + dbUrl + ", dbPwd=" + dbPwd
                + ", dbUser=" + dbUser + "]";
    }

}

```
**Server data**
``` java
package com.shaojun.zookeeper.subscribe;

public class ServerData {
    
    private String address;
    private Integer id;
    private String name;
    public String getAddress() {
        return address;
    }
    public void setAddress(String address) {
        this.address = address;
    }
    public Integer getId() {
        return id;
    }
    public void setId(Integer id) {
        this.id = id;
    }
    public String getName() {
        return name;
    }
    public void setName(String name) {
        this.name = name;
    }
    
    @Override
    public String toString() {
        return "ServerData [address=" + address + ", id=" + id + ", name="
                + name + "]";
    }

}

```
**订阅发布入口:**
``` java
package com.shaojun.zookeeper.subscribe;

import java.io.BufferedReader;
import java.io.InputStreamReader;
import java.util.ArrayList;
import java.util.List;

import org.I0Itec.zkclient.ZkClient;
import org.I0Itec.zkclient.serialize.BytesPushThroughSerializer;


public class SubscribeZkClient {
    
       private static final int  CLIENT_QTY = 5;

        private static final String  ZOOKEEPER_SERVER = "192.168.1.105:2181";
        
        private static final String  CONFIG_PATH = "/config";
        private static final String  COMMAND_PATH = "/command";
        private static final String  SERVERS_PATH = "/servers";
           
        public static void main(String[] args) throws Exception
        {

            List<ZkClient>  clients = new ArrayList<ZkClient>();
            List<WorkServer>  workServers = new ArrayList<WorkServer>();
            ManageServer manageServer = null;

            try
            {
                ServerConfig initConfig = new ServerConfig();
                initConfig.setDbPwd("123456");
                initConfig.setDbUrl("jdbc:mysql://localhost:3306/mydb");
                initConfig.setDbUser("root");
                
                ZkClient clientManage = new ZkClient(ZOOKEEPER_SERVER, 5000, 5000, new BytesPushThroughSerializer());
                manageServer = new ManageServer(SERVERS_PATH, COMMAND_PATH,CONFIG_PATH,clientManage,initConfig);
                manageServer.start();
                                
                for ( int i = 0; i < CLIENT_QTY; ++i )
                {
                    ZkClient client = new ZkClient(ZOOKEEPER_SERVER, 5000, 5000, new BytesPushThroughSerializer());
                    clients.add(client);
                    ServerData serverData = new ServerData();
                    serverData.setId(i);
                    serverData.setName("WorkServer#"+i);
                    serverData.setAddress("192.168.1."+i);

                    WorkServer  workServer = new WorkServer(CONFIG_PATH, SERVERS_PATH, serverData, client, initConfig);
                    workServers.add(workServer);
                    workServer.start();                 
                    
                }               
                System.out.println("敲回车键退出！\n");
                new BufferedReader(new InputStreamReader(System.in)).readLine();
                
            }
            finally
            {
                System.out.println("Shutting down...");

                for ( WorkServer workServer : workServers )
                {
                    try {
                        workServer.stop();
                    } catch (Exception e) {
                        e.printStackTrace();
                    }               
                }
                for ( ZkClient client : clients )
                {
                    try {
                        client.close();
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                    
                }
            }
        }   
}

```
**Work Server 类:**

``` java
package com.shaojun.zookeeper.subscribe;

import org.I0Itec.zkclient.IZkDataListener;
import org.I0Itec.zkclient.ZkClient;
import org.I0Itec.zkclient.exception.ZkNoNodeException;

import com.alibaba.fastjson.JSON;

public class WorkServer {

    private ZkClient zkClient;
    private String configPath;
    private String serversPath;
    private ServerData serverData;
    private ServerConfig serverConfig;
    private IZkDataListener dataListener;

    public WorkServer(String configPath, String serversPath,
            ServerData serverData, ZkClient zkClient, ServerConfig initConfig) {
        this.zkClient = zkClient;
        this.serversPath = serversPath;
        this.configPath = configPath;
        this.serverConfig = initConfig;
        this.serverData = serverData;

        this.dataListener = new IZkDataListener() {

            public void handleDataDeleted(String dataPath) throws Exception {
                // TODO Auto-generated method stub

            }

            public void handleDataChange(String dataPath, Object data)
                    throws Exception {
                // TODO Auto-generated method stub
                String retJson = new String((byte[])data);
                ServerConfig serverConfigLocal = (ServerConfig)JSON.parseObject(retJson,ServerConfig.class);
                updateConfig(serverConfigLocal);
                System.out.println("new Work server config is:"+serverConfig.toString());
                
            }
        };

    }

    public void start() {
        System.out.println("work server start...");
        initRunning();

    }

    public void stop() {
        System.out.println("work server stop...");
        zkClient.unsubscribeDataChanges(configPath, dataListener);
    }

    private void initRunning() {

        registMe();
        zkClient.subscribeDataChanges(configPath, dataListener);

    }

    private void registMe() {
        String mePath = serversPath.concat("/").concat(serverData.getAddress());

        try {
            zkClient.createEphemeral(mePath, JSON.toJSONString(serverData)
                    .getBytes());
        } catch (ZkNoNodeException e) {
            zkClient.createPersistent(serversPath, true);
            registMe();
        }
    }

    private void updateConfig(ServerConfig serverConfig) {
        this.serverConfig = serverConfig;
    }

}

```

## 负载均衡

**架构图**

![](https://dn-imjun.qbox.me/2016-07-25-11-24-14.jpg)
**客户端流程**

![](https://dn-imjun.qbox.me/2016-07-25-11-24-37.jpg)
**服务端主体流程图**

![](https://dn-imjun.qbox.me/2016-07-25-11-25-00.jpg)
**Server 核心类图**

![](https://dn-imjun.qbox.me/2016-07-25-11-25-18.jpg)
**代码结构:**
**客户端**
![](https://dn-imjun.qbox.me/2016-07-25-11-26-25.jpg)
**服务端**

![](https://dn-imjun.qbox.me/2016-07-25-11-26-59.jpg)

## 命名服务
**架构图**
![](https://dn-imjun.qbox.me/2016-07-25-11-30-32.jpg)
**核心算法**
![](https://dn-imjun.qbox.me/2016-07-25-11-30-51.jpg)
**代码**
``` java
package com.shaojun.zookeeper.nameservice;

import org.I0Itec.zkclient.ZkClient;
import org.I0Itec.zkclient.exception.ZkNodeExistsException;
import org.I0Itec.zkclient.serialize.BytesPushThroughSerializer;

import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;
import java.util.concurrent.TimeUnit;

public class IdMaker {
    
    
    private ZkClient client = null;
    private final String server;
    private final String root;
    private final String nodeName;
    private volatile boolean running = false;
    private ExecutorService cleanExector = null;
    
    public enum RemoveMethod{
        NONE,IMMEDIATELY,DELAY
        
    }
    
    public IdMaker(String zkServer,String root,String nodeName){
        
        this.root = root;
        this.server = zkServer;
        this.nodeName = nodeName;
        
    }
    
    public void start() throws Exception {
        
        if (running)
            throw new Exception("server has stated...");
        running = true;
        
        init();
        
    }
    
    
    public void stop() throws Exception {
        
        if (!running)
            throw new Exception("server has stopped...");
        running = false;
        
        freeResource();
        
    }
    
    
    private void init(){
        
        client = new ZkClient(server,5000,5000,new BytesPushThroughSerializer());
        cleanExector = Executors.newFixedThreadPool(10);
        try{
            client.createPersistent(root,true);
        }catch (ZkNodeExistsException e){
            //ignore;
        }
        
    }
    
    private void freeResource(){
    
        cleanExector.shutdown();
        try{
            cleanExector.awaitTermination(2, TimeUnit.SECONDS);
            
        }catch(InterruptedException e){
            e.printStackTrace();
        }finally{
            cleanExector = null;
        }
    
        if (client!=null){
            client.close();
            client=null;
            
        }
    }
    
    private void checkRunning() throws Exception {
        if (!running)
            throw new Exception("请先调用start");
        
    }
    
    private String ExtractId(String str){
        int index = str.lastIndexOf(nodeName);
        if (index >= 0){
            index+=nodeName.length();
            return index <= str.length()?str.substring(index):"";
        }
        return str;
        
    }
    
    public String generateId(RemoveMethod removeMethod) throws Exception{
        checkRunning();
        final String fullNodePath = root.concat("/").concat(nodeName);
        final String ourPath = client.createPersistentSequential(fullNodePath, null);
        
        if (removeMethod.equals(RemoveMethod.IMMEDIATELY)){
            client.delete(ourPath);
        }else if (removeMethod.equals(RemoveMethod.DELAY)){
            cleanExector.execute(new Runnable() {
                
                public void run() {
                    // TODO Auto-generated method stub
                    client.delete(ourPath);
                }
            });
            
        }
        //node-0000000000, node-0000000001
        return ExtractId(ourPath);
    }

}

```
**测试**
``` java
package com.shaojun.zookeeper.nameservice;


public class TestIdMaker {

    public static void main(String[] args) throws Exception {
        
        IdMaker idMaker = new IdMaker("localhost:2181",
                "/NameService/IdGen", "ID");
        idMaker.start();

        try {
            for (int i = 0; i < 10; i++) {
                String id = idMaker.generateId(IdMaker.RemoveMethod.DELAY);
                System.out.println(id);

            }
        } finally {
            idMaker.stop();

        }
    }

}

```
## 分布式队列
**架构图**
![](https://dn-imjun.qbox.me/2016-07-25-11-31-24.jpg)
**offer 核心算法**
![](https://dn-imjun.qbox.me/2016-07-25-11-31-32.jpg)
**poll 核心算法**
![](https://dn-imjun.qbox.me/2016-07-25-11-31-40.jpg)
**核心代码**
**简单的队列**
``` java
package com.shaojun.zookeeper.queue;
import org.I0Itec.zkclient.ExceptionUtil;
import org.I0Itec.zkclient.ZkClient;
import org.I0Itec.zkclient.exception.ZkNoNodeException;

import java.util.Collections;
import java.util.Comparator;
import java.util.List;

public class DistributedSimpleQueue<T> {

    protected final ZkClient zkClient;
    protected final String root;

    protected static final String Node_NAME = "n_";
    public DistributedSimpleQueue(ZkClient zkClient, String root) {
        this.zkClient = zkClient;
        this.root = root;
    }

    public int size() {
        return zkClient.getChildren(root).size();
    }

    public boolean isEmpty() {
        return zkClient.getChildren(root).size() == 0;
    }
    
    public boolean offer(T element) throws Exception{
        
        String nodeFullPath = root .concat( "/" ).concat( Node_NAME );
        try {
            zkClient.createPersistentSequential(nodeFullPath , element);
        }catch (ZkNoNodeException e) {
            zkClient.createPersistent(root);
            offer(element);
        } catch (Exception e) {
            throw ExceptionUtil.convertToRuntimeException(e);
        }
        return true;
    }


    @SuppressWarnings("unchecked")
    public T poll() throws Exception {
        
        try {

            List<String> list = zkClient.getChildren(root);
            if (list.size() == 0) {
                return null;
            }
            Collections.sort(list, new Comparator<String>() {
                public int compare(String lhs, String rhs) {
                    return getNodeNumber(lhs, Node_NAME).compareTo(getNodeNumber(rhs, Node_NAME));
                }
            });
            
            for ( String nodeName : list ){
                
                String nodeFullPath = root.concat("/").concat(nodeName);    
                try {
                    T node = (T) zkClient.readData(nodeFullPath);
                    zkClient.delete(nodeFullPath);
                    return node;
                } catch (ZkNoNodeException e) {
                    // ignore
                }
            }
            
            return null;
            
        } catch (Exception e) {
            throw ExceptionUtil.convertToRuntimeException(e);
        }

    }

    private String getNodeNumber(String str, String nodeName) {
        int index = str.lastIndexOf(nodeName);
        if (index >= 0) {
            index += Node_NAME.length();
            return index <= str.length() ? str.substring(index) : "";
        }
        return str;

    }

}

```
**扩展队列**
```java
package com.shaojun.zookeeper.queue;




import org.I0Itec.zkclient.IZkChildListener;
import org.I0Itec.zkclient.ZkClient;

import java.util.List;
import java.util.concurrent.CountDownLatch;


public class DistributedBlockingQueue<T> extends DistributedSimpleQueue<T>{      
    
    
    public DistributedBlockingQueue(ZkClient zkClient, String root) {
        super(zkClient, root);

    }
    

    @Override
    public T poll() throws Exception {

        while (true){
            
            final CountDownLatch    latch = new CountDownLatch(1);
            final IZkChildListener childListener = new IZkChildListener() {
                
                public void handleChildChange(String parentPath, List<String> currentChilds)
                        throws Exception {
                    latch.countDown();
                    
                }
            };
            zkClient.subscribeChildChanges(root, childListener);
            try{
                T node = super.poll();
                if ( node != null ){
                    return node;
                }else{
                    latch.await();
                }
            }finally{
                zkClient.unsubscribeChildChanges(root, childListener);
                
            }
            
        }
    }

}

```
**测试类**
```java
package com.shaojun.zookeeper.queue;

import org.I0Itec.zkclient.ZkClient;
import org.I0Itec.zkclient.serialize.SerializableSerializer;

import java.util.concurrent.Executors;
import java.util.concurrent.ScheduledExecutorService;
import java.util.concurrent.TimeUnit;

public class TestDistributedBlockingQueue {

    public static void main(String[] args) {
        
        
        ScheduledExecutorService delayExector = Executors.newScheduledThreadPool(1);
        int delayTime = 5;
        
        ZkClient zkClient = new ZkClient("localhost:2181", 5000, 5000, new SerializableSerializer());
        final DistributedBlockingQueue<User> queue = new DistributedBlockingQueue<User>(zkClient,"/Queue");
        
        final User user1 = new User();
        user1.setId("1");
        user1.setName("xiao wang");
        
        final User user2 = new User();
        user2.setId("2");
        user2.setName("xiao wang");     
        
        try {
            
            delayExector.schedule(new Runnable() {
                
                public void run() {
                    try {
                        queue.offer(user1);
                        queue.offer(user2);
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                    
                }
            }, delayTime , TimeUnit.SECONDS);
            
            System.out.println("ready poll!");
            User u1 = (User) queue.poll();
            User u2 = (User) queue.poll();
            
            if (user1.getId().equals(u1.getId()) && user2.getId().equals(u2.getId())){
                System.out.println("Success!");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
        } finally{
            delayExector.shutdown();
            try {
                delayExector.awaitTermination(2, TimeUnit.SECONDS);
            } catch (InterruptedException e) {
            }
            
        }
    
    }
    
}

```

## 分布式锁
**架构图**

![](https://dn-imjun.qbox.me/2016-07-25-11-32-54.jpg)
**核心算法流程图**

![](https://dn-imjun.qbox.me/2016-07-25-11-33-12.jpg)
**全局事务锁的相关代码**

![](https://dn-imjun.qbox.me/2016-07-25-11-41-10.jpg)
