---
layout: post
title: Sublime Text快捷键
date: 2016-06-19
categories: 
    - ide
    - editor
tags: [ide, sublime]
---



# Content

* 标准快捷键
* 插件安装
* 插件快捷键
* 我的插件列表




# 标准快捷键

### 一. 视图

* `cmd + num` 切换tab
* `cmd + shift + [` 向左切换tab
* `cmd + shift + ]` 向右切换tab
* `cmd + w` 关闭tab
* `cmd + shift + w` 关闭全部tab
* `cmd + shift + t` 打开关闭的tab
* `cmd + k , b` 显示和关闭侧边栏
* `cmd + ctrl + p` 打开项目选择器
* `cmd + alt [1,2,3,4]` 窗口拆分 单列、双列、三列、四列
* `cmd + alt + 5` 拆分成4个窗口
* `ctrl + [1,2,3,4]` 跳转到相应窗口
* `ctrl + shift + [1,2,3,4]` 将当前文件移到对应的窗口

### 二. 查找

* `cmd + p` 在整个项目查找文件名
* `cmd + f` 当前文件查找字符串
* `cmd + shift + f` 在整个项目里查找字符串
* `cmd + r` 打开类结构,可以方便跳转symbol,method,class
* `ctrl + g` 跳转到行
* `cmd + t` 跳转到文件
* `cmd + m` 可以在闭合括号前后跳转

### 三. 编辑

* `cmd + d` 选择,多次使用把相同字符串一起选择,用于重构
* `cmd + ctrl + g` 同时选中所有相同的字符处
* `cmd + l` 选中一行
* `cmd + shift + j` 选中子元素,适用于xml
* `cmd + shift + d` 复制并粘贴一行
* `cmd + ctrl + 上/下` 行互换
* 安装cmd,点击任何地方何以同时获得多个光标,方便重构
* 按住alt,拖动,也可以同时获得多个光标
* `cmd + enter` 在下面新建一行
* `cmd + shift + enter` 在上面新建一行
* `cmd + ]` 选中多行,向右缩进
* `cmd + [` 选中多行,向左缩进
* `ctrl + shift + 方向` 快速选中
* `cmd + shift + 方向` 快速选中一行
* `ctrl + shift +k` 删除一行
* `ctrl + -` 光标跳回上一个位置
* `cmd + kk` 删至行尾
* `cmd + k,delete` 删至行首
* `cmd + alt + v` 从剪贴板历史中选择性粘贴
* 输入标签名,然后tab,可以自动写入一个闭合标签(html)
* `ctrl + shift + w` 用标签包裹所选区域(html)
* `cmd + j` 合并多行
* `cmd + shift + d` 复制多行
* `alt + 上/下` 快速移到光标到行首,行尾
* `alt + shift + 上/下` 快速从光标选中到行首或行尾
* `cmd + k,u` 转大写
* `cmd + k,l` 转小写
* `ctrl + t` 字母左右互换

# 安装Package Control

> `Sublime Text 2`

按Ctrl + `, 然后输入

```python
import urllib2,os,hashlib; h = '7183a2d3e96f11eeadd761d777e62404e330c659d4bb41d3bdf022e94cab3cd0'; pf = 'Package Control.sublime-package'; ipp = sublime.installed_packages_path(); os.makedirs( ipp ) if not os.path.exists(ipp) else None; urllib2.install_opener( urllib2.build_opener( urllib2.ProxyHandler()) ); by = urllib2.urlopen( 'http://sublime.wbond.net/' + pf.replace(' ', '%20')).read(); dh = hashlib.sha256(by).hexdigest(); open( os.path.join( ipp, pf), 'wb' ).write(by) if dh == h else None; print('Error validating download (got %s instead of %s), please try manual install' % (dh, h) if dh != h else 'Please restart Sublime Text to finish installation')
```

> `Sublime Text 3`

按Ctrl + `, 然后输入

```python
import urllib.request,os,hashlib; h = '7183a2d3e96f11eeadd761d777e62404e330c659d4bb41d3bdf022e94cab3cd0'; pf = 'Package Control.sublime-package'; ipp = sublime.installed_packages_path(); urllib.request.install_opener( urllib.request.build_opener( urllib.request.ProxyHandler()) ); by = urllib.request.urlopen( 'http://sublime.wbond.net/' + pf.replace(' ', '%20')).read(); dh = hashlib.sha256(by).hexdigest(); print('Error validating download (got %s instead of %s), please try manual install' % (dh, h)) if dh != h else open(os.path.join( ipp, pf), 'wb' ).write(by)
```


# 插件快捷键


### 一. Keymaps

快捷键插件

* [Home page](https://packagecontrol.io/packages/Keymaps)
* 功能: 查找快捷键

##### 基本用法 

* `Ctrl+Alt+?` 搜索快捷键
* `ctrl + alt + _` 打开快捷键的Cheat Sheet
    - `Ctrl + Alt + Shift + down` 向下切换
    - `Ctrl + Alt + Shift + up` 向上切换
    - `Ctrl + Alt + Shift + c` 取消选择
    - `Ctrl + Alt + Shift + enter` 打开keymap文件编辑

### 二. Pretty JSON

json格式化插件

* [Home page](https://packagecontrol.io/packages/Pretty%20JSON)
* 功能: json格式化

##### 基本用法 

* `Ctrl+cmd+j` 格式化选中的json
* validate json, 没有快捷键 cmd + shift + p 查找以后使用
* Compress / Minify JSON , 没有快捷键 cmd + shift + p 查找以后使用
* Convert JSON to XML, 没有快捷键 cmd + shift + p 查找以后使用


### 三. InsertDate

日期插件

* [Home page](https://packagecontrol.io/packages/InsertDate)
* 功能: 快速插入日期,可以定制格式

##### 基本用法 

* `F5` 打开选择器,选择格式插入日期
* `alt + f5` 自己输入格式,插入日期



##### 日期格式化参数


| Format string |  Parameters | Resulting string |
| :------ |:--- | :--- |
| %d/%m/%Y %I:%M %p |     | 12/08/2014 08:55  |
| %d. %b %y  |    | 12. Aug 14 |
| %H:%M:%S.%f%z |     | 20:55:00.473603+0200 |
| %Y-%m-%dT%H:%M:%S.%f%z |     |2014-08-12T20:55:00.473603+0200 |
| iso |{'tz_out': 'UTC'}  | 2014-08-12T18:55:00+00:00 |
| %c UTC%z |   {'tz_in': 'local'} | 12.08.2014 20:55:00 UTC+0200 |
| %X %Z |  {'tz_in': 'Europe/Berlin'} | 20:55:00 CEST |
| %d/%m/%Y %I:%M %Z |  {'tz_in': 'America/St_Johns'}  | 12/08/2014 08:55 NDT |
| %c %Z (UTC%z) |  {'tz_out': 'EST'}  | 12.08.2014 13:55:00 EST (UTC-0500) |
| %x %X %Z (UTC%z) |   {'tz_out': 'America/New_York'} | 12.08.2014 14:55:00 EDT (UTC-0400) |
| unix |      | 1407869700 |

### 四. Markdown Preview

markdown预览插件

* [Home page](https://packagecontrol.io/packages/Markdown%20Preview)
* 功能: 预览markdown文件

##### 基本用法 

* 没有快捷键 cmd + shift + p 查找以后使用


### 五. Emmet for Sublime Text

前端利器,不解释了

* [Home page](https://packagecontrol.io/packages/Emmet)
* 功能: html编辑增强

##### 基本用法 

Available actions

* Expand Abbreviation – Tab or Ctrl+E
* Interactive “Expand Abbreviation” — Ctrl+Alt+Enter
* Match Tag Pair Outward – ⌃D (Mac) / Ctrl+, (PC)
* Match Tag Pair Inward – ⌃J / Shift+Ctrl+0
* Go to Matching Pair – ⇧⌃T / Ctrl+Alt+J
* Wrap With Abbreviation — ⌃W / Shift+Ctrl+G
* Go to Edit Point — Ctrl+Alt+→ or Ctrl+Alt+←
* Select Item – ⇧⌘. or ⇧⌘, / Shift+Ctrl+. or Shift+Ctrl+,
* Toggle Comment — ⇧⌥/ / Shift+Ctrl+/
* Split/Join Tag — ⇧⌘' / Shift+Ctrl+`
* Remove Tag – ⌘' / Shift+Ctrl+;
* Update Image Size — ⇧⌃I / Ctrl+U
* Evaluate Math Expression — ⇧⌘Y / Shift+Ctrl+Y
* Reflect CSS Value – ⇧⌘R / Shift+Ctrl+R
* Encode/Decode Image to data:URL – ⇧⌃D / Ctrl+'
* Rename Tag – ⇧⌘K / Shift+Ctrl+'

Increment/Decrement Number actions:

* Increment by 1: Ctrl+↑
* Decrement by 1: Ctrl+↓
* Increment by 0.1: Alt+↑
* Decrement by 0.1: Alt+↓
* Increment by 10: ⌥⌘↑ / Shift+Alt+↑
* Decrement by 10: ⌥⌘↓ / Shift+Alt+↓

### 六. Table Editor

文本文件里表格插件

* [Home page](https://packagecontrol.io/packages/Table%20Editor)
* 功能: 在文本文件里编辑表格

```
|    Name   |   Phone   | Age |             Position             |
|-----------|-----------|-----|----------------------------------|
| Anna      | 123456789 |  32 | Senior Software Engineer_        |
| Alexander | 987654321 |  28 | Senior Software Testing Engineer |
|           |           |     |                                  |
```


##### 基本用法 

* click ctrl+shift+p
* select Table Editor: Enable for current syntax or Table Editor: Enable for current view or "Table Editor: Set table syntax ... for current view"

* 先输入

```
| Name | Phone |
|-
```

然后按tab


* 先输入

```
| Name | Phone |
|=
```

然后按tab

* 添加或删除列,alt+shift+right,比如下面的

```
|    Name   |   Phone   |
|-----------|-----------|
| Anna      | 123456789 |
| Alexander | 987654321 |
|           | _         |
```

在phone 那一列的任意位置按alt+shift+right, 就可以得到

```
|    Name   |     |   Phone   |
| --------- | --- | --------- |
| Anna      |     | 123456789 |
| Alexander |     | 987654321 |
|           | _   |           |
```

* 移动列, alt + right ,如果想把上面的phone移动到中间,就在phone那一列按 alt+left即可


```
|    Name   |   Phone   |     |
| --------- | --------- | --- |
| Anna      | 123456789 |     |
| Alexander | 987654321 |     |
|           |           | _   |
```

* 添加删除行, 其实更像移动 alt+shift+down. 在上面的Alexander那一行按alt+shift+down

```
|    Name   |   Phone   |     |
| --------- | --------- | --- |
| Anna      | 123456789 |     |
|           |           |     |
| Alexander | 987654321 |     |
|           |           | _   |
```


* 几种格式支持

Simple

```
|    Name   | Age |
|-----------|-----|
| Anna      |  20 |
| Alexander |  27 |
```

EmacsOrgMode

```
|    Name   | Age |
|-----------+-----|
| Anna      |  20 |
| Alexander |  27 |
```

Pandoc Grid Tables

```
+-----------+-----+
|    Name   | Age |
+===========+=====+
| Anna      |  20 |
+-----------+-----+
| Alexander |  27 |
+-----------+-----+
```

Pandoc Pipe tables

Pandoc Pipe tables is the same as Multi Markdown, you have to switch into Multi Markdown if you use this table style.

Multi Markdown/Pandoc Pipe tables

Alignment:

```
|    Name   | Phone | Age Column |
| :-------- | :---: | ---------: |
| Anna      |   12  |         20 |
| Alexander |   13  |         27 |

```

```

| Right | Left | Default | Center |
| ----: | :--- | ------- | :----: |
|    12 | 12   |      12 |   12   |
|   123 | 123  |     123 |  123   |
|     1 | 1    |       1 |   1    |
```

Colspan(alpha status):

```
|              |           Grouping          ||
| First Header | Second Header | Third Header |
| ------------ | :-----------: | -----------: |
| Content      |         *Long Cell*         ||
| Content      |    **Cell**   |         Cell |
| New section  |      More     |         Data |
| And more     |    And more   |              |
| :---------------------------------------: |||

```
RestructuredText

```
|    Name   | Age |
+-----------+-----+
| Anna      |  20 |
| Alexander |  27 |
```

Textile

Alignment:

```
|_.   Name  |_. Age |_. Custom Alignment Demo |
| Anna      |    20 |<. left                  |
| Alexander |    27 |>.                 right |
| Misha     |    42 |=.         center        |
|           |       |                         |
```

Colspan(alpha status):

```
|\2. spans two cols   |
| col 1    | col 2    |
```

Rowspan(alpha status):

```
|/3. spans 3 rows | a |
| b               |
| c               |
```

Compound Textile table cell specifiers:

```
|_\2.  spans two cols |
|_<. col 1 |_>. col 2 |
```



# 我的插件列表

* AdvancedNewFile
* InsertDate
* KeyMaps
* Markdow Preview
* Pretty JSON
* SideBarEnhancements
