---
layout: post
title: Docker里运行Docker docker in docker(dind)
date: 2017-05-24
categories: 
    - docker
---

# 目的

制作一个可以build docker镜像的docker镜像,jenkins CI服务节点,部署到阿里云的容器服务集群里.

阿里云官方有完整的镜像,master和slave的都有,时间稍微久远了一点,所以自己研究一下build个最新的版本.


# 关于 docker in docker

### docker运行在docker里面分两种情况

* (dind) docker inside docker
* (dood) docker outside of docker

dood的好处是内部容器并不需要真正的安装docker而是挂载父级docker的socket和执行文件就可以,但是缺点也非常明显,就是内部容器必须和外部的docker环境保持一致,不然会报各种错误,缺少库文件什么的,而且安全性有很大问题,[Docker-in-Docker](https://github.com/jpetazzo/dind) ,[贴吧翻译版本](https://tieba.baidu.com/p/4063973075), 这个项目的作者本身就不建议这么去使用docker(dind的方式),有安全性问题,存储问题


### 看了这些文章之后,得出的结论如下

* 真正的docker in docker 在docker官方有镜像直接就能用 [官方dind镜像](https://hub.docker.com/_/docker/)
* docker in docker dind 是用来学习的,在实际生产环境中一般用不到
* docker in docker dind 是有很多问题的(意想不到的), 比如存储空间,安全等等
* 如果只是使用CI如jenkins这种,在容器里需要build镜像,那么不需要纯粹的dind, 可以变通的使用host的docker(通过二进制docker文件和宿主的sock来实现)


### 那么解决方案是什么

**原文**

---



### The solution

Let’s take a step back here. Do you really want Docker-in-Docker? Or do you just want to be able to run Docker (specifically: build, run, sometimes push containers and images) from your CI system, while this CI system itself is in a container?

I’m going to bet that most people want the latter. All you want is a solution so that your CI system like Jenkins can start containers.

And the simplest way is to just expose the Docker socket to your CI container, by bind-mounting it with the `-v` flag.

Simply put, when you start your CI container (Jenkins or other), instead of hacking something together with Docker-in-Docker, start it with:
```
docker run -v /var/run/docker.sock:/var/run/docker.sock ...
```
Now this container will have access to the Docker socket, and will therefore be able to start containers. Except that instead of starting “child” containers, it will start “sibling” containers.

Try it out, using the `docker` official image (which contains the Docker binary):

```
docker run -v /var/run/docker.sock:/var/run/docker.sock \
           -ti docker
```
This looks like Docker-in-Docker, feels like Docker-in-Docker, but it’s not Docker-in-Docker: when this container will create more containers, those containers will be created in the top-level Docker. You will not experience nesting side effects, and the build cache will be shared across multiple invocations.

Former versions of this post advised to bind-mount the docker binary from the host to the container. This is not reliable anymore, because the Docker Engine is no longer distributed as (almost) static libraries.

If you want to use e.g. Docker from your Jenkins CI system, you have multiple options:

* installing the Docker CLI using your base image’s packaging system (i.e. if your image is based on Debian, use .deb packages),
* using the Docker API.

---

**翻译后**

---

### 解决方案

退一步, 是需要一个真正的 docker in docker,还是只想在类似jenkins这样的CI系统里要运行docker命令(build push images)

我想大部分人只是需要后者,你所需要的是你的ci系统可以启动容器,或者构建容器(这是我加的)

最简单的方式是启动容器的时候以`-v`的方式挂载宿主机的docker的socket给含有jenkins这种CI的容器使用

简单的说,启动你的CI 容器(jenkins或者其他), 而不是用docker-in-docker上hacking, 启动方法:

```
docker run -v /var/run/docker.sock:/var/run/docker.sock ...
```

这样这个容器就会可以访问到宿主机的docker socket并使用它,因为这个容器就有能力启动容器,这样他启动和操作的容器和他本身是兄弟关系,是平级的而不是父子关系.

试试官方的`docker`镜像, 包含二进制可执行程序

```
docker run -v /var/run/docker.sock:/var/run/docker.sock -ti docker
```

### 插个楼,我再本机上做的实验

```
➜  jenkins docker run -v /var/run/docker.sock:/var/run/docker.sock \
           -ti docker:17.05
Unable to find image 'docker:17.05' locally

17.05: Pulling from library/docker
cfc728c1c558: Pull complete
81d7b2e827ca: Pull complete
144b6478a622: Pull complete
e04c57814bdc: Pull complete
Digest: sha256:da22b37a64e68f7b2199ba619f61e0b82f95d6fa4ed812b2d6c19e486d933ed0
Status: Downloaded newer image for docker:17.05

/ # which docker
/usr/local/bin/docker
/ # docker ps
CONTAINER ID        IMAGE                   COMMAND                  CREATED             STATUS              PORTS                                NAMES
cae7df10f791        docker:17.05            "docker-entrypoint..."   20 seconds ago      Up 19 seconds                                            hungry_banach
d0c7c57ee2c9        jenkinsci/jenkins:lts   "/bin/tini -- /usr..."   18 hours ago        Up 8 hours          50000/tcp, 0.0.0.0:49001->8080/tcp   vigilant_pasteur
/ # docker ps -a
CONTAINER ID        IMAGE                   COMMAND                  CREATED             STATUS                      PORTS                                NAMES
cae7df10f791        docker:17.05            "docker-entrypoint..."   23 seconds ago      Up 22 seconds                                                    hungry_banach
512c903e80da        django:test03           "/bin/bash"              10 hours ago        Exited (0) 6 hours ago                                           testdjango01
d0c7c57ee2c9        jenkinsci/jenkins:lts   "/bin/tini -- /usr..."   18 hours ago        Up 8 hours                  50000/tcp, 0.0.0.0:49001->8080/tcp   vigilant_pasteur
cb5527ee98c5        jenkinsci/jenkins:lts   "/bin/tini -- /usr..."   18 hours ago        Created                                                          vigilant_easley
fcd7e2089a0d        12c901436f44            "/bin/sh -c 'echo ..."   19 hours ago        Exited (127) 19 hours ago                                        amazing_easley
0fb85d775afc        04b5d101ead1            "/bin/sh -c 'set -..."   20 hours ago        Exited (2) 19 hours ago                                          gracious_swirles
2ff8dce9c205        ee4682994d35            "/bin/bash"              20 hours ago        Exited (0) 19 hours ago                                          testpython2

```

可以清楚的看到,这些结果都是宿主机上的docker的结果,所以这里使用的docker命令实际上的空间和进程都是在宿主机上的.

可以看一些这个镜像的[Dockfile](https://github.com/docker-library/docker/blob/ce78a19aac321bbe50d060426b5b633cb5f74825/17.05/Dockerfile)

### 穿越回来,继续翻译

这看起来像是docker-in-docker,但是实际上不是,当你要在这个容器里创建新的容器的时候,这些容器并不是在容器里被创建的,而是在host机器上创建的,你将不会受到内嵌的影响,构建缓存也在多实例间共享.

这篇文章的老版本建议bind docker的二进制文件从host到容器,这个说法已经不再可靠,因为docker 引擎不再发布静态库,所以单纯用挂载的方式使docker的二进制文件在容器和host间共享的方式不存在了,取而代之的是直接在容器内解压一个编译好的docker.

所以现在如果你想使用docker在jenkins CI的容器里,你有以下选择:

* 安装docker cli,在你的基础docker镜像里(比如,你使用debian, 就使用 deb packages)
* 使用remote api


---

# 我的方案

好了看了这么多,是时候自己构建一个供jenkins子节点使用的镜像了,包含docker,可以build和push镜像

我的场景如下

* 阿里云上用几台机器组件了容器的集群
* 现在要搭建一个CI的demo(jenkins的)
* jenkins是master agent模式,不同节点环境不一样的,有的是python的,有的是java的
* 子节点在有代码更新的时候,触发任务,任务很简单,就是用Dockerfile构建新的镜像
* 新的镜像构建完成以后,直接推送(走阿里云的内网,不用流量费)
* 镜像有更新,触发容器集群重新部署应用.


### 需要的镜像

* 1个jenkins master容器
* 1个jenkins agent容器 用来build镜像并推送到镜像仓库
* 一个python+mysql 编排

# 最后附上我已经配置好的Dockerfile(已经在阿里云的容器里运行)

```
FROM ubuntu:xenial

MAINTAINER Vincent Wantchalk <ohergal@gmail.com>

RUN apt-get update


RUN apt-get -y install wget \ 
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


RUN locale-gen en_US.UTF-8
RUN dpkg-reconfigure locales


RUN echo "Asia/shanghai" > /etc/timezone
RUN ln -fs /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \ 
	&& dpkg-reconfigure -f noninteractive tzdata 

ENV LANG en_US.UTF-8
ENV LANGUAGE en_US:en
ENV LC_ALL en_US.UTF-8



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

RUN apt-get purge -y --auto-remove build-essential libssl-dev

RUN useradd -m -d /home/jenkins -s /bin/bash jenkins && \
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

### 参考:
* [阿里的jenkins的slave镜像,可以build docker](https://github.com/AliyunContainerService/jenkins-slaves?spm=5176.doc42988.2.2.JYbZh8)
* [成熟的dind方案](https://github.com/jpetazzo/dind)
* [docker里运行docker](http://www.dockone.io/article/431)
* [不要在ci方案使用dind](https://jpetazzo.github.io/2015/09/03/do-not-use-docker-in-docker-for-ci/)

