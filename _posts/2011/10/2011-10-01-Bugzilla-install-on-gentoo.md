---
layout: post
title: Bugzilla在Gentoo上安装
date: 2011-10-01
category: [devops, server]
tags: [bugzilla, gentoo]
---


gentoo下bugzilla安装



添加perl包
	emerge -av dev-perl/GD

进入bugzilla目录
	./checksetup.pl --check-modules
	./install-module.pl

安装需要的模块

	perl install-module.pl List::MoreUtils
	perl install-module.pl DateTime::Locale


数据库初始化

```
mysql> create database testbugs;


mysql> grant all privileges on testbugs.* to 'bugzilla'@'%' identified by 'bugzilla';


mysql> grant all privileges on testbugs.* to 'bugzilla'@'localhost' identified by 'bugzilla';

mysql> flush privileges;
```

然后执行

	./checksetup.pl

修改配置

	localconfig

再次执行

	./checksetup.pl

配置apache

```
<VirtualHost *:80>
   
    ServerAdmin ohergal@gmail.com
   
    DocumentRoot "/wch/dev/env/bug_track/bugzilla-3.4.6"
   
    AddHandler cgi-script .cgi
   
    ServerName localbugs
   
    DirectoryIndex index.php index.php3 index.html index.cgi index.htm home.htm
   
    <Directory /var/www/localhost/htdocs/bbs>
       
    Options FollowSymLinks Indexes ExecCGI
      
    AllowOverride limit
   
    Order deny,allow
       
    # Deny from all                                                                                                                                                           
       
    Satisfy all
   
    </Directory>

</VirtualHost>
```


	./checksetup.pl


增加rpc支持

	./install-module.pl SOAP::Lite


