---
layout: post
title: 使用Docker配置基于0.14.x版本kong做为api网关
subtitle: kong在升级以后整个结构全部变了,以前0.8版本的配置完全不能用了 
date: 2018-11-26
category: [sa, gateway]
tags: [kong, api]
published: true
---


### 环境

* aliyun容器服务集群
* kong版本0.14.x


### 新的概念

变化还真大,之前用的0.8,那时候的概念主要是API, consumers, 一年没折腾回来一看,大变化.





### kong的Service和Route

从0.13开始 kong就弃用的api改用service来组织api

* 增加了service Route Upstream Target
* service 相当于原来的api,但是没有路由信息,可以直接挂载物理host,也可以挂一个Upstream的host
* Route就是专门定义外部访问的分发hosts,strip_path,preserve_host,protocols,甚至method都在这里定义,和service关联
* Upstream,这个是新东西,一个虚拟的后端服务, 需要结合Target一起使用, 好处是可以在这里就完成负载均衡,还有健康检查
* 给Upstream添加实际的物理节点,实现的负载均衡


Service：
    Service 顾名思义，就是我们自己定义的上游服务，通过Kong匹配到相应的请求要转发的地方

    Service 可以与下面的Route进行关联，一个Service可以有很多Route，匹配到的Route就会转发到Service中，
    当然中间也会通过Plugin的处理，增加或者减少一些相应的Header或者其他信息

    Service可以是一个实际的地址，也可以是Kong内部提供的upstream object

Route：
    Route 字面意思就是路由，实际就是我们通过定义一些规则来匹配客户端的请求，每个路由都会关联一个Service,
    并且Service可以关联多个Route，当匹配到客户端的请求时，每个请求都会被代理到其配置的Service中

    Route作为客户端的入口，通过将Route和Service的松耦合，可以通过hosts path等规则的配置，最终让请求到不同的Service中

    例如，我们规定api.example.com 和 api.service.com的登录请求都能够代理到123.11.11.11:8000端口上，那我们可以通过hosts和path来路由

    首先，创建一个Service s1，其相应的host和port以及协议为http://123.11.11.11:8000
    然后，创建一个Route，关联的Service为s1，其hosts为[api.service.com, api.example.com],path为login
    最后，将域名api.example.com和api.service.com的请求转到到我们的Kong集群上，也就是我们上面一节中通过Nginx配置的请求地址
    那么，当我们请求api.example.com/login和api.service.com/login时，其通过Route匹配，然后转发到Service，最终将会请求我们自己的服务。

Upstream：


    这是指您自己的API /服务位于Kong后面，客户端请求被转发到该服务器。

    相当于Kong提供了一个负载的功能，基于Nginx的虚拟主机的方式做的负载功能

    当我们部署集群时，一个单独的地址不足以满足我们的时候，我们可以使用Kong的upstream来进行设置

    首先在service中指定host的时候，可以指定为我们的upstream定义的hostname

    我们在创建upstream时指定名字，然后指定solts(暂时不确定具体作用)，upstream可以进行健康检查等系列操作。这里先不开启（还没有研究）

    然后我们可以再创建target类型，将target绑定到upstream上，那么基本上我们部署集群时，也可以使用

Target：

    target 就是在upstream进行负载均衡的终端，当我们部署集群时，需要将每个节点作为一个target，并设置负载的权重，当然也可以通过upstream的设置对target进行健康检查。
    当我们使用upstream时，整个路线是 Route >> Service >> Upstream >> Target 

API：
    用于表示您的上游服务的传统实体。自0.13.0起弃用服务。这里就不在深入了解

Consumer：

    Consumer 可以代表一个服务，可以代表一个用户，也可以代表消费者，可以根据我们自己的需求来定义

    可以将一个Consumer对应到实际应用中的一个用户，也可以只是作为一个Service的请求消费者

    Consumer具体可以在Plugin使用时再做深入了解

Plugin：
    在请求被代理到上游API之前或之后执行Kong内的动作的插件。

    例如，请求之前的Authentication或者是请求限流插件的使用

    Plugin可以和Service绑定，也可以和Route以及Consumer进行关联。

    具体的使用可以根据在创建Plugin以及后面的修改时，具体与Consumer，Service，Route绑定关系时，可参考


# 新建一个服务的全部过程


### 1.添加service

```
curl -X POST \
  http://kong.admin.example.com/services \
  -H 'Cache-Control: no-cache' \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  -H 'Postman-Token: d83730eb-e0c5-4d8e-aa88-326b26fc6dd1' \
  -d 'name=igw_dev_http&host=igw-node-server-development&port=3000&protocol=http&read_timeout=60000&write_timeout=60000'
```



```
{
    "host": "igw-node-server-development",
    "created_at": 1535959703,
    "connect_timeout": 60000,
    "id": "1234567890qazwsx",
    "protocol": "http",
    "name": "igw_dev_http",
    "read_timeout": 60000,
    "port": 3000,
    "path": null,
    "updated_at": 1535959703,
    "retries": 5,
    "write_timeout": 60000
}
```


### 2.添加 route

```
curl -X POST \
  http://kong.admin.example.com/routes/ \
  -H 'Cache-Control: no-cache' \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  -H 'Postman-Token: 5e44a8dc-e457-4af3-b11f-be4d8c0236bf' \
  -d 'protocols%5B%5D=http&methods%5B%5D=GET&methods%5B%5D=POST&hosts%5B%5D=igw.dev.example.com&strip_path=false&preserve_host=true&service.id=1234567890qazwsx'
```


```
{
    "created_at": 1535962443,
    "strip_path": false,
    "hosts": [
        "igw.dev.example.com"
    ],
    "preserve_host": true,
    "regex_priority": 0,
    "updated_at": 1535962443,
    "paths": null,
    "service": {
        "id": "1234567890qazwsx"
    },
    "methods": [
        "GET",
        "POST"
    ],
    "protocols": [
        "http"
    ],
    "id": "1234567890qwertyuiop"
}
```



### 3.新的添加route的方法

之后所有的api走同一个域名的不同path,这样可以节约ssl证书,都在api.example.com下


```
curl -X POST \
  http://kong.admin.example.com/routes/ \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  -H 'Postman-Token: 0a4f4173-e4fa-4fe0-b3e5-20ef5363bdbe' \
  -H 'cache-control: no-cache' \
  -d 'protocols%5B%5D=http&protocols%5B%5D=https&methods%5B%5D=GET&methods%5B%5D=POST&methods%5B%5D=PUT&methods%5B%5D=DELETE&methods%5B%5D=PATCH&methods%5B%5D=HEAD&hosts%5B%5D=api.example.com&strip_path=true&preserve_host=true&service.id=1234567890qazwsx&paths%5B%5D=%2Figw&undefined='
```


```
{
    "created_at": 1543224681,
    "strip_path": true,
    "hosts": [
        "api.example.com"
    ],
    "preserve_host": true,
    "regex_priority": 0,
    "updated_at": 1543224681,
    "paths": [
        "/igw"
    ],
    "service": {
        "id": "1234567890qazwsx"
    },
    "methods": [
        "GET",
        "POST",
        "PUT",
        "DELETE",
        "PATCH",
        "HEAD"
    ],
    "protocols": [
        "http",
        "https"
    ],
    "id": "23456789ertyuiop"
}
```
