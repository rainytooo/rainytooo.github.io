---
layout: post
title: 在github.io上给jekyll添加分类和标签页
date: 2016-06-19
categories: 
    - writing
    - jekyll
tags: [jekyll, github]
---



花了些时间写了插件支持`jekyll`自动生成category和tag的索引页,并支持分页,push到github上发现悲剧,`github.io`不支持自定义插件.
欲哭无泪,不过也可以理解,毕竟静态页面是github服务器自动生成的,插件是用ruby语言写的,如果有人心存不轨还是很麻烦的.

关于github.io对插件的支持,看看这篇文章[Adding Jekyll plugins to a GitHub Pages site](https://help.github.com/articles/adding-jekyll-plugins-to-a-github-pages-site/)

怎么办?

没办法,那就自己静态化了.参考这个[Separate pages per tag/category with Jekyll (without plugins)](http://christianspecht.de/2014/10/25/separate-pages-per-tag-category-with-jekyll-without-plugins/), 去插件来实现标签和分页.

