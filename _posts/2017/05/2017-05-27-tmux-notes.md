---
layout: post
title: tmux的使用
date: 2017-05-27
categories: 
    - others
---



简单的说,tmux给你的terminal会话提供了分组,保存,拆分,切换,标记等等方便的功能,对于经常在term上工作的有很大的帮助,
比如你经常要开个vim,连接个服务器,还要起一个调试的console,一个运行server的日志窗口,如果一辈子不关机,不掉线应该问题不大,
但是不可能,所以,tmux的作用就出来了. 好比你每天打开浏览器,需要打开邮件,新闻,twitter,facebook,stackoverflow,还有上次没有看完的一些tab,
这个时候有个保存会话的功能该有多好,每次打开浏览器点击一个按钮,我定制的tab就全部自动打开,tmux就是运维和在terminal上工作的人的效率工具.




### 安装

我用的osx,比较简单直接`brew install tmux`就可以了,如果你没有安装libevent可以先`brew install libevent`


### 体验

```
tmux
```

就打开了一个会话

### 概念

* session                                   会话,一组窗口的集合，通常用来概括同一个任务。session可以有自己的名字便于任务之间的切换
* window                                    窗口,单个可见窗口。Windows有自己的编号
* pane                                      块,窗格,一个窗口可以利用窗格来划分成多个窗格

### 命令
* `tmux new-session`                        新建会话
    - `tmux new-session -s writing`             新建会话,并命名
    - `tmux new-session -s writing -d`          在后台创建会话,并命名
* `tmux list-session` or `tmux ls`          列出所有会话
* `tmux attach -t 数字或者名字`             进入并恢复会话
* `tmux kill-session -t 数字或者名字`       关闭会话
* `tmux kill-server`                        关闭tmux服务


### 会话内的操作

`prefix`默认是`<C-b>`,下面的命令都是在键入prefix之后的操作

* `"`           将窗口垂直平分为上下两个窗格pane
* `#`           列出所有的剪贴板
* `$`           重命名当前会话
* `%`           将窗口水平平分为左右两个窗格
* `&`           关闭当前窗口
* `'`           以提示的方式,等待用户输入编号来切换窗口
* `(`           切换到上一个会话
* `)`           切换到下一个会话
* `,`           重命名当前窗口
* `-`           Delete the most recently copied buffer of text.
* `.`           用编号来切换窗口,在提示下输入编号
* `0 to 9`      按编号切换窗口
* `:`           进入tmux的命令提示符,和vim类似
* `;`           进入上一个pane
* `=`           选择一个buffer来进行粘贴
* `?`           列出所有的key bind
* `D`           选择一个客户端,让其断线
* `L`           将连接的客户端切换到最后一个会话
* `[`           进入粘贴模式,或者查看历史
* `]`           粘贴最后一次拷贝的内容
* `c`           创建新的窗口
* `d`           断开当前的客户端连接,退出的意思
* `f`           在所有打开的窗口搜索你再提示符里输入的字符串
* `i`           显示当前窗口的信息在底部
* `l`           移动到上一个选择的窗口
* `n`           切换到下一个窗口
* `o`           切换到当前窗口的下一个pane和`;`相反
* `p`           切换到上一个窗口
* `q`           显示当前窗口所有pane的编号
* `r`           强制重画当前连接的客户端
* `m`           标记当前的pane,(see select-pane -m).
* `M`           清除pane的标记
* `s`           列出所有会话,可以选择一个进行切换
* `t`           显示当前时间
* `w`           在当前窗口显示所有窗口的信息,可以进行选择切换
* `x`           提示是否关闭当前pane
* `z`           最大化当前pane
* `{`           将当前pane和上一个pane切换
* `}`           将当前pane和下一个pane切换
* `~`           显示tmux的日志信息
* `Page Up`     Enter copy mode and scroll one page up.
* `上下左右`    切换pane
* `Space`       将pane进行重新排列,有多种方式

### 注意事项


如果你的vim的配色在tmux下不能正常显示,在vimrc里加上

```bash
if exists('$TMUX')
  set term=screen-256color
endif
```


### 合并窗口面板

如果你开了两个窗口,需要显示在一个窗口下,变成2个pane时候

```
# 先开启命令模式 pre :  , 我这里是Ctrl + b :
join-pane -s 1.0			# 意思是 把1号窗口里的pane0 移到窗口0里
join-pane -s 1:2.3			# 意思是把session1的窗口2的pane3移过来
```

