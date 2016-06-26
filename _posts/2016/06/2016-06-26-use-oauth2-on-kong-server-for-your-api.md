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




