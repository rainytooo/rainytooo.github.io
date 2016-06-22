---
layout: post
title: ubuntu14.04 上kong服务器的搭建
date: 2016-06-22
categories: 
    - server
tags: [kong, api, restful]
---



# kong是什么

[kong](https://getkong.org/)是由Mashape出品的一款开源的api gateway服务器,官方解释为API Gateway, or API Middleware,由lua语言编写.

kong的主要功能:

* 集中管理api,各个业务模块可以在kong上注册,集中访问
* 权限控制,提供丰富的插件,包括Base Authentication, Oauth2, HMAC Authentication, LDAP, JWT等等
* 安全管理
* 访问监控
* 数据分析
* 过滤数据和转换
* 日志集中收集和报告
* 丰富的可插拔的插件
* 自定义开发插件

为何使用kong?原来直接管理api不行吗?看看下面的对比图

随着业务的增加,平台的多样化,使用kong之前和使用kong以后的架构图

<img src="/img/posts/2016/06/diagram-left.png" alt="..." width="300"> <img src="/img/posts/2016/06/diagram-right.png" alt="..." width="300">

更多的就不再介绍了,去官网看吧,下面进入正题.


# 准备

### 操作系统

这里我用的是ubuntu14.04 64位,直接在virtual box上新装的一个,完全干净.


### 安装PostgreSql

这里遇到一个坑,之前装ubuntu的时候,在安装操作系统的时候就选上了一起安装了,但是最后kong运行不起来,
发现官方要求安装的是9.4以上版本,无奈写作9.3重新安装.
这里可以参考[postgre download](https://www.postgresql.org/download/linux/ubuntu/)


我的操作步骤是:

##### 1. 添加一个非官方源

```bash
sudo vim /etc/apt/sources.list.d/pgdg.list
# 添加以下内容
deb http://apt.postgresql.org/pub/repos/apt/ trusty-pgdg main
```

##### 2. 导入key,刷新

```bash
wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | \
  sudo apt-key add -
sudo apt-get update
```

##### 3. 安装postgresql

```
sudo apt-get install postgresql-9.5
```

(1).修改配置文件`postgresql.conf `

```
sudo vim /etc/postgresql/9.5/main/postgresql.conf 
```

需要修改的内容如下

```
listen_addresses = '*'
password_encryption = on
```

(2).修改配置文件`pg_hba.conf `

```
sudo vim /etc/postgresql/9.5/main/pg_hba.conf
```

需要修改的内容如下,尾部加上

```
host all all 0.0.0.0 0.0.0.0 md5
```

重启postgresql

```
sudo service postgresql restart
```

##### 4. 修改口令

安装过程中,系统已经添加了postgres的用户,并且这个用户的环境变量都设置好了,命令行工具很丰富.

```
sudo passwd postgres
```

然后切换到用户,修改postgre数据库的密码

```
su - postgres
```

修改密码

```
postgres@vos2016062102:~$ psql postgres 
psql (9.5.3)
输入 "help" 来获取帮助信息.

postgres=# alter user postgres with password 'your password';
ALTER ROLE
postgres=# 

```

##### 5. 建立数据库给kong用

先创建用户


```
CREATE USER kong_user WITH PASSWORD 'kong_pass';

```

创建数据库,并给用户授权

```
create database "kong_db";

GRANT ALL PRIVILEGES ON DATABASE "kong_db" to kong_user;
```

至此,数据库准备完毕,当然还有另外一个选择,`Apache Cassandra`这里就不去介绍了.


# 安装kong



安装之前先保证如下软件安装

```
sudo apt-get install netcat openssl libpcre3 dnsmasq procps
```

在[https://getkong.org/install/ubuntu/](https://getkong.org/install/ubuntu/)下载最新的kong的deb安装包,然后

```
sudo dpkg -i kong-0.8.3.*.deb
```



# 配置kong

kong的配置相对简单,我这里只是简单的配置了数据库.

```bash
sudo vim /etc/kong/kong.yml 
```

修改数据库配置


```bash
######
## Specify which database to use. Only "cassandra" and "postgres" are currently available.
database: postgres

######
## PostgreSQL configuration
postgres:
  host: "127.0.0.1"
  port: 5434

  ######
  ## Name of the database used by Kong. Will be created if it does not exist.
  database: kong_db

  #####
  ## User authentication settings
  user: "kong_user"
  password: "kong_pass"

```

# 启动kong

```
vincent@vos2016062102:~$ kong start
[INFO] kong 0.8.3
[INFO] Using configuration: /etc/kong/kong.yml
[INFO] Setting working directory to /usr/local/kong
[INFO] database...........postgres host=127.0.0.1 database=kong_db user=kong_user password=kong_pass port=5434
[INFO] dnsmasq............address=127.0.0.1:8053 dnsmasq=true port=8053
[INFO] serf ..............-profile=wan -rpc-addr=127.0.0.1:7373 -event-handler=member-join,member-leave,member-failed,member-update,member-reap,user:kong=/usr/local/kong/serf_event.sh -bind=0.0.0.0:7946 -node=vos2016062102_0.0.0.0:7946_41048dd160be4135b4cfa9e5476f4275 -log-level=err
[INFO] Trying to auto-join Kong nodes, please wait..
[INFO] No other Kong nodes were found in the cluster
[WARN] ulimit is currently set to "1024". For better performance set it to at least "4096" using "ulimit -n"
[INFO] nginx .............admin_api_listen=0.0.0.0:8001 proxy_listen=0.0.0.0:8000 proxy_listen_ssl=0.0.0.0:8443
[OK] Started
```

测试

```bash
curl 127.0.0.1:8001
```

响应如下


```json
{
  "timers": {
    "running": 0,
    "pending": 4
  },
  "version": "0.8.3",
  "configuration": {
    "send_anonymous_reports": true,
    "dns_resolver": {
      "address": "127.0.0.1:8053",
      "dnsmasq": true,
      "port": 8053
    },
    "postgres": {
      "host": "127.0.0.1",
      "database": "kong_db",
      "user": "kong_user",
      "password": "kong_pass",
      "port": 5434
    },
    "cluster_listen": "0.0.0.0:7946",
    "cluster": {
      "auto-join": true,
      "profile": "wan",
      "ttl_on_failure": 3600
    },
    "proxy_listen": "0.0.0.0:8000",
    "nginx": "此处省略n多字",
    "custom_plugins": {},
    "proxy_listen_ssl": "0.0.0.0:8443",
    "dns_resolvers_available": {
      "server": {
        "address": "8.8.8.8"
      },
      "dnsmasq": {
        "port": 8053
      }
    },
    "dao_config": {
      "host": "127.0.0.1",
      "database": "kong_db",
      "user": "kong_user",
      "password": "kong_pass",
      "port": 5434
    },
    "nginx_working_dir": "/usr/local/kong",
    "database": "postgres",
    "plugins": [
      "ssl",
      "jwt",
      "acl",
      "correlation-id",
      "cors",
      "oauth2",
      "tcp-log",
      "udp-log",
      "file-log",
      "http-log",
      "key-auth",
      "hmac-auth",
      "basic-auth",
      "ip-restriction",
      "galileo",
      "request-transformer",
      "response-transformer",
      "request-size-limiting",
      "rate-limiting",
      "response-ratelimiting",
      "syslog",
      "loggly",
      "datadog",
      "runscope",
      "ldap-auth",
      "statsd"
    ],
    "pid_file": "/usr/local/kong",
    "cassandra": {
      "contact_points": [
        "127.0.0.1:9042"
      ],
      "data_centers": {},
      "ssl": {
        "verify": false,
        "enabled": false
      },
      "port": 9042,
      "timeout": 5000,
      "replication_strategy": "SimpleStrategy",
      "keyspace": "kong",
      "replication_factor": 1,
      "consistency": "ONE"
    },
    "admin_api_listen": "0.0.0.0:8001",
    "memory_cache_size": 128,
    "cluster_listen_rpc": "127.0.0.1:7373"
  },
  "lua_version": "LuaJIT 2.1.0-beta1",
  "tagline": "Welcome to kong",
  "hostname": "vos2016062102",
  "plugins": {
    "enabled_in_cluster": {},
    "available_on_server": [
      "ssl",
      "jwt",
      "acl",
      "correlation-id",
      "cors",
      "oauth2",
      "tcp-log",
      "udp-log",
      "file-log",
      "http-log",
      "key-auth",
      "hmac-auth",
      "basic-auth",
      "ip-restriction",
      "galileo",
      "request-transformer",
      "response-transformer",
      "request-size-limiting",
      "rate-limiting",
      "response-ratelimiting",
      "syslog",
      "loggly",
      "datadog",
      "runscope",
      "ldap-auth",
      "statsd"
    ]
  }
}
```




# 参考

* [https://getkong.org/install/ubuntu/](https://getkong.org/install/ubuntu/)
* [https://www.postgresql.org/download/linux/ubuntu/](https://www.postgresql.org/download/linux/ubuntu/)

