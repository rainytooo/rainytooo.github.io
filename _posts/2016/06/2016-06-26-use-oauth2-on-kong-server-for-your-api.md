---
layout: post
title: 在kong上配置oauth2来做api的认证
subtitle: 使用oauth2的 Resource Owner Password Credentials方式做api认证
date: 2016-06-26
categories: 
    - server
tags: [kong, rest, oauth2]
---



之前有有一篇介绍了如何搭建kong服务器,参考[ubuntu14.04 上kong服务器的搭建](/c/server/2016/06/22/ubuntu1404-kong-server.html)


# 目的

目前我们的系统有很多业务子系统,几乎都是rest api server,所以统一把认证在kong上做,另外我们独立开发了一个简单的sso(用户认证中心),
所有系统的登录统一在sso登录,拿到token,然后就可以通过kong去访问api服务器了.具体有以下流程和关键点

业务流程可以查看这个图:

<img src="/img/posts/2016/06/oauth2-flow2.png" alt="oauth2流程" width="500"> 

### 场景一: 网站 - 用户未登录

1. 客户在A网站访问需要登录跳转至Auth Server(sso)
    * 返回url,next_url
2. SSO系统验证用户未登录,跳转至登录页面
    * 用户输入用户名密码登录
    * 成功后,sso计算对称加密一个ticket,
    * 在api gateway(kong)请求一个oauth的token,
    * 同时将加密的ticket和同户名,access_token和refresh_token的信息一起存入redis.

3. SSO系统本地登录
    * 保存session.
    * 将oauth信息保存到数据库.

4. SSO将回调链接带上ticket参数返回A网站的链接
    * A网站拿到ticket,再次在后台调用SSO的验证api,解密后的ticket参数
    * SSO将ticket验证通过,返回用户名和oauth的信息,同时从redis里删除ticket的数据
    * A网站拿到用户信息,本地登录,存session
    * A网站将oauth信息保存到session和redis


### 场景二: 网站 - 用户登录A,再访问B

1. 客户访问B网站
    * 跳转到SSO的登录
    * SSO的session发现此用户已经验证
    * 成功后,sso计算一个对称加密的ticket,
    * 数据库查询token信息,将加密的ticket和access_token和refresh_token一起存redis

2. SSO将回调链接带上ticket参数返回A网站的链接
    * B网站拿到ticket,再次调用SSO的验证api,带上ticket参数
    * SSO将ticket验证通过,返回用户名和oauth的信息,同时从redis里删除ticket的数据
    * A网站拿到用户信息,本地登录,存session
    * 将oauth信息保存到session和redis


### 场景三: 手机和其它非web client - 用户未登录

1. 调用登录API,传递用户名和密码
2. SSO服务器验证用户合法性
3. 通过登录,向Api gateway(kong)请求oauth信息
4. 将oauth信息返回给客户端


### 综上所述kong上简要流程如下

1. 为api开启oauth2认证
2. 使用Resource Owner Password Credentials的授权流程
3. 让我们业务系统的sso(用户中心)在成功登陆后,在kong server上获取用户的access_token和refresh_token,返回给sso
4. sso将成功登录的消息,用户信息和token一起返回给业务系统(这一步省略)



# 配置过程

前提条件: kong的server已经准备好了,参考[ubuntu14.04 上kong服务器的搭建](/c/server/2016/06/22/ubuntu1404-kong-server.html)


## 一.添加api

这里添加的方式不是host,是request_path

### 请求

```bash
curl -X POST -H "Cache-Control: no-cache" -H "Content-Type: multipart/form-data; boundary=----WebKitFormBoundary7MA4YWxkTrZu0gW" -F "name=docsapi" -F "upstream_url=http://docs.apiusage.com" -F "request_path=/docs" -F "strip_request_path=true" "http://10.0.0.202:8001/apis/"
```

### 响应

```json
{
  "upstream_url": "http://docs.apiusage.com",
  "request_path": "/docs",
  "id": "954b2dfc-e6d5-421b-a796-cd1d751f0af8",
  "created_at": 1466920233000,
  "preserve_host": false,
  "strip_request_path": true,
  "name": "docsapi"
}
```


### 添加完以后可以验证一下

```bash
curl -X GET -H "Cache-Control: no-cache" "http://10.0.0.202:8000/docs/online_docs/linux/rsync/rsync.html"
```

## 二.为api安装oauth2插件

### 请求

```bash
curl -X POST -H "Content-Type: multipart/form-data; boundary=----WebKitFormBoundary7MA4YWxkTrZu0gW" -F "name=oauth2" -F "config.token_expiration=720000" -F "config.enable_password_grant=true" -F "config.scopes=email,phone,address" "http://10.0.0.202:8001/apis/docsapi/plugins"
```

### 响应

```json
{
  "api_id": "954b2dfc-e6d5-421b-a796-cd1d751f0af8",
  "id": "7734b163-721e-430f-9ad9-9dd4c5f47b71",
  "created_at": 1466927983000,
  "enabled": true,
  "name": "oauth2",
  "config": {
    "mandatory_scope": false,
    "token_expiration": 720000,
    "enable_implicit_grant": false,
    "scopes": [
      "email",
      "phone",
      "address"
    ],
    "hide_credentials": false,
    "enable_password_grant": true,
    "accept_http_if_already_terminated": false,
    "provision_key": "758017a57c4447628546d0d266f92a9b",
    "enable_client_credentials": false,
    "enable_authorization_code": true
  }
}
```


## 三.添加一个开发者账号

一个开发者账号是可以全站用的

### 请求

```bash
curl -X POST -H "Cache-Control: no-cache" -H "Postman-Token: 1636232e-7e6b-3ee5-8e5a-11ac4579f972" -H "Content-Type: multipart/form-data; boundary=----WebKitFormBoundary7MA4YWxkTrZu0gW" -F "username=vincent" -F "custom_id=1" "http://10.0.0.202:8001/consumers"

```


### 响应

```json
{
  "custom_id": "1",
  "username": "vincent",
  "created_at": 1466928362000,
  "id": "ab7fcd95-fa06-456a-9e4a-b2b701a510de"
}
```

## 四.为开发者注册一个应用,用来访问api


### 请求

```bash
curl -X POST -H "Cache-Control: no-cache" -H "Postman-Token: b6bf0e87-3d98-e4fb-26f4-4711d61513e0" -H "Content-Type: multipart/form-data; boundary=----WebKitFormBoundary7MA4YWxkTrZu0gW" -F "name=openapidoc" -F "redirect_uri=http://some-domain/endpoint/" "http://10.0.0.202:8001/consumers/ab7fcd95-fa06-456a-9e4a-b2b701a510de/oauth2"
```


### 响应

```json
{
  "consumer_id": "ab7fcd95-fa06-456a-9e4a-b2b701a510de",
  "client_id": "309e682d142147c29f49a83b5498f164",
  "id": "2523187c-d4a3-4c7d-b35c-2663b2a02822",
  "created_at": 1466928527000,
  "redirect_uri": "[\"http:\\/\\/some-domain\\/endpoint\\/\"]",
  "name": "openapidoc",
  "client_secret": "2d20985e78424ea5922589db71632769"
}

```


## 五.为一个client已经登录成功的用户生成auth的access_token

这一步的前面还有一些别的步骤,比如认证系统的用户登录认证,就省略了,直接到生成access_token这一步.


### 请求

```bash
curl -X POST -H "Cache-Control: no-cache" -H "Postman-Token: 8718a5a5-2ff2-bc3f-7e57-70443e86620b" -H "Content-Type: multipart/form-data; boundary=----WebKitFormBoundary7MA4YWxkTrZu0gW" -F "client_id=309e682d142147c29f49a83b5498f164" -F "client_secret=2d20985e78424ea5922589db71632769" -F "scope=phone" -F "provision_key=758017a57c4447628546d0d266f92a9b" -F "authenticated_userid=1" -F "username=vincent" -F "password=123456" -F "grant_type=password" "https://10.0.0.202:8443/docs/oauth2/token"
```

### 响应

```json
{
  "refresh_token": "5ec407d2cfcb42639b642355a916e117",
  "token_type": "bearer",
  "access_token": "36651445140a47329e6d0badf14e09aa",
  "expires_in": 720000
}

```

## 六.用token来测试访问原有的api

注意,如果是用postman访问,最好先用https在浏览器上访问以下,并忽略未认证证书的警告再来测试.

### 请求

```bash
curl -X GET -H "Authorization: bearer 36651445140a47329e6d0badf14e09aa" "https://10.0.0.202:8443/docs/online_docs/linux/rsync/rsync.html"
```


成功返回,表示配置成功. 把token换成错误的会得到以下提示.

> {"error_description":"The access token is invalid or has expired","error":"invalid_token"}

如果用http访问,则会得到以下提示.

> {"error_description":"The access token is missing","error":"invalid_request"}


至此,一个授权流程和访问api已经结束.

