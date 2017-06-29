---
layout: post
title: 为github.io设置自己的域名
date: 2016-06-18
categories: [extra, writing]
tags: [jekyll, github]
---



为github.io设置自己的域名

如果有自己的域名想要绑定到github page,操作如下

### 1. 在域名供应商的设置里添加一条cname记录,指向github page的域名

![cname-to-github-io](/img/posts/2016/06/QQ20160619-0@2x.png)


### 2. 在jekyll根目录下添加一个CNAME文件

内容为你的域名

```
www.wantchalk.com
```


就这么简单