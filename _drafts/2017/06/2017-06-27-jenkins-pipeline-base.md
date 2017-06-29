---
layout: post
title: Jenkins Pipeline 基础
date: 2017-06-27
category: [devops, cicd]
tags: [jenkins-pipeline, jenkins]
---


Jenkins2.0版本是一个重大变革,将





### 今天遇到一个坑,浪费我几个小时

我之前用别的方式将一个自己构建的镜像(java的jenkins agent ,dind)部署在阿里云容器集群里,之后我的jenkins pipeline如果使用这个镜像无法pull,会报错


```
com.github.kostyasha.yad_docker_java.com.github.dockerjava.api.exception.DockerClientException: Could not pull image: Pulling registry-internal.cn-hangzhou.aliyuncs.com/wc-docker/jenkins-dind-agent-java:jdk8gradle4... : downloaded
	at com.github.kostyasha.yad_docker_java.com.github.dockerjava.core.command.PullImageResultCallback.awaitSuccess(PullImageResultCallback.java:50)
	at com.github.kostyasha.yad.commons.DockerPullImage.exec(DockerPullImage.java:111)
	at com.github.kostyasha.yad.DockerCloud.provisionWithWait(DockerCloud.java:227)
	at com.github.kostyasha.yad.DockerCloud.lambda$provision$0(DockerCloud.java:134)
	at jenkins.util.ContextResettingExecutorService$2.call(ContextResettingExecutorService.java:46)
	at java.util.concurrent.FutureTask.run(FutureTask.java:266)
	at java.util.concurrent.ThreadPoolExecutor.runWorker(ThreadPoolExecutor.java:1142)
	at java.util.concurrent.ThreadPoolExecutor$Worker.run(ThreadPoolExecutor.java:617)
	at java.lang.Thread.run(Thread.java:748)
```

遇到这种情况,我猜测可以在容器的集群上先去删除这个镜像,登录到服务器里手动删除镜像,我的解决办法是给镜像打了一个新的tag,然后再jenkins的系统配置里的docker template里使用这个新的tag. 问题解决.

