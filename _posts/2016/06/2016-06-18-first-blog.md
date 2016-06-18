---
layout: post
title: First Blog
category: nocat
tags: [wc]
---





### 回望过去

好久没折腾自己的东西了,最早用`google note`, google停止note服务以后,`wordpress`, `evernote`,`vimwiki`,`Sphinx + reST`
再后来用markdown在`简书`上也写过一段时间(主要是简书的书写确实很方便),再后来就自己用`dropbox + markdown + fabric`来编写和保存文章.
中间有的一段时间还在`javaeye`和`csdn`写过blog,但是一直没有找到一个合适的方式,各有优缺点.


### 我的需求到底是什么

* 书写简单,简洁,书写的语法学习成本低,如`markdown`,`vimwiki`,`reStructuredText(稍复杂)`
* 语法高亮,这个是必须,而且可以选择输出的样式风格
* 输出的界面风格可以随时替换
    - 如果是生成生成静态文件,模板可以高度定制
    - 最好能有丰富的现成的模板
* 可以随时书写,哪怕非常零散
* 最好托管在第三方服务(最好免费)
* 可以绑定自己的域名(最好不用备案)
* 不受限于网络也能编写
* 全文检索(这个编辑器就能实现)
* 目录层次可以自己按自己的喜好分类
* 编写速度要快,编辑起来顺手(`vim + vimwiki`是最快的因为vim, `wordpress`是最慢的,需要联网,打开慢编写慢,保存慢,后期无法忍受)
* 极少的占用内存(evernote要开软件,占内存)
* 随时能备份,在多处`dropbox`,`git`,`本地`
* 随时导入导出,这一点就把所有blog给淘汰了
* 不需要频繁的升级什么的,没有任何安全因素干扰(这一点`wordpress`坑太多)


### Finally,`jekyll + github.io`

这不就是我想要的吗?毫不犹豫的用起来,可无缝的把我之前的markdown文件挪过来.

* 模板丰富
    - [jekyllthemes.io](http://jekyllthemes.io/)
    - [jekyllthemes.org](http://jekyllthemes.org/)
* 很好的支持了`markdown`
* 自定义插件简单
* 可以无缝托管到[github.io](https://github.io/)上
* 目录高度自定义,输出结构可以自定义
* 自己的域名可以简单CNAME到github.io上
* 平时开一个`sublime`或者`vim`就可以了,无需额外占用内存(coder必然打开一些编辑器)
* 支持category和Tag
* 自定义开发用的`ruby`,这个我也熟悉
* 平时没有整理好的可以放`_drafts`里,不发布
* 只要有git,文章都有版本管理啦
* 不需要网络也能愉快的书写
* 开着`jekyll serve --drafts -w`, 可以边写边看

