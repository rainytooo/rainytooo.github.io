---
layout: post
title: Docker容器里的mysql如何实现自动备份
subtitle: 运行在docker容器里的mysql服务使用cron定时任务实现自动备份
date: 2019-01-29
category: [sa]
tags: [docker, mysql]
published: false
---


mysql运行在host机上的备份很简单,运行在docker容器如何定时备份呢

如果不觉得丑陋,自己用mysql官方镜像加上crontab做个自己镜像,然后写进crontab,再挂载云盘,或者host主机的磁盘来做备份也是可以实现的,但是这太不docker了,每次版本更新就要重新build自己的镜像,而且编排里要写一堆和业务无关的东西

# Content

* 如何做


## 那么如果实现

