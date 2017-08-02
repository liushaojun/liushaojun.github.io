title: IOS抓包工具
categories:
  - 工具
tags:
  - https
  - ios
date: 2016-11-23 11:52:00
---
>在iOS开发过程中，抓包是常见的必备技能之一。这里我们主要介绍一下Mac下的抓包利器Charles（文中版本：4.0.1）。它可以非常方便的抓取Http/Https请求，从而提高我们的开发效率。本文中不提供破解版安装使用说明（网上一大堆），建议使用正版，官方dmg下载地址：[Charlesproxy](https://www.chrelesproxy.com/download/)

<!-- more -->
破解版:http://charles.iiilab.com)

## 如何抓取Http请求？

- 安装完成之后打开Charles，设置端口号:8888（端口号可以自定义）。

选择“Proxy”菜单下的“Proxy Settings”子菜单。打开“Proxy Settings”对话框：
![](https://dn-imjun.qbox.me/chreles1.jpg)
- 在“Proxy Settings”对话框中设置端口号:8888，并勾选“Enable transparent Http proxying”

![](https://dn-imjun.qbox.me/chreles2.jpg)

- 打开“网络偏好设置”查看电脑IP地址：

![](https://dn-imjun.qbox.me/chreles3.jpg)

- 设置手机网络（iOS）
![](https://dn-imjun.qbox.me/chreles4.jpg)


- 打开需要抓包的手机APP，初次使用时，Charles会弹出确认对话框，直接点击”Allow”按钮后就可以看到对应的请求数据

__温馨提示__：抓完包之后，请把手机WiFi中的HTTP代理关闭。不然可能造成iOS无法访问网络。


## 如何抓取Https请求?

1. 电脑安装SSL证书

选中Charles，在“Help”菜单中选择—>“SSL Proxying”—>“Install Charles Root Certificate”会自动打开钥匙串访问窗口
![](https://dn-imjun.qbox.me/chreles5.jpg)
在“钥匙串访问”窗口中找到对应的证书，双击打开。设置“使用证书时”项为：始终信任。
![](https://dn-imjun.qbox.me/chreles6.jpg)

填写管理员密码更新设置。
![](https://dn-imjun.qbox.me/chreles7.jpg)

2. 手机安装证书（使用Safari方式）

请确保手机已经设置好手动代理（具体方式参照上面HTTP抓包设置方式）。

在手机Safari浏览器中输入下面的链接地址：
[Charles Proxy](http://charlesproxy.com/getssl)。手机会自动跳转安装“Charles Proxy SSL Proxying”描述文件。如下图所示：
![](https://dn-imjun.qbox.me/chreles8.jpg)
点击“安装”按钮，会提示输入手机密码，然后确认安装。
![](https://dn-imjun.qbox.me/chreles9.jpg)
以上便完成手机SSL证书安装步骤。

3. 在Charles工具栏上点击设置按钮，选择“SSL Proxying Settings…”

打开“SSL Proxying Settings”对话框

![](https://dn-imjun.qbox.me/chreles10.jpg)
点击“Add”添加：Host中输入*表示匹配所有主机。https默认端口号：443
![](https://dn-imjun.qbox.me/chreles11.jpg)
添加完成显示结果如下
![](https://dn-imjun.qbox.me/chreles12.jpg)


3. 测试

- 安装手机证书之前测试结果如下图所示
![](https://dn-imjun.qbox.me/chreles13.jpg)


- 安装手机证书之后测试结果如下图所示：
![](https://dn-imjun.qbox.me/chreles14.jpg)


针对Charles代理访问https有些正常有些失败的处理方法（一般https只要打开charles 的”Enable SSL Proxying”代理就能访问）

## 如果没有Wifi，我们还可以这样抓包？（本文不做详解）

1. 抓包之rvictl方式
- 开启虚拟端口：`rvictl -s`
- 关闭虚拟端口：`rvictl -x`
- 然后使用`wireshark`来捕捉这个端口数据。

2. 抓包之tcpdump方式
有个很大的缺点是手机需要越狱。