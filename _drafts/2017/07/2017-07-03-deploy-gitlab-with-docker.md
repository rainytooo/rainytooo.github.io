---
layout: post
title: 用docker快速部署gitlab-ce
date: 2017-07-03
category: [devops, docker]
tags: [git]
---

基于docker还是比较方便,我的环境是在阿里云容器服务里, 用自建的docker差别也不大



# 准备阶段

### 一.创建数据卷

主要用到3个数据目录

* `/var/opt/gitlab`     用于存储数据
* `/var/log/gitlab`     日志
* `/etc/gitlab`         配置

那么到docker的集群的物理机器上(也可能是运行docker集群的虚拟机),创建相应的目录

```
sudo mkdir -p /docker/data/gitlab/gitlab-ce/var/opt/gitlab
sudo mkdir -p /docker/data/gitlab/gitlab-ce/var/log/gitlab
sudo mkdir -p /docker/data/gitlab/gitlab-ce/etc/gitlab

```

权限问题暂时不清楚这个镜像使用的uid和gid,但是看官方文档上有个修复权限的命令,这个一会等报错了再说

所以这里先不管下面的这个权限修复的命令

```
sudo docker exec gitlab update-permissions
sudo docker restart gitlab
```

### 二.端口预留

22端口是git的ssh方式必须用到的,如果占用这个端口就会使得host机器的ssh服务无法使用,有两种办法

* 1.将gitlab所使用的端口调整,官方是这样推荐
* 2.将host机器的sshd的port调整

我用的是第二种,因为host机器很少连,调高一点ssh的端口反而也安全一点,另外我的目的是省去以后客户端的git设置,因为你ssh的默认端口变了,所有ssh方式的git客户端肯定要设置,
这样必然会有很多麻烦.

具体步骤就不写了,去修改`/etc/ssh/sshd_config`里的端口配置然后重启ssh服务即可.


80和443我不需要映射到主机,因为我可以直接用另一个nginx来转发,所以这里我一会也会和官网的配置有所不同,我不会去映射host机的80和443端口

### 三.nginx设置(optional)

因为我是用另一个docker 的nginx container提供web服务, 所以在docker的私网里就可以,无需暴露出端口.
那么nginx就可以设置域名和代理



# 部署阶段


### 四.创建compose编排

我用的是阿里云的容器服务,所以可能和标准的compose文件稍有不同

```
gitlab-ce:
  image: 'gitlab/gitlab-ce:latest'
  restart: always
  hostname: 'gitlab-ce-server'
  environment:
    GITLAB_OMNIBUS_CONFIG: |
      external_url 'https://gitlab.example.com'
      # Add any other gitlab.rb configuration here, each on its own line
  ports:
    - '22:22'
  volumes:
    - '/docker/data/gitlab/gitlab-ce/etc/gitlab:/etc/gitlab:rw'
    - '/docker/data/gitlab/gitlab-ce/var/log/gitlab:/var/log/gitlab:rw'
    - '/docker/data/gitlab/gitlab-ce/var/opt/gitlab:/var/opt/gitlab:rw'
```

我这里去掉了`80`和`443`,前面说过原因

直接run的方式,将数据卷替换成自己创建的.

```

sudo docker run --detach \
    --hostname gitlab.example.com \
    --publish 443:443 --publish 80:80 --publish 22:22 \
    --name gitlab \
    --restart always \
    --volume /srv/gitlab/config:/etc/gitlab:Z \
    --volume /srv/gitlab/logs:/var/log/gitlab:Z \
    --volume /srv/gitlab/data:/var/opt/gitlab:Z \
    gitlab/gitlab-ce:latest
```

### 五.部署镜像

这一步因为环境不同,就不详细了.


### 六.处理问题

没有那么顺利,访问我的网站的时候出现了502,然后看日志

```
2017-07-03T04:23:55.750526273Z 2017-07-03_04:23:55.75016 nginx: [emerg] BIO_new_file("/etc/gitlab/ssl/gitlab.example.com.crt") failed (SSL: error:02001002:system library:fopen:No such file or directory:fopen('/etc/gitlab/ssl/gitlab.example.com.crt','r') error:2006D080:BIO routines:BIO_new_file:no such file)
```

因为我在`external_url`里使用了`https`,所以需要针对https做相应的配置

最后折腾一番发现https不能代理,用户和第一个接触的网关服务器之间建立加密,不能在中间有其它代理,这样防止篡改.
没办法我的解决办法就是抛弃原来的nginx,直接将gitlab的nginx服务暴露出来,80和443端口做映射,修改后的编排文件如下

```
gitlab-ce:
  image: 'gitlab/gitlab-ce:latest'
  restart: always
  hostname: 'gitlab-ce-server'
  environment:
    GITLAB_OMNIBUS_CONFIG: |
      external_url 'https://gitlab.apiusage.com'
      # Add any other gitlab.rb configuration here, each on its own line
    constraint:aliyun.node_index: 2
  ports:
    - '80:80/tcp'
    - '443:443/tcp'
    - '22:22'
  volumes:
    - '/docker/data/gitlab/gitlab-ce/etc/gitlab:/etc/gitlab:rw'
    - '/docker/data/gitlab/gitlab-ce/var/log/gitlab:/var/log/gitlab:rw'
    - '/docker/data/gitlab/gitlab-ce/var/opt/gitlab:/var/opt/gitlab:rw'
    - '/etc/localtime:/etc/localtime:rw'
  memswap_limit: 0
  shm_size: 0
  memswap_reservation: 0
  kernel_memory: 0
  mem_limit: 0
```


这里还省略了一个准备工作,就是申请可用的ssl证书,阿里云有免费的,可以用一年,推荐. startssl免费的已经被封杀不要再使用了.

基本就没什么了,第一次访问记得初始化密码, 然后就可以用root登录了.

### 参考

* [官方镜像地址](https://hub.docker.com/r/gitlab/gitlab-ce/)
* [安装说明](https://docs.gitlab.com/omnibus/docker/)
* [NGINX settings](https://docs.gitlab.com/omnibus/settings/nginx.html#enable-https)
