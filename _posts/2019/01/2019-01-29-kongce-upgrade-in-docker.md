---
layout: post
title: 记一次kong的升级docker容器,从0.14到1.0.2
subtitle: kong的docker版本升级
date: 2019-01-29
category: [DevOps, docker]
tags: [kong, api]
published: true
---


# Content

* 环境
* 实施过程


## 环境

* 阿里云的容器集群swarm模式
* docker17.06.2-ce	
* mysql版本`mysql:5.7.24`


## 实施过程


### 1.修改镜像版本

原来的服务编排

```
pro-kong-ce:
  image: 'kong:0.14.1-alpine'
  restart: always
  hostname: 'production-kong-ce'
  environment:
    - KONG_DATABASE=postgres
    - KONG_PG_HOST=pro-postgre-db
    - 'constraint:aliyun.node_index==3'
    - KONG_ADMIN_LISTEN=0.0.0.0:8001, 0.0.0.0:8444 ssl
  labels:
    aliyun.scale: '1'
```

要升级到最新版本(最新版本是1.0.2),直接修改版本号

```
pro-kong-ce:
  image: 'kong:1.0.2-alpine'
  restart: always
  hostname: 'production-kong-ce'
  environment:
    - KONG_DATABASE=postgres
    - KONG_PG_HOST=pro-postgre-db
    - 'constraint:aliyun.node_index==3'
    - KONG_ADMIN_LISTEN=0.0.0.0:8001, 0.0.0.0:8444 ssl
  labels:
    aliyun.scale: '1'
```

### 2.启动服务

运行后服务无法启动,看日志,发现没有migration


### 3.执行migration


于是登录到host,执行下面的命令(sudo)

```
docker run --rm \
    --network=multi-host-network \
    -e "KONG_DATABASE=postgres" \
    -e "KONG_PG_HOST=pro-postgre-db" \
    -e "KONG_CASSANDRA_CONTACT_POINTS=kong-database" \
    kong:1.0.2-alpine kong migrations up
```

注意`--network=multi-host-network`一定要有,否则找不到postgre的主机

### 4.再次重启服务

一切ok,升级完毕.