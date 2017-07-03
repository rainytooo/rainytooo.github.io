---
layout: post
title: 用aliyun容器搭建基于docker的jenkins动态agent节点
date: 2017-07-03
category: [devops, docker]
tags: [jenkins]
---


## Content

* 目标
* 优点
* 准备
* 建代码仓库
* 建镜像仓库
* 编写Jenkins agent的Dockerfile
* 构建镜像
* 部署Jenkins的Master节点
* Jenkins master节点配置 - 插件安装
* Jenkins master节点配置 - Credentials
* 添加docker cloud和docker template
* 参考

### 目标

* 有一个jenkins服务
* 全部运行在docker容器上
* 任务都运行在jenkins的agent上
* agent在docker容器里运行
* agent的docker容器是动态创建的,在build完了以后自动销毁
* agent节点可以build docker的镜像

### 优点

* Jenkins的master环境是干净的
* agent节点在每次跑任务的时候都是干净的
* agent节点自动伸缩,在需要的时候会自动创建,没有任务的时候销毁,不占用资源


### 准备

* 阿里云容器集群
* 一些jenkins的docker镜像
	- master
	- agent base
	- agent python
	- agent java
	- 等等根据自己项目需要
* 镜像仓库(aliyun)
* 代码仓库(aliyun code)

### 建代码仓库

这个代码仓库是用来保存Dockerfile的,阿里云的仓库可以自动拉取代码,然后根据Dockerfile来构建镜像


<img src="/img/posts/2017/07/20170703174344.png" alt="..." width="600">


### 建镜像仓库

打开镜像控制台,[阿里云镜像控制台](https://cr.console.aliyun.com), 新建一个agent的仓库,作为agent的base镜像

<img src="/img/posts/2017/07/20170703173547.png" alt="..." width="600">

设置代码源那里选择之前建的代码仓库(这里截图不一致,请忽略).

`dind`的意思是docker in docker


### 编写Jenkins agent的Dockerfile


```
FROM ubuntu:xenial

MAINTAINER Vincent Wantchalk <ohergal@gmail.com>

RUN apt-get update


RUN apt-get -y install wget \ 
	sudo \
	apt-utils \
	locales \
	tzdata \
	\
	build-essential \
	apt-transport-https \
	ca-certificates \
	curl \
	git \
	openssh-server \
	zlib1g \
	zlib1g.dev \
	openssl \
	libssl-dev \
	iptables && \
	rm -rf /var/lib/apt/lists/*


ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8

RUN locale-gen en_US.UTF-8
RUN dpkg-reconfigure locales


RUN echo "Asia/shanghai" > /etc/timezone
RUN ln -fs /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \ 
	&& dpkg-reconfigure -f noninteractive tzdata 



# To avoid annoying "perl: warning: Setting locale failed." errors,
# do not allow the client to pass custom locals, see:
# http://stackoverflow.com/a/2510548/15677
# RUN sed -i 's/^AcceptEnv LANG LC_\*$//g' /etc/ssh/sshd_config


RUN apt-get -q update &&\
    DEBIAN_FRONTEND="noninteractive" apt-get -q install -y -o Dpkg::Options::="--force-confnew" --no-install-recommends software-properties-common && \
    add-apt-repository -y ppa:openjdk-r/ppa &&\
    apt-get -q update &&\
    DEBIAN_FRONTEND="noninteractive" apt-get -q install -y -o Dpkg::Options::="--force-confnew" --no-install-recommends openjdk-8-jdk && \
    apt-get -q clean -y && rm -rf /var/lib/apt/lists/* && rm -f /var/cache/apt/*.bin && \
	sed -i 's|session    required     pam_loginuid.so|session    optional     pam_loginuid.so|g' /etc/pam.d/sshd &&\
	mkdir -p /var/run/sshd

# clean compile tools

# RUN apt-get purge -y --auto-remove build-essential libssl-dev

RUN groupadd --gid 1000 jenkins
RUN useradd -m -d /home/jenkins -s /bin/bash -g 1000 -u 1000 jenkins && \
	echo "jenkins:jenkins" | chpasswd


# install docker binary files

ENV DOCKER_BUCKET get.docker.com
ENV DOCKER_VERSION 17.05.0-ce
ENV DOCKER_SHA256_x86_64 340e0b5a009ba70e1b644136b94d13824db0aeb52e09071410f35a95d94316d9
ENV DOCKER_SHA256_armel 59bf474090b4b095d19e70bb76305ebfbdb0f18f33aed2fccd16003e500ed1b7


RUN curl -fSL "https://${DOCKER_BUCKET}/builds/Linux/x86_64/docker-${DOCKER_VERSION}.tgz" -o docker.tgz \
	&& echo "${DOCKER_SHA256_x86_64} *docker.tgz" | sha256sum -c - \
	&& tar -xzvf docker.tgz \
	&& mv docker/* /usr/local/bin/ \
	&& rmdir docker \
	&& rm docker.tgz \
	&& chmod +x /usr/local/bin/docker 
#	&& docker -v \
#	&& docker ps -a


RUN echo "jenkins ALL=NOPASSWD: ALL" >> /etc/sudoers


# Standard SSH port
EXPOSE 22


COPY docker-entrypoint.sh /usr/local/bin/
ENTRYPOINT ["docker-entrypoint.sh"]

# Default command
CMD ["/usr/sbin/sshd", "-D"]

```
解释一下,这个镜像就是从ubuntu作为基础,然后添加了java的运行环境,使用的是openjdk-8,然后下载解压了一个docker,
这个docker不能直接用,还是要配合挂载Host的docker的sock来使用,后面会有提到

创建docker-enterpoint.sh

```
#!/bin/sh
set -e

# first arg is `-f` or `--some-option`
if [ "${1#-}" != "$1" ]; then
	set -- docker "$@"
fi

# if our command is a valid Docker subcommand, let's invoke it through Docker instead
# (this allows for "docker run docker ps", etc)
if docker help "$1" > /dev/null 2>&1; then
	set -- docker "$@"
fi

# if we have "--link some-docker:docker" and not DOCKER_HOST, let's set DOCKER_HOST automatically
if [ -z "$DOCKER_HOST" -a "$DOCKER_PORT_2375_TCP" ]; then
	export DOCKER_HOST='tcp://docker:2375'
fi

exec "$@"

```


### 构建镜像

直接在阿里云的仓库里构建镜像,点立即构建就行了,默认每次提交代码都会重新构建镜像,这就是aliyun容器仓库和code配合使用的方便之处


<img src="/img/posts/2017/07/20170703175739.png" alt="..." width="600">


这一步鼠标点点就可以了.



不想自己构建镜像的可以直接使用aliyun官方提供的镜像,地址如下

[https://github.com/AliyunContainerService/jenkins-slaves](https://github.com/AliyunContainerService/jenkins-slaves)

里面有6个agent,包含go,node,java,python,php等等


### 部署Jenkins的Master节点

推荐编写一个`Compose`, 日后在别的环境也都能使用

使用官方的jenkins镜像就好,升级也省心. 

```
jenkins-master:
  restart: always
  ports:
    - '49001:8080/tcp'
  memswap_limit: 0
  labels:
    aliyun.scale: '1'
    aliyun.routing.port_8080: jenkins;ci.yourdomain.com
  shm_size: 0
  image: 'jenkinsci/jenkins:lts'
  memswap_reservation: 0
  volumes:
    - '/docker/data/container1/jenkins/var/jenkins_home:/var/jenkins_home:rw'
    - '/etc/localtime:/etc/localtime:rw'
  kernel_memory: 0
  mem_limit: 0

```

这里有几个点要注意

	1.端口可以不用暴露,如果你有nginx的容器在一个docker私网里,可以直接nginx代理jenkins
	2.labels里有阿里云的标签, 如果是做测试这个简单路由还是很好用的,配置好后可以用一个阿里云的指定域名就能访问了.
	3.目录挂载,数据目录一定要挂载,不然重启容器数据就全部没有了

主节点就是这么简单, 主节点的镜像部署还有什么问题可以参考镜像的官方文档,底部有连接


### Jenkins master节点配置 - 安装插件

* `Yet Another Docker`
* `Docker 插件`

### Jenkins master节点配置 - Credentials


1. 添加一个domain

这一步不是必须,但是为了区分,我建立了一个名为`aliyun-container`的domain


2. 添加集群的认证,domain为刚建立的`aliyun-container` 类型为`Docker Host Certificate Authentication`,然后将阿里云容器集群里的证书文件依次导入进去

先去下载你的证书文件


<img src="/img/posts/2017/07/20170703190647.png" alt="..." width="600">

用证书文件里的秘钥建立一个`Docker Host Certificate Authentication`类型的 credential,这个类型好像是必须装过插件才会有

<img src="/img/posts/2017/07/20170703190415.png" alt="..." width="600">

3. 添加agent节点的认证,domain为`global`, 类型为`username with password`, 这个是给jenkins的agent节点用的, 密码再dockerfile里初始化好了,为`jenkins`

这个认证是用来让master可以连接并操作agent的一个linux用户

<img src="/img/posts/2017/07/20170703190450.png" alt="..." width="600">


4. 在`aliyun-container`下创建一个`Docker Registery Auth`的认证, 用户名,邮箱 密码都是你推送镜像到阿里云镜像仓库的那个.id填`aliyun-registry-auth`

这个认证可以用来pull和push阿里云镜像仓库上的私有镜像

5. 创建`git`的domain, 创建一个认证,类型为`username with password`, 这个用来在gitlab上拉代码,username用邮箱

这个认证可以用来让jenkins拉取`code.aliyun.com`上的代码


### 添加docker cloud和docker template

需要安装插件`Yet Another Docker`

然后到`系统管理->系统设置里添加 docker的云`


主要要填写`Host Credentials`用前面建好的第二个和`Docker URL`(在阿里云容器后台的集群管理里可以找到), 填完可以测试.


<img src="/img/posts/2017/07/20170703191740.png" alt="..." width="600">

保存

下一步添加template,这一步比较复杂一步步来

	1. Docker Image Name

填写你需要的,我这里是`registry-internal.cn-hangzhou.aliyuncs.com/mydocker/jenkins-dind-agent-python:py2.7.13`


<img src="/img/posts/2017/07/20170703191908.png" alt="..." width="600">

注意:我这里用的阿里云内网的地址,最后记得要带上tag,不然如果没有latest就无法创建容器.

	2. Registry Credentials

使用上面第四步创建的认证

	3. Create Container Settings

这里更具需要,我主要是要挂载docker的socket和时区文件.

那么在Volumes里填写

```
/var/run/docker.sock:/var/run/docker.sock
/etc/localtime:/etc/localtime
```

	4. Remote Filing System Root

<img src="/img/posts/2017/07/20170703191937.png" alt="..." width="600">

保持默认`/home/jenkins`


	5. Labels

更具需要,我填写的是`dind-py2`




	6. Launch method

换成SSH的

	7. Credentials

用上面第三步创建的认证

	8. Host Key Verification Strategy

调整成 Non Verifying

至此agent的配置基本就完成了

下一篇会现在开始建立pipeline,来使用jenkins的agent build镜像


### 参考

* [jenkins official image](https://hub.docker.com/_/jenkins/)
* [基于 Jenkins 的持续交付](https://help.aliyun.com/document_detail/42988.html?spm=5176.product25972.6.659.3JLb6s)
