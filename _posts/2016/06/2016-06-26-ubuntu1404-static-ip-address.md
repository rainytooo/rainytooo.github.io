---
layout: post
title: ubuntu14.04 更换ip地址为静态地址
date: 2016-06-26
categories: 
    - server
    - linux
    - ubuntu
tags: [ubuntu, config, linux, network]
---


好久没有折腾运维的事情了,以前还是玩gentoo的多,现在全民皆ubuntu了,用了一下,确实方便,快,gentoo唯一就是编译慢,都是源码自定义编译.


### 1.修改网卡配置文件

`sudo vim /etc/network/interfaces`

### 2.内容如下

```
auto eth0
iface eth0 inet static 
  address 10.0.0.201
  netmask 255.0.0.0
  network 10.0.0.0
  gateway 10.0.0.1
  dns-nameservers 114.114.114.114 114.114.115.115

```

### 3.重启网卡

```bash
sudo ifdown eth0 && sudo ifup eth0

```
